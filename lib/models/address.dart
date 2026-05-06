// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'address.g.dart';

/// Model which represents an address for a given collector.
@immutable
@JsonSerializable()
class Address {
  /// Gets address property.
  final String? property;

  /// Gets address street.
  final String? street;

  /// Gets address town.
  final String? town;

  /// Gets address postcode.
  final String? postcode;

  /// Gets address uid.
  final String? uid;

  /// Gets the collector UID format version that was current when this address was fetched.
  /// Sent with bin day requests so the API can detect stale UIDs after a format change.
  final int? collectorVersion;

  /// Creates an instance of [Address].
  const Address({
    this.property,
    this.street,
    this.town,
    this.postcode,
    this.uid,
    this.collectorVersion,
  });

  /// Creates an [Address] from its JSON representation.
  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// Converts this [Address] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
