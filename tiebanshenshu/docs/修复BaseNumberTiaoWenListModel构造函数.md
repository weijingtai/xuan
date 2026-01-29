# BaseNumberTiaoWenListModel 构造函数参数修复

## 问题描述

在 `huang_ji_interactive_strategy.dart` 第246-250行，`BaseNumberTiaoWenListModel` 构造函数调用缺少必需参数：

```
The named parameter 'name' is required, but there's no corresponding argument.
The named parameter 'description' is required, but there's no corresponding argument. 
The named parameter 'tiaoWenNumbers' is required, but there's no corresponding argument.
```

## 问题分析

`BaseNumberTiaoWenListModel` 继承自 `BaseNumberModel`，其构造函数需要以下必需参数：
- `baseNumber` (int) - 基础数值
- `name` (String) - 基础数名称  
- `description` (String) - 基础数描述
- `source` (BaseNumberSource) - 基础数来源
- `tiaoWenNumbers` (List<int>) - 条文编号列表
- `tiaoWenDataList` (List<TiaoWenDataModel>) - 条文数据列表

## 修复方案

### 修复前代码
```dart
final baseList = raw.finalNumbers
    .map(
      (n) => BaseNumberTiaoWenListModel(
        baseNumber: n,
        source: BaseNumberSource.calculated,  // 错误的枚举值
        tiaoWenDataList: raw.tiaoWenDataList ?? [],
      ),
    )
    .toList();
```

### 修复后代码
```dart
final baseList = raw.finalNumbers
    .map(
      (n) => BaseNumberTiaoWenListModel(
        baseNumber: n,
        name: '皇极基础数 $n',
        description: '通过皇极交互式计算得出的基础数',
        source: BaseNumberSource.interactive,
        tiaoWenNumbers: raw.tiaoWenDataList?.map((t) => t.id).toList() ?? [],
        tiaoWenDataList: raw.tiaoWenDataList ?? [],
      ),
    )
    .toList();
```

## 修复内容

1. **添加 `name` 参数**：使用动态名称 `'皇极基础数 $n'`
2. **添加 `description` 参数**：提供有意义的描述 `'通过皇极交互式计算得出的基础数'`
3. **修复 `source` 参数**：从错误的 `BaseNumberSource.calculated` 改为正确的 `BaseNumberSource.interactive`
4. **添加 `tiaoWenNumbers` 参数**：从 `tiaoWenDataList` 中提取 `id` 字段构建编号列表

## 技术细节

- `BaseNumberSource` 枚举包含：`yearZhu`, `monthZhu`, `dayZhu`, `timeZhu`, `combined`, `initial`, `secondary`, `custom`, `interactive`
- `TiaoWenDataModel` 使用 `id` 字段而不是 `number` 字段作为条文编号
- 使用空安全操作符 `?.` 和空合并操作符 `??` 处理可能为空的 `tiaoWenDataList`

## 验证结果

修复后运行 `dart analyze` 和 `flutter analyze`，确认：
- ✅ 构造函数参数错误已解决
- ✅ 项目编译成功
- ✅ 无严重错误，仅有信息性警告

## 影响范围

此修复仅影响 `HuangJiInteractiveStrategy.execute()` 方法中的结果构建逻辑，不影响其他功能模块。

## 修复时间

2024年12月19日