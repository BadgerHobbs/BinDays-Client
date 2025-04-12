// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_side_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientSideRequest _$ClientSideRequestFromJson(Map<String, dynamic> json) =>
    ClientSideRequest(
      requestId: (json['requestId'] as num).toInt(),
      url: json['url'] as String,
      method: json['method'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      body: json['body'] as String,
    );

Map<String, dynamic> _$ClientSideRequestToJson(ClientSideRequest instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'url': instance.url,
      'method': instance.method,
      'headers': instance.headers,
      'body': instance.body,
    };
