// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_side_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientSideResponse _$ClientSideResponseFromJson(Map<String, dynamic> json) =>
    ClientSideResponse(
      requestId: (json['requestId'] as num).toInt(),
      statusCode: (json['statusCode'] as num).toInt(),
      headers: Map<String, String>.from(json['headers'] as Map),
      content: json['content'] as String,
      reasonPhrase: json['reasonPhrase'] as String,
      options:
          json['options'] == null
              ? const ClientSideOptions()
              : ClientSideOptions.fromJson(
                json['options'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ClientSideResponseToJson(ClientSideResponse instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'statusCode': instance.statusCode,
      'headers': instance.headers,
      'content': instance.content,
      'reasonPhrase': instance.reasonPhrase,
      'options': instance.options,
    };
