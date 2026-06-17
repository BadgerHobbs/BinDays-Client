# BinDays-Client

[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

![d2(12)](https://github.com/user-attachments/assets/c5ee3027-69ee-4c8a-ae72-d3f9c70fbc67)

<p align="center">
  <a href="https://github.com/BadgerHobbs/BinDays-App">BinDays-App</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-Client">BinDays-Client</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-API">BinDays-API</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-HomeAssistant">BinDays-HomeAssistant</a>
</p>

> **Council-related issue?** For problems with a specific council's bin collection data or to request a new council, please open an issue in the [**BinDays-API repository**](https://github.com/BadgerHobbs/BinDays-API/issues).

## Overview

This is the repository for the BinDays-Client, a Dart library that facilitates communication between a client application (like the [BinDays-App](https://github.com/BadgerHobbs/BinDays-App)) and the [BinDays-API](https://github.com/BadgerHobbs/BinDays-API).

Its primary purpose is to handle the request-response cycle for fetching bin collection data.

## Usage

Here is a basic example of how to use the client:

```dart
import 'package:bindays_client/client.dart';

void main() async {
  // Configure the client with the API base URL.
  final client = Client(Uri.parse('https://api.bindays.app'));

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

## Browser impersonation transport

`Client` routes every request through a browser-impersonation transport by
default: a Dio `HttpClientAdapter` backed by
[`libcurl-impersonate`](https://github.com/lexiforest/curl-impersonate) via
`dart:ffi`, reproducing a real Chrome TLS ClientHello (JA3/JA4) and HTTP/2
fingerprint. This is required for councils behind a Cloudflare TLS-fingerprint
challenge (e.g. Sunderland) and, with certificate validation disabled, also
tolerates the incomplete certificate chains some councils serve (e.g. West
Devon). Pass `impersonate: false` to fall back to the standard `dart:io`
transport.

Because the transport lives here, the app and the BinDays-API integration tests
share one code path — there is no separate impersonation package.

### Native library

The native `libcurl-impersonate` binaries are published as a GitHub Release
(tag `native-v<version>`) by the [`publish-native-libs`](.github/workflows/publish-native-libs.yml)
workflow, pinned by [`native_libs.version`](native_libs.version). They are taken
from the official upstream release — desktop tarballs verbatim, Android paired
with the NDK's `libc++_shared.so`, and a dynamic iOS xcframework wrapped from the
official dylib slices.

- **App (Android/iOS):** the [BinDays-App](https://github.com/BadgerHobbs/BinDays-App)
  build downloads the matching binary from the Release and bundles it.
- **Desktop (`dart`/`dart test`):** provision it with
  `dart run bindays_client:install`, which downloads the library for the current
  platform into `.native/`.

To update the native library, bump `native_libs.version` and re-run the
`publish-native-libs` workflow.

## License

This project is licensed under the [GPLv3 License](LICENSE).

## Support

If you find this project helpful, please consider supporting its development.

[![Buy Me A Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=badgerhobbs&button_colour=FFDD00&font_colour=000000&font_family=Poppins&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/badgerhobbs)
