// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_bin_days_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBinDaysResponse _$GetBinDaysResponseFromJson(Map<String, dynamic> json) =>
    GetBinDaysResponse(
      nextClientSideRequest:
          json['NextClientSideRequest'] == null
              ? null
              : ClientSideRequest.fromJson(
                json['NextClientSideRequest'] as Map<String, dynamic>,
              ),
      binDays:
          (json['BinDays'] as List<dynamic>?)
              ?.map((e) => BinDay.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$GetBinDaysResponseToJson(GetBinDaysResponse instance) =>
    <String, dynamic>{
      'NextClientSideRequest': instance.nextClientSideRequest,
      'BinDays': instance.binDays,
    };
