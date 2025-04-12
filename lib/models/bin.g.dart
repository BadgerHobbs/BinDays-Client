// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bin _$BinFromJson(Map<String, dynamic> json) => Bin(
  name: json['name'] as String,
  colour: json['colour'] as String,
  type: json['type'] as String?,
  keys: (json['keys'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BinToJson(Bin instance) => <String, dynamic>{
  'name': instance.name,
  'colour': instance.colour,
  'type': instance.type,
  'keys': instance.keys,
};
