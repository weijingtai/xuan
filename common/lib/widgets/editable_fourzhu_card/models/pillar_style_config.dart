import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_style_config.dart';

part 'pillar_style_config.g.dart';

/// PillarStyleConfig
/// 封装柱（列容器）的视觉样式配置，尽可能复用已有的 `CardStyleConfig` 数据结构。
/// 功能描述：
/// - 通过组合 `CardStyleConfig` 承载边框/背景/圆角/内边距/阴影；
/// - 仅在柱层级新增 `margin: EdgeInsets` 字段以控制列间距；
/// - 提供 `toBoxDecoration()` 与 JSON 序列化/反序列化；
/// - 提供派生 getter（borderWidth/borderColor/cornerRadius/backgroundColor/padding）便于测量与渲染使用。
/// 参数说明：
/// - [baseStyle]：复用卡片样式数据类承载柱的装饰；
/// - [margin]：柱外边距（列间距）；
/// - [boxShadowOverride]：柱层级的阴影覆盖（可选，未提供时使用 `baseStyle.toBoxDecoration().boxShadow`）。
/// 返回值：不可变配置对象。
@JsonSerializable()
class PillarStyleConfig extends BaseBoxStyleConfig {
  const PillarStyleConfig({
    super.border,
    super.lightBackgroundColor,
    super.darkBackgroundColor,
    super.padding = EdgeInsets.zero,
    super.margin = EdgeInsets.zero,
    super.shadow,
  });

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
  PillarStyleConfig copyWith({
    BoxBorderStyle? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadowStyle? shadow,
  }) {
    return PillarStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      // size: size ?? this.size,
    );
  }

  /// 将对象序列化为 JSON。仅写入非空字段，减少冗余。
  Map<String, dynamic> toJson() => _$PillarStyleConfigToJson(this);
  factory PillarStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$PillarStyleConfigFromJson(json);

  /// 创建默认的 CardStyleConfig
  static PillarStyleConfig get defaultPillarStyleConfig {
    return PillarStyleConfig(
      border: BoxBorderStyle(
        enabled: true,
        width: 1.0,
        lightColor: Colors.grey.shade300,
        darkColor: Colors.grey.shade700,
        radius: 8.0,
      ),
      lightBackgroundColor: Colors.white,
      darkBackgroundColor: Colors.grey.shade900,
      padding: EdgeInsets.zero,
      shadow: BoxShadowStyle.defaultShadow,
      margin: EdgeInsets.zero,
      // size: null,
    );
  }
}
