// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_collector_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCollectorResponse _$GetCollectorResponseFromJson(
  Map<String, dynamic> json,
) => GetCollectorResponse(
  nextClientSideRequest:
      json['NextClientSideRequest'] == null
          ? null
          : ClientSideRequest.fromJson(
            json['NextClientSideRequest'] as Map<String, dynamic>,
          ),
  collector:
      json['Collector'] == null
          ? null
          : Collector.fromJson(json['Collector'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetCollectorResponseToJson(
  GetCollectorResponse instance,
) => <String, dynamic>{
  'NextClientSideRequest': instance.nextClientSideRequest,
  'Collector': instance.collector,
};
