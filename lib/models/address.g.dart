// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  property: json['property'] as String?,
  street: json['street'] as String?,
  town: json['town'] as String?,
  postcode: json['postcode'] as String?,
  uid: json['uid'] as String?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'property': instance.property,
  'street': instance.street,
  'town': instance.town,
  'postcode': instance.postcode,
  'uid': instance.uid,
};
