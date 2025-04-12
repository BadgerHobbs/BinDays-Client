// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'client_side_response.g.dart';

/// Model which represents a HTTP response from a request executed client-side.
@immutable
@JsonSerializable()
class ClientSideResponse {
  /// Gets the request id.
  final int requestId;

  /// Gets the HTTP status code of the response.
  final int statusCode;

  /// Gets the headers of the response.
  final Map<String, String> headers;

  /// Gets the content of the response as a string.
  final String content;

  /// Gets the reason phrase of the response.
  final String reasonPhrase;

  /// Creates an instance of [ClientSideResponse].
  const ClientSideResponse({
    required this.requestId,
    required this.statusCode,
    required this.headers,
    required this.content,
    required this.reasonPhrase,
  });

  /// Gets a value indicating whether the request was successful (status code 200-299).
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isSuccessStatusCode => statusCode >= 200 && statusCode <= 299;

  /// Creates a [ClientSideResponse] from its JSON representation.
  factory ClientSideResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientSideResponseFromJson(json);

  /// Converts this [ClientSideResponse] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$ClientSideResponseToJson(this);
}
