// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'bin.g.dart';

/// Model which represents a bin for a given collector.
@immutable
@JsonSerializable()
class Bin {
  /// Gets bin name.
  final String name;

  /// Gets bin colour.
  final String colour;

  /// Gets bin type.
  final String? type;

  /// Gets bin keys (identifiers).
  final List<String> keys;

  /// Creates an instance of [Bin].
  const Bin({
    required this.name,
    required this.colour,
    this.type,
    required this.keys,
  });

  /// Creates a [Bin] from its JSON representation.
  factory Bin.fromJson(Map<String, dynamic> json) => _$BinFromJson(json);

  /// Converts this [Bin] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$BinToJson(this);
}
