// External Imports
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Internal Imports
import 'package:bindays_client/client.dart';

void main() {
  late Client client;
  final String postcode = "BN14 9NS";

  setUp(() {
    final baseUrl = Uri.parse("https://api.bindays.app");
    final httpClient = Dio();
    client = Client(baseUrl, httpClient);
  });

  test('getCollectors', () async {
    var collectors = await client.getCollectors();
    expect(collectors.length, greaterThan(0));
  });

  test('getCollector', () async {
    var collector = await client.getCollector(postcode);
    expect(collector.name, isNotNull);
  });

  test('getAddresses', () async {
    var collector = await client.getCollector(postcode);
    expect(collector.name, isNotNull);

    var addresses = await client.getAddresses(collector, postcode);
    expect(addresses, isNotEmpty);
  });

  test('getBinDays', () async {
    var collector = await client.getCollector(postcode);
    expect(collector.name, isNotNull);

    var addresses = await client.getAddresses(collector, postcode);
    expect(addresses, isNotEmpty);

    var binDays = await client.getBinDays(collector, addresses.first);
    expect(binDays, isNotEmpty);
  });
}
