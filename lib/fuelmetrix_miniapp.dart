/// Embeds the fuelmetrix mini app (wallet, refuel, purchase history, QPay,
/// etc) inside a host Flutter app as a native PlatformView — no WebView
/// setup, bridge logic, or mini app source ever lives in the host.
library;

export 'src/fuelmetrix_mini_app.dart' show FuelmetrixMiniApp;
