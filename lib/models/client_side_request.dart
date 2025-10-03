// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

// Internal Imports
import 'client_side_options.dart';

part 'client_side_request.g.dart';

/// Model which represents a HTTP request executed client-side.
@immutable
@JsonSerializable()
class ClientSideRequest {
  /// Gets the request id.
  final int requestId;

  /// Gets the URL of the request.
  final String url;

  /// Gets the HTTP method of the request.
  final String method;

  /// Gets the headers of the request.
  final Map<String, String> headers;

  /// Gets the body of the request.
  final String? body;

  /// Gets the options of the request.
  final ClientSideOptions options;

  /// Creates an instance of [ClientSideRequest].
  const ClientSideRequest({
    required this.requestId,
    required this.url,
    required this.method,
    required this.headers,
    required this.body,
    this.options = const ClientSideOptions(),
  });

  /// Creates a [ClientSideRequest] from its JSON representation.
  factory ClientSideRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientSideRequestFromJson(json);

  /// Converts this [ClientSideRequest] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$ClientSideRequestToJson(this);
}
