import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'text_style_config.g.dart';

/// 文本样式配置数据类
///
/// 封装所有字体样式属性，支持 JSON 序列化和与 Flutter TextStyle 的双向转换。
///
/// 设计原则：
/// 1. 所有字段可选（nullable），默认值由 TextStyle 提供
/// 2. 使用可序列化类型（String, double, int）而非 Flutter 类型
/// 3. 向后兼容：可从旧的 RowConfig 离散字段构造
@JsonSerializable()
class TextStyleConfig {
  /// 构造函数
  const TextStyleConfig({
    // 基础属性（当前已支持）
    this.fontFamily,
    this.fontSize,
    this.colorHex,
    this.fontWeightValue, // 100-900

    // 阴影属性（当前已支持）
    this.shadowColorHex,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,

    // 扩展属性（未来支持）
    this.letterSpacing,
    this.wordSpacing,
    this.height, // 行高倍数
    this.decorationStyle, // 'none', 'underline', 'overline', 'lineThrough'
    this.decorationColorHex,
    this.decorationThickness,
    this.fontStyle, // 'normal', 'italic'
    this.backgroundColor,

    // 彩色模式逐字颜色
    this.perCharColorsLight,
    this.perCharColorsDark,
  });

  // ==================== 基础属性 ====================

  /// 字体家族（如 'NotoSansSC-Regular', 'PingFang SC'）
  final String? fontFamily;

  /// 字体大小（逻辑像素）
  final double? fontSize;

  /// 文本颜色（#AARRGGBB 格式）
  final String? colorHex;

  /// 字体粗细（100-900，对应 FontWeight.w100 到 w900）
  final int? fontWeightValue;

  // ==================== 阴影属性 ====================

  /// 阴影颜色（#AARRGGBB 格式）
  final String? shadowColorHex;

  /// 阴影 X 轴偏移
  final double? shadowOffsetX;

  /// 阴影 Y 轴偏移
  final double? shadowOffsetY;

  /// 阴影模糊半径
  final double? shadowBlurRadius;

  // ==================== 扩展属性 ====================

  /// 字符间距
  final double? letterSpacing;

  /// 单词间距
  final double? wordSpacing;

  /// 行高倍数（如 1.5 表示 1.5 倍行高）
  final double? height;

  /// 文本装饰样式（'none', 'underline', 'overline', 'lineThrough'）
  final String? decorationStyle;

  /// 装饰线颜色（#AARRGGBB 格式）
  final String? decorationColorHex;

  /// 装饰线粗细
  final double? decorationThickness;

  /// 字体样式（'normal', 'italic'）
  final String? fontStyle;

  /// 背景颜色（#AARRGGBB 格式）
  final String? backgroundColor;

  // ==================== 彩色模式逐字颜色 ====================

  /// 亮色主题下的逐字颜色映射（彩色模式）
  /// 例如：{'甲': '#FF00FF00', '乙': '#FF00FF00'}
  /// 用于 ColorfulTextStyleEditorWidget 恢复用户自定义的字符颜色
  final Map<String, String>? perCharColorsLight;

  /// 暗色主题下的逐字颜色映射（彩色模式）
  /// 例如：{'甲': '#FFFFFFFF', '乙': '#FFFFFFFF'}
  /// 用于 ColorfulTextStyleEditorWidget 恢复用户自定义的字符颜色
  final Map<String, String>? perCharColorsDark;

  // ==================== JSON 序列化 ====================

  /// 从 JSON 反序列化
  factory TextStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$TextStyleConfigFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$TextStyleConfigToJson(this);

  // ==================== 与 Flutter TextStyle 的转换 ====================

  /// 转换为 Flutter TextStyle
  ///
  /// 所有 null 字段将使用 TextStyle 的默认值
  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: _parseColor(colorHex),
      fontWeight: _parseFontWeight(fontWeightValue),
      shadows: _buildShadows(),
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: _parseDecoration(decorationStyle),
      decorationColor: _parseColor(decorationColorHex),
      decorationThickness: decorationThickness,
      fontStyle: _parseFontStyle(fontStyle),
      backgroundColor: _parseColor(backgroundColor),
    );
  }

  /// 从 Flutter TextStyle 构造
  ///
  /// 提取所有支持的属性并转换为可序列化格式
  ///
  /// 参数：
  /// - style: Flutter TextStyle 对象
  /// - perCharColorsLight: 亮色主题下的逐字颜色映射（可选）
  /// - perCharColorsDark: 暗色主题下的逐字颜色映射（可选）
  factory TextStyleConfig.fromTextStyle(
    TextStyle style, {
    Map<String, String>? perCharColorsLight,
    Map<String, String>? perCharColorsDark,
  }) {
    return TextStyleConfig(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      colorHex: _colorToHex(style.color),
      fontWeightValue: style.fontWeight?.value,
      shadowColorHex: style.shadows?.isNotEmpty == true
          ? _colorToHex(style.shadows!.first.color)
          : null,
      shadowOffsetX: style.shadows?.isNotEmpty == true
          ? style.shadows!.first.offset.dx
          : null,
      shadowOffsetY: style.shadows?.isNotEmpty == true
          ? style.shadows!.first.offset.dy
          : null,
      shadowBlurRadius: style.shadows?.isNotEmpty == true
          ? style.shadows!.first.blurRadius
          : null,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      height: style.height,
      decorationStyle: _decorationToString(style.decoration),
      decorationColorHex: _colorToHex(style.decorationColor),
      decorationThickness: style.decorationThickness,
      fontStyle: style.fontStyle?.name,
      backgroundColor: _colorToHex(style.backgroundColor),
      perCharColorsLight: perCharColorsLight,
      perCharColorsDark: perCharColorsDark,
    );
  }

  /// 从旧的 RowConfig 离散字段构造（向后兼容）
  ///
  /// 参数：
  /// - fontFamily: 字体家族
  /// - fontSize: 字体大小
  /// - textColorHex: 文本颜色
  /// - fontWeight: 字体粗细（'w400', 'w700' 等）
  /// - shadowColorHex, shadowOffsetX, shadowOffsetY, shadowBlurRadius: 阴影属性
  factory TextStyleConfig.fromLegacyRowConfig({
    String? fontFamily,
    double? fontSize,
    String? textColorHex,
    String? fontWeight,
    String? shadowColorHex,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
  }) {
    return TextStyleConfig(
      fontFamily: fontFamily,
      fontSize: fontSize,
      colorHex: textColorHex,
      fontWeightValue: _parseFontWeightString(fontWeight),
      shadowColorHex: shadowColorHex,
      shadowOffsetX: shadowOffsetX,
      shadowOffsetY: shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius,
    );
  }

  // ==================== copyWith ====================

  TextStyleConfig copyWith({
    String? fontFamily,
    double? fontSize,
    String? colorHex,
    int? fontWeightValue,
    String? shadowColorHex,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    String? decorationStyle,
    String? decorationColorHex,
    double? decorationThickness,
    String? fontStyle,
    String? backgroundColor,
    Map<String, String>? perCharColorsLight,
    Map<String, String>? perCharColorsDark,
  }) {
    return TextStyleConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      colorHex: colorHex ?? this.colorHex,
      fontWeightValue: fontWeightValue ?? this.fontWeightValue,
      shadowColorHex: shadowColorHex ?? this.shadowColorHex,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      height: height ?? this.height,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationColorHex: decorationColorHex ?? this.decorationColorHex,
      decorationThickness: decorationThickness ?? this.decorationThickness,
      fontStyle: fontStyle ?? this.fontStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      perCharColorsLight: perCharColorsLight ?? this.perCharColorsLight,
      perCharColorsDark: perCharColorsDark ?? this.perCharColorsDark,
    );
  }

  // ==================== 私有辅助方法 ====================

  /// 构建阴影列表
  List<Shadow>? _buildShadows() {
    if (shadowColorHex == null) return null;
    final color = _parseColor(shadowColorHex);
    if (color == null) return null;

    return [
      Shadow(
        color: color,
        offset: Offset(
          shadowOffsetX ?? 0,
          shadowOffsetY ?? 1,
        ),
        blurRadius: shadowBlurRadius ?? 2,
      ),
    ];
  }

  /// 解析颜色字符串为 Color
  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceAll('#', '');
    if (normalized.length == 8) {
      // AARRGGBB
      final value = int.tryParse(normalized, radix: 16);
      if (value == null) return null;
      return Color(value);
    }
    if (normalized.length == 6) {
      // RRGGBB -> 强制不透明
      final value = int.tryParse(normalized, radix: 16);
      if (value == null) return null;
      return Color(0xFF000000 | value);
    }
    return null;
  }

  /// 将 Color 转为 #AARRGGBB 字符串
  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    final a = color.alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = color.red.toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = color.green.toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$a$r$g$b';
  }

  /// 解析 FontWeight 数值
  static FontWeight? _parseFontWeight(int? value) {
    if (value == null) return null;
    switch (value) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  /// 解析旧格式 FontWeight 字符串（'w400' -> 400）
  static int? _parseFontWeightString(String? str) {
    if (str == null || str.isEmpty) return null;
    final valueStr = str.replaceFirst('w', '');
    return int.tryParse(valueStr);
  }

  /// 解析装饰样式
  static TextDecoration? _parseDecoration(String? style) {
    switch (style) {
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'none':
        return TextDecoration.none;
      default:
        return null;
    }
  }

  /// 装饰样式转字符串
  static String? _decorationToString(TextDecoration? decoration) {
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.overline) return 'overline';
    if (decoration == TextDecoration.lineThrough) return 'lineThrough';
    if (decoration == TextDecoration.none) return 'none';
    return null;
  }

  /// 解析字体样式
  static FontStyle? _parseFontStyle(String? style) {
    switch (style) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return null;
    }
  }

  // ==================== 相等性比较 ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TextStyleConfig &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.colorHex == colorHex &&
        other.fontWeightValue == fontWeightValue &&
        other.shadowColorHex == shadowColorHex &&
        other.shadowOffsetX == shadowOffsetX &&
        other.shadowOffsetY == shadowOffsetY &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.letterSpacing == letterSpacing &&
        other.wordSpacing == wordSpacing &&
        other.height == height &&
        other.decorationStyle == decorationStyle &&
        other.decorationColorHex == decorationColorHex &&
        other.decorationThickness == decorationThickness &&
        other.fontStyle == fontStyle &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
        fontFamily,
        fontSize,
        colorHex,
        fontWeightValue,
        shadowColorHex,
        shadowOffsetX,
        shadowOffsetY,
        shadowBlurRadius,
        Object.hash(
          letterSpacing,
          wordSpacing,
          height,
          decorationStyle,
          decorationColorHex,
          decorationThickness,
          fontStyle,
          backgroundColor,
        ),
      );
}
