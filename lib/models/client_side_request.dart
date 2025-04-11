// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'client_side_request.g.dart';

/// Model which represents a HTTP request executed client-side.
@immutable
@JsonSerializable()
class ClientSideRequest {
  /// Gets the request id.
  @JsonKey(name: 'RequestId')
  final int requestId;

  /// Gets the URL of the request.
  @JsonKey(name: 'Url')
  final String url;

  /// Gets the HTTP method of the request.
  @JsonKey(name: 'Method')
  final String method;

  /// Gets the headers of the request.
  @JsonKey(name: 'Headers')
  final Map<String, String> headers;

  /// Gets the body of the request.
  @JsonKey(name: 'Body')
  final String body;

  /// Creates an instance of [ClientSideRequest].
  const ClientSideRequest({
    required this.requestId,
    required this.url,
    required this.method,
    required this.headers,
    required this.body,
  });

  /// Creates a [ClientSideRequest] from its JSON representation.
  factory ClientSideRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientSideRequestFromJson(json);

  /// Converts this [ClientSideRequest] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$ClientSideRequestToJson(this);
}
