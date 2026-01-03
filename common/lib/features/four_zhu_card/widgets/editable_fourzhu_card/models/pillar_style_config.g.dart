// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PillarStyleConfig _$PillarStyleConfigFromJson(Map<String, dynamic> json) =>
    PillarStyleConfig(
      border: json['border'] == null
          ? null
          : BoxBorderStyle.fromJson(json['border'] as Map<String, dynamic>),
      lightBackgroundColor: const NullableColorAHexConverter()
          .fromJson(json['lightBackgroundColor'] as String?),
      darkBackgroundColor: const NullableColorAHexConverter()
          .fromJson(json['darkBackgroundColor'] as String?),
      padding: json['padding'] == null
          ? EdgeInsets.zero
          : const EdgeInsetsConverter()
              .fromJson(json['padding'] as Map<String, dynamic>),
      margin: json['margin'] == null
          ? EdgeInsets.zero
          : const EdgeInsetsConverter()
              .fromJson(json['margin'] as Map<String, dynamic>),
      shadow: BoxShadowStyle.fromJson(json['shadow'] as Map<String, dynamic>),
      separatorWidth: (json['separatorWidth'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PillarStyleConfigToJson(PillarStyleConfig instance) =>
    <String, dynamic>{
      'border': instance.border,
      'lightBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.lightBackgroundColor),
      'darkBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.darkBackgroundColor),
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'margin': const EdgeInsetsConverter().toJson(instance.margin),
      'shadow': instance.shadow,
      'separatorWidth': instance.separatorWidth,
    };
