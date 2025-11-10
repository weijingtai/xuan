// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextStyleConfig _$TextStyleConfigFromJson(Map<String, dynamic> json) =>
    TextStyleConfig(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      colorHex: json['colorHex'] as String?,
      fontWeightValue: (json['fontWeightValue'] as num?)?.toInt(),
      shadowColorHex: json['shadowColorHex'] as String?,
      shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble(),
      shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble(),
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble(),
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      wordSpacing: (json['wordSpacing'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      decorationStyle: json['decorationStyle'] as String?,
      decorationColorHex: json['decorationColorHex'] as String?,
      decorationThickness: (json['decorationThickness'] as num?)?.toDouble(),
      fontStyle: json['fontStyle'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      perCharColorsLight:
          (json['perCharColorsLight'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      perCharColorsDark:
          (json['perCharColorsDark'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$TextStyleConfigToJson(TextStyleConfig instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'colorHex': instance.colorHex,
      'fontWeightValue': instance.fontWeightValue,
      'shadowColorHex': instance.shadowColorHex,
      'shadowOffsetX': instance.shadowOffsetX,
      'shadowOffsetY': instance.shadowOffsetY,
      'shadowBlurRadius': instance.shadowBlurRadius,
      'letterSpacing': instance.letterSpacing,
      'wordSpacing': instance.wordSpacing,
      'height': instance.height,
      'decorationStyle': instance.decorationStyle,
      'decorationColorHex': instance.decorationColorHex,
      'decorationThickness': instance.decorationThickness,
      'fontStyle': instance.fontStyle,
      'backgroundColor': instance.backgroundColor,
      'perCharColorsLight': instance.perCharColorsLight,
      'perCharColorsDark': instance.perCharColorsDark,
    };
