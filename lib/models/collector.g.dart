// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collector _$CollectorFromJson(Map<String, dynamic> json) => Collector(
  name: json['Name'] as String?,
  websiteUrl: _uriFromJson(json['WebsiteUrl'] as String?),
  govUkId: json['GovUkId'] as String?,
  govUkUrl: _uriFromJson(json['GovUkUrl'] as String?),
);

Map<String, dynamic> _$CollectorToJson(Collector instance) => <String, dynamic>{
  'Name': instance.name,
  'WebsiteUrl': _uriToJson(instance.websiteUrl),
  'GovUkId': instance.govUkId,
  'GovUkUrl': _uriToJson(instance.govUkUrl),
};
