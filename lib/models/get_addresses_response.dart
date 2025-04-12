// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

// Internal Imports
import 'address.dart';
import 'client_side_request.dart';

part 'get_addresses_response.g.dart';

/// Represents the response from an address lookup request.
@immutable
@JsonSerializable()
class GetAddressesResponse {
  /// Gets the next client-side request to be made.
  final ClientSideRequest? nextClientSideRequest;

  /// Gets the list of addresses found.
  final List<Address>? addresses;

  /// Creates an instance of [GetAddressesResponse].
  const GetAddressesResponse({this.nextClientSideRequest, this.addresses});

  /// Creates a [GetAddressesResponse] from its JSON representation.
  factory GetAddressesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAddressesResponseFromJson(json);

  /// Converts this [GetAddressesResponse] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$GetAddressesResponseToJson(this);
}
