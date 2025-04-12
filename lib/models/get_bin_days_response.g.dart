// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_bin_days_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBinDaysResponse _$GetBinDaysResponseFromJson(Map<String, dynamic> json) =>
    GetBinDaysResponse(
      nextClientSideRequest:
          json['nextClientSideRequest'] == null
              ? null
              : ClientSideRequest.fromJson(
                json['nextClientSideRequest'] as Map<String, dynamic>,
              ),
      binDays:
          (json['binDays'] as List<dynamic>?)
              ?.map((e) => BinDay.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$GetBinDaysResponseToJson(GetBinDaysResponse instance) =>
    <String, dynamic>{
      'nextClientSideRequest': instance.nextClientSideRequest,
      'binDays': instance.binDays,
    };
