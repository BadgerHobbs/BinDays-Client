// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_side_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientSideResponse _$ClientSideResponseFromJson(Map<String, dynamic> json) =>
    ClientSideResponse(
      requestId: (json['RequestId'] as num).toInt(),
      statusCode: (json['StatusCode'] as num).toInt(),
      headers: Map<String, String>.from(json['Headers'] as Map),
      content: json['Content'] as String,
      reasonPhrase: json['ReasonPhrase'] as String,
    );

Map<String, dynamic> _$ClientSideResponseToJson(ClientSideResponse instance) =>
    <String, dynamic>{
      'RequestId': instance.requestId,
      'StatusCode': instance.statusCode,
      'Headers': instance.headers,
      'Content': instance.content,
      'ReasonPhrase': instance.reasonPhrase,
    };
