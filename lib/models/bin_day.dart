// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

// Internal Imports
import 'address.dart';
import 'bin.dart';

part 'bin_day.g.dart';

/// Helper function to handle DateOnly (YYYY-MM-DD) format if needed.
/// Converts a date string (YYYY-MM-DD) to a DateTime object.
DateTime _dateFromJson(String dateStr) =>
    DateTime.parse('${dateStr}T00:00:00Z');

/// Helper function to handle DateOnly (YYYY-MM-DD) format if needed.
/// Converts a DateTime object to a date string (YYYY-MM-DD).
String _dateToJson(DateTime date) => date.toIso8601String().substring(0, 10);

/// Model which represents a bin day for a given collector.
@immutable
@JsonSerializable()
class BinDay {
  /// Gets bin day date.
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime date;

  /// Gets bin day address.
  final Address address;

  /// Gets bin day bins.
  final List<Bin> bins;

  /// Creates an instance of [BinDay].
  const BinDay({required this.date, required this.address, required this.bins});

  /// Creates a [BinDay] from its JSON representation.
  factory BinDay.fromJson(Map<String, dynamic> json) => _$BinDayFromJson(json);

  /// Converts this [BinDay] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$BinDayToJson(this);
}
