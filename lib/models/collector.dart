// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'collector.g.dart';

/// Helper function for JSON serialization.
/// Converts a URL string to a [Uri] object, returning null if the string is null or invalid.
Uri? _uriFromJson(String? urlString) =>
    urlString == null ? null : Uri.tryParse(urlString);

/// Helper function for JSON serialization.
/// Converts a [Uri] object to its string representation, returning null if the Uri is null.
String? _uriToJson(Uri? uri) => uri?.toString();

/// Model which represents a waste collection provider (collector).
@immutable
@JsonSerializable()
class Collector {
  /// Gets the name of the collector.
  @JsonKey(name: 'Name')
  final String? name;

  /// Gets the website url of the collector.
  @JsonKey(name: 'WebsiteUrl', fromJson: _uriFromJson, toJson: _uriToJson)
  final Uri? websiteUrl;

  /// Gets the gov.uk id of the collector.
  @JsonKey(name: 'GovUkId')
  final String? govUkId;

  /// Gets the gov.uk url of the collector.
  @JsonKey(name: 'GovUkUrl', fromJson: _uriFromJson, toJson: _uriToJson)
  final Uri? govUkUrl;

  /// Creates an instance of [Collector].
  const Collector({this.name, this.websiteUrl, this.govUkId, this.govUkUrl});

  /// Creates a [Collector] from its JSON representation.
  factory Collector.fromJson(Map<String, dynamic> json) =>
      _$CollectorFromJson(json);

  /// Converts this [Collector] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$CollectorToJson(this);
}
