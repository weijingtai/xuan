// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_style_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CellStyleConfig _$CellStyleConfigFromJson(Map<String, dynamic> json) =>
    CellStyleConfig(
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
      showsTitleInCell: json['showsTitleInCell'] as bool? ?? false,
      separatorHeight: (json['separatorHeight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CellStyleConfigToJson(CellStyleConfig instance) =>
    <String, dynamic>{
      'border': instance.border,
      'lightBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.lightBackgroundColor),
      'darkBackgroundColor': const NullableColorAHexConverter()
          .toJson(instance.darkBackgroundColor),
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'margin': const EdgeInsetsConverter().toJson(instance.margin),
      'shadow': instance.shadow,
      'showsTitleInCell': instance.showsTitleInCell,
      'separatorHeight': instance.separatorHeight,
    };
