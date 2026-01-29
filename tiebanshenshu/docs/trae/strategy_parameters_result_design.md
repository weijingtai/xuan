# Strategy模式参数与结果标准化设计

## 设计原则

### 1. 类型安全原则
- 所有Strategy必须定义明确的泛型参数 `<P extends BaseCalculationParams, R extends BaseCalculationResult>`
- 编译时类型检查，避免运行时错误

### 2. 接口统一原则
- 所有参数类继承自 `BaseCalculationParams`
- 所有结果类继承自 `BaseCalculationResult`
- 提供统一的验证、序列化、缓存机制

### 3. 可扩展原则
- 支持元数据附加
- 支持验证规则自定义
- 支持结果格式化自定义

---

## 基础接口设计

### BaseCalculationParams (基础参数类)

```dart
/// 所有算法参数的基础抽象类
abstract class BaseCalculationParams {
  /// 参数唯一标识符
  String get id;
  
  /// 参数创建时间
  DateTime get createdAt;
  
  /// 参数版本号
  String get version;
  
  /// 参数元数据
  Map<String, dynamic> get metadata;
  
  /// 参数验证
  ValidationResult validate();
  
  /// 序列化为JSON
  Map<String, dynamic> toJson();
  
  /// 参数摘要（用于缓存key生成）
  String get digest;
  
  /// 参数描述
  String get description;
}
```

### BaseCalculationResult (基础结果类)

```dart
/// 所有算法结果的基础抽象类
abstract class BaseCalculationResult {
  /// 结果唯一标识符
  String get id;
  
  /// 计算完成时间
  DateTime get completedAt;
  
  /// 计算耗时（毫秒）
  int get executionTimeMs;
  
  /// 使用的策略名称
  String get strategyName;
  
  /// 输入参数摘要
  String get inputDigest;
  
  /// 结果状态
  CalculationStatus get status;
  
  /// 错误信息（如果有）
  String? get errorMessage;
  
  /// 结果元数据
  Map<String, dynamic> get metadata;
  
  /// 序列化为JSON
  Map<String, dynamic> toJson();
  
  /// 结果摘要
  String get summary;
  
  /// 是否成功
  bool get isSuccess => status == CalculationStatus.success;
}
```

### 辅助枚举和类

```dart
/// 计算状态枚举
enum CalculationStatus {
  success,
  failed,
  timeout,
  cancelled,
  partialSuccess
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  static const ValidationResult valid = ValidationResult(isValid: true);
}
```

---

## 具体实现示例

### 1. 六亲考刻算法参数

```dart
/// 六亲考刻法计算参数
class LiuQinKaoKeParams extends BaseCalculationParams {
  final FourZhu fourZhu;
  final String gender;
  final bool useAdvancedMode;
  final Map<String, dynamic> customSettings;
  
  LiuQinKaoKeParams({
    required this.fourZhu,
    required this.gender,
    this.useAdvancedMode = false,
    this.customSettings = const {},
  });
  
  @override
  String get id => 'liuqin_kaoke_${fourZhu.hashCode}_${gender}_${DateTime.now().millisecondsSinceEpoch}';
  
  @override
  DateTime get createdAt => DateTime.now();
  
  @override
  String get version => '1.0.0';
  
  @override
  Map<String, dynamic> get metadata => {
    'algorithm': 'liu_qin_kao_ke',
    'gender': gender,
    'advanced_mode': useAdvancedMode,
    'four_zhu_summary': fourZhu.toString(),
    ...customSettings,
  };
  
  @override
  ValidationResult validate() {
    List<String> errors = [];
    List<String> warnings = [];
    
    // 验证性别
    if (!['男', '女'].contains(gender)) {
      errors.add('性别必须为"男"或"女"');
    }
    
    // 验证四柱
    if (fourZhu.year.isEmpty || fourZhu.month.isEmpty || 
        fourZhu.day.isEmpty || fourZhu.time.isEmpty) {
      errors.add('四柱信息不完整');
    }
    
    // 验证自定义设置
    if (customSettings.containsKey('max_iterations') && 
        customSettings['max_iterations'] is! int) {
      warnings.add('max_iterations应为整数类型');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'version': version,
    'four_zhu': fourZhu.toJson(),
    'gender': gender,
    'use_advanced_mode': useAdvancedMode,
    'custom_settings': customSettings,
    'metadata': metadata,
  };
  
  @override
  String get digest {
    final content = '${fourZhu.toString()}_${gender}_${useAdvancedMode}_${customSettings.toString()}';
    return content.hashCode.toString();
  }
  
  @override
  String get description => '六亲考刻法计算参数 - 性别:$gender, 四柱:${fourZhu.toString()}';
}
```

### 2. 六亲考刻算法结果

```dart
/// 六亲考刻法计算结果
class LiuQinKaoKeResult extends BaseCalculationResult {
  final String xianTianBaseGua;
  final String houTianBaseGua;
  final int xianTianBaseNumber;
  final int houTianBaseNumber;
  final List<CorrectionSixQinKe> xianTianGuaStageList;
  final List<CorrectionSixQinKe> houTianGuaStageList;
  final List<int> xianTianNumberList;
  final List<int> houTianNumberList;
  final Map<String, dynamic> calculationDetails;
  
  // 基础字段
  @override
  final String id;
  @override
  final DateTime completedAt;
  @override
  final int executionTimeMs;
  @override
  final String strategyName;
  @override
  final String inputDigest;
  @override
  final CalculationStatus status;
  @override
  final String? errorMessage;
  
  LiuQinKaoKeResult({
    required this.xianTianBaseGua,
    required this.houTianBaseGua,
    required this.xianTianBaseNumber,
    required this.houTianBaseNumber,
    required this.xianTianGuaStageList,
    required this.houTianGuaStageList,
    required this.xianTianNumberList,
    required this.houTianNumberList,
    this.calculationDetails = const {},
    required this.id,
    required this.completedAt,
    required this.executionTimeMs,
    required this.strategyName,
    required this.inputDigest,
    this.status = CalculationStatus.success,
    this.errorMessage,
  });
  
  @override
  Map<String, dynamic> get metadata => {
    'algorithm': 'liu_qin_kao_ke',
    'xian_tian_base_gua': xianTianBaseGua,
    'hou_tian_base_gua': houTianBaseGua,
    'xian_tian_base_number': xianTianBaseNumber,
    'hou_tian_base_number': houTianBaseNumber,
    'stage_count': xianTianGuaStageList.length + houTianGuaStageList.length,
    'number_count': xianTianNumberList.length + houTianNumberList.length,
    ...calculationDetails,
  };
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'completed_at': completedAt.toIso8601String(),
    'execution_time_ms': executionTimeMs,
    'strategy_name': strategyName,
    'input_digest': inputDigest,
    'status': status.name,
    'error_message': errorMessage,
    'xian_tian_base_gua': xianTianBaseGua,
    'hou_tian_base_gua': houTianBaseGua,
    'xian_tian_base_number': xianTianBaseNumber,
    'hou_tian_base_number': houTianBaseNumber,
    'xian_tian_gua_stage_list': xianTianGuaStageList.map((e) => e.toJson()).toList(),
    'hou_tian_gua_stage_list': houTianGuaStageList.map((e) => e.toJson()).toList(),
    'xian_tian_number_list': xianTianNumberList,
    'hou_tian_number_list': houTianNumberList,
    'calculation_details': calculationDetails,
    'metadata': metadata,
  };
  
  @override
  String get summary => '六亲考刻法结果 - 先天基本卦:$xianTianBaseGua($xianTianBaseNumber), 后天基本卦:$houTianBaseGua($houTianBaseNumber)';
}
```

### 3. 皇极取数法参数

```dart
/// 皇极取数法计算参数
class HuangJiQuShuParams extends BaseCalculationParams {
  final FourZhu fourZhu;
  final String gender;
  final int method; // 1, 2, 3 对应三种皇极取数法
  final bool includeDetailSteps;
  final Map<String, int> customNumbers;
  
  HuangJiQuShuParams({
    required this.fourZhu,
    required this.gender,
    required this.method,
    this.includeDetailSteps = true,
    this.customNumbers = const {},
  });
  
  @override
  String get id => 'huangji_qushu_${method}_${fourZhu.hashCode}_${gender}_${DateTime.now().millisecondsSinceEpoch}';
  
  @override
  ValidationResult validate() {
    List<String> errors = [];
    
    if (![1, 2, 3].contains(method)) {
      errors.add('皇极取数法方法必须为1、2或3');
    }
    
    if (!['男', '女'].contains(gender)) {
      errors.add('性别必须为"男"或"女"');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  @override
  String get description => '皇极取数法$method计算参数 - 性别:$gender';
  
  // ... 其他实现
}
```

### 4. 皇极取数法结果

```dart
/// 皇极取数法计算结果
class HuangJiQuShuResult extends BaseCalculationResult {
  final int yuanNumber;
  final int huiNumber;
  final int yunNumber;
  final int shiNumber;
  final List<int> tiaoWenNumbers;
  final List<String> calculationSteps;
  final Map<String, int> intermediateNumbers;
  
  // 基础字段
  @override
  final String id;
  @override
  final DateTime completedAt;
  @override
  final int executionTimeMs;
  @override
  final String strategyName;
  @override
  final String inputDigest;
  @override
  final CalculationStatus status;
  @override
  final String? errorMessage;
  
  HuangJiQuShuResult({
    required this.yuanNumber,
    required this.huiNumber,
    required this.yunNumber,
    required this.shiNumber,
    required this.tiaoWenNumbers,
    required this.calculationSteps,
    this.intermediateNumbers = const {},
    required this.id,
    required this.completedAt,
    required this.executionTimeMs,
    required this.strategyName,
    required this.inputDigest,
    this.status = CalculationStatus.success,
    this.errorMessage,
  });
  
  @override
  String get summary => '皇极取数法结果 - 元:$yuanNumber, 会:$huiNumber, 运:$yunNumber, 世:$shiNumber, 条文数:${tiaoWenNumbers.length}个';
  
  // ... 其他实现
}
```

---

## 增强的Strategy接口

```dart
/// 增强版计算策略接口
abstract class CalculationStrategy<P extends BaseCalculationParams, R extends BaseCalculationResult> {
  // 基础信息
  String get name;
  String get description;
  List<String> get detailSteps;
  String get school;
  String get version;
  
  // 参数和结果类型信息
  Type get parameterType => P;
  Type get resultType => R;
  
  // 支持的参数版本
  List<String> get supportedParameterVersions;
  
  // 核心计算方法
  Future<R> calculate(P params);
  
  // 参数验证
  ValidationResult validateParameters(P params) => params.validate();
  
  // 是否支持缓存
  bool get supportsCaching => true;
  
  // 缓存TTL（秒）
  int get cacheTtlSeconds => 3600;
  
  // 预估执行时间（毫秒）
  int get estimatedExecutionTimeMs => 1000;
  
  // 策略元数据
  Map<String, dynamic> get metadata => {
    'name': name,
    'description': description,
    'school': school,
    'version': version,
    'parameter_type': parameterType.toString(),
    'result_type': resultType.toString(),
    'supports_caching': supportsCaching,
    'cache_ttl_seconds': cacheTtlSeconds,
    'estimated_execution_time_ms': estimatedExecutionTimeMs,
  };
}
```

---

## 策略注册器增强

```dart
/// 策略注册器
class StrategyRegistry {
  static final Map<String, CalculationStrategy> _strategies = {};
  static final Map<Type, List<String>> _parameterTypeIndex = {};
  static final Map<Type, List<String>> _resultTypeIndex = {};
  
  /// 注册策略
  static void register<P extends BaseCalculationParams, R extends BaseCalculationResult>(
    CalculationStrategy<P, R> strategy
  ) {
    // 验证策略
    final validation = _validateStrategy(strategy);
    if (!validation.isValid) {
      throw ArgumentError('策略注册失败: ${validation.errors.join(', ')}');
    }
    
    _strategies[strategy.name] = strategy;
    
    // 建立类型索引
    _parameterTypeIndex.putIfAbsent(P, () => []).add(strategy.name);
    _resultTypeIndex.putIfAbsent(R, () => []).add(strategy.name);
  }
  
  /// 根据参数类型查找策略
  static List<CalculationStrategy> findByParameterType<P extends BaseCalculationParams>() {
    final strategyNames = _parameterTypeIndex[P] ?? [];
    return strategyNames.map((name) => _strategies[name]!).toList();
  }
  
  /// 根据结果类型查找策略
  static List<CalculationStrategy> findByResultType<R extends BaseCalculationResult>() {
    final strategyNames = _resultTypeIndex[R] ?? [];
    return strategyNames.map((name) => _strategies[name]!).toList();
  }
  
  /// 验证策略
  static ValidationResult _validateStrategy(CalculationStrategy strategy) {
    List<String> errors = [];
    
    if (strategy.name.isEmpty) {
      errors.add('策略名称不能为空');
    }
    
    if (_strategies.containsKey(strategy.name)) {
      errors.add('策略名称已存在: ${strategy.name}');
    }
    
    if (strategy.supportedParameterVersions.isEmpty) {
      errors.add('必须支持至少一个参数版本');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

---

## 使用示例

```dart
// 1. 注册策略
StrategyRegistry.register(SixQinCorrectKeCalculationStrategy());
StrategyRegistry.register(HuangJiQuShuStrategy1());

// 2. 创建参数
final params = LiuQinKaoKeParams(
  fourZhu: FourZhu(...),
  gender: '男',
  useAdvancedMode: true,
);

// 3. 验证参数
final validation = params.validate();
if (!validation.isValid) {
  print('参数验证失败: ${validation.errors}');
  return;
}

// 4. 执行计算
final strategy = StrategyRegistry.get<LiuQinKaoKeParams, LiuQinKaoKeResult>('六亲考刻法');
final result = await strategy.calculate(params);

// 5. 处理结果
if (result.isSuccess) {
  print('计算成功: ${result.summary}');
  print('执行时间: ${result.executionTimeMs}ms');
} else {
  print('计算失败: ${result.errorMessage}');
}
```

---

## 优势总结

### 1. 类型安全
- 编译时类型检查
- 避免运行时类型错误
- IDE智能提示支持

### 2. 接口统一
- 所有策略遵循相同的参数/结果规范
- 统一的验证、序列化机制
- 便于测试和调试

### 3. 可维护性
- 清晰的接口定义
- 标准化的错误处理
- 完整的元数据支持

### 4. 可扩展性
- 支持新算法快速接入
- 支持参数版本演进
- 支持自定义验证规则

### 5. 性能优化
- 支持结果缓存
- 支持执行时间监控
- 支持批量处理优化

这个设计确保了每个Strategy都有明确的输入输出契约，提升了整个系统的健壮性和可维护性。