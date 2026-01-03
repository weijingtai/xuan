// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardStyleConfig _$CardStyleConfigFromJson(Map<String, dynamic> json) =>
    CardStyleConfig(
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
    );

Map<String, dynamic> _$CardStyleConfigToJson(CardStyleConfig instance) =>
    <String, dynamic>{
      'border': instance.border,
      'lightBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.lightBackgroundColor),
      'darkBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.darkBackgroundColor),
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'margin': const EdgeInsetsConverter().toJson(instance.margin),
      'shadow': instance.shadow,
    };
