package com.vendor.fuelmetrix_miniapp

import android.content.Context
import android.view.View
import com.vendor.mininativelib.MiniAppView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

private const val VIEW_TYPE = "miniapp_view"

// Generic close-event channel — forwards a "close" call from the vendor's
// PlatformView to Dart (see FuelmetrixMiniApp in lib/), which pops the
// screen. This is plumbing only (a name and a pop), not business logic:
// the host app never sees what closeMiniapp() means to the mini app.
private const val EVENTS_CHANNEL = "miniapp/events"

/**
 * Registers the vendor's mini app PlatformView. A host app only needs to
 * add this package as a dependency and use the [FuelmetrixMiniApp] widget
 * — this plugin auto-registers via Flutter's plugin registrant, so no
 * MainActivity.kt edits are required on the host side. It has no idea
 * what's inside the view — no rendering setup, no bridge logic, no
 * business logic. All of that lives in mini_native_lib (compiled AAR).
 */
class FuelmetrixMiniappPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            MiniAppViewFactory(binding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}

private class MiniAppViewFactory(
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // The host only ever supplies the logged-in user's phone number
        // plus its own vendor clientId/clientSecret — everything else
        // (the load URL, auth) is resolved internally by the vendor's view.
        val params = args as? Map<*, *>
        val phone = params?.get("phone") as? String
            ?: error("miniapp_view: missing required \"phone\" creation param")
        val clientId = params["clientId"] as? String
            ?: error("miniapp_view: missing required \"clientId\" creation param")
        val clientSecret = params["clientSecret"] as? String
            ?: error("miniapp_view: missing required \"clientSecret\" creation param")
        // Optional — a host with no loyalty-program identifier for this user
        // just omits it (FuelmetrixMiniApp defaults it to '').
        val merchantCustomerId = params["merchantCustomerId"] as? String ?: ""
        return MiniAppViewPlatformView(context, phone, clientId, clientSecret, merchantCustomerId, messenger)
    }
}

private class MiniAppViewPlatformView(
    context: Context,
    phone: String,
    clientId: String,
    clientSecret: String,
    merchantCustomerId: String,
    messenger: BinaryMessenger,
) : PlatformView {
    private val channel = MethodChannel(messenger, EVENTS_CHANNEL)
    private val view = MiniAppView(
        context,
        phone = phone,
        clientId = clientId,
        clientSecret = clientSecret,
        merchantCustomerId = merchantCustomerId,
        onClose = { channel.invokeMethod("close", null) },
    )

    init {
        // Same channel, the other direction: Dart's PopScope (see
        // FuelmetrixMiniApp) forwards a system back press here. The plugin
        // doesn't decide anything — just forwards to the vendor's view,
        // which is the only thing that knows its own navigation state.
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "backPressed" -> {
                    view.handleBackPressed()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = view
    override fun dispose() {
        channel.setMethodCallHandler(null)
        view.dispose()
    }
}
