# BinDays-Client

[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

![d2](https://github.com/user-attachments/assets/c9dccc4d-eec1-4de5-b0e7-3e6767d66409)

<p align="center">
  <a href="https://github.com/BadgerHobbs/BinDays-App">BinDays-App</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-Client">BinDays-Client</a> •
  <a href="https://github.com/BadgerHobbs/BinDays-API">BinDays-API</a>
</p>

## Welcome!

Got an issue with a council or want one added? Head to the [BinDays-API](https://github.com/BadgerHobbs/BinDays-API) repository. Otherwise, please read onwards.

## Overview

You are currently viewing the repository for the BinDays-Client, with is the client library the [BinDays-App](https://github.com/BadgerHobbs/BinDays-App) uses interact with the [BinDays-API](https://github.com/BadgerHobbs/BinDays-API).

## Design

The design of the BinDays-Client library is relativly simple. Essentially the client makes a request to the BinDays-API attempting to fetch some data (e.g. collectors, addresses, bin days), and the API returns a request which the client must process. The response is then sent back to the API for processing, either returning the final result or another request to make (and the cycle continues).

## Usage

Below is some basic usage for the client library, you can also find anothe rexample in the `client_test.dart` file in the repository.

```dart
// Import the library, and the Dio http client
import 'package:bindays_client/client.dart';
import 'package:dio/dio.dart';

// Configure the client with the API url.
final baseUrl = Uri.parse("https://api.bindays.app");
final httpClient = Dio();
client = Client(baseUrl, httpClient);

// Get the currently supported collectors
var collectors = await client.getCollectors();

// Get a specific collector for a given postcode.
var collector = await client.getCollector("BN14 9NS");

// Get the addresses for the postcode and collector.
var addresses = await client.getAddresses(collector, "BN14 9NS");

// Get the bin collections for the address.
var binDays = await client.getBinDays(collector, addresses.first);
```

## License

The code and documentation in this project are released under the [GPLv3 License](LICENSE).
