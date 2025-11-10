# Bug 修复总结：FourZhuEditPage 样式同步问题

**修复日期**: 2025-11-10
**问题**: 在 FourZhuEditPage 中，Sidebar 编辑干支样式后，只有字体大小生效，其他属性（颜色、字体家族、字体粗细等）全部失效

---

## 🐛 Bug 根本原因

### 三个断裂点

1. **断裂点 1**：`editor_sidebar_v2.dart` 的 `_applyTextStyleToConfig` 只提取了 3 个属性（fontFamily, fontSize, textColorHex），丢失了 fontWeight
2. **断裂点 2**：`editor_workspace.dart` 的 `_applyViewModelToNotifiers` 完全忽略了 RowConfig 的样式字段
3. **断裂点 3**（最致命）：`editor_workspace.dart` 构建 V3Card 时没有传递 `groupTextStyles` 参数

### 为什么只有 fontSize 生效？

因为 EditorWorkspace 传了 `globalFontSize`（全局字体大小），这是兜底设置。当 `groupTextStyles` 缺失时，V3Card 会应用全局字体大小，但其他属性因为没有全局设置而被忽略。

---

## ✅ 修复内容

### 1. 扩展 RowConfig 模型
**文件**: `lib/models/layout_template.dart`

**修改**:
- 添加 `String? fontWeight` 字段
- 更新 `copyWith`, `toJson`, `fromJson` 方法

```dart
class RowConfig {
  final String? fontWeight; // 新增字段
  // ...
}
```

### 2. 扩展样式提取方法
**文件**: `lib/widgets/editor_sidebar_v2.dart`

**修改**:
- 添加 `_fontWeightToString()` 辅助方法
- 添加 `_stringToFontWeight()` 辅助方法
- 更新 `_applyTextStyleToConfig()` 提取 fontWeight
- 更新 `_configToTextStyle()` 应用 fontWeight

```dart
RowConfig _applyTextStyleToConfig(RowConfig config, TextStyle style) {
  return config.copyWith(
    fontFamily: style.fontFamily,
    fontSize: style.fontSize,
    textColorHex: _colorToHex(style.color),
    fontWeight: _fontWeightToString(style.fontWeight), // 新增
  );
}
```

### 3. 构建 groupTextStyles 映射
**文件**: `lib/widgets/four_zhu_card_editor_page/editor_workspace.dart`

**修改**:
- 添加实例变量 `Map<TextGroup, TextStyle>? _groupTextStyles`
- 在 `_applyViewModelToNotifiers()` 中从 RowConfig 构建 groupTextStyles
- 添加辅助方法：
  - `_rowTypeToTextGroup()` - 映射 RowType 到 TextGroup
  - `_parseFontWeight()` - 解析字体粗细字符串

```dart
// 构建 groupTextStyles 映射：从 RowConfig 转换到 TextGroup -> TextStyle
final groupStyles = <TextGroup, TextStyle>{};
for (final config in configs) {
  final textGroup = _rowTypeToTextGroup(config.type);
  if (textGroup != null) {
    groupStyles[textGroup] = TextStyle(
      fontFamily: config.fontFamily,
      fontSize: config.fontSize,
      color: _parseHexColor(config.textColorHex),
      fontWeight: _parseFontWeight(config.fontWeight),
    );
  }
}
_groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;
```

### 4. 传递 groupTextStyles 给 V3Card
**文件**: `lib/widgets/four_zhu_card_editor_page/editor_workspace.dart`

**修改**:
- 在 `EditableFourZhuCardV3` 构造中添加 `groupTextStyles: _groupTextStyles` 参数

```dart
EditableFourZhuCardV3(
  pillarsNotifier: _pillarsNotifier,
  rowListNotifier: _rowListNotifier,
  paddingNotifier: _paddingNotifier,
  gender: Gender.male,
  globalFontFamily: globalFamily,
  globalFontSize: globalSize,
  globalFontColor: globalColor,
  groupTextStyles: _groupTextStyles, // 🔧 关键修复
)
```

---

## 🎯 修复效果

修复后，FourZhuEditPage 的 Sidebar 中编辑的所有样式属性都能正确应用到 EditorWorkspace 的 V3Card：

- ✅ 字体家族（fontFamily）
- ✅ 字体大小（fontSize）
- ✅ 字体颜色（color）
- ✅ 字体粗细（fontWeight）

---

## 📝 数据流（修复后）

```
[Sidebar 编辑样式]
  ↓
ColorfulTextStyleEditorWidget._emit()
  ↓ (TextStyle: 包含 fontFamily, fontSize, color, fontWeight)
_applyTextStyleToConfig(config, style)
  ↓ (RowConfig: 包含所有样式字段)
FourZhuEditorViewModel.updateRowStyle()
  ↓ (更新 _currentTemplate.rowConfigs)
notifyListeners()
  ↓
EditorWorkspace._applyViewModelToNotifiers()
  ↓ (构建 groupTextStyles: Map<TextGroup, TextStyle>)
更新 _groupTextStyles
  ↓
EditableFourZhuCardV3(groupTextStyles: _groupTextStyles)
  ↓
V3Card._resolveTextStyle() 应用分组样式
  ↓
[UI 更新完成]
```

---

## 🧪 测试建议

### 手动测试步骤
1. 打开 FourZhuEditPage
2. 在 Sidebar 中选择"天干行"
3. 修改以下属性：
   - 字体家族：改为"楷体"
   - 字体大小：改为 20
   - 字体颜色：改为红色 (#FF0000)
   - 字体粗细：改为 Bold (w700)
4. 检查 EditorWorkspace 中的 V3Card 是否所有属性都正确显示

### 预期结果
- 天干文字显示为"楷体"
- 字体大小为 20
- 颜色为红色
- 粗体显示

---

## 📊 修改文件统计

| 文件 | 修改内容 | 行数变化 |
|------|---------|---------|
| `layout_template.dart` | 添加 fontWeight 字段 | +7 行 |
| `editor_sidebar_v2.dart` | 添加 fontWeight 转换方法 | +44 行 |
| `editor_workspace.dart` | 构建 groupTextStyles 并传递 | +77 行 |

**总计**: +128 行（不含注释和空行）

---

## 🔗 相关文档

- [完整分析报告](./summary_v1.md)
- [FourZhuEditPage 架构](../../EditableFourZhuCardV3_refactor/)
- [V3 Card 样式系统](../../EditableFourZhuCardV3/)

---

**修复完成** ✅
