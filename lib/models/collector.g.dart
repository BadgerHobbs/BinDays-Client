// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collector _$CollectorFromJson(Map<String, dynamic> json) => Collector(
  name: json['name'] as String,
  websiteUrl: _uriFromJson(json['websiteUrl'] as String),
  govUkId: json['govUkId'] as String,
  govUkUrl: _uriFromJson(json['govUkUrl'] as String),
);

Map<String, dynamic> _$CollectorToJson(Collector instance) => <String, dynamic>{
  'name': instance.name,
  'websiteUrl': _uriToJson(instance.websiteUrl),
  'govUkId': instance.govUkId,
  'govUkUrl': _uriToJson(instance.govUkUrl),
};
