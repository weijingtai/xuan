# 八刻秘数表考刻功能 - 技术架构设计

## 1. 架构概述

本功能采用Clean Architecture分层架构,参考项目中`huang_ji` feature的设计模式。

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────────┐  ┌──────────────────────────────┐ │
│  │   Interactive   │  │        ViewModel             │ │
│  │      Page       │◄─┤  (ChangeNotifier Pattern)    │ │
│  └─────────────────┘  └──────────────────────────────┘ │
└───────────────────────────────▲─────────────────────────┘
                                │
┌───────────────────────────────┼─────────────────────────┐
│                    Domain Layer│                         │
│  ┌─────────────────────────────┴──────────────────────┐ │
│  │              UseCase (Business Logic)              │ │
│  │  - initializeSession()                             │ │
│  │  - prepareKeSelectionData()                        │ │
│  │  - submitUserSelection()                           │ │
│  │  - calculateGua()                                  │ │
│  │  - calculateFinalTiaoWen()                         │ │
│  │  - rollback()                                      │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                ▲                         ▲
                │                         │
┌───────────────┼─────────────────────────┼───────────────┐
│  Data Layer   │                         │               │
│  ┌────────────┴──────────┐  ┌──────────┴─────────────┐ │
│  │  SessionManager       │  │  CalculationStrategy   │ │
│  │  - State Management   │  │  - Gua Calculation     │ │
│  │  - Snapshot/Rollback  │  │  - TiaoWen Calculation │ │
│  └───────────────────────┘  └────────────────────────┘ │
│          │                            │                 │
│  ┌───────┴────────┐          ┌───────┴────────────┐    │
│  │  Repository    │          │  External Strategy │    │
│  │  - Session     │          │  - JiaZe           │    │
│  │  - TiaoWen     │          │  - GanZhiHe        │    │
│  └────────────────┘          └────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 2. 模块设计

### 2.1 Feature目录结构

```
lib/features/kao_ke/
├── kao_ke_session_models.dart          # 会话数据模型
├── kao_ke_session_models.g.dart        # 生成的序列化代码
├── kao_ke_session_manager.dart         # 会话管理器
├── kao_ke_calculation_strategy.dart    # 计算策略接口
├── kao_ke_calculation_strategy_impl.dart # 计算策略实现
├── kao_ke_use_case.dart                # 业务逻辑编排
├── kao_ke_view_model.dart              # 视图模型
├── kao_ke_interactive_page.dart        # 主交互页面
└── widgets/
    ├── ke_selection_table.dart         # 刻选择表格
    ├── tiao_wen_detail_dialog.dart     # 条文详情对话框
    ├── gua_display_widget.dart         # 卦象展示
    ├── method_selector_widget.dart     # 计算方法选择器
    └── final_result_display.dart       # 最终结果展示
```

### 2.2 核心类设计

#### 2.2.1 Session Models

```dart
// 会话阶段枚举
enum KaoKeSessionPhase {
  initialized,                  // 初始化
  keSelectionReady,            // 刻选择准备就绪
  keSelected,                  // 已选择刻
  baseNumberCalculated,        // 基础数已计算(卦象)
  finalCalculationComplete,    // 最终计算完成
}

// 会话状态枚举
enum KaoKeSessionStatus {
  notStarted,
  inProgress,
  waitingForSelection,
  completed,
  cancelled,
  error,
}

// 计算方法枚举
enum KaoKeCalculationMethod {
  baGuaJiaZe,          // 八卦加则
  liuYaoGanZhiHe,      // 爻干支和数法
}

// 选择记录
class KeSelectionRecord {
  DiZhi shiChen;
  EigthKe ke;
  int tiaoWenNumber;
  String cipherText;
  String originalText;
  DateTime selectedAt;
}

// 卦象计算结果
class GuaCalculationResult {
  int shangGuaNumber;
  int xiaGuaNumber;
  String shangGuaName;
  String xiaGuaName;
  String fullGuaName;
  String calculationDetail;
}

// 会话快照
class KaoKeSessionSnapshot {
  String snapshotId;
  KaoKeSessionPhase phase;
  DateTime timestamp;
  Map<String, dynamic> state;
}

// 主会话类
class KaoKeSession {
  String sessionId;
  String sessionName;
  EightChars eightChars;
  KeSelectionRecord? keSelection;
  GuaCalculationResult? guaResult;
  Set<KaoKeCalculationMethod> selectedMethods;
  Map<KaoKeCalculationMethod, List<TiaoWenResult>>? finalResults;
  KaoKeSessionPhase currentPhase;
  List<KaoKeSessionSnapshot> phaseHistory;
  KaoKeSessionStatus status;
  // ... timestamps and metadata
}
```

#### 2.2.2 Session Manager

```dart
class KaoKeSessionManager {
  final SessionRepository _sessionRepository;
  final KaoKeCalculationStrategy _calculationStrategy;

  // 创建新会话
  Future<KaoKeSession> createSession({
    required EightChars eightChars,
    String? sessionName,
  });

  // 恢复会话
  Future<KaoKeSession?> restoreSession(String sessionId);

  // 保存会话
  Future<void> saveSession(KaoKeSession session);

  // 推进到下一阶段
  Future<KaoKeSession> advanceToPhase({
    required KaoKeSession session,
    required KaoKeSessionPhase targetPhase,
  });

  // 创建快照
  KaoKeSessionSnapshot createSnapshot(KaoKeSession session);

  // 回滚到快照
  Future<KaoKeSession> rollbackToSnapshot({
    required KaoKeSession session,
    required String snapshotId,
  });
}
```

#### 2.2.3 Calculation Strategy

```dart
abstract class KaoKeCalculationStrategy {
  // 计算卦象
  GuaCalculationResult calculateGua(int baseNumber);

  // 计算单个方法的条文
  Future<List<TiaoWenResult>> calculateTiaoWenByMethod({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required KaoKeCalculationMethod method,
    required EightChars eightChars,
  });
}

class KaoKeCalculationStrategyImpl implements KaoKeCalculationStrategy {
  final XianHoutianJiaZeStrategy _jiaZeStrategy;
  final LiuYaoGanZhiHeStrategy _ganZhiHeStrategy;
  final TiaoWenRepository _tiaoWenRepository;

  // Implementation...
}
```

#### 2.2.4 UseCase

```dart
class KaoKeUseCase {
  final KaoKeSessionManager _sessionManager;
  final KaoKeCalculationStrategy _calculationStrategy;
  final KaoKeConstants _kaoKeConstants;
  final TiaoWenRepository _tiaoWenRepository;

  // 1. 初始化会话
  Future<KaoKeSession> initializeSession({
    required EightChars eightChars,
    String? sessionName,
  });

  // 2. 准备刻选择数据
  Map<DiZhi, List<KaoEigthKeNumber>> prepareKeSelectionData();

  // 3. 提交用户选择
  Future<KaoKeSession> submitKeSelection({
    required KaoKeSession session,
    required KaoEigthKeNumber selectedKe,
  });

  // 4. 计算卦象
  Future<KaoKeSession> calculateGua(KaoKeSession session);

  // 5. 更新计算方法选择
  Future<KaoKeSession> updateCalculationMethods({
    required KaoKeSession session,
    required Set<KaoKeCalculationMethod> methods,
  });

  // 6. 计算最终条文
  Future<KaoKeSession> calculateFinalTiaoWen(KaoKeSession session);

  // 7. 回滚
  Future<KaoKeSession> rollbackToPhase({
    required KaoKeSession session,
    required KaoKeSessionPhase targetPhase,
  });
}
```

#### 2.2.5 ViewModel

```dart
class KaoKeViewModel extends ChangeNotifier {
  final KaoKeUseCase _useCase;

  KaoKeSession? _session;
  bool _isLoading = false;
  String? _error;

  // Getters
  KaoKeSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取12时辰×8刻的完整数据
  Map<DiZhi, List<KaoEigthKeNumber>> get keSelectionData;

  // 判断某个时辰是否为用户出生时辰
  bool isUserBirthShiChen(DiZhi shiChen);

  // Actions
  Future<void> initialize(EightChars eightChars);
  Future<void> selectKe(KaoEigthKeNumber selectedKe);
  Future<void> toggleCalculationMethod(KaoKeCalculationMethod method);
  Future<void> calculateFinalResults();
  Future<void> rollback(KaoKeSessionPhase targetPhase);
}
```

## 3. 数据流设计

### 3.1 初始化流程

```
User Input (EightChars)
  ↓
ViewModel.initialize()
  ↓
UseCase.initializeSession()
  ↓
SessionManager.createSession()
  ↓
UseCase.prepareKeSelectionData()
  ↓
Load KaoKeConstants
  ↓
Update ViewModel State
  ↓
UI Displays 12×8 Table
```

### 3.2 选择刻流程

```
User Clicks Cell
  ↓
Show TiaoWenDetailDialog
  ↓
User Confirms Selection
  ↓
ViewModel.selectKe()
  ↓
UseCase.submitKeSelection()
  ↓
SessionManager.advanceToPhase(keSelected)
  ↓
UseCase.calculateGua()
  ↓
CalculationStrategy.calculateGua()
  ↓
Update Session with GuaResult
  ↓
SessionManager.advanceToPhase(baseNumberCalculated)
  ↓
Update ViewModel State
  ↓
UI Displays Gua Result
```

### 3.3 计算最终条文流程

```
User Confirms Method Selection
  ↓
ViewModel.calculateFinalResults()
  ↓
UseCase.calculateFinalTiaoWen()
  ↓
For each selected method:
  ├─ CalculationStrategy.calculateTiaoWenByMethod()
  ├─ Call external strategy (JiaZe or GanZhiHe)
  └─ Query TiaoWenRepository for content
  ↓
Aggregate results by method
  ↓
SessionManager.advanceToPhase(finalCalculationComplete)
  ↓
Update ViewModel State
  ↓
UI Displays Final Results (Tabbed by Method)
```

## 4. 依赖注入配置

### 4.1 Provider配置

```dart
// 在 infrastructure/di/kao_ke_providers.dart
class KaoKeProviders {
  static List<SingleChildWidget> get providers => [
    // Strategy
    Provider<KaoKeCalculationStrategy>(
      create: (context) => KaoKeCalculationStrategyImpl(
        jiaZeStrategy: context.read<XianHoutianJiaZeStrategy>(),
        ganZhiHeStrategy: context.read<LiuYaoGanZhiHeStrategy>(),
        tiaoWenRepository: context.read<TiaoWenRepository>(),
      ),
    ),

    // Session Manager
    Provider<KaoKeSessionManager>(
      create: (context) => KaoKeSessionManager(
        sessionRepository: context.read<SessionRepository>(),
        calculationStrategy: context.read<KaoKeCalculationStrategy>(),
      ),
    ),

    // UseCase
    Provider<KaoKeUseCase>(
      create: (context) => KaoKeUseCase(
        sessionManager: context.read<KaoKeSessionManager>(),
        calculationStrategy: context.read<KaoKeCalculationStrategy>(),
        kaoKeConstants: KaoKeConstants(),
        tiaoWenRepository: context.read<TiaoWenRepository>(),
      ),
    ),

    // ViewModel
    ChangeNotifierProvider<KaoKeViewModel>(
      create: (context) => KaoKeViewModel(
        useCase: context.read<KaoKeUseCase>(),
      ),
    ),
  ];
}
```

## 5. 错误处理策略

### 5.1 异常类型

```dart
// 无效的阶段转换
class InvalidPhaseTransitionException implements Exception {
  final KaoKeSessionPhase currentPhase;
  final KaoKeSessionPhase targetPhase;
}

// 未选择刻
class KeNotSelectedException implements Exception {}

// 无效的基础数
class InvalidBaseNumberException implements Exception {
  final int baseNumber;
}

// 计算方法未选择
class NoMethodSelectedException implements Exception {}
```

### 5.2 错误处理流程

- ViewModel层捕获所有异常
- 更新_error状态
- 显示SnackBar或Dialog提示用户
- 记录日志用于调试

## 6. 性能优化

### 6.1 数据加载优化

- KaoKeConstants数据使用lazy loading
- 条文内容使用批量查询减少Repository调用次数
- 卦象计算结果缓存

### 6.2 UI渲染优化

- Table使用DataTable with pagination
- 条文详情对话框使用FutureBuilder异步加载
- 长列表使用ListView.builder
- 图片资源使用缓存

## 7. 测试策略

### 7.1 单元测试

- GuaCalculationHelper的卦象计算逻辑
- KaoKeCalculationStrategy的各个计算方法
- SessionManager的状态管理和快照功能

### 7.2 Widget测试

- KeSelectionTable的交互行为
- TiaoWenDetailDialog的显示和关闭
- MethodSelectorWidget的多选逻辑

### 7.3 集成测试

- 完整的用户流程测试
- 会话回滚功能测试
- 多计算方法并行测试

---

## 8. 技术选型

| 类别 | 技术选择 | 说明 |
|------|---------|------|
| 状态管理 | Provider + ChangeNotifier | 与项目保持一致 |
| 序列化 | json_serializable | 自动生成序列化代码 |
| 依赖注入 | Provider | 遵循现有DI模式 |
| 路由管理 | Named Routes | 使用Navigator.generateRoute |
| 数据持久化 | SessionRepository | 复用现有Repository |
| 异步处理 | Future + async/await | Dart标准异步模式 |

## 9. 扩展性设计

### 9.1 新增计算方法

实现`KaoKeCalculationStrategy`接口,在enum中添加新方法类型即可。

### 9.2 新增刻数据源

修改`KaoKeConstants`或从Repository加载,UseCase层无需修改。

### 9.3 自定义UI主题

UI组件支持Theme定制,可通过ThemeData注入不同样式。
