// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'client_side_options.g.dart';

/// Client side request/response options to preserve across request/response cycles.
@immutable
@JsonSerializable()
class ClientSideOptions {
  /// Follow HTTP redirects (300-399)
  final bool followRedirects;

  /// Metadata (e.g. tokens, cookies, etc.)
  final Map<String, String> metadata;

  /// Creates an instance of [ClientSideOptions].
  const ClientSideOptions({
    this.followRedirects = true,
    this.metadata = const {},
  });

  /// Creates a [ClientSideOptions] from its JSON representation.
  factory ClientSideOptions.fromJson(Map<String, dynamic> json) =>
      _$ClientSideOptionsFromJson(json);

  /// Converts this [ClientSideOptions] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$ClientSideOptionsToJson(this);
}