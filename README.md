# fuelmetrix_miniapp

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
