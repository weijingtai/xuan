import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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
  colorful
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
            lightShadowColor: Colors.black,
            darkShadowColor: Colors.white,
            shadowOpacity: 0.7,
            shadowOffsetX: 1,
            shadowOffsetY: 1,
          ),
          fontStyleDataModel: FontStyleDataModel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'NotoSansSC',
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
                .zodiacGanColors
                .map((k, v) => MapEntry(k.name, v))
                .entries),
            pureDarkMapper: Map.fromEntries(allZhiStrList
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
            lightShadowColor: Colors.black,
            darkShadowColor: Colors.white,
            shadowOpacity: 0.7,
            shadowOffsetX: 1,
            shadowOffsetY: 1,
          ),
          fontStyleDataModel: FontStyleDataModel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'NotoSansSC',
          ),
        );
      }();
  static TextStyleConfig defaultConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      colorfulLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      pureDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
      colorfulDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      fontFamily: 'NotoSansSC',
    ),
  );

  static TextStyleConfig defaultOthersConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      colorfulLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      pureDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
      colorfulDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      fontFamily: 'NotoSansSC',
    ),
  );
  static TextStyleConfig defaultOthersTitleConfig = TextStyleConfig(
    colorMapperDataModel: ColorMapperDataModel(
      pureLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      colorfulLightMapper: {
        "乾造": Colors.black87,
        "坤造": Colors.black87,
      },
      pureDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
      colorfulDarkMapper: {
        "乾造": Colors.white,
        "坤造": Colors.white,
      },
    ),
    textShadowDataModel: TextShadowDataModel(),
    fontStyleDataModel: FontStyleDataModel(
      fontWeight: FontWeight.normal,
      fontSize: 8,
      fontFamily: 'NotoSansSC',
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
    Color? textColor;
    if (char != null && colorPreviewMode != null && brightness != null) {
      final mapper =
          colorMapperDataModel.getBy(theme: brightness, mode: colorPreviewMode);
      textColor = mapper[char];
      // print(
      //     '🔍 [toTextStyle] 字符="$char", mode=$colorPreviewMode, brightness=$brightness');
      // print('🔍 [toTextStyle] mapper 包含 ${mapper.length} 个颜色映射');
      // print('🔍 [toTextStyle] 该字符颜色: $textColor');
    }

    return TextStyle(
      fontFamily: fontStyleDataModel.fontFamily,
      fontSize: fontStyleDataModel.fontSize,
      color: textColor,
      fontWeight: fontStyleDataModel.fontWeight,
      shadows: textShadowDataModel.shadowEnabled
          ? [
              Shadow(
                color: textShadowDataModel.followTextColor
                    ? textColor ?? textShadowDataModel.lightShadowColor
                    : textShadowDataModel.lightShadowColor,
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
        lightShadowColor: shadow?.color ?? (style.color ?? Colors.black),
        shadowOpacity: 0.65,
        shadowOffsetX: shadow?.offset.dx ?? 5.0,
        shadowOffsetY: shadow?.offset.dy ?? 5.0,
      ),
      fontStyleDataModel: FontStyleDataModel(
        fontFamily: style.fontFamily ?? 'System',
        fontSize: style.fontSize ?? 14.0,
        fontWeight: style.fontWeight ?? FontWeight.w400,
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
      ),
      textShadowDataModel: TextShadowDataModel(
        shadowEnabled: (shadowColorHex != null) ||
            (shadowOffsetX != null) ||
            (shadowOffsetY != null) ||
            (shadowBlurRadius != null),
        followTextColor: false,
        shadowBlurRadius: shadowBlurRadius ?? 10,
        lightShadowColor: shadowColor,
        shadowOpacity: 0.65,
        shadowOffsetX: shadowOffsetX ?? 5.0,
        shadowOffsetY: shadowOffsetY ?? 5.0,
      ),
      fontStyleDataModel: FontStyleDataModel(
        fontFamily: fontFamily ?? 'System',
        fontSize: fontSize ?? 14.0,
        fontWeight: weight,
      ),
    );
  }

  // ==================== copyWith ====================

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
  });
  Map<String, Color> getBy({
    required Brightness theme,
    required ColorPreviewMode mode,
  }) {
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

  ColorMapperDataModel update({
    required Brightness brightness,
    required ColorPreviewMode mode,
    required String char,
    required Color color,
  }) {
    // 根据 theme 和 mode 定位对应的 mapper
    final mapper = getBy(theme: brightness, mode: mode);
    // 创建新的 mapper 副本并更新指定 char 的颜色
    final updatedMapper = Map<String, Color>.from(mapper);
    updatedMapper[char] = color;

    // 根据 brightness 和 mode 决定返回哪个字段的新值
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
    );
  }

  factory ColorMapperDataModel.fromJson(Map<String, dynamic> json) {
    final pureLight = json['pureLightMapper'] as Map<String, dynamic>?;
    final colorfulLight = json['colorfulLightMapper'] as Map<String, dynamic>?;
    final pureDark = json['pureDarkMapper'] as Map<String, dynamic>?;
    final colorfulDark = json['colorfulDarkMapper'] as Map<String, dynamic>?;
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
    );
  }
  Map<String, dynamic> toJson() => {
        'pureLightMapper': ColorAhexConverter.mapToJson(pureLightMapper),
        'colorfulLightMapper':
            ColorAhexConverter.mapToJson(colorfulLightMapper),
        'pureDarkMapper': ColorAhexConverter.mapToJson(pureDarkMapper),
        'colorfulDarkMapper': ColorAhexConverter.mapToJson(colorfulDarkMapper),
      };
}

class TextShadowDataModel {
  bool shadowEnabled = false;
  bool followTextColor = false;
  double shadowBlurRadius = 10;
  Color lightShadowColor = Colors.black;
  Color darkShadowColor = Colors.white;
  double shadowOpacity = 0.65;
  double shadowOffsetX = 5.0; // 默认 X 轴偏移
  double shadowOffsetY = 5.0; // 默认 Y 轴偏移
  TextShadowDataModel({
    this.shadowEnabled = false,
    this.followTextColor = false,
    this.shadowBlurRadius = 10,
    this.lightShadowColor = Colors.black,
    this.darkShadowColor = Colors.white,
    this.shadowOpacity = 0.65,
    this.shadowOffsetX = 5.0,
    this.shadowOffsetY = 5.0,
  });
  TextShadowDataModel copyWith({
    bool? shadowEnabled,
    bool? followTextColor,
    double? shadowBlurRadius,
    Color? lightShadowColor,
    Color? darkShadowColor,
    double? shadowOpacity,
    double? shadowOffsetX,
    double? shadowOffsetY,
  }) {
    return TextShadowDataModel(
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      followTextColor: followTextColor ?? this.followTextColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      lightShadowColor: lightShadowColor ?? this.lightShadowColor,
      darkShadowColor: darkShadowColor ?? this.darkShadowColor,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
    );
  }

  factory TextShadowDataModel.fromJson(Map<String, dynamic> json) {
    const c = ColorAhexConverter();
    return TextShadowDataModel(
      shadowEnabled: json['shadowEnabled'] as bool? ?? false,
      followTextColor: json['followTextColor'] as bool? ?? false,
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 10,
      lightShadowColor:
          c.fromJson((json['shadowColor'] as String?) ?? '#FF000000'),
      shadowOpacity: (json['shadowOpacity'] as num?)?.toDouble() ?? 0.65,
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
      'shadowOpacity': shadowOpacity,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
    };
  }
}

class FontStyleDataModel {
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;

  FontStyleDataModel({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
  });

  FontStyleDataModel copyWith({
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return FontStyleDataModel(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  /// 使用数字 100–900 进行 `fontWeight` 的 JSON 读写
  factory FontStyleDataModel.fromJson(Map<String, dynamic> json) {
    final family = (json['fontFamily'] as String?) ?? 'System';
    final size = (json['fontSize'] as num?)?.toDouble() ?? 14.0;
    final weightNum = (json['fontWeight'] as num?)?.toInt();
    final weight =
        TextStyleConfig._parseFontWeight(weightNum) ?? FontWeight.w400;
    return FontStyleDataModel(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      // 序列化为 100、200、…、900 的数字
      'fontWeight': fontWeight.value,
    };
  }
}
