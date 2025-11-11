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

ColorMapperDataModel _$ColorMapperDataModelFromJson(
        Map<String, dynamic> json) =>
    ColorMapperDataModel(
      pureLightMapper: ColorAhexConverter.mapFromJson(
          json['pureLightMapper'] as Map<String, dynamic>),
      colorfulLightMapper: ColorAhexConverter.mapFromJson(
          json['colorfulLightMapper'] as Map<String, dynamic>),
      pureDarkMapper: ColorAhexConverter.mapFromJson(
          json['pureDarkMapper'] as Map<String, dynamic>),
      colorfulDarkMapper: ColorAhexConverter.mapFromJson(
          json['colorfulDarkMapper'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ColorMapperDataModelToJson(
        ColorMapperDataModel instance) =>
    <String, dynamic>{
      'pureLightMapper': ColorAhexConverter.mapToJson(instance.pureLightMapper),
      'colorfulLightMapper':
          ColorAhexConverter.mapToJson(instance.colorfulLightMapper),
      'pureDarkMapper': ColorAhexConverter.mapToJson(instance.pureDarkMapper),
      'colorfulDarkMapper':
          ColorAhexConverter.mapToJson(instance.colorfulDarkMapper),
    };
