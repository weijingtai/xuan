// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ju_mapping_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JuMappingDataModel _$JuMappingDataModelFromJson(Map<String, dynamic> json) =>
    JuMappingDataModel(
      dayJiaZiName: json['dayJiaZi'] as String,
      timeDiZhiName: json['timeDiZhi'] as String,
      yinYangValue: json['yinYang'] as String,
      juNumber: (json['juNumber'] as num).toInt(),
    );

Map<String, dynamic> _$JuMappingDataModelToJson(JuMappingDataModel instance) =>
    <String, dynamic>{
      'dayJiaZi': instance.dayJiaZiName,
      'timeDiZhi': instance.timeDiZhiName,
      'yinYang': instance.yinYangValue,
      'juNumber': instance.juNumber,
    };
