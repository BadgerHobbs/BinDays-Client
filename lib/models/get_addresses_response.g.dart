// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_addresses_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAddressesResponse _$GetAddressesResponseFromJson(
  Map<String, dynamic> json,
) => GetAddressesResponse(
  nextClientSideRequest:
      json['NextClientSideRequest'] == null
          ? null
          : ClientSideRequest.fromJson(
            json['NextClientSideRequest'] as Map<String, dynamic>,
          ),
  addresses:
      (json['Addresses'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$GetAddressesResponseToJson(
  GetAddressesResponse instance,
) => <String, dynamic>{
  'NextClientSideRequest': instance.nextClientSideRequest,
  'Addresses': instance.addresses,
};
