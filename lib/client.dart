// External Imports
import 'package:dio/dio.dart' as dio;
import 'package:package/extensions/dio_response_extension.dart';

// Internal Imports
import 'package:package/extensions/uri_extension.dart';
import 'package:package/models/address.dart';
import 'package:package/models/bin_day.dart';
import 'package:package/models/client_side_request.dart';
import 'package:package/models/client_side_response.dart';
import 'package:package/models/collector.dart';
import 'package:package/models/get_addresses_response.dart';
import 'package:package/models/get_bin_days_response.dart';
import 'package:package/models/get_collector_response.dart';

/// A client for interacting with the BinDays API.
///
/// This class provides methods for retrieving collectors, addresses, and bin days
/// from the BinDays API. It handles multi-step requests indicated by the API.
class Client {
  /// The base URL of the BinDays API.
  final Uri baseUrl;

  /// The HTTP client used for making requests.
  final dio.Dio httpClient;

  /// Creates a new BinDays API client.
  ///
  /// Requires the API [baseUrl] (e.g. "http://localhost:5042/api") and an
  /// [httpClient] instance. The caller is responsible for managing the
  /// lifecycle of the [httpClient] (including closing it).
  Client(this.baseUrl, this.httpClient);

  /// Retrieves a list of all [Collector]s.
  ///
  /// Returns a list of [Collector] objects.
  /// Throws an [Exception] if the request fails or no collectors are found.
  Future<List<Collector>> getCollectors() async {
    final url = baseUrl.add('/collectors');

    // Get collectors from API endpoint
    final response = await httpClient.getUri(url);

    // Validate response status, throws if not successful
    response.isSuccessStatusCode();

    // Parse and return response
    final responseJson = response.data;

    List<Collector> collectors = [];
    for (dynamic collectorJson in responseJson) {
      collectors.add(Collector.fromJson(collectorJson));
    }

    return collectors;
  }

  /// Retrieves a [Collector] for a given postcode.
  ///
  /// [postcode] The postcode to search for.
  ///
  /// Returns a [Collector] object.
  /// Throws an [Exception] if the request fails or no collector is found.
  Future<Collector> getCollector(String postcode) async {
    final url = baseUrl
        .add('/collector')
        .replace(queryParameters: {"postcode": postcode});

    return await _fetchData<Collector, GetCollectorResponse>(
      url: url,
      responseParser: (json) => GetCollectorResponse.fromJson(json),
      dataExtractor: (response) => response.collector,
      nextRequestExtractor: (response) => response.nextClientSideRequest,
      errorMessage: "No collector found for postcode '$postcode'.",
    );
  }

  /// Retrieves a list of [Address] for a given postcode.
  ///
  /// [postcode] The postcode to search for.
  /// [collector] The collector for the postcode.
  ///
  /// Returns a list of [Address] objects.
  /// Throws an [Exception] if the request fails or no addresses are found.
  Future<List<Address>> getAddresses(
    Collector collector,
    String postcode,
  ) async {
    final url = baseUrl
        .add('${collector.govUkId}/addresses')
        .replace(queryParameters: {"postcode": postcode});

    return await _fetchData<List<Address>, GetAddressesResponse>(
      url: url,
      responseParser: (json) => GetAddressesResponse.fromJson(json),
      dataExtractor: (response) => response.addresses,
      nextRequestExtractor: (response) => response.nextClientSideRequest,
      errorMessage: "No addresses found for postcode '$postcode'.",
    );
  }

  /// Retrieves a list of [BinDay] for a given [Collector] and [Address].
  ///
  /// [collector] The collector for the address.
  /// [address] The address to search for.
  ///
  /// Returns a list of [BinDay] objects.
  /// Throws an [Exception] if the request fails or no bin days are found.
  Future<List<BinDay>> getBinDays(Collector collector, Address address) async {
    // Construct the path using the collector's ID
    final url = baseUrl.add("/${collector.govUkId}/binDays");

    // For verbose error message
    final addressString = _formatAddress(address);

    return await _fetchData<List<BinDay>, GetBinDaysResponse>(
      url: url,
      responseParser: (json) => GetBinDaysResponse.fromJson(json),
      dataExtractor: (response) => response.binDays,
      nextRequestExtractor: (response) => response.nextClientSideRequest,
      errorMessage:
          "No bin days found for collector '${collector.name}' and address '$addressString'.",
    );
  }

  /// Generic function to fetch data from the API, handling multi-step requests.
  ///
  /// [url] The initial URL to fetch data from.
  /// [responseParser] Parses the JSON response into a response object [R].
  /// [dataExtractor] Extracts the desired data [T] from the response object [R].
  /// [nextRequestExtractor] Extracts the optional [ClientSideRequest] for the next step.
  /// [errorMessage] Base error message if no data or next step is provided by the API.
  ///
  /// Returns the extracted data of type [T].
  Future<T> _fetchData<T, R>({
    required Uri url,
    required R Function(dynamic json) responseParser,
    required T? Function(R response) dataExtractor,
    required ClientSideRequest? Function(R response) nextRequestExtractor,
    required String errorMessage,
  }) async {
    // Result from the previous client-side request, if any.
    ClientSideResponse? clientSideResponse;

    while (true) {
      // Prepare body for the main API request. It includes the result
      // of the previous client-side request, if one was performed.
      dynamic requestBody;
      if (clientSideResponse != null) {
        requestBody = clientSideResponse.toJson();
      }

      // Make the main POST request to our API endpoint
      final response = await httpClient.postUri(
        url,
        data: requestBody,
        options: dio.Options(contentType: 'application/json'),
      );

      // Validate response status, throws if not successful
      response.isSuccessStatusCode();

      // Parse the main response
      final parsedResponse = responseParser(response.data);

      // Try to extract the final data
      final data = dataExtractor(parsedResponse);
      if (data != null) {
        // Data successfully retrieved, return it.
        return data;
      }

      // If no data, check if there's a next step (client-side request)
      final nextRequest = nextRequestExtractor(parsedResponse);
      if (nextRequest != null) {
        // Perform the client-side request required by the API
        clientSideResponse = await _sendClientSideRequest(nextRequest);
        // Continue the loop to send the clientSideResponse back to the main API
      } else {
        // No data and no next step instruction, throw an error.
        throw Exception(errorMessage);
      }
    }
  }

  /// Sends a client-side request as instructed by the main API.
  ///
  /// [request] The client-side request details provided by the main API.
  ///
  /// Returns a [ClientSideResponse] parsed from the response.
  Future<ClientSideResponse> _sendClientSideRequest(
    ClientSideRequest request,
  ) async {
    // Send request
    var response = await httpClient.request(
      request.url,
      data: request.body,
      options: dio.Options(
        method: request.method,
        headers: request.headers,
        followRedirects: true,
        validateStatus: (status) => true,
      ),
    );

    // Validate response status, throws if not successful
    response.isSuccessStatusCode();

    // Create response object
    var clientSideResponse = ClientSideResponse(
      requestId: request.requestId,
      statusCode: response.statusCode ?? 0,
      headers: response.headers.map.map((key, value) {
        // Flatten the list of strings to a single string, comma-separated
        final headerValue = value.join(',');
        return MapEntry(key, headerValue);
      }),
      content: response.data.toString(),
      reasonPhrase: response.statusMessage ?? "",
    );

    return clientSideResponse;
  }

  /// Formats an [Address] into a string representation.
  ///
  /// [address] The address to format.
  ///
  /// Returns a string representation of the address, with non-null and
  /// non-empty parts joined by commas.
  String _formatAddress(Address address) {
    final addressParts = [
      address.property,
      address.street,
      address.town,
      address.postcode,
      address.uid,
    ];

    final filteredAddressParts = addressParts.where(
      (part) => part != null && part.trim().isNotEmpty,
    );

    return filteredAddressParts.join(", ");
  }
}
