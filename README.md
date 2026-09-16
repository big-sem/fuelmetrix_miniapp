# fuelmetrix_miniapp

Embeds the fuelmetrix mini app (wallet, refuel, purchase history, QPay,
NATS, etc) inside a host Flutter app as a native `PlatformView` — no
WebView setup, bridge logic, or mini app source ever lives in the host.

## Usage

```dart
import 'package:fuelmetrix_miniapp/fuelmetrix_miniapp.dart';

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => FuelmetrixMiniApp(
      phone: currentUserPhone,       // your logged-in user's phone number
      clientId: yourVendorClientId,  // issued to you by fuelmetrix
      clientSecret: yourVendorClientSecret,
    ),
  ),
);
```

You only ever hand this widget your own user's identity and your own
vendor credentials. Auth against fuelmetrix's backend, and everything
about what gets rendered, is resolved entirely inside this package.

## Android setup

This package wraps a proprietary AAR (`mini_native_lib`) that isn't on
Maven Central. Its own private Maven repo ships bundled inside this
package (`android/maven-repo`) — add it to your app's
`android/build.gradle.kts`:

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("${rootDir}/../fuelmetrix_miniapp/android/maven-repo") }
    }
}
```

(Adjust the path to wherever `fuelmetrix_miniapp` resolves in your
`.pub-cache` once this package is actually published — this is
documented here because Gradle resolves a plugin's own dependencies
using the *consuming app's* repositories, not the plugin's.)

## iOS setup

Nothing extra needed — the vendor's `MiniNativeLib.xcframework` is
bundled in this package and picked up automatically via CocoaPods. Your
app's minimum iOS deployment target must be **14.0** or higher.
