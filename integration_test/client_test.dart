// External Imports
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

// Internal Imports
import 'package:package/client.dart';

void main() {
  late Client client;

  setUp(() {
    final baseUrl = Uri.parse("http://localhost:5042");
    final httpClient = http.Client();
    client = Client(baseUrl, httpClient);
  });

  test('getCollectors', () async {
    var collectors = await client.getCollectors();
    expect(collectors.length, greaterThan(0));
  });
}
