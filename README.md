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
      merchantCustomerId: yourCustomerId, // optional — your own id for this user in your loyalty program
    ),
  ),
);
```

`merchantCustomerId` is optional. If you have your own identifier for this
user in your loyalty program, pass it — the mini app uses it to redeem
loyalty points against the right merchant-side customer record. Omit it if
you don't have one.
