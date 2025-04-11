// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  property: json['Property'] as String?,
  street: json['Street'] as String?,
  town: json['Town'] as String?,
  postcode: json['Postcode'] as String?,
  uid: json['Uid'] as String?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'Property': instance.property,
  'Street': instance.street,
  'Town': instance.town,
  'Postcode': instance.postcode,
  'Uid': instance.uid,
};
