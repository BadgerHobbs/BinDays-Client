// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

// Internal Imports
import 'collector.dart';
import 'client_side_request.dart';

part 'get_collector_response.g.dart';

/// Represents the response from an address lookup request.
@immutable
@JsonSerializable()
class GetCollectorResponse {
  /// Gets the next client-side request to be made.
  @JsonKey(name: 'NextClientSideRequest')
  final ClientSideRequest? nextClientSideRequest;

  /// Gets the list of collector found.
  @JsonKey(name: 'Collector')
  final Collector? collector;

  /// Creates an instance of [GetCollectorResponse].
  const GetCollectorResponse({this.nextClientSideRequest, this.collector});

  /// Creates a [GetCollectorResponse] from its JSON representation.
  factory GetCollectorResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCollectorResponseFromJson(json);

  /// Converts this [GetCollectorResponse] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$GetCollectorResponseToJson(this);
}
