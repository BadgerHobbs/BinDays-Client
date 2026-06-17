// External Imports
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Internal Imports
import 'package:bindays_client/client.dart';

void main() {
  late Client client;
  final List<String> postcodes = ['KA6 6EX'];

  setUp(() {
    final baseUrl = Uri.parse("https://api.bindays.app");
    final httpClient = Dio();
    client = Client(baseUrl, httpClient: httpClient, impersonate: false);
  });

  test('getCollectors', () async {
    var collectors = await client.getCollectors();
    expect(collectors.length, greaterThan(0));
  });

  for (final postcode in postcodes) {
    test('getBinDays for postcode $postcode', () async {
      var collector = await client.getCollector(postcode);
      expect(collector.name, isNotNull);

      var addresses = await client.getAddresses(collector, postcode);
      expect(addresses, isNotEmpty);

      var binDays = await client.getBinDays(collector, addresses.first);
      expect(binDays, isNotEmpty);
    });
  }
}
