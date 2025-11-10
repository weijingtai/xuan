# 柱样式配置（PillarStyleConfig）重构方案设计

**生成时间**: 2025-11-10  
**目标**: 设计类似 CardStyleConfig 的柱样式配置类，实现柱容器样式的统一管理与持久化

---

## 目录
- [1. 当前状态分析](#1-当前状态分析)
- [2. PillarStyleConfig 完整设计](#2-pillarstyleconfig-完整设计)
- [3. 重构方案时间线](#3-重构方案时间线)
- [4. 原子化任务清单（JSON）](#4-原子化任务清单json)
- [5. 与 CardStyleConfig 对比分析](#5-与-cardstyleconfig-对比分析)

---

## 1. 当前状态分析

### 1.1 当前柱样式属性清单

**存储位置**: `EditableFourZhuCardTheme.PillarSection` 类（主题模型）

| 属性名称 | 数据类型 | 当前默认值 | 作用描述 |
|---------|---------|-----------|---------|
| `defaultMargin` | `EdgeInsets?` | `EdgeInsets.all(8)` | 柱外边距（4方向） |
| `defaultPadding` | `EdgeInsets?` | `EdgeInsets.all(16)` | 柱内边距（4方向） |
| `borderWidth` | `double?` | `2.0` | 边框宽度 |
| `borderColor` | `Color?` | `Colors.red` | 边框颜色 |
| `cornerRadius` | `double?` | `0.0` | 圆角半径 |
| `backgroundColor` | `Color?` | `Colors.transparent` | 背景颜色 |
| `shadowColor` | `Color?` | `null` | 阴影颜色 |
| `shadowOffsetX` | `double?` | `0.0` | 阴影X偏移 |
| `shadowOffsetY` | `double?` | `0.0` | 阴影Y偏移 |
| `shadowBlurRadius` | `double?` | `0.0` | 阴影模糊半径 |
| `shadowSpreadRadius` | `double?` | `0.0` | 阴影扩展半径 |
| `perPillarMargin` | `Map<PillarType, EdgeInsets>?` | `{}` | 每柱独立外边距覆盖 |

**新增需求**:
- 每柱独立配置支持（类似每行独立样式）
- 4方向独立 margin/padding 控制
- width/height 尺寸配置

### 1.2 属性传递路径

```
Sidebar (editable_four_zhu_style_editor_panel.dart)
    ↓ (主题更新)
ViewModel (FourZhuEditorViewModel)
    ↓ (读取 theme.pillar)
EditorWorkspace (editor_workspace.dart)
    ↓ (传递给 V3 Card 构造函数)
EditableFourZhuCardV3 (editable_fourzhu_card_impl.dart)
    ↓ (应用到柱容器装饰)
柱渲染（AnimatedOpacity → Container → padding/decoration）
```

**关键代码位置**:
- **Sidebar**: `lib/widgets/style_editor/editable_four_zhu_style_editor_panel.dart` (行 52-65, 125-135)
- **V3 Card**: `lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart` (行 39-46, 249-323)
- **主题模型**: `lib/themes/editable_four_zhu_card_theme.dart` (行 276-320)

### 1.3 硬编码情况

| 位置 | 硬编码内容 | 行号 |
|-----|-----------|-----|
| `editable_fourzhu_card_impl.dart` | 默认 margin: `EdgeInsets.all(8.0)` | 250 |
| `editable_fourzhu_card_impl.dart` | 默认 padding: `EdgeInsets.all(16.0)` | 264 |
| `editable_fourzhu_card_impl.dart` | 默认 borderWidth: `2.0` | 267 |
| `editable_fourzhu_card_impl.dart` | 默认 borderColor: `Colors.red` | 270 |
| `editable_fourzhu_card_impl.dart` | 默认 cornerRadius: `0.0` | 273 |
| `editable_fourzhu_card_impl.dart` | 默认 backgroundColor: `Colors.transparent` | 277 |

**存在问题**:
1. ❌ 默认值散落在多个文件
2. ❌ 无统一的配置持久化路径
3. ❌ 每柱独立配置通过 `perPillarMargin` 实现，但缺少其他属性支持
4. ❌ 4方向独立控制需要手动构造 `EdgeInsets.only(...)`

---

## 2. PillarStyleConfig 完整设计

### 2.1 类定义（JSON 序列化）

```dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pillar_style_config.g.dart';

/// 柱容器样式配置类（类似 CardStyleConfig）
/// 
/// 功能：
/// - 统一管理柱的边框、背景、圆角、内外边距、阴影、尺寸
/// - 支持 JSON 序列化持久化
/// - 4方向独立控制（margin/padding/borderRadius）
/// - 提供 Flutter 原生类型转换方法
@JsonSerializable()
class PillarStyleConfig {
  // ==================== 边框配置 ====================
  /// 边框宽度（像素）
  final double? borderWidth;
  
  /// 边框颜色（#AARRGGBB 格式）
  @JsonKey(name: 'borderColorHex')
  final String? borderColorHex;
  
  /// 边框样式（solid/dashed/dotted/none）
  final String? borderStyle;
  
  // ==================== 背景配置 ====================
  /// 背景颜色（#AARRGGBB 格式）
  @JsonKey(name: 'backgroundColorHex')
  final String? backgroundColorHex;
  
  // ==================== 圆角配置 ====================
  /// 统一圆角半径（优先级低）
  final double? borderRadius;
  
  /// 左上角圆角半径
  final double? borderRadiusTopLeft;
  
  /// 右上角圆角半径
  final double? borderRadiusTopRight;
  
  /// 左下角圆角半径
  final double? borderRadiusBottomLeft;
  
  /// 右下角圆角半径
  final double? borderRadiusBottomRight;
  
  // ==================== 内边距配置（Padding）====================
  /// 顶部内边距
  final double? paddingTop;
  
  /// 底部内边距
  final double? paddingBottom;
  
  /// 左侧内边距
  final double? paddingLeft;
  
  /// 右侧内边距
  final double? paddingRight;
  
  // ==================== 外边距配置（Margin）⚠️ 新增 ====================
  /// 顶部外边距
  final double? marginTop;
  
  /// 底部外边距
  final double? marginBottom;
  
  /// 左侧外边距
  final double? marginLeft;
  
  /// 右侧外边距
  final double? marginRight;
  
  // ==================== 阴影配置 ====================
  /// 阴影颜色（#AARRGGBB 格式）
  @JsonKey(name: 'shadowColorHex')
  final String? shadowColorHex;
  
  /// 阴影X轴偏移
  final double? shadowOffsetX;
  
  /// 阴影Y轴偏移
  final double? shadowOffsetY;
  
  /// 阴影模糊半径
  final double? shadowBlurRadius;
  
  /// 阴影扩展半径
  final double? shadowSpreadRadius;
  
  // ==================== 尺寸配置 ====================
  /// 柱宽度（像素）
  final double? width;
  
  /// 柱高度（像素，通常不设置，由内容自适应）
  final double? height;

  const PillarStyleConfig({
    // Border
    this.borderWidth,
    this.borderColorHex,
    this.borderStyle,
    // Background
    this.backgroundColorHex,
    // Border Radius
    this.borderRadius,
    this.borderRadiusTopLeft,
    this.borderRadiusTopRight,
    this.borderRadiusBottomLeft,
    this.borderRadiusBottomRight,
    // Padding
    this.paddingTop,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingRight,
    // Margin ⚠️ 新增
    this.marginTop,
    this.marginBottom,
    this.marginLeft,
    this.marginRight,
    // Shadow
    this.shadowColorHex,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,
    this.shadowSpreadRadius,
    // Size
    this.width,
    this.height,
  });

  // ==================== JSON 序列化 ====================
  factory PillarStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$PillarStyleConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PillarStyleConfigToJson(this);

  // ==================== 类型转换方法 ====================
  
  /// 转换为 Flutter BoxDecoration
  BoxDecoration toBoxDecoration() {
    return BoxDecoration(
      color: _parseHexColor(backgroundColorHex),
      border: _buildBorder(),
      borderRadius: _buildBorderRadius(),
      boxShadow: _buildBoxShadows(),
    );
  }
  
  /// 获取内边距（Padding）
  EdgeInsets? get padding {
    if (paddingTop == null &&
        paddingBottom == null &&
        paddingLeft == null &&
        paddingRight == null) {
      return null;
    }
    return EdgeInsets.only(
      top: paddingTop ?? 0,
      bottom: paddingBottom ?? 0,
      left: paddingLeft ?? 0,
      right: paddingRight ?? 0,
    );
  }
  
  /// 获取外边距（Margin）⚠️ 新增
  EdgeInsets? get margin {
    if (marginTop == null &&
        marginBottom == null &&
        marginLeft == null &&
        marginRight == null) {
      return null;
    }
    return EdgeInsets.only(
      top: marginTop ?? 0,
      bottom: marginBottom ?? 0,
      left: marginLeft ?? 0,
      right: marginRight ?? 0,
    );
  }

  // ==================== 辅助方法（私有）====================
  
  Border? _buildBorder() {
    if (borderWidth == null || borderWidth! <= 0) return null;
    final color = _parseHexColor(borderColorHex) ?? Colors.transparent;
    return Border.all(
      color: color,
      width: borderWidth!,
    );
  }

  BorderRadius? _buildBorderRadius() {
    // 优先使用4角独立配置
    if (borderRadiusTopLeft != null ||
        borderRadiusTopRight != null ||
        borderRadiusBottomLeft != null ||
        borderRadiusBottomRight != null) {
      return BorderRadius.only(
        topLeft: Radius.circular(borderRadiusTopLeft ?? 0),
        topRight: Radius.circular(borderRadiusTopRight ?? 0),
        bottomLeft: Radius.circular(borderRadiusBottomLeft ?? 0),
        bottomRight: Radius.circular(borderRadiusBottomRight ?? 0),
      );
    }
    // 回退到统一圆角
    if (borderRadius != null && borderRadius! > 0) {
      return BorderRadius.circular(borderRadius!);
    }
    return null;
  }

  List<BoxShadow>? _buildBoxShadows() {
    final color = _parseHexColor(shadowColorHex);
    if (color == null) return null;
    return [
      BoxShadow(
        color: color,
        offset: Offset(
          shadowOffsetX ?? 0,
          shadowOffsetY ?? 0,
        ),
        blurRadius: shadowBlurRadius ?? 0,
        spreadRadius: shadowSpreadRadius ?? 0,
      ),
    ];
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final sanitized = hex.replaceAll('#', '');
      if (sanitized.length == 6) {
        // RRGGBB -> 添加不透明度
        return Color(int.parse('FF$sanitized', radix: 16));
      } else if (sanitized.length == 8) {
        // AARRGGBB
        return Color(int.parse(sanitized, radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // ==================== 工厂构造函数 ====================
  
  /// 从现有 BoxDecoration 反向构建（用于编辑器初始化）
  factory PillarStyleConfig.fromBoxDecoration(
    BoxDecoration decoration, {
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    final border = decoration.border as Border?;
    final borderRadius = decoration.borderRadius as BorderRadius?;
    final shadow = decoration.boxShadow?.firstOrNull;

    return PillarStyleConfig(
      // Border
      borderWidth: border?.top.width,
      borderColorHex: border?.top.color != null
          ? '#${border!.top.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      // Background
      backgroundColorHex: decoration.color != null
          ? '#${decoration.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      // Border Radius
      borderRadiusTopLeft: borderRadius?.topLeft.x,
      borderRadiusTopRight: borderRadius?.topRight.x,
      borderRadiusBottomLeft: borderRadius?.bottomLeft.x,
      borderRadiusBottomRight: borderRadius?.bottomRight.x,
      // Padding
      paddingTop: padding?.top,
      paddingBottom: padding?.bottom,
      paddingLeft: padding?.left,
      paddingRight: padding?.right,
      // Margin ⚠️ 新增
      marginTop: margin?.top,
      marginBottom: margin?.bottom,
      marginLeft: margin?.left,
      marginRight: margin?.right,
      // Shadow
      shadowColorHex: shadow?.color != null
          ? '#${shadow!.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      shadowOffsetX: shadow?.offset.dx,
      shadowOffsetY: shadow?.offset.dy,
      shadowBlurRadius: shadow?.blurRadius,
      shadowSpreadRadius: shadow?.spreadRadius,
      // Size
      width: width,
      height: height,
    );
  }

  /// 从旧版 PillarSection 迁移（向后兼容）
  factory PillarStyleConfig.fromLegacy({
    EdgeInsets? defaultMargin,
    EdgeInsets? defaultPadding,
    double? borderWidth,
    Color? borderColor,
    double? cornerRadius,
    Color? backgroundColor,
    Color? shadowColor,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? width,
    double? height,
  }) {
    return PillarStyleConfig(
      // Border
      borderWidth: borderWidth,
      borderColorHex: borderColor != null
          ? '#${borderColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      // Background
      backgroundColorHex: backgroundColor != null
          ? '#${backgroundColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      // Border Radius（统一圆角）
      borderRadius: cornerRadius,
      // Padding
      paddingTop: defaultPadding?.top,
      paddingBottom: defaultPadding?.bottom,
      paddingLeft: defaultPadding?.left,
      paddingRight: defaultPadding?.right,
      // Margin
      marginTop: defaultMargin?.top,
      marginBottom: defaultMargin?.bottom,
      marginLeft: defaultMargin?.left,
      marginRight: defaultMargin?.right,
      // Shadow
      shadowColorHex: shadowColor != null
          ? '#${shadowColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
          : null,
      shadowOffsetX: shadowOffsetX,
      shadowOffsetY: shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius,
      // Size
      width: width,
      height: height,
    );
  }

  // ==================== CopyWith ====================
  
  PillarStyleConfig copyWith({
    double? borderWidth,
    String? borderColorHex,
    String? borderStyle,
    String? backgroundColorHex,
    double? borderRadius,
    double? borderRadiusTopLeft,
    double? borderRadiusTopRight,
    double? borderRadiusBottomLeft,
    double? borderRadiusBottomRight,
    double? paddingTop,
    double? paddingBottom,
    double? paddingLeft,
    double? paddingRight,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
    String? shadowColorHex,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? width,
    double? height,
  }) {
    return PillarStyleConfig(
      borderWidth: borderWidth ?? this.borderWidth,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      borderStyle: borderStyle ?? this.borderStyle,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      borderRadius: borderRadius ?? this.borderRadius,
      borderRadiusTopLeft: borderRadiusTopLeft ?? this.borderRadiusTopLeft,
      borderRadiusTopRight: borderRadiusTopRight ?? this.borderRadiusTopRight,
      borderRadiusBottomLeft:
          borderRadiusBottomLeft ?? this.borderRadiusBottomLeft,
      borderRadiusBottomRight:
          borderRadiusBottomRight ?? this.borderRadiusBottomRight,
      paddingTop: paddingTop ?? this.paddingTop,
      paddingBottom: paddingBottom ?? this.paddingBottom,
      paddingLeft: paddingLeft ?? this.paddingLeft,
      paddingRight: paddingRight ?? this.paddingRight,
      marginTop: marginTop ?? this.marginTop,
      marginBottom: marginBottom ?? this.marginBottom,
      marginLeft: marginLeft ?? this.marginLeft,
      marginRight: marginRight ?? this.marginRight,
      shadowColorHex: shadowColorHex ?? this.shadowColorHex,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  // ==================== 默认值工厂 ====================
  
  /// 默认柱样式（透明背景、无边框、8px外边距、16px内边距）
  static const PillarStyleConfig defaultStyle = PillarStyleConfig(
    marginTop: 8,
    marginBottom: 8,
    marginLeft: 8,
    marginRight: 8,
    paddingTop: 16,
    paddingBottom: 16,
    paddingLeft: 16,
    paddingRight: 16,
    borderWidth: 0,
    borderRadius: 0,
  );
}
```

### 2.2 集成方案：存储位置选择

#### 方案 A：`LayoutTemplate` 中全局配置（推荐）

```dart
// lib/models/layout_template.dart

class LayoutTemplate {
  final String id;
  final String name;
  final CardStyle cardStyle;
  
  /// 全局柱样式配置（应用于所有柱）
  final PillarStyleConfig? globalPillarStyle; // ⚠️ 新增
  
  /// 每柱独立样式覆盖（优先级高于全局）
  final Map<PillarType, PillarStyleConfig>? perPillarStyles; // ⚠️ 新增
  
  final List<ChartGroup> chartGroups;
  final List<RowConfig> rowConfigs;
  
  // ... 其余字段
}
```

**优点**:
- ✅ 与 `CardStyle` 平级，语义清晰
- ✅ 支持全局 + 每柱覆盖的灵活配置
- ✅ JSON 持久化路径明确

**缺点**:
- ⚠️ 需要修改 `LayoutTemplate` 的序列化逻辑

---

#### 方案 B：`ChartGroup` 中每组独立配置

```dart
class ChartGroup {
  final String id;
  final String title;
  final List<PillarType> pillarOrder;
  
  /// 本组的柱样式配置
  final PillarStyleConfig? pillarStyle; // ⚠️ 新增
  
  // ... 其余字段
}
```

**优点**:
- ✅ 支持按组差异化样式（如：本命盘组 vs 大运组）
- ✅ 局部修改影响范围小

**缺点**:
- ❌ 增加配置复杂度（每组都要单独设置）
- ❌ 与全局样式冲突时需要优先级规则

---

#### 方案 C：混合方案（全局 + 每柱）

```dart
class LayoutTemplate {
  final PillarStyleConfig? globalPillarStyle;
  final Map<PillarType, PillarStyleConfig>? perPillarStyles;
  // ...
}

// ViewModel API
void updateGlobalPillarStyle(PillarStyleConfig config);
void updatePillarStyle(PillarType type, PillarStyleConfig config);
```

**优先级规则**:
```
perPillarStyles[type] > globalPillarStyle > 硬编码默认值
```

**推荐**: ✅ **方案 C（混合方案）** - 灵活性最高，兼容全局统一 + 每柱定制

---

### 2.3 ViewModel API 设计

```dart
// lib/viewmodels/four_zhu_editor_view_model.dart

class FourZhuEditorViewModel extends ChangeNotifier {
  LayoutTemplate? _template;
  
  /// 获取全局柱样式
  PillarStyleConfig? get globalPillarStyle => _template?.globalPillarStyle;
  
  /// 获取指定柱的样式（优先返回独立配置，否则全局）
  PillarStyleConfig? getPillarStyle(PillarType type) {
    return _template?.perPillarStyles?[type] ?? globalPillarStyle;
  }
  
  /// 更新全局柱样式
  void updateGlobalPillarStyle(PillarStyleConfig config) {
    if (_template == null) return;
    _template = _template!.copyWith(globalPillarStyle: config);
    notifyListeners();
  }
  
  /// 更新指定柱的独立样式
  void updatePillarStyle(PillarType type, PillarStyleConfig config) {
    if (_template == null) return;
    final updated = Map<PillarType, PillarStyleConfig>.from(
      _template!.perPillarStyles ?? {},
    );
    updated[type] = config;
    _template = _template!.copyWith(perPillarStyles: updated);
    notifyListeners();
  }
  
  /// 清除指定柱的独立样式（回退到全局）
  void clearPillarStyle(PillarType type) {
    if (_template == null) return;
    final updated = Map<PillarType, PillarStyleConfig>.from(
      _template!.perPillarStyles ?? {},
    );
    updated.remove(type);
    _template = _template!.copyWith(perPillarStyles: updated);
    notifyListeners();
  }
}
```

---

### 2.4 Sidebar UI 设计（参考现有 RowConfig 编辑器）

```dart
// lib/widgets/style_editor/pillar_style_editor_section.dart

class PillarStyleEditorSection extends StatefulWidget {
  final PillarStyleConfig? globalStyle;
  final Map<PillarType, PillarStyleConfig>? perPillarStyles;
  final ValueChanged<PillarStyleConfig> onGlobalStyleChanged;
  final void Function(PillarType, PillarStyleConfig) onPillarStyleChanged;
  
  // ...
}

class _PillarStyleEditorSectionState extends State<...> {
  bool _showPerPillarEditor = false; // 切换全局/每柱编辑模式
  PillarType? _selectedPillar; // 当前选中柱
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题 + 模式切换按钮
        Row(
          children: [
            Text('柱样式', style: ...),
            Spacer(),
            SegmentedButton<bool>(
              selected: {_showPerPillarEditor},
              segments: [
                ButtonSegment(value: false, label: Text('全局')),
                ButtonSegment(value: true, label: Text('每柱')),
              ],
              onSelectionChanged: (set) {
                setState(() => _showPerPillarEditor = set.first);
              },
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // 全局编辑器
        if (!_showPerPillarEditor) ...[
          _buildStyleEditor(
            config: widget.globalStyle,
            onChanged: widget.onGlobalStyleChanged,
          ),
        ],
        
        // 每柱编辑器
        if (_showPerPillarEditor) ...[
          DropdownButton<PillarType>(
            value: _selectedPillar,
            items: PillarType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_pillarTypeLabel(type)),
              );
            }).toList(),
            onChanged: (type) {
              setState(() => _selectedPillar = type);
            },
          ),
          
          if (_selectedPillar != null) ...[
            SizedBox(height: 16),
            _buildStyleEditor(
              config: widget.perPillarStyles?[_selectedPillar],
              onChanged: (config) {
                widget.onPillarStyleChanged(_selectedPillar!, config);
              },
            ),
            
            TextButton.icon(
              icon: Icon(Icons.clear),
              label: Text('清除独立样式（回退到全局）'),
              onPressed: () {
                // 调用 ViewModel.clearPillarStyle()
              },
            ),
          ],
        ],
      ],
    );
  }
  
  /// 构建通用样式编辑器（复用 RowConfig 编辑器的 UI 组件）
  Widget _buildStyleEditor({
    required PillarStyleConfig? config,
    required ValueChanged<PillarStyleConfig> onChanged,
  }) {
    return Column(
      children: [
        // Margin 4方向滑块
        _buildMarginSliders(config, onChanged),
        
        Divider(),
        
        // Padding 4方向滑块
        _buildPaddingSliders(config, onChanged),
        
        Divider(),
        
        // Border 配置（宽度 + 颜色）
        _buildBorderConfig(config, onChanged),
        
        Divider(),
        
        // Background 颜色选择器
        _buildBackgroundPicker(config, onChanged),
        
        Divider(),
        
        // BorderRadius 配置（统一 + 4角独立）
        _buildBorderRadiusConfig(config, onChanged),
        
        Divider(),
        
        // Shadow 配置（颜色 + 偏移 + 模糊）
        _buildShadowConfig(config, onChanged),
      ],
    );
  }
  
  String _pillarTypeLabel(PillarType type) {
    switch (type) {
      case PillarType.year: return '年柱';
      case PillarType.month: return '月柱';
      case PillarType.day: return '日柱';
      case PillarType.hour: return '时柱';
      case PillarType.luckCycle: return '大运';
      default: return type.name;
    }
  }
  
  // ... 辅助构建方法
}
```

---

## 3. 重构方案时间线（1-2周）

### Week 1: 核心设计与迁移（5-7天）

| 任务 | 工作日 | 说明 |
|-----|-------|-----|
| **Task 1-10**: PillarStyleConfig 类实现 | Day 1-2 | 创建类、添加序列化、转换方法 |
| **Task 11-20**: LayoutTemplate 集成 | Day 3-4 | 添加字段、更新 JSON 序列化 |
| **Task 21-30**: ViewModel API 实现 | Day 5 | 添加更新方法、通知监听 |
| **Task 31-35**: V3 Card 应用样式 | Day 6-7 | 修改构造函数、应用装饰 |

### Week 2: UI 编辑器与测试（5-7天）

| 任务 | 工作日 | 说明 |
|-----|-------|-----|
| **Task 36-40**: Sidebar 编辑器 | Day 8-9 | 全局/每柱切换、滑块/颜色选择器 |
| **Task 41-43**: 数据迁移工具 | Day 10 | 旧 PillarSection → 新配置 |
| **Task 44-47**: 单元测试 | Day 11-12 | JSON 序列化、转换方法、边界情况 |
| **Task 48-50**: 文档与发布 | Day 13-14 | 更新 API 文档、迁移指南、Code Review |

**总计**: 10-14 工作日（含测试与文档）

---

## 4. 原子化任务清单（JSON）

```json
{
  "projectName": "PillarStyleConfig 重构",
  "totalTasks": 50,
  "estimatedDays": 14,
  "tasks": [
    {
      "id": 1,
      "title": "创建 PillarStyleConfig 类文件",
      "description": "在 lib/models/ 下创建 pillar_style_config.dart",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [],
      "tags": ["model", "setup"]
    },
    {
      "id": 2,
      "title": "定义边框属性字段",
      "description": "添加 borderWidth, borderColorHex, borderStyle",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 20,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 3,
      "title": "定义背景属性字段",
      "description": "添加 backgroundColorHex",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 10,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 4,
      "title": "定义圆角属性字段",
      "description": "添加 borderRadius, borderRadiusTopLeft, borderRadiusTopRight, borderRadiusBottomLeft, borderRadiusBottomRight",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 5,
      "title": "定义内边距属性字段",
      "description": "添加 paddingTop, paddingBottom, paddingLeft, paddingRight",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 20,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 6,
      "title": "定义外边距属性字段 ⚠️ 新增",
      "description": "添加 marginTop, marginBottom, marginLeft, marginRight",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 20,
      "dependencies": [1],
      "tags": ["model", "properties", "new-feature"]
    },
    {
      "id": 7,
      "title": "定义阴影属性字段",
      "description": "添加 shadowColorHex, shadowOffsetX, shadowOffsetY, shadowBlurRadius, shadowSpreadRadius",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 8,
      "title": "定义尺寸属性字段",
      "description": "添加 width, height",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 10,
      "dependencies": [1],
      "tags": ["model", "properties"]
    },
    {
      "id": 9,
      "title": "添加 json_serializable 注解",
      "description": "@JsonSerializable() + part 'pillar_style_config.g.dart'",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 15,
      "dependencies": [2, 3, 4, 5, 6, 7, 8],
      "tags": ["model", "serialization"]
    },
    {
      "id": 10,
      "title": "生成 JSON 序列化代码",
      "description": "运行 `flutter packages pub run build_runner build`",
      "file": "lib/models/pillar_style_config.g.dart",
      "estimateMinutes": 5,
      "dependencies": [9],
      "tags": ["codegen"]
    },
    {
      "id": 11,
      "title": "实现 toBoxDecoration() 方法",
      "description": "将配置转换为 Flutter BoxDecoration",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 60,
      "dependencies": [10],
      "tags": ["model", "converter"]
    },
    {
      "id": 12,
      "title": "实现 padding getter",
      "description": "返回 EdgeInsets.only(...) 或 null",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["model", "converter"]
    },
    {
      "id": 13,
      "title": "实现 margin getter ⚠️ 新增",
      "description": "返回 EdgeInsets.only(...) 或 null",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["model", "converter", "new-feature"]
    },
    {
      "id": 14,
      "title": "实现 _buildBorder() 私有方法",
      "description": "根据 borderWidth/borderColorHex 构建 Border",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [11],
      "tags": ["model", "converter"]
    },
    {
      "id": 15,
      "title": "实现 _buildBorderRadius() 私有方法",
      "description": "支持统一圆角 + 4角独立配置",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 40,
      "dependencies": [11],
      "tags": ["model", "converter"]
    },
    {
      "id": 16,
      "title": "实现 _buildBoxShadows() 私有方法",
      "description": "根据 shadowColorHex/offset/blur 构建 BoxShadow 列表",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [11],
      "tags": ["model", "converter"]
    },
    {
      "id": 17,
      "title": "实现 _parseHexColor() 私有方法",
      "description": "解析 #AARRGGBB 或 #RRGGBB 字符串",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 30,
      "dependencies": [11],
      "tags": ["model", "converter"]
    },
    {
      "id": 18,
      "title": "实现 fromBoxDecoration() 工厂构造",
      "description": "反向构建，用于编辑器初始化",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 60,
      "dependencies": [10],
      "tags": ["model", "factory"]
    },
    {
      "id": 19,
      "title": "实现 fromLegacy() 工厂构造",
      "description": "从旧版 PillarSection 迁移",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 60,
      "dependencies": [10],
      "tags": ["model", "factory", "migration"]
    },
    {
      "id": 20,
      "title": "实现 copyWith() 方法",
      "description": "支持部分字段更新",
      "file": "lib/models/pillar_style_config.dart",
      "estimateMinutes": 40,
      "dependencies": [10],
      "tags": ["model", "utility"]
    },
    {
      "id": 21,
      "title": "在 LayoutTemplate 添加 globalPillarStyle 字段",
      "description": "final PillarStyleConfig? globalPillarStyle;",
      "file": "lib/models/layout_template.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["model", "integration"]
    },
    {
      "id": 22,
      "title": "在 LayoutTemplate 添加 perPillarStyles 字段",
      "description": "final Map<PillarType, PillarStyleConfig>? perPillarStyles;",
      "file": "lib/models/layout_template.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["model", "integration"]
    },
    {
      "id": 23,
      "title": "更新 LayoutTemplate.toJson()",
      "description": "序列化新增字段",
      "file": "lib/models/layout_template.dart",
      "estimateMinutes": 30,
      "dependencies": [21, 22],
      "tags": ["model", "serialization"]
    },
    {
      "id": 24,
      "title": "更新 LayoutTemplate.fromJson()",
      "description": "反序列化新增字段",
      "file": "lib/models/layout_template.dart",
      "estimateMinutes": 30,
      "dependencies": [21, 22],
      "tags": ["model", "serialization"]
    },
    {
      "id": 25,
      "title": "更新 LayoutTemplate.copyWith()",
      "description": "支持新增字段的 copyWith",
      "file": "lib/models/layout_template.dart",
      "estimateMinutes": 20,
      "dependencies": [21, 22],
      "tags": ["model", "utility"]
    },
    {
      "id": 26,
      "title": "在 ViewModel 添加 globalPillarStyle getter",
      "description": "PillarStyleConfig? get globalPillarStyle",
      "file": "lib/viewmodels/four_zhu_editor_view_model.dart",
      "estimateMinutes": 10,
      "dependencies": [21],
      "tags": ["viewmodel", "api"]
    },
    {
      "id": 27,
      "title": "在 ViewModel 添加 getPillarStyle() 方法",
      "description": "PillarStyleConfig? getPillarStyle(PillarType type)",
      "file": "lib/viewmodels/four_zhu_editor_view_model.dart",
      "estimateMinutes": 30,
      "dependencies": [21, 22],
      "tags": ["viewmodel", "api"]
    },
    {
      "id": 28,
      "title": "在 ViewModel 添加 updateGlobalPillarStyle() 方法",
      "description": "void updateGlobalPillarStyle(PillarStyleConfig config)",
      "file": "lib/viewmodels/four_zhu_editor_view_model.dart",
      "estimateMinutes": 30,
      "dependencies": [21],
      "tags": ["viewmodel", "api"]
    },
    {
      "id": 29,
      "title": "在 ViewModel 添加 updatePillarStyle() 方法",
      "description": "void updatePillarStyle(PillarType, PillarStyleConfig)",
      "file": "lib/viewmodels/four_zhu_editor_view_model.dart",
      "estimateMinutes": 40,
      "dependencies": [22],
      "tags": ["viewmodel", "api"]
    },
    {
      "id": 30,
      "title": "在 ViewModel 添加 clearPillarStyle() 方法",
      "description": "void clearPillarStyle(PillarType type)",
      "file": "lib/viewmodels/four_zhu_editor_view_model.dart",
      "estimateMinutes": 20,
      "dependencies": [22],
      "tags": ["viewmodel", "api"]
    },
    {
      "id": 31,
      "title": "在 V3 Card 添加 globalPillarStyle 参数",
      "description": "final PillarStyleConfig? globalPillarStyle;",
      "file": "lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["widget", "integration"]
    },
    {
      "id": 32,
      "title": "在 V3 Card 添加 perPillarStyles 参数",
      "description": "final Map<PillarType, PillarStyleConfig>? perPillarStyles;",
      "file": "lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart",
      "estimateMinutes": 20,
      "dependencies": [10],
      "tags": ["widget", "integration"]
    },
    {
      "id": 33,
      "title": "修改 V3 Card 柱装饰逻辑",
      "description": "替换硬编码为 PillarStyleConfig.toBoxDecoration()",
      "file": "lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart",
      "estimateMinutes": 90,
      "dependencies": [31, 32],
      "tags": ["widget", "rendering"]
    },
    {
      "id": 34,
      "title": "应用 margin getter ⚠️ 新增",
      "description": "使用外层 Container 应用 margin: config.margin",
      "file": "lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart",
      "estimateMinutes": 60,
      "dependencies": [33],
      "tags": ["widget", "rendering", "new-feature"]
    },
    {
      "id": 35,
      "title": "测试 V3 Card 柱样式渲染",
      "description": "手动验证边框、背景、圆角、阴影、margin 显示正确",
      "file": "N/A",
      "estimateMinutes": 60,
      "dependencies": [34],
      "tags": ["testing", "manual"]
    },
    {
      "id": 36,
      "title": "创建 PillarStyleEditorSection 组件",
      "description": "在 lib/widgets/style_editor/ 下创建文件",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 30,
      "dependencies": [10],
      "tags": ["ui", "setup"]
    },
    {
      "id": 37,
      "title": "实现全局/每柱模式切换按钮",
      "description": "SegmentedButton<bool>('全局', '每柱')",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 40,
      "dependencies": [36],
      "tags": ["ui", "interaction"]
    },
    {
      "id": 38,
      "title": "实现每柱下拉选择器",
      "description": "DropdownButton<PillarType>(年柱/月柱/日柱/时柱)",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 40,
      "dependencies": [37],
      "tags": ["ui", "interaction"]
    },
    {
      "id": 39,
      "title": "实现 Margin 4方向滑块",
      "description": "复用 RowConfig 编辑器的滑块组件",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 60,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 40,
      "title": "实现 Padding 4方向滑块",
      "description": "复用 RowConfig 编辑器的滑块组件",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 60,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 41,
      "title": "实现 Border 配置区（宽度 + 颜色）",
      "description": "Slider(borderWidth) + ColorPicker(borderColorHex)",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 60,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 42,
      "title": "实现 Background 颜色选择器",
      "description": "ColorPicker(backgroundColorHex)",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 30,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 43,
      "title": "实现 BorderRadius 配置（统一 + 4角独立）",
      "description": "Slider(borderRadius) + 展开按钮 + 4个独立 Slider",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 90,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 44,
      "title": "实现 Shadow 配置区",
      "description": "ColorPicker(shadowColorHex) + Slider(offset/blur)",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 90,
      "dependencies": [36],
      "tags": ["ui", "form-controls"]
    },
    {
      "id": 45,
      "title": "实现「清除独立样式」按钮",
      "description": "TextButton.icon + 调用 ViewModel.clearPillarStyle()",
      "file": "lib/widgets/style_editor/pillar_style_editor_section.dart",
      "estimateMinutes": 30,
      "dependencies": [38],
      "tags": ["ui", "interaction"]
    },
    {
      "id": 46,
      "title": "集成到 EditorSidebarV2",
      "description": "在 Sidebar 添加 PillarStyleEditorSection",
      "file": "lib/widgets/editor_sidebar_v2.dart",
      "estimateMinutes": 30,
      "dependencies": [45],
      "tags": ["ui", "integration"]
    },
    {
      "id": 47,
      "title": "编写数据迁移工具",
      "description": "PillarSection → PillarStyleConfig 转换脚本",
      "file": "scripts/migrate_pillar_style.dart",
      "estimateMinutes": 120,
      "dependencies": [19],
      "tags": ["migration", "tooling"]
    },
    {
      "id": 48,
      "title": "单元测试: JSON 序列化",
      "description": "测试 toJson/fromJson 的往返一致性",
      "file": "test/models/pillar_style_config_test.dart",
      "estimateMinutes": 60,
      "dependencies": [10],
      "tags": ["testing", "unit"]
    },
    {
      "id": 49,
      "title": "单元测试: 类型转换方法",
      "description": "测试 toBoxDecoration/padding/margin getter",
      "file": "test/models/pillar_style_config_test.dart",
      "estimateMinutes": 90,
      "dependencies": [11, 12, 13],
      "tags": ["testing", "unit"]
    },
    {
      "id": 50,
      "title": "单元测试: 工厂构造函数",
      "description": "测试 fromBoxDecoration/fromLegacy",
      "file": "test/models/pillar_style_config_test.dart",
      "estimateMinutes": 60,
      "dependencies": [18, 19],
      "tags": ["testing", "unit"]
    }
  ],
  "milestones": [
    {
      "name": "核心类完成",
      "taskIds": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "deadline": "Day 2"
    },
    {
      "name": "转换方法完成",
      "taskIds": [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      "deadline": "Day 4"
    },
    {
      "name": "ViewModel 集成完成",
      "taskIds": [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
      "deadline": "Day 6"
    },
    {
      "name": "V3 Card 应用完成",
      "taskIds": [31, 32, 33, 34, 35],
      "deadline": "Day 8"
    },
    {
      "name": "Sidebar UI 完成",
      "taskIds": [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46],
      "deadline": "Day 12"
    },
    {
      "name": "测试与发布",
      "taskIds": [47, 48, 49, 50],
      "deadline": "Day 14"
    }
  ]
}
```

---

## 5. 与 CardStyleConfig 对比分析

### 5.1 相同点

| 属性类别 | CardStyleConfig | PillarStyleConfig |
|---------|----------------|------------------|
| 边框 | `borderWidth`, `borderColorHex`, `borderStyle` | ✅ 相同 |
| 背景 | `backgroundColorHex` | ✅ 相同 |
| 圆角 | `borderRadius`, 4角独立 | ✅ 相同 |
| 内边距 | `paddingTop/Bottom/Left/Right` | ✅ 相同 |
| 阴影 | `shadowColorHex`, `shadowOffset`, `shadowBlur` | ✅ 相同 |
| 尺寸 | `width`, `height` | ✅ 相同 |

### 5.2 不同点

| 属性 | CardStyleConfig | PillarStyleConfig | 说明 |
|-----|----------------|------------------|-----|
| **外边距（Margin）** | ❌ 无 | ✅ 有（4方向） | ⚠️ 核心差异 |
| **应用场景** | 全局卡片 | 柱容器（4-5个） | 柱支持每柱独立配置 |
| **持久化位置** | `LayoutTemplate.cardStyle` | `LayoutTemplate.globalPillarStyle` + `perPillarStyles` | 柱支持全局+每柱覆盖 |

### 5.3 复用可能性分析

#### 方案 A: 继承复用（不推荐）

```dart
class PillarStyleConfig extends CardStyleConfig {
  final double? marginTop;
  final double? marginBottom;
  final double? marginLeft;
  final double? marginRight;
  
  // ...
}
```

**问题**:
- ❌ Dart 单继承限制
- ❌ JSON 序列化复杂度增加
- ❌ 语义不清晰（柱不是卡片的子类）

#### 方案 B: 组合复用（推荐）

```dart
class PillarStyleConfig {
  /// 内部组合 CardStyleConfig 的边框/背景/圆角/内边距/阴影
  final CardStyleConfig? baseStyle;
  
  /// 柱特有的外边距
  final double? marginTop;
  final double? marginBottom;
  final double? marginLeft;
  final double? marginRight;
  
  // 委托方法
  BoxDecoration toBoxDecoration() => baseStyle?.toBoxDecoration() ?? BoxDecoration();
  EdgeInsets? get padding => baseStyle?.padding;
  
  // 柱特有方法
  EdgeInsets? get margin => ...;
}
```

**优点**:
- ✅ 复用 CardStyleConfig 的逻辑
- ✅ 清晰的职责分离
- ✅ JSON 序列化可选嵌套

**缺点**:
- ⚠️ 需要修改现有 API（baseStyle.xxx）
- ⚠️ 可能引入间接复杂度

#### 方案 C: 独立定义（当前推荐）

```dart
class PillarStyleConfig {
  // 独立定义所有属性（含 margin）
  // 与 CardStyleConfig 平级，不继承/组合
}
```

**优点**:
- ✅ 语义清晰，易于理解
- ✅ 避免继承/组合的复杂度
- ✅ 灵活扩展（未来可能需要柱特有属性，如 `perRowPadding`）

**缺点**:
- ⚠️ 代码重复（边框/背景/圆角/内边距/阴影逻辑相同）

**结论**: 推荐 **方案 C（独立定义）**，通过私有方法复用转换逻辑（如 `_parseHexColor`），保持简洁性。

---

## 6. 关键注意事项

### 6.1 Margin 的 Flutter 实现

Flutter 中 margin 通常通过**外层 Container** 实现：

```dart
// ❌ 错误：BoxDecoration 不支持 margin
BoxDecoration(
  margin: EdgeInsets.all(8), // 不存在此属性
)

// ✅ 正确：外层 Container 应用 margin
Container(
  margin: EdgeInsets.all(8),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(...),
      // ...
    ),
  ),
)
```

**V3 Card 应用示例**:

```dart
// 当前代码（行 2306-2325）
Container(
  margin: _pillarMarginAtIndex(i), // ⚠️ 已存在
  child: Container(
    padding: _pillarPaddingEff,
    decoration: BoxDecoration(
      color: _pillarBackgroundColorEff,
      borderRadius: BorderRadius.circular(_pillarCornerRadiusEff),
      border: Border.all(...),
      boxShadow: widget.pillarBoxShadow,
    ),
    child: SizedBox(
      width: colW,
      child: columnContent,
    ),
  ),
)
```

**重构后**:

```dart
final style = getPillarStyle(i); // 从 ViewModel 读取
Container(
  margin: style.margin ?? _pillarMarginAtIndex(i), // ⚠️ 优先级：独立配置 > 全局
  child: Container(
    padding: style.padding ?? _pillarPaddingEff,
    decoration: style.toBoxDecoration(),
    child: SizedBox(
      width: colW,
      child: columnContent,
    ),
  ),
)
```

### 6.2 柱的识别与区分

**当前机制**（通过 `PillarPayload.pillarType`）:

| 柱类型 | `PillarType` 枚举 | 显示标签 |
|-------|-----------------|---------|
| 年柱 | `PillarType.year` | '年' |
| 月柱 | `PillarType.month` | '月' |
| 日柱 | `PillarType.day` | '日' |
| 时柱 | `PillarType.hour` | '时' |
| 大运 | `PillarType.luckCycle` | '大运' |
| 行标题列 | `PillarType.rowTitleColumn` | '行标题' |
| 分隔符 | `PillarType.separator` | '|' |

**独立配置支持**:

```dart
// ViewModel 存储
Map<PillarType, PillarStyleConfig> perPillarStyles = {
  PillarType.year: PillarStyleConfig(...),   // 年柱独立样式
  PillarType.day: PillarStyleConfig(...),    // 日柱独立样式
  // 其余柱回退到全局样式
};

// V3 Card 应用
for (int i = 0; i < pillars.length; i++) {
  final pillarType = payloads[i].pillarType;
  final style = perPillarStyles[pillarType] ?? globalPillarStyle;
  // 应用 style.toBoxDecoration(), style.margin, style.padding
}
```

### 6.3 与 CardStyleConfig 的协同顺序

**推荐实施顺序**:

1. ✅ **先完成 CardStyleConfig 重构**（已完成？）
2. ⚠️ **然后实施 PillarStyleConfig 重构**（本文档）
3. ✅ **最后统一测试**（确保 Card + Pillar 样式无冲突）

**潜在冲突场景**:

| 场景 | CardStyleConfig | PillarStyleConfig | 解决方案 |
|-----|----------------|------------------|---------|
| 卡片边框 vs 柱边框 | Card.borderWidth | Pillar.borderWidth | 独立控制，不冲突 |
| 卡片内边距 vs 柱外边距 | Card.padding | Pillar.margin | 叠加生效（Card padding 包裹 Pillar margin） |
| 卡片背景 vs 柱背景 | Card.background | Pillar.background | 柱背景覆盖卡片背景（正常行为） |

---

## 7. 参考资料

- **CardStyleConfig 重构提案**: `docs/card_style_config_refactor_proposal.md`
- **现有柱样式实现**: `lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart` (行 39-323)
- **主题模型**: `lib/themes/editable_four_zhu_card_theme.dart` (行 276-320)
- **ViewModel**: `lib/viewmodels/four_zhu_editor_view_model.dart`
- **Sidebar**: `lib/widgets/style_editor/editable_four_zhu_style_editor_panel.dart`

---

**文档结束** | 总计 50 项原子化任务 | 预计 10-14 工作日
