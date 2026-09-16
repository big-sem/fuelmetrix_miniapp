## 0.0.2

* Trim README to usage only.
* Drop repository/homepage links from package metadata.

## 0.0.1

Initial release.

* `FuelmetrixMiniApp` widget — embeds the fuelmetrix mini app (wallet,
  refuel, purchase history, QPay) as a native `PlatformView`, given a
  host user's `phone` and the host's vendor `clientId`/`clientSecret`.
* Bundles the compiled native SDK for Android (`mini_native_lib` AAR,
  via a bundled Maven repo) and iOS (`MiniNativeLib.xcframework`).
