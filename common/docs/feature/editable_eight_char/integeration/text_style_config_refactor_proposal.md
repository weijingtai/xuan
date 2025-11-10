# TextStyleConfig 重构方案详细设计

**创建日期**: 2025-11-10
**状态**: 待讨论
**迁移周期**: 1-2 周（激进模式）

---

## 📋 执行摘要

### 核心问题
当前架构通过 13 个离散参数传递字体样式，导致：
- 历史上 3 次属性丢失事故（fontWeight 两次，shadow 字段 4 个）
- 80% 代码重复（Color/FontWeight 转换器各 5 份实现）
- 扩展成本高（新增 3 个属性需要修改 60+ 处代码）

### 解决方案
引入 `TextStyleConfig` 数据类，封装所有字体样式属性：
- **基础属性**：fontFamily, fontSize, color, fontWeight
- **扩展属性**：shadows, letterSpacing, wordSpacing, height, decoration 等
- **自动序列化**：使用 json_serializable 生成 JSON 转换代码
- **类型安全**：所有类型转换在 TextStyleConfig 内部完成

### 预期收益
- ✅ 参数数量：13 → 1（92% 减少）
- ✅ 代码重复：80% → 0%
- ✅ 扩展成本：60+ 行 → 10 行（83% 减少）
- ✅ 类型安全：编译时检查，杜绝属性丢失
- ✅ 向后兼容：自动处理旧数据格式

---

## 🎯 方案对比：激进 vs 渐进迁移

### 用户需求分析
根据问卷调查结果：
- ✅ 序列化方式：json_serializable
- ✅ 属性范围：基础 + 扩展 + 当前已支持
- ✅ 迁移节奏：激进迁移（1-2 周）
- ✅ 讨论方式：先讨论细节

### 方案 A：激进完全替换（推荐）

**时间线**: 1-2 周

**Week 1 (Day 1-3): 准备阶段**
- Day 1: 创建 TextStyleConfig 类 + 单元测试（完整覆盖）
- Day 2: 更新 RowConfig 模型（添加 textStyleConfig 字段）
- Day 3: 实现向后兼容的 JSON 解析逻辑

**Week 1 (Day 4-5): 核心迁移**
- Day 4: 更新 ViewModel（updateRowStyle 简化为单参数）
- Day 5: 更新 Sidebar UI（使用 TextStyleConfig）

**Week 2 (Day 1-2): EditorWorkspace 重构**
- Day 1: 简化 groupTextStyles 构建逻辑（已完成）
  - EditorWorkspace 读取 `RowConfig.textStyleConfig.toTextStyle()` 优先构建 `groupTextStyles`，仅在缺失时回退旧字段（fontFamily/fontSize/textColorHex/fontWeight/shadows）。
  - 验收说明：分组样式在存在 `TextStyleConfig` 时优先生效，全局设置仅在分组未设定时覆盖。
- Day 2: 移除旧的转换辅助方法（保留必要最小回退路径，待最终清理）

**Week 2 (Day 3-5): 验证与清理**
- Day 3-4: 完整回归测试（手动 + 自动化）
- Day 5: 清理遗留代码，更新文档

### 全局字体路径核查与对齐（新增并已完成）
- 目标：对齐“主题侧栏 → ViewModel → Workspace → V3 渲染”的全局字体链路与优先级。
- 结果：
  - ThemeSidebar：`_onThemeChanged` 将 `TypographySection.globalFont*` 同步到 ViewModel。
  - ViewModel：`updateGlobalFontFamily/Size/Color` 更新 `cardStyle`，新增函数注释明确优先级与行为。
  - Workspace：将 `cardStyle.globalFont*` 绑定到 `EditableFourZhuCardV3`，`groupTextStyles` 由 `TextStyleConfig` 优先构建。
  - V3：`_resolveTextStyle` 合并顺序为“分组默认 → 全局设置 → 分组覆写 → 入参临时覆写”，彩色模式下对天干/地支抑制全局颜色。
- 验收：演示页与编辑页行为一致，分组优先覆盖，全局设置在未配置分组时生效。

**风险等级**: 🟡 中等
- 单次大规模修改，影响面广
- 需要完善的测试覆盖

**优势**:
- ✅ 一次性彻底解决问题
- ✅ 避免长期维护双系统
- ✅ 代码简洁，无历史包袱

**劣势**:
- ⚠️ 回滚复杂度高（需要整体回退）
- ⚠️ 测试压力集中

---

### 方案 B：渐进混合迁移（保守）

**时间线**: 4-6 周

**Week 1-2: TextStyleConfig 基础**
- Week 1: 创建 TextStyleConfig + 测试
- Week 2: RowConfig 添加可选 textStyleConfig 字段（保留旧字段）

**Week 3-4: 双系统并存**
- Week 3: ViewModel 同时支持新旧 API
- Week 4: Sidebar 迁移到新 API（UI 层）

**Week 5-6: 清理阶段**
- Week 5: EditorWorkspace 迁移
- Week 6: 移除旧字段和逻辑

**风险等级**: 🟢 低
- 渐进迁移，每步可独立验证
- 出问题可快速回退单个步骤

**优势**:
- ✅ 回滚容易（每步独立）
- ✅ 可逐步验证功能

**劣势**:
- ❌ 时间周期长（4-6 周）
- ❌ 长期维护双系统成本高
- ❌ 代码冗余（新旧逻辑并存）

---

### 🎯 最终推荐：方案 A（激进完全替换）+ 增强安全措施

**理由**:
1. **符合用户意愿**: 明确选择"激进迁移（1-2 周）"
2. **收益更高**: 一次性解决所有问题，无历史包袱
3. **风险可控**: 通过增强的安全措施降低风险

**增强安全措施**:
1. **完整单元测试**: TextStyleConfig 覆盖率 100%
2. **数据迁移脚本**: 自动转换旧数据 + 验证
3. **Feature Flag**: 代码中保留临时开关，便于快速回退
4. **并行测试环境**: 新旧版本并行测试 3 天
5. **分支策略**: 独立 feature branch，主分支可随时回退

---

## 📐 TextStyleConfig 详细设计

### 完整类定义

```dart
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
    this.fontWeightValue,  // 100-900

    // 阴影属性（当前已支持）
    this.shadowColorHex,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,

    // 扩展属性（未来支持）
    this.letterSpacing,
    this.wordSpacing,
    this.height,          // 行高倍数
    this.decorationStyle, // 'none', 'underline', 'overline', 'lineThrough'
    this.decorationColorHex,
    this.decorationThickness,
    this.fontStyle,       // 'normal', 'italic'
    this.backgroundColor,
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
  factory TextStyleConfig.fromTextStyle(TextStyle style) {
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
      case 100: return FontWeight.w100;
      case 200: return FontWeight.w200;
      case 300: return FontWeight.w300;
      case 400: return FontWeight.w400;
      case 500: return FontWeight.w500;
      case 600: return FontWeight.w600;
      case 700: return FontWeight.w700;
      case 800: return FontWeight.w800;
      case 900: return FontWeight.w900;
      default: return FontWeight.w400;
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
      case 'underline': return TextDecoration.underline;
      case 'overline': return TextDecoration.overline;
      case 'lineThrough': return TextDecoration.lineThrough;
      case 'none': return TextDecoration.none;
      default: return null;
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
      case 'italic': return FontStyle.italic;
      case 'normal': return FontStyle.normal;
      default: return null;
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
```

---

## 🔄 RowConfig 集成策略

### 方案 A：完全替换（推荐用于激进迁移）

```dart
class RowConfig {
  const RowConfig({
    required this.type,
    required this.isVisible,
    required this.isTitleVisible,
    this.textAlign,
    this.padding,
    this.borderType,
    this.borderColorHex,
    // 🔥 新增：统一字体样式配置
    this.textStyleConfig,
  });

  final RowType type;
  final bool isVisible;
  final bool isTitleVisible;
  final RowTextAlign? textAlign;
  final double? padding;
  final BorderType? borderType;
  final String? borderColorHex;

  /// 文本样式配置（封装所有字体相关属性）
  final TextStyleConfig? textStyleConfig;

  // 移除旧的离散字段：
  // ❌ fontFamily, fontSize, textColorHex, fontWeight
  // ❌ shadowColorHex, shadowOffsetX, shadowOffsetY, shadowBlurRadius

  RowConfig copyWith({
    RowType? type,
    bool? isVisible,
    bool? isTitleVisible,
    RowTextAlign? textAlign,
    double? padding,
    BorderType? borderType,
    String? borderColorHex,
    TextStyleConfig? textStyleConfig,
  }) {
    return RowConfig(
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      isTitleVisible: isTitleVisible ?? this.isTitleVisible,
      textAlign: textAlign ?? this.textAlign,
      padding: padding ?? this.padding,
      borderType: borderType ?? this.borderType,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      textStyleConfig: textStyleConfig ?? this.textStyleConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isVisible': isVisible,
      'isTitleVisible': isTitleVisible,
      'textAlign': textAlign?.name,
      'padding': padding,
      'borderType': borderType?.name,
      'borderColorHex': borderColorHex,
      'textStyleConfig': textStyleConfig?.toJson(),
    };
  }

  factory RowConfig.fromJson(Map<String, dynamic> json) {
    // 🔧 向后兼容逻辑：优先使用新字段，回退到旧字段
    TextStyleConfig? styleConfig;

    if (json.containsKey('textStyleConfig') && json['textStyleConfig'] != null) {
      // 新格式：直接解析 textStyleConfig
      styleConfig = TextStyleConfig.fromJson(
        json['textStyleConfig'] as Map<String, dynamic>
      );
    } else {
      // 旧格式：从离散字段构造 TextStyleConfig
      final hasLegacyFields = json.containsKey('fontFamily') ||
                              json.containsKey('fontSize') ||
                              json.containsKey('textColorHex') ||
                              json.containsKey('fontWeight') ||
                              json.containsKey('shadowColorHex');

      if (hasLegacyFields) {
        styleConfig = TextStyleConfig.fromLegacyRowConfig(
          fontFamily: json['fontFamily'] as String?,
          fontSize: (json['fontSize'] as num?)?.toDouble(),
          textColorHex: json['textColorHex'] as String?,
          fontWeight: json['fontWeight'] as String?,
          shadowColorHex: json['shadowColorHex'] as String?,
          shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble(),
          shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble(),
          shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble(),
        );
      }
    }

    return RowConfig(
      type: RowType.values.firstWhere(
        (element) => element.name == (json['type'] as String?),
        orElse: () => RowType.heavenlyStem,
      ),
      isVisible: json['isVisible'] as bool? ?? true,
      isTitleVisible: json['isTitleVisible'] as bool? ?? true,
      textAlign: json['textAlign'] != null
          ? RowTextAlign.values.firstWhere(
              (e) => e.name == json['textAlign'],
              orElse: () => RowTextAlign.left,
            )
          : null,
      padding: (json['padding'] as num?)?.toDouble(),
      borderType: json['borderType'] != null
          ? BorderType.values.firstWhere(
              (e) => e.name == json['borderType'],
              orElse: () => BorderType.solid,
            )
          : null,
      borderColorHex: json['borderColorHex'] as String?,
      textStyleConfig: styleConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RowConfig &&
        other.type == type &&
        other.isVisible == isVisible &&
        other.isTitleVisible == isTitleVisible &&
        other.textAlign == textAlign &&
        other.padding == padding &&
        other.borderType == borderType &&
        other.borderColorHex == borderColorHex &&
        other.textStyleConfig == textStyleConfig;
  }

  @override
  int get hashCode => Object.hash(
    type,
    isVisible,
    isTitleVisible,
    textAlign,
    padding,
    borderType,
    borderColorHex,
    textStyleConfig,
  );
}
```

**优势**:
- ✅ 代码简洁（字段数量从 18 减少到 8）
- ✅ 类型安全（所有样式属性集中管理）
- ✅ 扩展容易（新属性只需修改 TextStyleConfig）
- ✅ 向后兼容（fromJson 自动处理旧数据）

**劣势**:
- ⚠️ 需要数据迁移（首次加载时自动转换）
- ⚠️ JSON 格式变化（但自动兼容旧格式）

---

## 🛠️ ViewModel 简化

### 当前代码（13 个参数）

```dart
void updateRowStyle(
  RowType type, {
  String? fontFamily,
  double? fontSize,
  String? colorHex,
  String? fontWeight,
  RowTextAlign? textAlign,
  double? padding,
  BorderType? borderType,
  String? borderColorHex,
  String? shadowColorHex,
  double? shadowOffsetX,
  double? shadowOffsetY,
  double? shadowBlurRadius,
}) {
  final template = _currentTemplate;
  if (template == null) return;
  final updated = template.rowConfigs
      .map((config) => config.type == type
          ? config.copyWith(
              fontFamily: fontFamily ?? config.fontFamily,
              fontSize: fontSize ?? config.fontSize,
              textColorHex: colorHex ?? config.textColorHex,
              fontWeight: fontWeight ?? config.fontWeight,
              textAlign: textAlign ?? config.textAlign,
              padding: padding ?? config.padding,
              borderType: borderType ?? config.borderType,
              borderColorHex: borderColorHex ?? config.borderColorHex,
              shadowColorHex: shadowColorHex ?? config.shadowColorHex,
              shadowOffsetX: shadowOffsetX ?? config.shadowOffsetX,
              shadowOffsetY: shadowOffsetY ?? config.shadowOffsetY,
              shadowBlurRadius: shadowBlurRadius ?? config.shadowBlurRadius,
            )
          : config)
      .toList(growable: false);
  _applyCurrentTemplate(template.copyWith(rowConfigs: updated));
}
```

**问题**:
- ❌ 13 个参数（超过最佳实践 7 个的 86%）
- ❌ 每个参数需要手动空合并（?? 操作符）
- ❌ 添加新属性需要修改 3 处（参数列表、copyWith、空合并）

---

### 重构后代码（1 个参数）

```dart
void updateRowStyle(
  RowType type, {
  TextStyleConfig? textStyleConfig,
  RowTextAlign? textAlign,
  double? padding,
  BorderType? borderType,
  String? borderColorHex,
}) {
  final template = _currentTemplate;
  if (template == null) return;

  final updated = template.rowConfigs
      .map((config) {
        if (config.type != type) return config;

        // 🔥 智能合并：如果提供了新样式，与旧样式合并
        TextStyleConfig? mergedStyle = config.textStyleConfig;
        if (textStyleConfig != null) {
          if (mergedStyle != null) {
            // 合并新旧样式（新样式覆盖旧样式的非 null 字段）
            mergedStyle = TextStyleConfig(
              fontFamily: textStyleConfig.fontFamily ?? mergedStyle.fontFamily,
              fontSize: textStyleConfig.fontSize ?? mergedStyle.fontSize,
              colorHex: textStyleConfig.colorHex ?? mergedStyle.colorHex,
              fontWeightValue: textStyleConfig.fontWeightValue ?? mergedStyle.fontWeightValue,
              shadowColorHex: textStyleConfig.shadowColorHex ?? mergedStyle.shadowColorHex,
              shadowOffsetX: textStyleConfig.shadowOffsetX ?? mergedStyle.shadowOffsetX,
              shadowOffsetY: textStyleConfig.shadowOffsetY ?? mergedStyle.shadowOffsetY,
              shadowBlurRadius: textStyleConfig.shadowBlurRadius ?? mergedStyle.shadowBlurRadius,
              // 扩展属性同样自动处理
              letterSpacing: textStyleConfig.letterSpacing ?? mergedStyle.letterSpacing,
              wordSpacing: textStyleConfig.wordSpacing ?? mergedStyle.wordSpacing,
              height: textStyleConfig.height ?? mergedStyle.height,
              decorationStyle: textStyleConfig.decorationStyle ?? mergedStyle.decorationStyle,
              decorationColorHex: textStyleConfig.decorationColorHex ?? mergedStyle.decorationColorHex,
              decorationThickness: textStyleConfig.decorationThickness ?? mergedStyle.decorationThickness,
              fontStyle: textStyleConfig.fontStyle ?? mergedStyle.fontStyle,
              backgroundColor: textStyleConfig.backgroundColor ?? mergedStyle.backgroundColor,
            );
          } else {
            mergedStyle = textStyleConfig;
          }
        }

        return config.copyWith(
          textStyleConfig: mergedStyle,
          textAlign: textAlign ?? config.textAlign,
          padding: padding ?? config.padding,
          borderType: borderType ?? config.borderType,
          borderColorHex: borderColorHex ?? config.borderColorHex,
        );
      })
      .toList(growable: false);

  _applyCurrentTemplate(template.copyWith(rowConfigs: updated));
}
```

**改进**:
- ✅ 参数数量：13 → 5（62% 减少）
- ✅ 字体相关参数统一为 1 个对象
- ✅ 智能合并逻辑（部分更新支持）
- ✅ 未来扩展：新增属性无需修改此方法

**进一步简化版（如果不需要部分更新）**:

```dart
void updateRowStyle(
  RowType type, {
  TextStyleConfig? textStyleConfig,
  RowTextAlign? textAlign,
  double? padding,
  BorderType? borderType,
  String? borderColorHex,
}) {
  final template = _currentTemplate;
  if (template == null) return;

  final updated = template.rowConfigs
      .map((config) => config.type == type
          ? config.copyWith(
              textStyleConfig: textStyleConfig ?? config.textStyleConfig,
              textAlign: textAlign ?? config.textAlign,
              padding: padding ?? config.padding,
              borderType: borderType ?? config.borderType,
              borderColorHex: borderColorHex ?? config.borderColorHex,
            )
          : config)
      .toList(growable: false);

  _applyCurrentTemplate(template.copyWith(rowConfigs: updated));
}
```

**代码行数**: 30 行 → 15 行（50% 减少）

---

## 🎨 Sidebar UI 简化

### 当前代码（复杂的属性提取）

```dart
RowConfig _applyTextStyleToConfig(RowConfig config, TextStyle style) {
  // 提取阴影信息（如果存在）
  String? shadowHex;
  double? shadowX, shadowY, shadowBlur;
  if (style.shadows != null && style.shadows!.isNotEmpty) {
    final shadow = style.shadows!.first;
    shadowHex = _colorToHex(shadow.color);
    shadowX = shadow.offset.dx;
    shadowY = shadow.offset.dy;
    shadowBlur = shadow.blurRadius;
  }

  return config.copyWith(
    fontFamily: style.fontFamily,
    fontSize: style.fontSize,
    textColorHex: _colorToHex(style.color),
    fontWeight: _fontWeightToString(style.fontWeight),
    // 阴影字段
    shadowColorHex: shadowHex,
    shadowOffsetX: shadowX,
    shadowOffsetY: shadowY,
    shadowBlurRadius: shadowBlur,
  );
}

// 需要配套的转换方法（80% 代码重复）
String? _colorToHex(Color? c) { /* 实现 */ }
String? _fontWeightToString(FontWeight? weight) { /* 实现 */ }
```

---

### 重构后代码（一行完成）

```dart
RowConfig _applyTextStyleToConfig(RowConfig config, TextStyle style) {
  return config.copyWith(
    textStyleConfig: TextStyleConfig.fromTextStyle(style),
  );
}

// ✅ 不再需要转换方法（已内置在 TextStyleConfig 中）
```

**改进**:
- ✅ 代码行数：30 行 → 3 行（90% 减少）
- ✅ 移除重复的转换逻辑
- ✅ 类型安全（编译时检查）
- ✅ 自动支持所有属性（包括未来新增的）

---

### Sidebar 回调简化

**当前代码**:
```dart
onInlineSave: (updatedConfig) {
  viewModel.updateRowStyle(
    updatedConfig.type,
    fontFamily: updatedConfig.fontFamily,
    fontSize: updatedConfig.fontSize,
    colorHex: updatedConfig.textColorHex,
    fontWeight: updatedConfig.fontWeight,
    textAlign: updatedConfig.textAlign,
    padding: updatedConfig.padding,
    borderType: updatedConfig.borderType,
    borderColorHex: updatedConfig.borderColorHex,
    // 阴影参数
    shadowColorHex: updatedConfig.shadowColorHex,
    shadowOffsetX: updatedConfig.shadowOffsetX,
    shadowOffsetY: updatedConfig.shadowOffsetY,
    shadowBlurRadius: updatedConfig.shadowBlurRadius,
  );
},
```

**重构后**:
```dart
onInlineSave: (updatedConfig) {
  viewModel.updateRowStyle(
    updatedConfig.type,
    textStyleConfig: updatedConfig.textStyleConfig,
    textAlign: updatedConfig.textAlign,
    padding: updatedConfig.padding,
    borderType: updatedConfig.borderType,
    borderColorHex: updatedConfig.borderColorHex,
  );
},
```

**改进**: 13 行 → 6 行（54% 减少）

---

## 🏗️ EditorWorkspace 简化

### 当前代码（复杂的 groupTextStyles 构建）

```dart
final groupStyles = <TextGroup, TextStyle>{};
for (final config in configs) {
  final textGroup = _rowTypeToTextGroup(config.type);
  if (textGroup != null) {
    groupStyles[textGroup] = TextStyle(
      fontFamily: config.fontFamily,
      fontSize: config.fontSize,
      color: _parseHexColor(config.textColorHex),
      fontWeight: _parseFontWeight(config.fontWeight),
      shadows: _buildShadows(config),
    );
  }
}
_groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;

// 需要配套的辅助方法（120+ 行）
Color? _parseHexColor(String? hex) { /* 70 行实现 */ }
FontWeight? _parseFontWeight(String? str) { /* 30 行实现 */ }
List<Shadow>? _buildShadows(RowConfig config) { /* 20 行实现 */ }
```

---

### 重构后代码（一行完成）

```dart
final groupStyles = <TextGroup, TextStyle>{};
for (final config in configs) {
  final textGroup = _rowTypeToTextGroup(config.type);
  if (textGroup != null && config.textStyleConfig != null) {
    groupStyles[textGroup] = config.textStyleConfig!.toTextStyle();
  }
}
_groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;

// ✅ 移除所有辅助方法（已内置在 TextStyleConfig 中）
```

**改进**:
- ✅ 核心逻辑：11 行 → 5 行（55% 减少）
- ✅ 移除辅助方法：120 行 → 0 行（100% 减少）
- ✅ 总代码量：131 行 → 5 行（96% 减少）

---

## 📊 代码影响对比

### 当前架构 vs 重构后

| 指标 | 当前 | 重构后 | 改进 |
|------|------|--------|------|
| **ViewModel 参数数量** | 13 个 | 1 个（textStyleConfig）+ 4 个（其他） | **-62%** |
| **Sidebar 转换代码** | 30 行 | 3 行 | **-90%** |
| **EditorWorkspace 构建代码** | 131 行 | 5 行 | **-96%** |
| **Color 转换器重复** | 5 份 | 1 份（内置） | **-80%** |
| **FontWeight 转换器重复** | 5 份 | 1 份（内置） | **-80%** |
| **新增 3 属性的修改点** | 60+ 处 | 10 处 | **-83%** |
| **RowConfig 字段数** | 18 个 | 8 个 | **-56%** |

### 扩展性对比：新增 3 个属性（letterSpacing, height, decoration）

**当前架构需要修改**:
1. RowConfig 添加 3 个字段（3 处：字段声明、copyWith、toJson/fromJson）
2. updateRowStyle 添加 3 个参数（3 处：参数列表、copyWith 调用、空合并）
3. Sidebar 提取 3 个属性（3 处：_applyTextStyleToConfig、onInlineSave、辅助方法）
4. EditorWorkspace 构建 3 个属性（3 处：groupTextStyles 构建）
5. 每个转换器可能需要新的辅助方法（3 个新方法）

**总计**: **60+ 行代码修改**，跨越 **6 个文件**

---

**重构后需要修改**:
1. TextStyleConfig 添加 3 个字段（3 处：字段声明、copyWith、toJson/fromJson 自动生成）
2. toTextStyle 方法添加 3 个属性映射（3 行）
3. fromTextStyle 方法添加 3 个属性提取（3 行）

**总计**: **10 行代码修改**，仅在 **1 个文件**（text_style_config.dart）

**改进**: 60+ 行 → 10 行（**83% 减少**），6 个文件 → 1 个文件

---

## 🧪 测试策略

### 单元测试（TextStyleConfig）

```dart
void main() {
  group('TextStyleConfig', () {
    test('should convert from TextStyle correctly', () {
      final textStyle = TextStyle(
        fontFamily: 'NotoSansSC-Regular',
        fontSize: 16,
        color: Colors.red,
        fontWeight: FontWeight.w700,
        shadows: [Shadow(color: Colors.grey, offset: Offset(2, 2), blurRadius: 4)],
      );

      final config = TextStyleConfig.fromTextStyle(textStyle);

      expect(config.fontFamily, 'NotoSansSC-Regular');
      expect(config.fontSize, 16);
      expect(config.colorHex, '#FFFF0000');
      expect(config.fontWeightValue, 700);
      expect(config.shadowColorHex, '#FF9E9E9E');
      expect(config.shadowOffsetX, 2);
      expect(config.shadowOffsetY, 2);
      expect(config.shadowBlurRadius, 4);
    });

    test('should convert to TextStyle correctly', () {
      final config = TextStyleConfig(
        fontFamily: 'PingFang SC',
        fontSize: 18,
        colorHex: '#FF0000FF',
        fontWeightValue: 600,
        shadowColorHex: '#80000000',
        shadowOffsetX: 1,
        shadowOffsetY: 1,
        shadowBlurRadius: 2,
      );

      final textStyle = config.toTextStyle();

      expect(textStyle.fontFamily, 'PingFang SC');
      expect(textStyle.fontSize, 18);
      expect(textStyle.color, Color(0xFF0000FF));
      expect(textStyle.fontWeight, FontWeight.w600);
      expect(textStyle.shadows?.length, 1);
      expect(textStyle.shadows?.first.color, Color(0x80000000));
    });

    test('should handle legacy RowConfig fields', () {
      final config = TextStyleConfig.fromLegacyRowConfig(
        fontFamily: '楷体',
        fontSize: 20,
        textColorHex: '#FFFF0000',
        fontWeight: 'w700',
        shadowColorHex: '#FF808080',
        shadowOffsetX: 2,
        shadowOffsetY: 2,
        shadowBlurRadius: 4,
      );

      expect(config.fontFamily, '楷体');
      expect(config.fontSize, 20);
      expect(config.colorHex, '#FFFF0000');
      expect(config.fontWeightValue, 700);
      expect(config.shadowColorHex, '#FF808080');
    });

    test('should serialize to JSON correctly', () {
      final config = TextStyleConfig(
        fontFamily: 'NotoSansSC-Regular',
        fontSize: 14,
        colorHex: '#FF000000',
        fontWeightValue: 400,
      );

      final json = config.toJson();

      expect(json['fontFamily'], 'NotoSansSC-Regular');
      expect(json['fontSize'], 14);
      expect(json['colorHex'], '#FF000000');
      expect(json['fontWeightValue'], 400);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'fontFamily': 'Arial',
        'fontSize': 12.0,
        'colorHex': '#FF333333',
        'fontWeightValue': 500,
        'shadowColorHex': '#FF666666',
        'shadowOffsetX': 1.0,
        'shadowOffsetY': 1.0,
        'shadowBlurRadius': 3.0,
      };

      final config = TextStyleConfig.fromJson(json);

      expect(config.fontFamily, 'Arial');
      expect(config.fontSize, 12.0);
      expect(config.colorHex, '#FF333333');
      expect(config.fontWeightValue, 500);
    });

    test('should handle null values gracefully', () {
      final config = TextStyleConfig();
      final textStyle = config.toTextStyle();

      expect(textStyle.fontFamily, isNull);
      expect(textStyle.fontSize, isNull);
      expect(textStyle.color, isNull);
      expect(textStyle.fontWeight, isNull);
      expect(textStyle.shadows, isNull);
    });
  });
}
```

**覆盖率目标**: 100%

---

### 集成测试（向后兼容性）

```dart
void main() {
  group('RowConfig backward compatibility', () {
    test('should parse legacy JSON format', () {
      final legacyJson = {
        'type': 'heavenlyStem',
        'isVisible': true,
        'isTitleVisible': true,
        'fontFamily': '楷体',
        'fontSize': 20.0,
        'textColorHex': '#FFFF0000',
        'fontWeight': 'w700',
        'shadowColorHex': '#FF808080',
        'shadowOffsetX': 2.0,
        'shadowOffsetY': 2.0,
        'shadowBlurRadius': 4.0,
      };

      final config = RowConfig.fromJson(legacyJson);

      expect(config.textStyleConfig, isNotNull);
      expect(config.textStyleConfig!.fontFamily, '楷体');
      expect(config.textStyleConfig!.fontSize, 20.0);
      expect(config.textStyleConfig!.colorHex, '#FFFF0000');
      expect(config.textStyleConfig!.fontWeightValue, 700);
      expect(config.textStyleConfig!.shadowColorHex, '#FF808080');
    });

    test('should parse new JSON format', () {
      final newJson = {
        'type': 'earthlyBranch',
        'isVisible': true,
        'isTitleVisible': true,
        'textStyleConfig': {
          'fontFamily': 'PingFang SC',
          'fontSize': 18.0,
          'colorHex': '#FF0000FF',
          'fontWeightValue': 600,
        },
      };

      final config = RowConfig.fromJson(newJson);

      expect(config.textStyleConfig, isNotNull);
      expect(config.textStyleConfig!.fontFamily, 'PingFang SC');
      expect(config.textStyleConfig!.fontSize, 18.0);
    });

    test('should handle mixed format (prefer new)', () {
      final mixedJson = {
        'type': 'naYin',
        'isVisible': true,
        'isTitleVisible': true,
        // 新格式（优先）
        'textStyleConfig': {
          'fontFamily': 'NewFont',
          'fontSize': 16.0,
        },
        // 旧格式（应被忽略）
        'fontFamily': 'OldFont',
        'fontSize': 14.0,
      };

      final config = RowConfig.fromJson(mixedJson);

      expect(config.textStyleConfig!.fontFamily, 'NewFont');
      expect(config.textStyleConfig!.fontSize, 16.0);
    });
  });
}
```

---

### 手动测试清单

**测试 1: 新建模板（无历史数据）**
- [ ] 创建新模板
- [ ] 编辑天干行样式（字体、颜色、粗细、阴影）
- [ ] 保存模板
- [ ] 重新加载
- [ ] 验证样式正确显示

**测试 2: 旧模板迁移（有历史数据）**
- [ ] 准备旧格式 JSON 数据
- [ ] 启动应用（自动迁移）
- [ ] 验证所有旧样式正确加载
- [ ] 编辑样式并保存
- [ ] 验证保存为新格式

**测试 3: 新增扩展属性**
- [ ] 编辑行样式，添加 letterSpacing
- [ ] 保存并验证显示效果
- [ ] 重新加载，验证持久化成功

**测试 4: 混合格式兼容性**
- [ ] 准备混合格式数据（部分新、部分旧）
- [ ] 加载并验证所有行样式
- [ ] 编辑并保存
- [ ] 验证统一为新格式

**测试 5: 回滚测试**
- [ ] 迁移到新版本
- [ ] 回滚到旧代码分支
- [ ] 验证旧格式数据仍可读取（如果保留旧字段）

---

## ⚙️ 迁移实施计划（激进模式，1-2 周）

### Week 1: 核心重构

#### Day 1: TextStyleConfig 创建 + 测试
**上午**:
- [x] 创建 `lib/models/text_style_config.dart`
- [x] 实现完整类定义（所有字段、方法）
- [x] 添加 `part 'text_style_config.g.dart';`

**下午**:
- [x] 运行 `dart run build_runner build --delete-conflicting-outputs`
- [ ] 编写完整单元测试（覆盖率 100%）
- [ ] 验证所有测试通过

**验收标准**:
- ✅ TextStyleConfig 所有方法测试通过
- ✅ JSON 序列化/反序列化正确
- ✅ 与 TextStyle 双向转换无损

---

#### Day 2: RowConfig 模型更新
**上午**:
- [x] 修改 `lib/models/layout_template.dart`
- [x] 添加 `textStyleConfig` 字段
- [x] **保留旧字段**（作为临时 Feature Flag）
- [x] 实现向后兼容的 `fromJson` 逻辑

**下午**:
- [ ] 编写 RowConfig 集成测试
- [ ] 测试旧格式 → 新格式迁移
- [ ] 测试新格式直接解析
- [ ] 验证混合格式处理

**验收标准**:
- ✅ 旧 JSON 数据可正确加载
- ✅ 新 JSON 数据优先使用 textStyleConfig
- ✅ 所有测试通过

---

#### Day 3: ViewModel 层重构
**上午**:
- [x] 修改 `lib/viewmodels/four_zhu_editor_view_model.dart`
- [x] 简化 `updateRowStyle` 方法签名
- [x] 实现智能合并逻辑

**下午**:
- [ ] 添加 ViewModel 单元测试
- [ ] 测试部分更新（partial update）
- [ ] 测试完整替换（full replace）

**验收标准**:
- ✅ updateRowStyle 参数数量 ≤ 5
- ✅ 智能合并逻辑正确
- ✅ 所有测试通过

---

#### Day 4-5: UI 层重构
**Day 4 上午**: Sidebar
- [x] 修改 `lib/widgets/editor_sidebar_v2.dart`
- [x] 简化 `_applyTextStyleToConfig` 方法
- [x] 更新 `onInlineSave` 回调

**Day 4 下午**: Sidebar 测试
- [ ] Widget 测试（可选）
- [ ] 手动测试编辑流程

**Day 5 上午**: EditorWorkspace
- [x] 修改 `lib/widgets/four_zhu_card_editor_page/editor_workspace.dart`
- [x] 简化 `_applyViewModelToNotifiers` 方法
- [x] 移除旧的辅助方法（已移除 `_parseFontWeight`, `_buildShadows`；保留 `_parseHexColor` 供全局颜色/分隔线解析使用）

**Day 5 下午**: 集成测试
- [ ] 端到端测试：Sidebar → ViewModel → EditorWorkspace → V3Card
- [ ] 验证样式正确传递和显示

**验收标准**:
- ✅ Sidebar 编辑功能正常
- ✅ EditorWorkspace 样式构建正确
- ✅ V3Card 显示效果一致

---

### Week 2: 验证与清理

#### Day 1-2: 完整回归测试
**测试矩阵**:

| 场景 | 数据格式 | 操作 | 预期结果 |
|------|---------|------|---------|
| 1 | 旧格式 JSON | 加载 | 自动迁移到新格式 ✅ |
| 2 | 新格式 JSON | 加载 | 直接使用 textStyleConfig ✅ |
| 3 | 混合格式 | 加载 | 新格式优先 ✅ |
| 4 | 空样式 | 加载 | 使用默认值 ✅ |
| 5 | 编辑天干样式 | 保存 | 新格式保存 ✅ |
| 6 | 编辑阴影 | 保存 | 阴影正确持久化 ✅ |
| 7 | 新增 letterSpacing | 保存 | 扩展属性支持 ✅ |
| 8 | 重新加载 | 启动 | 所有样式恢复 ✅ |

**手动测试步骤**:
1. **准备测试数据**:
   - 导出当前生产环境的模板 JSON
   - 创建包含旧格式数据的测试模板
   - 创建包含新格式数据的测试模板

2. **加载测试**:
   - 清空应用数据
   - 导入旧格式模板 → 验证自动迁移
   - 导入新格式模板 → 验证直接加载

3. **编辑测试**:
   - 编辑每种行类型（天干、地支、纳音、空亡、十神）
   - 修改字体、颜色、粗细、阴影
   - 保存并重启应用 → 验证持久化

4. **扩展属性测试**（可选）:
   - 手动添加 letterSpacing 字段到 JSON
   - 加载并验证显示效果

**验收标准**:
- ✅ 所有测试场景通过
- ✅ 无崩溃或数据丢失
- ✅ 性能无明显下降

---

#### Day 3: 代码清理
**任务清单**:
- [ ] 移除 RowConfig 中的旧字段（fontFamily, fontSize, textColorHex, fontWeight, shadow* 等）
- [ ] 移除 ViewModel 中的旧参数（如果保留了 Feature Flag）
- [ ] 移除所有重复的转换辅助方法
- [x] 运行 `flutter analyze` 确保无警告
- [ ] 运行 `dart format .` 格式化代码

**代码审查**:
- [ ] 检查是否有遗漏的旧代码引用
- [ ] 确认所有 TODO 已处理
- [ ] 验证注释和文档更新

**验收标准**:
- ✅ flutter analyze 0 errors, 0 warnings
- ✅ 所有旧代码已移除
- ✅ 代码格式符合规范

---

#### Day 4: 文档更新
**文档任务**:
- [ ] 更新架构文档（`docs/feature/editable_eight_char/integeration/`）
- [ ] 创建迁移指南（`migration_guide_text_style_config.md`）
- [ ] 更新 README（如果需要）
- [ ] 添加代码注释（复杂逻辑）

**迁移指南内容**:
1. 变更摘要
2. 向后兼容说明
3. 旧 API → 新 API 映射表
4. 常见问题 FAQ
5. 如何回滚（如果需要）

**验收标准**:
- ✅ 文档完整清晰
- ✅ 包含实际代码示例
- ✅ 涵盖常见问题

---

#### Day 5: 最终验证 + 发布准备
**最终检查清单**:
- [ ] 所有单元测试通过
- [ ] 所有集成测试通过
- [ ] 手动回归测试通过
- [ ] 性能基准测试（可选）
- [ ] 代码覆盖率报告（目标 >80%）

**发布准备**:
- [ ] 创建 Git Tag（如 `v2.0.0-text-style-config`）
- [ ] 编写发布说明（Release Notes）
- [ ] 合并到主分支（master/main）
- [ ] 部署到测试环境（如果有）

**回滚计划**（保底方案）:
- [ ] 准备回滚脚本（恢复旧代码）
- [ ] 保留旧分支引用（至少 1 个月）
- [ ] 文档化回滚步骤

**验收标准**:
- ✅ 所有测试通过
- ✅ 代码已合并到主分支
- ✅ 发布说明完整

---

## 🔒 风险管理

### 已识别风险

| 风险 | 概率 | 影响 | 缓解措施 | 应急方案 |
|------|------|------|---------|---------|
| **数据迁移失败** | 🟡 中 | 🔴 高 | - 完整单元测试<br>- 向后兼容的 fromJson<br>- 迁移验证脚本 | - 保留旧字段 1 个月<br>- 快速回滚到旧版本 |
| **性能下降** | 🟢 低 | 🟡 中 | - JSON 解析基准测试<br>- 对象创建性能测试 | - 优化 TextStyleConfig.toTextStyle()<br>- 添加缓存机制 |
| **UI 显示异常** | 🟡 中 | 🟡 中 | - 完整手动测试<br>- Widget 测试覆盖 | - 快速修复 hotfix<br>- 回滚到旧版本 |
| **新旧格式冲突** | 🟢 低 | 🟡 中 | - 新格式优先逻辑<br>- 混合格式测试 | - 强制转换为新格式<br>- 数据修复脚本 |
| **开发进度延迟** | 🟡 中 | 🟢 低 | - 每日进度检查<br>- 关键路径优先 | - 延长到 3 周<br>- 分阶段交付 |
| **回归 bug** | 🟡 中 | 🟡 中 | - 完整回归测试<br>- 自动化测试覆盖 | - 快速修复<br>- Hotfix 流程 |

### 关键决策点

**决策 1**: 是否立即移除旧字段？
- **选项 A**: Day 3 移除（激进）
  - 优势：代码简洁，无历史包袱
  - 风险：回滚困难
- **选项 B**: 保留 1 个月（保守）
  - 优势：回滚容易
  - 劣势：维护成本高

**推荐**: **选项 A**（立即移除），因为有完善的测试覆盖和向后兼容的 fromJson

---

**决策 2**: 是否支持部分更新（partial update）？
- **选项 A**: 完整替换（简单）
  - updateRowStyle 只接受完整的 TextStyleConfig
  - 优势：逻辑简单，代码少
  - 劣势：UI 需要每次传递完整对象
- **选项 B**: 智能合并（灵活）
  - 自动合并新旧 TextStyleConfig 的非 null 字段
  - 优势：UI 可以只更新单个属性
  - 劣势：合并逻辑稍复杂

**推荐**: **选项 B**（智能合并），因为 UI 编辑器通常只修改单个属性（如只改颜色）

---

## ❓ 讨论问题

### 技术决策

1. **RowConfig 旧字段保留策略**
   - 问题：是否在 Week 2 Day 3 立即移除旧字段（fontFamily, fontSize 等）？
   - 选项：
     - A. 立即移除（推荐）- 代码简洁
     - B. 保留 1 个月 - 回滚容易
     - C. 永久保留作为备用 - 双系统维护
   - **请选择**: ______

2. **部分更新 vs 完整替换**
   - 问题：updateRowStyle 是否支持部分更新（只传递修改的字段）？
   - 选项：
     - A. 智能合并（推荐）- 灵活但逻辑稍复杂
     - B. 完整替换 - 简单但 UI 需传完整对象
   - **请选择**: ______

3. **扩展属性优先级**
   - 问题：当前立即支持所有扩展属性（letterSpacing, height 等），还是仅支持基础属性？
   - 选项：
     - A. 立即支持全部（推荐）- 一次性到位
     - B. 仅基础属性 - 降低初期风险
     - C. 基础 + 阴影 - 折中方案
   - **请选择**: ______

4. **数据迁移时机**
   - 问题：何时将旧格式数据转换为新格式写回磁盘？
   - 选项：
     - A. 加载时静默转换（推荐）- 首次加载即迁移
     - B. 编辑保存时转换 - 延迟迁移
     - C. 手动触发迁移 - 用户控制
   - **请选择**: ______

---

### 非功能性需求

5. **性能基准**
   - 问题：是否需要正式的性能基准测试？
   - 选项：
     - A. 需要（推荐）- 确保无性能回退
     - B. 不需要 - 信任单元测试
   - **请选择**: ______

6. **代码覆盖率目标**
   - 问题：TextStyleConfig 的测试覆盖率要求？
   - 选项：
     - A. 100%（推荐）- 核心数据模型必须完全覆盖
     - B. 80% - 常见场景覆盖
     - C. 不强制 - 依赖手动测试
   - **请选择**: ______

---

### 迁移策略

7. **回滚机制**
   - 问题：如果迁移后发现严重问题，如何回滚？
   - 选项：
     - A. Git revert + 数据修复脚本（推荐）
     - B. 保留旧字段作为 Feature Flag
     - C. 不提供回滚（信任测试）
   - **请选择**: ______

8. **发布策略**
   - 问题：是否需要分阶段发布（如先内部测试 1 周）？
   - 选项：
     - A. 直接合并主分支（推荐）- 快速迭代
     - B. 先发布到测试分支 - 保守稳妥
   - **请选择**: ______

---

## 📋 下一步行动

### 立即行动（等待决策）
1. **用户审阅本文档**
   - 阅读完整设计方案
   - 回答 8 个讨论问题
   - 确认是否同意激进迁移时间线

2. **技术澄清**
   - 确认 json_serializable 配置
   - 确认测试框架（如 flutter_test, mockito）
   - 确认是否有 CI/CD 流程

### 决策后启动（Week 1 Day 1）
1. **创建 feature 分支**
   ```bash
   git checkout -b feature/text-style-config-refactor
   ```

2. **创建 TextStyleConfig 类**
   - 文件路径：`lib/models/text_style_config.dart`
   - 运行代码生成：`dart run build_runner build --delete-conflicting-outputs`

3. **编写单元测试**
   - 文件路径：`test/models/text_style_config_test.dart`
   - 确保 100% 覆盖率

4. **每日进度同步**
   - 每天结束前 commit + push
   - 记录遇到的问题和解决方案

---

## 📞 支持与反馈

如有任何疑问或需要进一步澄清，请随时提出。我将根据您的反馈调整方案细节。

**关键问题清单**（请逐一确认）:
- [ ] 是否同意 1-2 周激进迁移时间线？
- [ ] 是否同意完全替换方案（移除旧字段）？
- [ ] 是否同意立即支持所有扩展属性？
- [ ] 是否需要修改任何技术细节？
- [ ] 是否需要增加额外的安全措施？

---

**文档版本**: v1.0
**最后更新**: 2025-11-10
**作者**: Claude Code
**状态**: 🔄 待用户审阅和决策
