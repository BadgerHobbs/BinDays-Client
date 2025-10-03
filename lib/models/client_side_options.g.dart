// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_side_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientSideOptions _$ClientSideOptionsFromJson(Map<String, dynamic> json) =>
    ClientSideOptions(
      followRedirects: json['followRedirects'] as bool? ?? true,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ClientSideOptionsToJson(ClientSideOptions instance) =>
    <String, dynamic>{
      'followRedirects': instance.followRedirects,
      'metadata': instance.metadata,
    };
