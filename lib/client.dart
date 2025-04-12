// External Imports
import 'dart:convert';
import 'package:http/http.dart' as http;

// Internal Imports
import 'package:package/extensions/http_response_extension.dart';
import 'package:package/models/address.dart';
import 'package:package/models/bin_day.dart';
import 'package:package/models/client_side_request.dart';
import 'package:package/models/client_side_response.dart';
import 'package:package/models/get_addresses_response.dart';

class Client {
  final String authority;
  late http.Client httpClient;

  Client(this.authority) {
    httpClient = http.Client();
  }

  Future<List<Address>> getAddresses(String postcode) async {
    // Prepare URL to get addresses
    var getAddressesUrl = Uri.https(authority, "/addresses", {
      "postcode": postcode,
    });

    // Store response for multi-step requests
    ClientSideRequest? clientSideRequest;

    // Send requests until addresses received
    while (true) {
      // Make client-side request if provided
      ClientSideResponse? clientSideResponse;
      if (clientSideRequest != null) {
        clientSideResponse = await _sendClientSideRequest(clientSideRequest);
      }

      // Prepare request to get address (may be multi-step)
      var requestJson = clientSideResponse?.toJson();
      var response = await httpClient.post(
        getAddressesUrl,
        headers: {"Content-Type": "application/json"},
        body: requestJson,
      );

      // Validate response success
      response.isSuccessStatusCode();

      // Parse response
      var responseJson = jsonDecode(response.body);
      var getAddressesResponse = GetAddressesResponse.fromJson(responseJson);

      // If addresses were returned, exit
      if (getAddressesResponse.addresses != null) {
        return getAddressesResponse.addresses!;
      }
      // Otherwise, make next request (if provided)
      else if (getAddressesResponse.nextClientSideRequest != null) {
        clientSideRequest = getAddressesResponse.nextClientSideRequest;
      }
      // If no addresses or next request, throw exception
      else {
        throw Exception(
          "No addresses or next request provided for postcode '$postcode'.",
        );
      }
    }
  }

  Future<List<BinDay>> getBinDays(Address address) async {
    return [];
  }

  /// Sends a client-side request to the server.
  ///
  /// [request] The client-side request to send.
  ///
  /// Returns a [ClientSideResponse] from the server.
  Future<ClientSideResponse> _sendClientSideRequest(
    ClientSideRequest request,
  ) async {
    var response = await httpClient.post(
      Uri.parse(request.url),
      headers: request.headers,
      body: request.body,
    );

    // Validate response success
    response.isSuccessStatusCode();

    // Parse response
    var responseJson = jsonDecode(response.body);
    var clientSideResponse = ClientSideResponse.fromJson(responseJson);

    return clientSideResponse;
  }
}
