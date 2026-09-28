## 0.0.6

* Fix: `MiniNativeLib.xcframework` only ever shipped a simulator slice,
  so `import MiniNativeLib` failed on any real-device iOS build. Now
  bundles both an `ios-arm64` (device) and `ios-arm64_x86_64-simulator`
  slice.

## 0.0.5

* `FuelmetrixMiniApp` gains an optional `merchantCustomerId` param — the
  host's own identifier for this user in its loyalty program, used to
  redeem loyalty points against the right merchant-side customer record.

## 0.0.4

* Unavailable state now shows a Mongolian message and a "back to host
  app" button instead of the WebView load screen staying stuck.

## 0.0.3

* `FuelmetrixMiniApp` widget — embeds the fuelmetrix mini app as a native
  `PlatformView`, given a host user's `phone` and the host's vendor
  `clientId`/`clientSecret`.
