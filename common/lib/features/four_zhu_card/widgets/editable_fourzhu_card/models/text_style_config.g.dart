// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextStyleConfig _$TextStyleConfigFromJson(Map<String, dynamic> json) =>
    TextStyleConfig(
      colorMapperDataModel: ColorMapperDataModel.fromJson(
          json['colorMapperDataModel'] as Map<String, dynamic>),
      textShadowDataModel: TextShadowDataModel.fromJson(
          json['textShadowDataModel'] as Map<String, dynamic>),
      fontStyleDataModel: FontStyleDataModel.fromJson(
          json['fontStyleDataModel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TextStyleConfigToJson(TextStyleConfig instance) =>
    <String, dynamic>{
      'colorMapperDataModel': instance.colorMapperDataModel,
      'textShadowDataModel': instance.textShadowDataModel,
      'fontStyleDataModel': instance.fontStyleDataModel,
    };
