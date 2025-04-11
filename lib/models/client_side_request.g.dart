// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_side_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientSideRequest _$ClientSideRequestFromJson(Map<String, dynamic> json) =>
    ClientSideRequest(
      requestId: (json['RequestId'] as num).toInt(),
      url: json['Url'] as String,
      method: json['Method'] as String,
      headers: Map<String, String>.from(json['Headers'] as Map),
      body: json['Body'] as String,
    );

Map<String, dynamic> _$ClientSideRequestToJson(ClientSideRequest instance) =>
    <String, dynamic>{
      'RequestId': instance.requestId,
      'Url': instance.url,
      'Method': instance.method,
      'Headers': instance.headers,
      'Body': instance.body,
    };
