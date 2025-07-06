// External Imports
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Internal Imports
import 'package:bindays_client/client.dart';

void main() {
  late Client client;
  final List<String> postcodes = [
    'BA2 2DL',
    'B34 6BS',
    'BS6 7SR',
    'HP22 5XA',
    'BD11 1JZ',
    'L15 2HF',
    'M15 6PN',
    'NE46 3JR',
    'OX4 3AT',
    'PL3 6AG',
    'CF72 9WR',
    'SY3 7TB',
    'B27 7AJ',
    'BS16 7ES',
    'PL8 2NG',
    'SO15 5NR',
    'TQ12 4EL',
    'EX20 1ZF',
    'WN7 2LG',
    'BA13 3JR',
    'BN14 9NS',
  ];

  setUp(() {
    final baseUrl = Uri.parse("https://api.bindays.app");
    final httpClient = Dio();
    client = Client(baseUrl, httpClient);
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
