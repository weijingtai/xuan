import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_style_config.dart';

part 'cell_style_config.g.dart';

/// CellStyleConfig
/// 定义“单元格（Cell）”级别的装饰样式配置，面向行内每个单元格的渲染与测量：背景、边框、圆角、内边距、外边距、阴影。
/// 与 `PillarStyleConfig` 一致的字段结构，便于统一计算与风格复用，但语义聚焦到 Cell 而非列容器。
@JsonSerializable()
class CellStyleConfig extends BaseBoxStyleConfig {
  /// 是否在单元格内显示标题（行类型覆盖优先）
  /// 默认值为 false
  final bool showsTitleInCell;

  /// 分隔行高度（仅当 RowType.separator 时生效）
  final double? separatorHeight;

  @override
  List<Object?> get props => [
        border,
        lightBackgroundColor,
        darkBackgroundColor,
        padding,
        margin,
        shadow,
        showsTitleInCell,
        separatorHeight,
      ];

  /// 构造一个 Cell 样式配置对象
  ///
  /// 参数：
  /// - [border]：边框样式（宽度、颜色、圆角、启用）
  /// - [lightBackgroundColor]/[darkBackgroundColor]：浅/深主题下的背景色
  /// - [padding]：内边距（内容与边框之间）
  /// - [margin]：外边距（单元格与相邻单元之间）
  /// - [shadow]：阴影样式（开关、颜色、偏移、模糊、扩散、透明度）
  /// - [separatorHeight]：分隔行高度（可选）
  ///
  /// 返回：不可变配置对象
  CellStyleConfig({
    required super.border,
    required super.lightBackgroundColor,
    required super.darkBackgroundColor,
    super.padding = EdgeInsets.zero,
    super.margin = EdgeInsets.zero,
    required super.shadow,
    this.showsTitleInCell = false,
    this.separatorHeight,
  });

  /// 创建一个更新后的副本
  ///
  /// 参数：
  /// - 同名字段为可选新值；未提供的字段保持原值
  ///
  /// 返回：新 `CellStyleConfig` 实例
  @override
  CellStyleConfig copyWith({
    BoxBorderStyle? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadowStyle? shadow,
    bool? showsTitleInCell,
    double? separatorHeight,
  }) {
    return CellStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      showsTitleInCell: showsTitleInCell ?? this.showsTitleInCell,
      separatorHeight: separatorHeight ?? this.separatorHeight,
    );
  }

  /// 序列化为 JSON（仅写入非空字段）
  ///
  /// 返回：`Map<String, dynamic>` 表示的 JSON
  Map<String, dynamic> toJson() => _$CellStyleConfigToJson(this);

  /// 从 JSON 反序列化
  ///
  /// 参数：
  /// - [json]：`Map<String, dynamic>` 输入
  ///
  /// 返回：反序列化后的 `CellStyleConfig` 实例
  factory CellStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$CellStyleConfigFromJson(json);

  /// 计算单元格装饰所占宽度（左右 `margin + padding + borderWidth*2`）
  ///
  /// 返回：装饰总宽度（逻辑像素）
  double getDecorationWidth() {
    final bw = (border?.width ?? 0.0).toDouble();
    final hasBorder = border?.enabled ?? false;
    final base = margin.left +
        margin.right +
        padding.left +
        padding.right +
        (hasBorder ? bw * 2 : 0.0);
    final extraShadowW = shadow.withShadow
        ? (shadow.blurRadius + shadow.spreadRadius + shadow.offset.dx.abs())
        : 0.0;
    return base + extraShadowW;
  }

  /// 计算单元格装饰所占高度（上下 `margin + padding + borderWidth*2`）
  ///
  /// 返回：装饰总高度（逻辑像素）
  double getDecorationHeight() {
    final bw = (border?.width ?? 0.0).toDouble();
    final hasBorder = border?.enabled ?? false;
    final base = margin.top +
        margin.bottom +
        padding.top +
        padding.bottom +
        (hasBorder ? bw * 2 : 0.0);
    final extraShadowH = shadow.withShadow
        ? (shadow.blurRadius + shadow.spreadRadius + shadow.offset.dy.abs())
        : 0.0;
    return base + extraShadowH;
  }

  /// 默认的 Cell 样式配置（无边距、默认阴影、圆角与边框禁用）
  ///
  /// 返回：标准默认配置
  static CellStyleConfig get defaultCellStyleConfig {
    return CellStyleConfig(
      border:
          BoxBorderStyle.defaultBorder.copyWith(enabled: false, radius: 4.0),
      lightBackgroundColor: Colors.transparent,
      darkBackgroundColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      margin: EdgeInsets.zero,
      shadow: BoxShadowStyle.defaultShadow.copyWith(withShadow: false),
      showsTitleInCell: false,
    );
  }
}
