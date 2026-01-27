// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yu_ding_da_liu_ren_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YuDingDaLiuRenDataModel _$YuDingDaLiuRenDataModelFromJson(
        Map<String, dynamic> json) =>
    YuDingDaLiuRenDataModel(
      details: Map<String, String>.from(json['details'] as Map),
      books: Map<String, String>.from(json['books'] as Map),
      dayJiaZi:
          YuDingDaLiuRenDataModel._jiaZiFromJson(json['dayJiaZi'] as String),
      juNumber: (json['juNumber'] as num).toInt(),
      juName: YuDingDaLiuRenDataModel._diZhiFromJson(json['juName'] as String),
      body: (json['body'] as List<dynamic>).map((e) => e as String).toSet(),
      meaning: json['meaning'] as String,
      explain: json['explain'] as String,
      predication: json['predication'] as String,
    );

Map<String, dynamic> _$YuDingDaLiuRenDataModelToJson(
        YuDingDaLiuRenDataModel instance) =>
    <String, dynamic>{
      'details': instance.details,
      'books': instance.books,
      'dayJiaZi': YuDingDaLiuRenDataModel._jiaZiToJson(instance.dayJiaZi),
      'juNumber': instance.juNumber,
      'juName': YuDingDaLiuRenDataModel._diZhiToJson(instance.juName),
      'body': instance.body.toList(),
      'meaning': instance.meaning,
      'explain': instance.explain,
      'predication': instance.predication,
    };
