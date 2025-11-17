import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_style_config.dart';

part 'card_style_config.g.dart';

/// CardStyleConfig
/// 封装卡片（容器）的视觉样式配置，尽可能复用已有的 `BaseBoxStyleConfig` 数据结构。
/// 功能描述：
@JsonSerializable()
class CardStyleConfig extends BaseBoxStyleConfig {
  CardStyleConfig({
    super.border,
    super.lightBackgroundColor,
    super.darkBackgroundColor,
    super.padding = EdgeInsets.zero,
    super.margin = EdgeInsets.zero,
    required super.shadow,
  });
  Map<String, dynamic> toJson() => _$CardStyleConfigToJson(this);
  factory CardStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$CardStyleConfigFromJson(json);

  @override
  List<Object?> get props => [
        border,
        lightBackgroundColor,
        darkBackgroundColor,
        padding,
        margin,
        shadow,
      ];
  @override
  CardStyleConfig copyWith({
    BoxBorderStyle? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadowStyle? shadow,
  }) {
    return CardStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      // size: size ?? this.size,
    );
  }

  /// 创建默认的 CardStyleConfig
  static CardStyleConfig get defaultCardStyleConfig {
    return CardStyleConfig(
      border: BoxBorderStyle.defaultBorder,
      lightBackgroundColor: Colors.white,
      darkBackgroundColor: Colors.grey.shade900,
      padding: const EdgeInsets.all(16.0),
      shadow: BoxShadowStyle.defaultShadow,
      margin: EdgeInsets.zero,
      // size: null,
    );
  }
}
