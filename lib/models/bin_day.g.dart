// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BinDay _$BinDayFromJson(Map<String, dynamic> json) => BinDay(
  date: _dateFromJson(json['date'] as String),
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  bins:
      (json['bins'] as List<dynamic>)
          .map((e) => Bin.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BinDayToJson(BinDay instance) => <String, dynamic>{
  'date': _dateToJson(instance.date),
  'address': instance.address,
  'bins': instance.bins,
};
