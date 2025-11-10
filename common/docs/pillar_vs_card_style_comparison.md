# Pillar vs Card 样式配置对比表

**版本**: v1.0  
**更新时间**: 2025-11-10  
**用途**: 快速对比 PillarStyleConfig 与 CardStyleConfig 的异同

---

## 属性对比总表

| 属性类别 | 属性名 | CardStyleConfig | PillarStyleConfig | 差异说明 |
|---------|-------|----------------|------------------|---------|
| **边框** | `borderWidth` | ✅ | ✅ | 完全相同 |
| | `borderColorHex` | ✅ | ✅ | 完全相同 |
| | `borderStyle` | ✅ | ✅ | 完全相同 |
| **背景** | `backgroundColorHex` | ✅ | ✅ | 完全相同 |
| **圆角** | `borderRadius` | ✅ | ✅ | 完全相同（统一圆角） |
| | `borderRadiusTopLeft` | ✅ | ✅ | 完全相同（4角独立） |
| | `borderRadiusTopRight` | ✅ | ✅ | 完全相同 |
| | `borderRadiusBottomLeft` | ✅ | ✅ | 完全相同 |
| | `borderRadiusBottomRight` | ✅ | ✅ | 完全相同 |
| **内边距** | `paddingTop` | ✅ | ✅ | 完全相同 |
| | `paddingBottom` | ✅ | ✅ | 完全相同 |
| | `paddingLeft` | ✅ | ✅ | 完全相同 |
| | `paddingRight` | ✅ | ✅ | 完全相同 |
| **外边距** | `marginTop` | ❌ | ✅ | ⚠️ Pillar 独有 |
| | `marginBottom` | ❌ | ✅ | ⚠️ Pillar 独有 |
| | `marginLeft` | ❌ | ✅ | ⚠️ Pillar 独有 |
| | `marginRight` | ❌ | ✅ | ⚠️ Pillar 独有 |
| **阴影** | `shadowColorHex` | ✅ | ✅ | 完全相同 |
| | `shadowOffsetX` | ✅ | ✅ | 完全相同 |
| | `shadowOffsetY` | ✅ | ✅ | 完全相同 |
| | `shadowBlurRadius` | ✅ | ✅ | 完全相同 |
| | `shadowSpreadRadius` | ✅ | ✅ | 完全相同 |
| **尺寸** | `width` | ✅ | ✅ | 完全相同 |
| | `height` | ✅ | ✅ | 完全相同 |

---

## 存储位置对比

| 配置类型 | CardStyleConfig | PillarStyleConfig |
|---------|----------------|------------------|
| **全局配置** | `LayoutTemplate.cardStyle` | `LayoutTemplate.globalPillarStyle` |
| **独立配置** | ❌ 不支持（卡片唯一） | ✅ `LayoutTemplate.perPillarStyles: Map<PillarType, PillarStyleConfig>` |
| **配置优先级** | N/A | `perPillarStyles[type] > globalPillarStyle > 默认值` |

---

## ViewModel API 对比

| 操作 | CardStyleConfig | PillarStyleConfig |
|-----|----------------|------------------|
| **读取全局配置** | `viewModel.cardStyle` | `viewModel.globalPillarStyle` |
| **读取独立配置** | N/A | `viewModel.getPillarStyle(PillarType.year)` |
| **更新全局配置** | `viewModel.updateCardStyle(config)` | `viewModel.updateGlobalPillarStyle(config)` |
| **更新独立配置** | N/A | `viewModel.updatePillarStyle(PillarType.year, config)` |
| **清除独立配置** | N/A | `viewModel.clearPillarStyle(PillarType.year)` |

---

## 类型转换方法对比

| 方法名 | CardStyleConfig | PillarStyleConfig | 返回类型 |
|-------|----------------|------------------|---------|
| `toBoxDecoration()` | ✅ | ✅ | `BoxDecoration` |
| `get padding` | ✅ | ✅ | `EdgeInsets?` |
| `get margin` | ❌ | ✅ | `EdgeInsets?` ⚠️ 独有 |
| `fromBoxDecoration()` | ✅ | ✅ | 工厂构造 |
| `fromLegacy()` | ✅ | ✅ | 工厂构造 |
| `copyWith()` | ✅ | ✅ | 实例方法 |

---

## UI 应用场景对比

### CardStyleConfig 应用场景

```dart
// 应用于整个卡片容器
Container(
  decoration: cardStyleConfig.toBoxDecoration(),
  padding: cardStyleConfig.padding,
  child: Column(
    children: [
      // 柱1, 柱2, 柱3, 柱4
    ],
  ),
)
```

**特点**:
- 全局唯一配置
- 作用于卡片最外层容器
- 不需要 margin（卡片本身与外界的间距由父布局控制）

### PillarStyleConfig 应用场景

```dart
// 应用于每个柱容器（可独立配置）
for (int i = 0; i < pillars.length; i++) {
  final pillarType = pillars[i].pillarType;
  final style = viewModel.getPillarStyle(pillarType); // ⚠️ 每柱可能不同
  
  Container(
    margin: style.margin, // ⚠️ 柱与柱之间的间距
    child: Container(
      padding: style.padding,
      decoration: style.toBoxDecoration(),
      child: Column(
        children: [
          // 天干行、地支行、纳音行...
        ],
      ),
    ),
  )
}
```

**特点**:
- 支持全局 + 每柱覆盖配置
- 需要 margin 控制柱间距
- 每柱可以有完全不同的样式（如：年柱红边框，日柱圆角，时柱阴影）

---

## Margin 实现差异详解

### 为什么 CardStyleConfig 不需要 Margin？

```dart
// 卡片外边距由父布局控制
Padding(
  padding: EdgeInsets.all(16), // ⚠️ 父布局负责
  child: Container(
    decoration: cardStyleConfig.toBoxDecoration(),
    padding: cardStyleConfig.padding,
    child: ...,
  ),
)
```

### 为什么 PillarStyleConfig 需要 Margin？

```dart
// 柱与柱之间需要间距
Row(
  children: [
    Container(
      margin: EdgeInsets.only(right: 8), // ⚠️ 年柱右侧间距
      decoration: pillarStyle1.toBoxDecoration(),
      child: ...,
    ),
    Container(
      margin: EdgeInsets.symmetric(horizontal: 4), // ⚠️ 月柱左右间距
      decoration: pillarStyle2.toBoxDecoration(),
      child: ...,
    ),
    // ... 日柱、时柱
  ],
)
```

**结论**: Margin 是 Pillar 的核心需求，用于控制柱间距，而 Card 的外边距由父布局控制。

---

## 独立配置支持对比

### CardStyleConfig: 全局唯一

```dart
class LayoutTemplate {
  final CardStyle cardStyle; // ⚠️ 整个布局只有一个卡片样式
}
```

**使用场景**:
- 所有卡片共享相同样式
- 统一修改（如：全局改为深色背景）

### PillarStyleConfig: 全局 + 每柱覆盖

```dart
class LayoutTemplate {
  final PillarStyleConfig? globalPillarStyle; // 默认样式
  final Map<PillarType, PillarStyleConfig>? perPillarStyles; // 每柱覆盖
}
```

**使用场景**:
- **全局样式**: 所有柱共享的基础样式（如：统一边框宽度 2px）
- **年柱独立**: 红色边框 + 圆角 8px
- **日柱独立**: 黄色背景 + 阴影效果
- **其余柱**: 回退到全局样式

**优先级规则**:
```
perPillarStyles[年柱] = 红色边框  // 最高优先级
    ↓
globalPillarStyle = 2px边框     // 中等优先级
    ↓
PillarStyleConfig.defaultStyle  // 最低优先级（硬编码默认值）
```

---

## 代码重复度分析

### 相同属性占比

| 属性类别 | 数量 | 重复度 | 复用方案 |
|---------|-----|-------|---------|
| 边框（border） | 3 个字段 | 100% | 复用 `_buildBorder()` 方法 |
| 背景（background） | 1 个字段 | 100% | 复用 `_parseHexColor()` 方法 |
| 圆角（borderRadius） | 5 个字段 | 100% | 复用 `_buildBorderRadius()` 方法 |
| 内边距（padding） | 4 个字段 | 100% | 复用 `get padding` getter |
| 阴影（shadow） | 5 个字段 | 100% | 复用 `_buildBoxShadows()` 方法 |
| 尺寸（size） | 2 个字段 | 100% | 无需转换 |
| **外边距（margin）** | 4 个字段 | 0% | ⚠️ Pillar 独有 |

**总计**: 24 个字段中，20 个（83%）与 CardStyleConfig 相同。

### 复用建议

#### 方案 1: 抽取公共工具类

```dart
// lib/utils/style_config_utils.dart
class StyleConfigUtils {
  static Border? buildBorder({
    double? width,
    String? colorHex,
  }) {
    if (width == null || width <= 0) return null;
    final color = parseHexColor(colorHex) ?? Colors.transparent;
    return Border.all(color: color, width: width);
  }
  
  static Color? parseHexColor(String? hex) {
    // 复用逻辑
  }
  
  static BorderRadius? buildBorderRadius({
    double? radius,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    // 复用逻辑
  }
  
  static List<BoxShadow>? buildBoxShadows({
    String? colorHex,
    double? offsetX,
    double? offsetY,
    double? blurRadius,
    double? spreadRadius,
  }) {
    // 复用逻辑
  }
}
```

#### 方案 2: 继承（不推荐）

```dart
// ❌ 问题：Dart 单继承限制，语义不清晰
class PillarStyleConfig extends CardStyleConfig {
  final double? marginTop;
  // ...
}
```

#### 方案 3: 组合（可选）

```dart
// ⚠️ 问题：增加间接性，API 变复杂
class PillarStyleConfig {
  final CardStyleConfig? baseStyle;
  final double? marginTop;
  // ...
  
  BoxDecoration toBoxDecoration() => baseStyle?.toBoxDecoration() ?? BoxDecoration();
}
```

**推荐**: ✅ **方案 1（公共工具类）** - 保持类的独立性，通过静态方法复用逻辑。

---

## 默认值对比

| 属性 | CardStyleConfig 默认值 | PillarStyleConfig 默认值 | 原因 |
|-----|----------------------|------------------------|-----|
| `borderWidth` | `0` | `0` | 默认无边框 |
| `borderRadius` | `0` | `0` | 默认直角 |
| `paddingTop/Bottom/Left/Right` | `16/16/16/16` | `16/16/16/16` | 统一内边距 |
| `marginTop/Bottom/Left/Right` | N/A | `8/8/8/8` | 柱间距 |
| `backgroundColor` | `transparent` | `transparent` | 默认透明 |
| `shadowBlurRadius` | `0` | `0` | 默认无阴影 |

**默认值工厂**:

```dart
// CardStyleConfig
static const CardStyleConfig defaultStyle = CardStyleConfig(
  paddingTop: 16,
  paddingBottom: 16,
  paddingLeft: 16,
  paddingRight: 16,
  borderWidth: 0,
  borderRadius: 0,
);

// PillarStyleConfig
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
```

---

## Sidebar UI 对比

### CardStyleConfig 编辑器

```
┌─────────────────────────────┐
│ 卡片样式配置                │
├─────────────────────────────┤
│ 边框配置                    │
│   宽度: [====○----] 2px     │
│   颜色: [🎨] #FF0000        │
├─────────────────────────────┤
│ 背景配置                    │
│   颜色: [🎨] #FFFFFF        │
├─────────────────────────────┤
│ 圆角配置                    │
│   半径: [===○-----] 8px     │
├─────────────────────────────┤
│ 内边距配置                  │
│   上: [====○----] 16px      │
│   下: [====○----] 16px      │
│   左: [====○----] 16px      │
│   右: [====○----] 16px      │
├─────────────────────────────┤
│ 阴影配置                    │
│   颜色: [🎨] #33000000      │
│   偏移X: [--○-------] 2px   │
│   偏移Y: [--○-------] 2px   │
│   模糊: [===○-----] 8px     │
└─────────────────────────────┘
```

### PillarStyleConfig 编辑器

```
┌─────────────────────────────┐
│ 柱样式配置                  │
│ 模式: [全局 | 每柱] ⚠️ 新增 │
├─────────────────────────────┤
│ 选择柱: [年柱 ▼] ⚠️ 每柱模式│
│ [清除独立样式] ⚠️ 回退全局  │
├─────────────────────────────┤
│ 外边距配置 ⚠️ 新增          │
│   上: [===○-----] 8px       │
│   下: [===○-----] 8px       │
│   左: [===○-----] 8px       │
│   右: [===○-----] 8px       │
├─────────────────────────────┤
│ 内边距配置                  │
│   上: [====○----] 16px      │
│   下: [====○----] 16px      │
│   左: [====○----] 16px      │
│   右: [====○----] 16px      │
├─────────────────────────────┤
│ 边框配置                    │
│   宽度: [====○----] 2px     │
│   颜色: [🎨] #FF0000        │
├─────────────────────────────┤
│ 背景配置                    │
│   颜色: [🎨] #FFFFFF        │
├─────────────────────────────┤
│ 圆角配置                    │
│   半径: [===○-----] 8px     │
│   [展开 4 角独立配置 ▼]     │
├─────────────────────────────┤
│ 阴影配置                    │
│   颜色: [🎨] #33000000      │
│   偏移X: [--○-------] 2px   │
│   偏移Y: [--○-------] 2px   │
│   模糊: [===○-----] 8px     │
└─────────────────────────────┘
```

**差异点**:
1. ⚠️ **模式切换**: PillarStyleConfig 支持全局/每柱模式切换
2. ⚠️ **柱选择器**: 每柱模式下可选择年/月/日/时柱
3. ⚠️ **外边距区**: PillarStyleConfig 独有
4. ⚠️ **清除按钮**: 清除独立样式，回退到全局

---

## 实施协同顺序建议

### 时间线

| 阶段 | 任务 | 预计时间 | 依赖 |
|-----|-----|---------|-----|
| 1️⃣ | CardStyleConfig 重构 | 5-7 天 | - |
| 2️⃣ | PillarStyleConfig 重构 | 10-14 天 | 阶段 1 完成 |
| 3️⃣ | 公共工具类抽取 | 2-3 天 | 阶段 1、2 完成 |
| 4️⃣ | 统一测试 | 3-5 天 | 阶段 3 完成 |

**总计**: 20-29 工作日（约 1 个月）

### 协同原则

1. **先 Card 后 Pillar**: CardStyleConfig 是基础，先完成以验证设计模式
2. **代码复用优先**: 实施过程中识别重复逻辑，及时抽取工具类
3. **向后兼容**: 保留旧版数据迁移路径（`fromLegacy()`）
4. **渐进式测试**: 每个阶段完成后独立测试，避免累积问题

---

## 潜在冲突场景分析

### 场景 1: 卡片边框 vs 柱边框

```dart
// 可能的视觉效果
┌─────────────────────────┐ ← Card.border (红色 2px)
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ │
│ │ 年│ │ 月│ │ 日│ │ 时│ │ ← Pillar.border (蓝色 1px)
│ └───┘ └───┘ └───┘ └───┘ │
└─────────────────────────┘
```

**结论**: ✅ 不冲突，各自独立控制。

### 场景 2: 卡片内边距 vs 柱外边距

```dart
// 叠加效果
┌─────────────────────────┐
│ ←── Card.padding: 16px  │
│   ┌───┐ ┌───┐ ┌───┐     │
│   │ 年│ │ 月│ │ 日│     │ ← Pillar.margin: 8px
│   └───┘ └───┘ └───┘     │
│                         │
└─────────────────────────┘
```

**结论**: ✅ 不冲突，叠加生效（总间距 = Card.padding + Pillar.margin）。

### 场景 3: 卡片背景 vs 柱背景

```dart
// 覆盖关系
┌─────────────────────────┐
│ Card.background: 白色   │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ │
│ │ 年│ │ 月│ │ 日│ │ 时│ │ ← Pillar.background: 黄色（覆盖）
│ └───┘ └───┘ └───┘ └───┘ │
└─────────────────────────┘
```

**结论**: ✅ 不冲突，柱背景覆盖卡片背景（符合预期）。

---

**文档结束** | 快速对比表 | 便于决策与实施规划
