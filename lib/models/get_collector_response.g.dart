// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_collector_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCollectorResponse _$GetCollectorResponseFromJson(
  Map<String, dynamic> json,
) => GetCollectorResponse(
  nextClientSideRequest:
      json['nextClientSideRequest'] == null
          ? null
          : ClientSideRequest.fromJson(
            json['nextClientSideRequest'] as Map<String, dynamic>,
          ),
  collector:
      json['collector'] == null
          ? null
          : Collector.fromJson(json['collector'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetCollectorResponseToJson(
  GetCollectorResponse instance,
) => <String, dynamic>{
  'nextClientSideRequest': instance.nextClientSideRequest,
  'collector': instance.collector,
};
