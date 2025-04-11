// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bin _$BinFromJson(Map<String, dynamic> json) => Bin(
  name: json['Name'] as String,
  colour: json['Colour'] as String,
  type: json['Type'] as String?,
  keys: (json['Keys'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BinToJson(Bin instance) => <String, dynamic>{
  'Name': instance.name,
  'Colour': instance.colour,
  'Type': instance.type,
  'Keys': instance.keys,
};
