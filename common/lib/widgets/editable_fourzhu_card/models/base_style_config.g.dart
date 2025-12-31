// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoxShadowStyle _$BoxShadowStyleFromJson(Map<String, dynamic> json) =>
    BoxShadowStyle(
      withShadow: json['withShadow'] as bool,
      followCardBackgroundColor: json['followCardBackgroundColor'] as bool,
      lightThemeColor: const ColorAHexConverter()
          .fromJson(json['lightThemeColor'] as String),
      darkThemeColor:
          const ColorAHexConverter().fromJson(json['darkThemeColor'] as String),
      offset: const OffsetConverter()
          .fromJson(json['offset'] as Map<String, dynamic>),
      blurRadius: (json['blurRadius'] as num).toDouble(),
      spreadRadius: (json['spreadRadius'] as num).toDouble(),
    );

Map<String, dynamic> _$BoxShadowStyleToJson(BoxShadowStyle instance) =>
    <String, dynamic>{
      'withShadow': instance.withShadow,
      'followCardBackgroundColor': instance.followCardBackgroundColor,
      'lightThemeColor':
          const ColorAHexConverter().toJson(instance.lightThemeColor),
      'darkThemeColor':
          const ColorAHexConverter().toJson(instance.darkThemeColor),
      'offset': const OffsetConverter().toJson(instance.offset),
      'blurRadius': instance.blurRadius,
      'spreadRadius': instance.spreadRadius,
    };

BoxBorderStyle _$BoxBorderStyleFromJson(Map<String, dynamic> json) =>
    BoxBorderStyle(
      enabled: json['enabled'] as bool,
      width: (json['width'] as num).toDouble(),
      lightColor:
          const ColorAHexConverter().fromJson(json['lightColor'] as String),
      darkColor:
          const ColorAHexConverter().fromJson(json['darkColor'] as String),
      radius: (json['radius'] as num).toDouble(),
    );

Map<String, dynamic> _$BoxBorderStyleToJson(BoxBorderStyle instance) =>
    <String, dynamic>{
      'width': instance.width,
      'lightColor': const ColorAHexConverter().toJson(instance.lightColor),
      'darkColor': const ColorAHexConverter().toJson(instance.darkColor),
      'radius': instance.radius,
      'enabled': instance.enabled,
    };

BaseBoxStyleConfig _$BaseBoxStyleConfigFromJson(Map<String, dynamic> json) =>
    BaseBoxStyleConfig(
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

Map<String, dynamic> _$BaseBoxStyleConfigToJson(BaseBoxStyleConfig instance) =>
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
