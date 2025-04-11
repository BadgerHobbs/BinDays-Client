// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BinDay _$BinDayFromJson(Map<String, dynamic> json) => BinDay(
  date: _dateFromJson(json['Date'] as String),
  address: Address.fromJson(json['Address'] as Map<String, dynamic>),
  bins:
      (json['Bins'] as List<dynamic>)
          .map((e) => Bin.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BinDayToJson(BinDay instance) => <String, dynamic>{
  'Date': _dateToJson(instance.date),
  'Address': instance.address,
  'Bins': instance.bins,
};
