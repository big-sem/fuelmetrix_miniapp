import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _viewType = 'miniapp_view';

// Bidirectional: native -> Dart "close" pops the screen; Dart -> native
// "backPressed" forwards a system back press (see _handleBackGesture).
const _eventsChannel = MethodChannel('miniapp/events');

/// Embeds the vendor's native mini app as a Flutter widget.
///
/// The host only ever hands in the logged-in user's [phone] number and its
/// own vendor [clientId]/[clientSecret] — auth against the vendor's
/// backend, and everything about what gets rendered, is entirely native.
/// The host app never sees the mini app's source, a load URL, or the
/// vendor's own internal implementation.
class FuelmetrixMiniApp extends StatefulWidget {
  const FuelmetrixMiniApp({
    super.key,
    required this.phone,
    required this.clientId,
    required this.clientSecret,
    this.merchantCustomerId,
  });

  /// The logged-in host user's phone number.
  final String phone;

  /// The host's own vendor credentials, issued to it by fuelmetrix — never
  /// the mini app's own internal secrets.
  final String clientId;
  final String clientSecret;

  /// The host's own identifier for this user within its loyalty program, if
  /// it has one. Optional — omit it if the host has nothing to pass. Used
  /// by the mini app to redeem loyalty points against the right
  /// merchant-side customer record.
  final String? merchantCustomerId;

  @override
  State<FuelmetrixMiniApp> createState() => _FuelmetrixMiniAppState();
}

class _FuelmetrixMiniAppState extends State<FuelmetrixMiniApp> {
  @override
  void initState() {
    super.initState();
    _eventsChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void dispose() {
    _eventsChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'close' && mounted) {
      Navigator.of(context).pop();
    }
  }

  // Native decides whether to navigate the mini app's own history back or
  // close it — Dart has no visibility into that state.
  Future<void> _handleBackGesture() async {
    await _eventsChannel.invokeMethod('backPressed');
  }

  @override
  Widget build(BuildContext context) {
    final creationParams = {
      'phone': widget.phone,
      'clientId': widget.clientId,
      'clientSecret': widget.clientSecret,
      'merchantCustomerId': widget.merchantCustomerId ?? '',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackGesture();
      },
      child: Platform.isIOS
          ? UiKitView(
              viewType: _viewType,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            )
          : AndroidView(
              viewType: _viewType,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            ),
    );
  }
}
