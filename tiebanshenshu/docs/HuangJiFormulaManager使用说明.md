# HuangJiFormulaManager 使用说明

## 概述

`HuangJiFormulaManager` 是一个用于管理皇极计算公式的单例管理器，负责从 JSON 文件中加载、缓存和管理 `HuangJiCalculationFormula` 实例。

## 主要功能

- **单例模式**：确保全局只有一个管理器实例
- **异步加载**：从 `assets/formulas` 目录加载公式 JSON 文件
- **缓存管理**：内存中缓存已加载的公式，提高查询性能
- **多种查询方式**：支持按 ID、名称查询公式
- **状态管理**：提供初始化状态检查和重置功能
- **错误处理**：优雅处理 JSON 解析错误和文件加载失败

## 基本使用

### 1. 获取管理器实例

```dart
final manager = HuangJiFormulaManager.instance;
```

### 2. 初始化管理器

```dart
// 初始化并加载所有公式
final loadedCount = await manager.initialize();
print('成功加载 $loadedCount 个公式');

// 检查是否已初始化
if (manager.isInitialized) {
  print('管理器已初始化，共有 ${manager.formulaCount} 个公式');
}
```

### 3. 查询公式

#### 按 ID 查询
```dart
final formula = manager.getFormulaById(1);
if (formula != null) {
  print('找到公式: ${formula.name}');
} else {
  print('未找到指定 ID 的公式');
}
```

#### 按名称查询
```dart
final formula = manager.getFormulaByName('皇极取数法一');
if (formula != null) {
  print('找到公式: ${formula.description}');
}
```

#### 检查公式是否存在
```dart
if (manager.hasFormula(1)) {
  print('ID 为 1 的公式存在');
}

if (manager.hasFormulaByName('皇极取数法一')) {
  print('名为"皇极取数法一"的公式存在');
}
```

### 4. 获取公式列表

#### 获取所有公式
```dart
final allFormulas = manager.getAllFormulas();
for (final formula in allFormulas) {
  print('公式: ${formula.name} (ID: ${formula.id})');
}
```

#### 获取所有公式名称
```dart
final allNames = manager.getAllFormulaNames();
print('可用公式: ${allNames.join(', ')}');
```

#### 获取公式信息摘要
```dart
final allInfo = manager.getAllFormulasInfo();
for (final info in allInfo) {
  print('公式: ${info['name']} - ${info['description']}');
  print('  组数: ${info['groupCount']}, 总公式数: ${info['totalFormulas']}');
}
```

### 5. 获取单个公式信息
```dart
final info = manager.getFormulaInfo(1);
if (info != null) {
  print('公式信息:');
  print('  ID: ${info['id']}');
  print('  名称: ${info['name']}');
  print('  描述: ${info['description']}');
  print('  组数: ${info['groupCount']}');
  print('  总公式数: ${info['totalFormulas']}');
}
```

## 高级功能

### 重新加载公式
```dart
// 重新从文件加载所有公式
final reloadedCount = await manager.reload();
print('重新加载了 $reloadedCount 个公式');
```

### 重置管理器
```dart
// 清空缓存并重置状态
manager.reset();
print('管理器已重置');
```

## 错误处理

管理器内置了完善的错误处理机制：

```dart
try {
  await manager.initialize();
  
  // 使用管理器进行查询
  final formula = manager.getFormulaById(1);
  
} catch (e) {
  print('初始化失败: $e');
  // 处理错误情况
}
```

### 常见错误情况

1. **未初始化就调用查询方法**：会抛出 `StateError`
2. **JSON 文件格式错误**：会跳过该文件并记录错误
3. **文件加载失败**：会跳过该文件并继续加载其他文件

## 最佳实践

### 1. 应用启动时初始化
```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeFormulas();
  }
  
  Future<void> _initializeFormulas() async {
    try {
      final count = await HuangJiFormulaManager.instance.initialize();
      print('成功加载 $count 个公式');
    } catch (e) {
      print('公式加载失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(/* ... */);
  }
}
```

### 2. 在需要时检查初始化状态
```dart
Widget buildFormulaSelector() {
  final manager = HuangJiFormulaManager.instance;
  
  if (!manager.isInitialized) {
    return CircularProgressIndicator();
  }
  
  final formulas = manager.getAllFormulas();
  return DropdownButton<HuangJiCalculationFormula>(
    items: formulas.map((formula) => DropdownMenuItem(
      value: formula,
      child: Text(formula.name),
    )).toList(),
    onChanged: (formula) {
      // 处理公式选择
    },
  );
}
```

### 3. 使用公式信息进行 UI 展示
```dart
Widget buildFormulaCard(int formulaId) {
  final manager = HuangJiFormulaManager.instance;
  final info = manager.getFormulaInfo(formulaId);
  
  if (info == null) {
    return Card(child: Text('公式不存在'));
  }
  
  return Card(
    child: ListTile(
      title: Text(info['name']),
      subtitle: Text(info['description']),
      trailing: Chip(
        label: Text('${info['groupCount']} 组'),
      ),
    ),
  );
}
```

## 文件结构

管理器从以下位置加载公式文件：
```
assets/
  formulas/
    huang_ji_1_formula.json
    huang_ji_2_formula.json
    huang_ji_3_formula.json
    ...
```

每个 JSON 文件应包含完整的 `HuangJiCalculationFormula` 数据结构。

## 性能考虑

- **内存缓存**：所有公式加载后保存在内存中，查询速度快
- **延迟加载**：只在调用 `initialize()` 时才加载文件
- **单例模式**：避免重复创建管理器实例
- **批量加载**：一次性加载所有公式文件，减少 I/O 操作

## 测试

项目包含完整的单元测试，覆盖所有主要功能：

```bash
flutter test test/features/huang_ji_formula_manager_test.dart
```

测试覆盖：
- 单例模式验证
- 初始化和重置功能
- 公式查询和存在性检查
- 错误处理和边界条件
- JSON 格式验证

## 注意事项

1. **必须先初始化**：在使用任何查询方法前必须调用 `initialize()`
2. **异步操作**：初始化和重新加载是异步操作，需要使用 `await`
3. **错误容忍**：单个文件加载失败不会影响其他文件的加载
4. **状态检查**：建议在查询前检查 `isInitialized` 状态
5. **内存管理**：如需释放内存，可调用 `reset()` 方法

## 集成示例

完整的集成示例：

```dart
import 'package:tiebanshenshu/features/huang_ji_formula_manager.dart';

class FormulaService {
  static final _manager = HuangJiFormulaManager.instance;
  
  static Future<void> initialize() async {
    await _manager.initialize();
  }
  
  static List<String> getAvailableFormulaNames() {
    return _manager.getAllFormulaNames();
  }
  
  static HuangJiCalculationFormula? getFormula(String name) {
    return _manager.getFormulaByName(name);
  }
  
  static bool isReady() {
    return _manager.isInitialized;
  }
}
```

这样可以在应用的其他部分通过 `FormulaService` 来使用公式管理功能。