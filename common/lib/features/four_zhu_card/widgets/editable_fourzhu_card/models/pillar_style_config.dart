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
  PillarStyleConfig({
    required super.border,
    required super.lightBackgroundColor,
    required super.darkBackgroundColor,
    super.padding = EdgeInsets.zero,
    super.margin = EdgeInsets.zero,
    required super.shadow,
    this.separatorWidth,
  });

  /// Separator列的宽度（仅用于 PillarType.separator）
  /// 当为 null 时，separator 列使用默认宽度
  final double? separatorWidth;

  @override
  List<Object?> get props => [
        border,
        lightBackgroundColor,
        darkBackgroundColor,
        padding,
        margin,
        shadow,
        separatorWidth,
      ];
  @override
  PillarStyleConfig copyWith({
    BoxBorderStyle? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadowStyle? shadow,
    double? separatorWidth,
  }) {
    return PillarStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      separatorWidth: separatorWidth ?? this.separatorWidth,
      // size: size ?? this.size,
    );
  }

  /// 将对象序列化为 JSON。仅写入非空字段，减少冗余。
  Map<String, dynamic> toJson() => _$PillarStyleConfigToJson(this);
  factory PillarStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$PillarStyleConfigFromJson(json);

  /// 获取柱的装饰宽度（包含边框宽度）
  /// WARNING: 并不包含组层Pillar的Cell宽度
  double getDecorationWidth() {
    final bw = border?.width ?? 0.0;
    if (border?.enabled ?? false) {
      return margin.left + margin.right + padding.left + padding.right + bw * 2;
    } else {
      return margin.left + margin.right + padding.left + padding.right;
    }
  }

  /// 获取柱的装饰高度（包含边框宽度）
  /// WARNING: 并不包含组层Pillar的Cell高度合
  double getDecorationHeight() {
    final bw = border?.width ?? 0;
    if (border?.enabled ?? false) {
      return margin.top + margin.bottom + padding.top + padding.bottom + bw * 2;
    } else {
      return margin.top + margin.bottom + padding.top + padding.bottom;
    }
  }

  /// 创建默认的 CardStyleConfig
  static PillarStyleConfig get defaultPillarStyleConfig {
    return PillarStyleConfig(
      border: BoxBorderStyle.defaultBorder.copyWith(enabled: false),
      lightBackgroundColor: Colors.white,
      darkBackgroundColor: Colors.grey.shade900,
      padding: EdgeInsets.zero,
      shadow: BoxShadowStyle.defaultShadow,
      margin: EdgeInsets.zero,
      // size: null,
    );
  }
}
