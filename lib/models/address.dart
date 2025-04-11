// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'address.g.dart';

/// Model which represents an address for a given collector.
@immutable
@JsonSerializable()
class Address {
  /// Gets address property.
  @JsonKey(name: 'Property')
  final String? property;

  /// Gets address street.
  @JsonKey(name: 'Street')
  final String? street;

  /// Gets address town.
  @JsonKey(name: 'Town')
  final String? town;

  /// Gets address postcode.
  @JsonKey(name: 'Postcode')
  final String? postcode;

  /// Gets address uid.
  @JsonKey(name: 'Uid')
  final String? uid;

  /// Creates an instance of [Address].
  const Address({
    this.property,
    this.street,
    this.town,
    this.postcode,
    this.uid,
  });

  /// Creates an [Address] from its JSON representation.
  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// Converts this [Address] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
