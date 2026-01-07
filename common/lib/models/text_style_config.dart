import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:common/utils/constant_values_utils.dart';

import '../const_resources_mapper.dart';
import '../dev_constant.dart';

part 'text_style_config.g.dart';

/// 文本样式配置数据类
///
/// 封装所有字体样式属性，支持 JSON 序列化和与 Flutter TextStyle 的双向转换。
///
/// 设计原则：
/// 1. 所有字段可选（nullable），默认值由 TextStyle 提供
/// 2. 使用可序列化类型（String, double, int）而非 Flutter 类型
/// 3. 向后兼容：可从旧的 RowConfig 离散字段构造
/// 颜色预览模式（用于样式编辑场景的模式持久化）
/// - pure：纯色预览（不按五行元素着色）
/// - colorful：彩色预览（按元素或策略着色）
enum ColorPreviewMode {
  @JsonValue("pure")
  pure,
  @JsonValue("colorful")
  colorful,
  @JsonValue("blackwhite")
  blackwhite,
}

@JsonSerializable()
class TextStyleConfig {
  final ColorMapperDataModel colorMapperDataModel;

  final TextShadowDataModel textShadowDataModel;

  final FontStyleDataModel fontStyleDataModel;

  /// 构造函数
  TextStyleConfig({
    required this.colorMapperDataModel,
    required this.textShadowDataModel,
    required this.fontStyleDataModel,
    // 基础属性（当前已支持）
  });

  TextStyleConfig copyWith({
    ColorMapperDataModel? colorMapperDataModel,
    TextShadowDataModel? textShadowDataModel,
    FontStyleDataModel? fontStyleDataModel,
  }) {
    return TextStyleConfig(
      colorMapperDataModel: colorMapperDataModel ?? this.colorMapperDataModel,
      textShadowDataModel: textShadowDataModel ?? this.textShadowDataModel,
      fontStyleDataModel: fontStyleDataModel ?? this.fontStyleDataModel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TextStyleConfig &&
        other.colorMapperDataModel == colorMapperDataModel &&
        other.textShadowDataModel == textShadowDataModel &&
        other.fontStyleDataModel == fontStyleDataModel;
  }

  @override
  int get hashCode => Object.hash(
        colorMapperDataModel,
        textShadowDataModel,
        fontStyleDataModel,
      );

  TextStyle toTextStyleWithoutContent({
    required Brightness brightness,
    required ColorPreviewMode mode,
  }) {
    final textColor = colorMapperDataModel.getBy(
        theme: brightness, mode: mode, content: null);
    final shadowBase = textShadowDataModel.resolveColor(brightness, textColor);
    return TextStyle(
      fontSize: fontStyleDataModel.fontSize,
      fontFamily: fontStyleDataModel.fontFamily,
      fontWeight: fontStyleDataModel.fontWeight,
      color: textColor,
      shadows: textShadowDataModel.shadowEnabled
          ? [
              Shadow(
                color: shadowBase,
                blurRadius: textShadowDataModel.shadowBlurRadius,
                offset: Offset(
                  textShadowDataModel.shadowOffsetX,
                  textShadowDataModel.shadowOffsetY,
                ),
              )
            ]
          : [],
    );
  }

  static TextStyleConfig get defaultGanConfig => () {
        List<String> allGanStrList = TianGan.values
            .where((e) => e != TianGan.KONG_WANG)
            .map((e) => e.name)
            .toList();
        return TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: Map.fromEntries(allGanStrList
                .asMap()
                .entries
                .map((e) => MapEntry(e.value, Colors.black87))),
            colorfulLightMapper: Map.fromEntries(ConstResourcesMapper
                .zodiacGanColors
                .map((k, v) => MapEntry(k.name, v))
                .entries),
            pureDarkMapper: Map.fromEntries(allGanStrList
                .asMap()
                .entries
                .map((e) => MapEntry(e.value, Colors.white))),
            colorfulDarkMapper: Map.fromEntries(ConstResourcesMapper
                .zodiacGanColors
                .map((k, v) => MapEntry(k.name, v))
                .entries),
          ),
          textShadowDataModel: TextShadowDataModel(
            shadowEnabled: true,
            followTextColor: true,
            shadowBlurRadius: 4,
            lightShadowColor: Colors.black.withAlpha(178),
            darkShadowColor: Colors.white.withAlpha(178),
            shadowOffsetX: 1,
            shadowOffsetY: 1,
          ),
          fontStyleDataModel: FontStyleDataModel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'NotoSansSC-Regular',
            height: 1.2,
          ),
        );
      }();
  static TextStyleConfig get defaultZhiConfig => () {
        List<String> allZhiStrList = DiZhi.values.map((e) => e.name).toList();
        return TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: Map.fromEntries(allZhiStrList
                .asMap()
                .entries
                .map((e) => MapEntry(e.value, Colors.black87))),
            colorfulLightMapper: Map.fromEntries(ConstResourcesMapper
                .zodiacZhiColors
                .map((k, v) => MapEntry(k.name, v))
                .entries),
            pureDarkMapper: Map.fromEntries(allZhiStrList
                .asMap()
                .entries
                .map((e) => MapEntry(e.value, Colors.white))),
            colorfulDarkMapper: Map.fromEntries(ConstResourcesMapper
                .zodiacZhiColors
                .map((k, v) => MapEntry(k.name, v))
                .entries),
          ),
          textShadowDataModel: TextShadowDataModel(
            shadowEnabled: true,
            followTextColor: true,
            shadowBlurRadius: 4,
            lightShadowColor: Colors.black.withAlpha(178),
            darkShadowColor: Colors.white.withAlpha(178),
            shadowOffsetX: 1,
            shadowOffsetY: 1,
          ),
          fontStyleDataModel: FontStyleDataModel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'NotoSansSC-Regular',
            height: 1.2,
          ),
        );
      }();
  static TextStyleConfig defaultTenGodsConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      colorfulLightMapper: {
        for (final zs in EnumTenGods.values) zs.name: Colors.purpleAccent,
        for (final zs in EnumTenGods.values) zs.singleName: Colors.purpleAccent,
        FourZhuText.qianZao: Colors.purpleAccent,
        FourZhuText.kunZao: Colors.purpleAccent,
      },
      pureLightMapper: {
        for (final zs in EnumTenGods.values) zs.name: Colors.black87,
        for (final zs in EnumTenGods.values) zs.singleName: Colors.black87,
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      colorfulDarkMapper: {
        for (final zs in EnumTenGods.values) zs.name: Colors.purple,
        for (final zs in EnumTenGods.values) zs.singleName: Colors.purple,
        FourZhuText.qianZao: Colors.purple,
        FourZhuText.kunZao: Colors.purple,
      },
      pureDarkMapper: {
        for (final zs in EnumTenGods.values) zs.name: Colors.white,
        for (final zs in EnumTenGods.values) zs.singleName: Colors.white,
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      fontFamily: 'NotoSansSC-Regular',
      height: 1.2,
    ),
  );
  static TextStyleConfig defaultTwelveZhangShengConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      colorfulLightMapper: Map.fromEntries(TwelveZhangSheng.values
          .map((zs) => MapEntry(zs.name, Colors.deepPurpleAccent))),
      pureLightMapper: Map.fromEntries(TwelveZhangSheng.values
          .map((zs) => MapEntry(zs.name, Colors.black87))),
      colorfulDarkMapper: Map.fromEntries(TwelveZhangSheng.values
          .map((zs) => MapEntry(zs.name, Colors.deepPurple))),
      pureDarkMapper: Map.fromEntries(
          TwelveZhangSheng.values.map((zs) => MapEntry(zs.name, Colors.white))),
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      fontFamily: 'NotoSansSC-Regular',
      height: 1.2,
    ),
  );

  static TextStyleConfig defaultConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      colorfulLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      pureDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
      colorfulDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      fontFamily: 'NotoSansSC-Regular',
      height: 1.2,
    ),
  );

  static TextStyleConfig defaultOthersConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      colorfulLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      pureDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
      colorfulDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      fontFamily: 'NotoSansSC-Regular',
      height: 1.2,
    ),
  );
  static TextStyleConfig defaultOthersTitleConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      colorfulLightMapper: {
        FourZhuText.qianZao: Colors.black87,
        FourZhuText.kunZao: Colors.black87,
      },
      pureDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
      colorfulDarkMapper: {
        FourZhuText.qianZao: Colors.white,
        FourZhuText.kunZao: Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 8,
      fontFamily: 'NotoSansSC-Regular',
      height: 1.2,
    ),
  );

  // ==================== JSON 序列化 ====================

  /// 从 JSON 反序列化
  factory TextStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$TextStyleConfigFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$TextStyleConfigToJson(this);

  // ==================== 与 Flutter TextStyle 的转换 ====================

  /// 转换为 Flutter TextStyle
  ///
  /// 可选传入 `char`、`colorPreviewMode`、`brightness` 用于按映射取色；
  /// 若未提供，颜色保持为 null，由上层渲染决定。
  TextStyle toTextStyle({
    String? char,
    ColorPreviewMode? colorPreviewMode,
    Brightness? brightness,
  }) {
    final b = brightness ?? Brightness.light;
    final m = colorPreviewMode ?? ColorPreviewMode.pure;

    final Color? textColor = (char != null || m == ColorPreviewMode.blackwhite)
        ? colorMapperDataModel.getBy(theme: b, mode: m, content: char)
        : null;

    final shadowBase = textShadowDataModel.resolveColor(b, textColor);

    return TextStyle(
      fontFamily: fontStyleDataModel.fontFamily,
      fontSize: fontStyleDataModel.fontSize,
      color: textColor,
      fontWeight: fontStyleDataModel.fontWeight,
      height: fontStyleDataModel.height,
      shadows: textShadowDataModel.shadowEnabled
          ? [
              Shadow(
                color: shadowBase,
                blurRadius: textShadowDataModel.shadowBlurRadius,
                offset: Offset(
                  textShadowDataModel.shadowOffsetX,
                  textShadowDataModel.shadowOffsetY,
                ),
              )
            ]
          : null,
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
    Map<String, Color> _toColorMap(Map<String, String>? m) {
      if (m == null) return const {};
      final out = <String, Color>{};
      m.forEach((k, v) {
        final c = _parseColor(v);
        if (c != null) out[k] = c;
      });
      return out;
    }

    final hasShadow = style.shadows?.isNotEmpty == true;
    final shadow = hasShadow ? style.shadows!.first : null;

    return TextStyleConfig(
      colorMapperDataModel: ColorMapperDataModel(
        pureLightMapper: _toColorMap(perCharColorsLight),
        colorfulLightMapper: const {},
        pureDarkMapper: _toColorMap(perCharColorsDark),
        colorfulDarkMapper: const {},
      ),
      textShadowDataModel: TextShadowDataModel(
        shadowEnabled: hasShadow,
        followTextColor: false,
        shadowBlurRadius: shadow?.blurRadius ?? 10,
        lightShadowColor:
            (shadow?.color ?? (style.color ?? Colors.black)).withAlpha(165),
        darkShadowColor:
            (shadow?.color ?? (style.color ?? Colors.black)).withAlpha(165),
        shadowOffsetX: shadow?.offset.dx ?? 5.0,
        shadowOffsetY: shadow?.offset.dy ?? 5.0,
      ),
      fontStyleDataModel: FontStyleDataModel(
        fontFamily: style.fontFamily ?? 'System',
        fontSize: style.fontSize ?? 14.0,
        fontWeight: style.fontWeight ?? FontWeight.w400,
        height: style.height ?? 1.2,
      ),
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
    // 兼容旧字段：将离散字段映射到三大子模型
    final color = _parseColor(textColorHex);
    final shadowColor = _parseColor(shadowColorHex) ?? Colors.black;
    final weight =
        _parseFontWeight(_parseFontWeightString(fontWeight)) ?? FontWeight.w400;
    return TextStyleConfig(
      colorMapperDataModel: ColorMapperDataModel(
        // 旧版没有逐字颜色映射，初始化为空映射
        pureLightMapper: const {},
        colorfulLightMapper: const {},
        pureDarkMapper: const {},
        colorfulDarkMapper: const {},
        defaultColor: color ?? Colors.blueGrey,
      ),
      textShadowDataModel: TextShadowDataModel(
        shadowEnabled: (shadowColorHex != null) ||
            (shadowOffsetX != null) ||
            (shadowOffsetY != null) ||
            (shadowBlurRadius != null),
        followTextColor: false,
        shadowBlurRadius: shadowBlurRadius ?? 10,
        lightShadowColor: shadowColor.withAlpha(165),
        darkShadowColor: shadowColor.withAlpha(165),
        shadowOffsetX: shadowOffsetX ?? 5.0,
        shadowOffsetY: shadowOffsetY ?? 5.0,
      ),
      fontStyleDataModel: FontStyleDataModel(
        fontFamily: fontFamily ?? 'System',
        fontSize: fontSize ?? 14.0,
        fontWeight: weight,
        height: 1.2,
      ),
    );
  }

  // ==================== copyWith ====================

  // TextStyleConfig copyWith({
  //   ColorMapperDataModel? colorMapperDataModel,
  //   TextShadowDataModel? textShadowDataModel,
  //   FontStyleDataModel? fontStyleDataModel,
  // }) {
  //   return TextStyleConfig(
  //     colorMapperDataModel: colorMapperDataModel ?? this.colorMapperDataModel,
  //     textShadowDataModel: textShadowDataModel ?? this.textShadowDataModel,
  //     fontStyleDataModel: fontStyleDataModel ?? this.fontStyleDataModel,
  //   );
  // }

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

  /// Map 比较（键值都为 String）
  ///
  /// 参数：
  /// - a：第一个映射
  /// - b：第二个映射
  /// 返回：是否相等（按键值对逐项比较）
  static bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  /// Map 生成哈希
  ///
  /// 参数：
  /// - m：映射（字符串键值）
  /// 返回：稳定哈希值（与字段参与对象哈希一致）
  static int _mapHash(Map<String, String>? m) {
    if (m == null) return 0;
    return Object.hashAll(
      m.entries.map((e) => Object.hash(e.key, e.value)),
    );
  }
}

/// 将 `Color` 按 AHEX（AARRGGBB）字符串进行 JSON 序列化/反序列化的转换器。
///
/// 说明：
/// - 序列化输出形如 `#AARRGGBB`（例如 `#FF112233`）。
/// - 反序列化支持 `#AARRGGBB` 或 `0xAARRGGBB`，若提供 `RRGGBB` 则默认补全不透明 Alpha（`FF`）。
class ColorAhexConverter implements JsonConverter<Color, String> {
  const ColorAhexConverter();

  /// 反序列化：将 AHEX 字符串转为 `Color`。
  ///
  /// 参数：
  /// - [json] AHEX 字符串（支持 `#` 或 `0x` 前缀）。
  /// 返回：
  /// - `Color` 对象（若输入为 `RRGGBB` 则补全 Alpha 为 `FF`）。
  @override
  Color fromJson(String json) {
    final s = json.trim();
    String hex = s.startsWith('#')
        ? s.substring(1)
        : (s.startsWith('0x') || s.startsWith('0X'))
            ? s.substring(2)
            : s;
    if (hex.length == 6) {
      // 若仅提供 RRGGBB，则默认 Alpha=FF。
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      throw FormatException('Invalid ahex color: "$json"');
    }
    final value = int.parse(hex, radix: 16);
    return Color(value);
  }

  /// 序列化：将 `Color` 转为 AHEX 字符串（`#AARRGGBB`）。
  ///
  /// 参数：
  /// - [color] 需要被序列化的 `Color`。
  /// 返回：
  /// - AHEX 字符串（大写，带 `#` 前缀）。
  @override
  String toJson(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$hex';
  }

  /// Map 反序列化：`Map<String, String>` (AHEX) → `Map<String, Color>`。
  ///
  /// 参数：
  /// - [json] JSON 中的字符串颜色映射。
  /// 返回：
  /// - `Map<String, Color>`（每个值按 AHEX 转换）。
  static Map<String, Color> mapFromJson(Map<String, dynamic> json) {
    const c = ColorAhexConverter();
    return json.map((key, value) => MapEntry(key, c.fromJson(value as String)));
  }

  /// Map 序列化：`Map<String, Color>` → `Map<String, String>` (AHEX)。
  ///
  /// 参数：
  /// - [value] 运行时的颜色映射。
  /// 返回：
  /// - `Map<String, String>`（每个值序列化为 AHEX）。
  static Map<String, String> mapToJson(Map<String, Color> value) {
    const c = ColorAhexConverter();
    return value.map((key, color) => MapEntry(key, c.toJson(color)));
  }
}

class ColorMapperDataModel {
  Color defaultColor = Colors.blueGrey;
  double blackwhiteLightStrength;
  double blackwhiteDarkStrength;
  @JsonKey(
      fromJson: ColorAhexConverter.mapFromJson,
      toJson: ColorAhexConverter.mapToJson)
  late final Map<String, Color> pureLightMapper;
  @JsonKey(
      fromJson: ColorAhexConverter.mapFromJson,
      toJson: ColorAhexConverter.mapToJson)
  late final Map<String, Color> colorfulLightMapper;
  @JsonKey(
      fromJson: ColorAhexConverter.mapFromJson,
      toJson: ColorAhexConverter.mapToJson)
  late final Map<String, Color> pureDarkMapper;
  @JsonKey(
      fromJson: ColorAhexConverter.mapFromJson,
      toJson: ColorAhexConverter.mapToJson)
  late final Map<String, Color> colorfulDarkMapper;

  ColorMapperDataModel({
    required this.pureLightMapper,
    required this.colorfulLightMapper,
    required this.pureDarkMapper,
    required this.colorfulDarkMapper,
    this.defaultColor = Colors.blueGrey,
    this.blackwhiteLightStrength = 1.0,
    this.blackwhiteDarkStrength = 1.0,
  });

  ColorMapperDataModel copyWith({
    Map<String, Color>? pureLightMapper,
    Map<String, Color>? colorfulLightMapper,
    Map<String, Color>? pureDarkMapper,
    Map<String, Color>? colorfulDarkMapper,
    Color? defaultColor,
    double? blackwhiteLightStrength,
    double? blackwhiteDarkStrength,
  }) {
    return ColorMapperDataModel(
      pureLightMapper: pureLightMapper ?? this.pureLightMapper,
      colorfulLightMapper: colorfulLightMapper ?? this.colorfulLightMapper,
      pureDarkMapper: pureDarkMapper ?? this.pureDarkMapper,
      colorfulDarkMapper: colorfulDarkMapper ?? this.colorfulDarkMapper,
      defaultColor: defaultColor ?? this.defaultColor,
      blackwhiteLightStrength:
          blackwhiteLightStrength ?? this.blackwhiteLightStrength,
      blackwhiteDarkStrength:
          blackwhiteDarkStrength ?? this.blackwhiteDarkStrength,
    );
  }

  static const DeepCollectionEquality _mapEquality =
      DeepCollectionEquality.unordered();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ColorMapperDataModel &&
        other.defaultColor == defaultColor &&
        other.blackwhiteLightStrength == blackwhiteLightStrength &&
        other.blackwhiteDarkStrength == blackwhiteDarkStrength &&
        _mapEquality.equals(other.pureLightMapper, pureLightMapper) &&
        _mapEquality.equals(other.colorfulLightMapper, colorfulLightMapper) &&
        _mapEquality.equals(other.pureDarkMapper, pureDarkMapper) &&
        _mapEquality.equals(other.colorfulDarkMapper, colorfulDarkMapper);
  }

  @override
  int get hashCode => Object.hash(
        defaultColor,
        blackwhiteLightStrength,
        blackwhiteDarkStrength,
        _mapEquality.hash(pureLightMapper),
        _mapEquality.hash(colorfulLightMapper),
        _mapEquality.hash(pureDarkMapper),
        _mapEquality.hash(colorfulDarkMapper),
      );

  Color _blackwhiteColor(Brightness theme) {
    final s = (theme == Brightness.light
            ? blackwhiteLightStrength
            : blackwhiteDarkStrength)
        .clamp(0.0, 1.0);
    return Color.lerp(
          Colors.grey,
          theme == Brightness.light ? Colors.black87 : Colors.white70,
          s,
        ) ??
        (theme == Brightness.light ? Colors.black87 : Colors.white70);
  }

  Color _modeDefaultColor({
    required Brightness theme,
    required ColorPreviewMode mode,
  }) {
    switch (mode) {
      case ColorPreviewMode.blackwhite:
        return _blackwhiteColor(theme);
      case ColorPreviewMode.pure:
      case ColorPreviewMode.colorful:
        return theme == Brightness.light ? Colors.black87 : Colors.white70;
    }
  }

  Map<String, Color> getMapperBy({
    required Brightness theme,
    required ColorPreviewMode mode,
  }) {
    if (mode == ColorPreviewMode.blackwhite) return const {};
    switch (theme) {
      case Brightness.light:
        return mode == ColorPreviewMode.colorful
            ? colorfulLightMapper
            : pureLightMapper;
      case Brightness.dark:
        return mode == ColorPreviewMode.colorful
            ? colorfulDarkMapper
            : pureDarkMapper;
    }
  }

  Color getBy({
    required Brightness theme,
    required ColorPreviewMode mode,
    required String? content,
  }) {
    if (mode == ColorPreviewMode.blackwhite) {
      return _blackwhiteColor(theme);
    }
    final fallback = _modeDefaultColor(theme: theme, mode: mode);
    if (content == null) {
      return fallback;
    }
    return getMapperBy(theme: theme, mode: mode)[content] ?? fallback;
  }

  ColorMapperDataModel update({
    required Brightness brightness,
    required ColorPreviewMode mode,
    required String char,
    required Color color,
  }) {
    if (mode == ColorPreviewMode.blackwhite) {
      return this;
    }

    final mapper = getMapperBy(theme: brightness, mode: mode);
    final updatedMapper = Map<String, Color>.from(mapper);
    updatedMapper[char] = color;

    final pureLight =
        brightness == Brightness.light && mode == ColorPreviewMode.pure
            ? updatedMapper
            : pureLightMapper;
    final colorfulLight =
        brightness == Brightness.light && mode == ColorPreviewMode.colorful
            ? updatedMapper
            : colorfulLightMapper;
    final pureDark =
        brightness == Brightness.dark && mode == ColorPreviewMode.pure
            ? updatedMapper
            : pureDarkMapper;
    final colorfulDark =
        brightness == Brightness.dark && mode == ColorPreviewMode.colorful
            ? updatedMapper
            : colorfulDarkMapper;

    return ColorMapperDataModel(
      pureLightMapper: pureLight,
      colorfulLightMapper: colorfulLight,
      pureDarkMapper: pureDark,
      colorfulDarkMapper: colorfulDark,
      defaultColor: defaultColor,
      blackwhiteLightStrength: blackwhiteLightStrength,
      blackwhiteDarkStrength: blackwhiteDarkStrength,
    );
  }

  factory ColorMapperDataModel.fromJson(Map<String, dynamic> json) {
    final pureLight = json['pureLightMapper'] as Map<String, dynamic>?;
    final colorfulLight = json['colorfulLightMapper'] as Map<String, dynamic>?;
    final pureDark = json['pureDarkMapper'] as Map<String, dynamic>?;
    final colorfulDark = json['colorfulDarkMapper'] as Map<String, dynamic>?;
    final bwLight =
        (json['blackwhiteLightStrength'] as num?)?.toDouble() ?? 1.0;
    final bwDark = (json['blackwhiteDarkStrength'] as num?)?.toDouble() ?? 1.0;
    return ColorMapperDataModel(
      pureLightMapper:
          pureLight == null ? {} : ColorAhexConverter.mapFromJson(pureLight),
      colorfulLightMapper: colorfulLight == null
          ? {}
          : ColorAhexConverter.mapFromJson(colorfulLight),
      pureDarkMapper:
          pureDark == null ? {} : ColorAhexConverter.mapFromJson(pureDark),
      colorfulDarkMapper: colorfulDark == null
          ? {}
          : ColorAhexConverter.mapFromJson(colorfulDark),
      blackwhiteLightStrength: bwLight,
      blackwhiteDarkStrength: bwDark,
    );
  }
  Map<String, dynamic> toJson() => {
        'pureLightMapper': ColorAhexConverter.mapToJson(pureLightMapper),
        'colorfulLightMapper':
            ColorAhexConverter.mapToJson(colorfulLightMapper),
        'pureDarkMapper': ColorAhexConverter.mapToJson(pureDarkMapper),
        'colorfulDarkMapper': ColorAhexConverter.mapToJson(colorfulDarkMapper),
        'blackwhiteLightStrength': blackwhiteLightStrength,
        'blackwhiteDarkStrength': blackwhiteDarkStrength,
      };
}

class TextShadowDataModel {
  bool shadowEnabled = false;
  bool followTextColor = false;
  double shadowBlurRadius = 10;
  Color lightShadowColor = Colors.black;
  Color darkShadowColor = Colors.white;
  double shadowOffsetX = 5.0; // 默认 X 轴偏移
  double shadowOffsetY = 5.0; // 默认 Y 轴偏移
  TextShadowDataModel({
    this.shadowEnabled = false,
    this.followTextColor = false,
    this.shadowBlurRadius = 10,
    this.lightShadowColor = Colors.black,
    this.darkShadowColor = Colors.white,
    this.shadowOffsetX = 5.0,
    this.shadowOffsetY = 5.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TextShadowDataModel &&
        other.shadowEnabled == shadowEnabled &&
        other.followTextColor == followTextColor &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.lightShadowColor == lightShadowColor &&
        other.darkShadowColor == darkShadowColor &&
        other.shadowOffsetX == shadowOffsetX &&
        other.shadowOffsetY == shadowOffsetY;
  }

  @override
  int get hashCode => Object.hash(
        shadowEnabled,
        followTextColor,
        shadowBlurRadius,
        lightShadowColor,
        darkShadowColor,
        shadowOffsetX,
        shadowOffsetY,
      );
  TextShadowDataModel copyWith({
    bool? shadowEnabled,
    bool? followTextColor,
    double? shadowBlurRadius,
    Color? lightShadowColor,
    Color? darkShadowColor,
    double? shadowOffsetX,
    double? shadowOffsetY,
  }) {
    return TextShadowDataModel(
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      followTextColor: followTextColor ?? this.followTextColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      lightShadowColor: lightShadowColor ?? this.lightShadowColor,
      darkShadowColor: darkShadowColor ?? this.darkShadowColor,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
    );
  }

  Color resolveColor(Brightness brightness, Color? textColor) {
    final base =
        brightness == Brightness.light ? lightShadowColor : darkShadowColor;
    if (followTextColor && textColor != null) {
      return textColor.withAlpha(base.alpha);
    }
    return base;
  }

  factory TextShadowDataModel.fromJson(Map<String, dynamic> json) {
    const c = ColorAhexConverter();
    final rawLight = (json['lightShadowColor'] as String?) ??
        (json['shadowColor'] as String?) ??
        '#FF000000';
    final rawDark = (json['darkShadowColor'] as String?) ?? rawLight;

    Color light = c.fromJson(rawLight);
    Color dark = c.fromJson(rawDark);

    final legacyOpacity = (json['shadowOpacity'] as num?)?.toDouble();
    if (legacyOpacity != null) {
      final a = (255 * legacyOpacity).toInt().clamp(0, 255);
      light = light.withAlpha(a);
      dark = dark.withAlpha(a);
    }

    return TextShadowDataModel(
      shadowEnabled: json['shadowEnabled'] as bool? ?? false,
      followTextColor: json['followTextColor'] as bool? ?? false,
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 10,
      lightShadowColor: light,
      darkShadowColor: dark,
      shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble() ?? 5.0,
      shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble() ?? 5.0,
    );
  }
  Map<String, dynamic> toJson() {
    const c = ColorAhexConverter();
    return {
      'shadowEnabled': shadowEnabled,
      'followTextColor': followTextColor,
      'shadowBlurRadius': shadowBlurRadius,
      'shadowColor': c.toJson(lightShadowColor),
      'lightShadowColor': c.toJson(lightShadowColor),
      'darkShadowColor': c.toJson(darkShadowColor),
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
    };
  }
}

class FontStyleDataModel {
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;

  FontStyleDataModel({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.height,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FontStyleDataModel &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(
        fontFamily,
        fontSize,
        fontWeight,
        height,
      );

  FontStyleDataModel copyWith({
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return FontStyleDataModel(
      height: height ?? this.height,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  /// 使用数字 100–900 进行 `fontWeight` 的 JSON 读写
  factory FontStyleDataModel.fromJson(Map<String, dynamic> json) {
    var family = (json['fontFamily'] as String?) ?? 'System';
    if (family == 'NotoSansSC' || family == 'NotoSans') {
      family = 'NotoSansSC-Regular';
    }
    final size = (json['fontSize'] as num?)?.toDouble() ?? 14.0;
    final weightNum = (json['fontWeight'] as num?)?.toInt();
    final weight =
        TextStyleConfig._parseFontWeight(weightNum) ?? FontWeight.w400;
    return FontStyleDataModel(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: (json['height'] as num?)?.toDouble() ?? 1.4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      // 序列化为 100、200、…、900 的数字
      'fontWeight': fontWeight.value,
      'height': height,
    };
  }
}
