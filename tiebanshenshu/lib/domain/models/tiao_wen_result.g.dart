// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiao_wen_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TiaoWenResult _$TiaoWenResultFromJson(Map<String, dynamic> json) =>
    TiaoWenResult(
      groupId: json['groupId'] as String,
      formulaName: json['formulaName'] as String,
      baseNumber: (json['baseNumber'] as num).toInt(),
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
      tiaoWenContent: json['tiaoWenContent'] as String,
      calculationDetail: json['calculationDetail'] as String,
    );

Map<String, dynamic> _$TiaoWenResultToJson(TiaoWenResult instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'formulaName': instance.formulaName,
      'baseNumber': instance.baseNumber,
      'tiaoWenNumber': instance.tiaoWenNumber,
      'tiaoWenContent': instance.tiaoWenContent,
      'calculationDetail': instance.calculationDetail,
    };
