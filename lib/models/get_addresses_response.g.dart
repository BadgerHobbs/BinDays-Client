// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_addresses_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAddressesResponse _$GetAddressesResponseFromJson(
  Map<String, dynamic> json,
) => GetAddressesResponse(
  nextClientSideRequest:
      json['nextClientSideRequest'] == null
          ? null
          : ClientSideRequest.fromJson(
            json['nextClientSideRequest'] as Map<String, dynamic>,
          ),
  addresses:
      (json['addresses'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$GetAddressesResponseToJson(
  GetAddressesResponse instance,
) => <String, dynamic>{
  'nextClientSideRequest': instance.nextClientSideRequest,
  'addresses': instance.addresses,
};
