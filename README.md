# BinDays-Client

[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

<p align="center">
  <a href="https://github.com/BadgerHobbs/BinDays-App">BinDays-App</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-Client">BinDays-Client</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-API">BinDays-API</a>
</p>

> **Council-related issue?** For problems with a specific council's bin collection data or to request a new council, please open an issue in the [**BinDays-API repository**](https://github.com/BadgerHobbs/BinDays-API/issues).

## Overview

This is the repository for the BinDays-Client, a Dart library that facilitates communication between a client application (like the [BinDays-App](https://github.com/BadgerHobbs/BinDays-App)) and the [BinDays-API](https://github.com/BadgerHobbs/BinDays-API).

Its primary purpose is to handle the request-response cycle for fetching bin collection data.

## Usage

Here is a basic example of how to use the client:

```dart
import 'package:bindays_client/bindays_client.dart';

void main() async {
  // Configure the client
  final client = BinDaysClient(
    apiHost: 'https://bindays-api.example.com',
  );

  // Get the collector for a postcode
  final collector = await client.getCollector('SW1A 0AA');

  // Get addresses for the postcode
  final addresses = await client.getAddresses(collector, 'SW1A 0AA');

  // Get bin days for the selected address
  final binDays = await client.getBinDays(collector, addresses.first);

  // Print the bin days
  for (final binDay in binDays) {
    print('${binDay.name}: ${binDay.date}');
  }
}
```

## License

This project is licensed under the [GPLv3 License](LICENSE).
