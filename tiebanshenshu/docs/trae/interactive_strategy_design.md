# 铁板神数交互式Strategy设计方案

## 1. 设计背景

铁板神数中的某些算法（如皇极取数法）需要在计算过程中等待用户确认：
- 计算出初始条文数后，需要用户确认是否符合实际情况
- 如不符合，需要按照"30"递加或递减直到找到对应的条文数
- 这种交互式计算需要特殊的Strategy设计，并集成到MVVM架构中

## 1.1 架构流程设计

### 标准计算流程
```
UI -> ViewModel -> UseCase(Strategy + Repository) -> ViewModel -> UI
```

### 交互式计算流程
```
UI -> ViewModel -> CallbackUseCase(Strategy + Repository + CallbackFunc<Data>) 
   -> ViewModel -> UI(user input) -> ViewModel -> CallbackUseCase#next -> ViewModel -> UI
```

## 2. 核心设计理念

### 2.1 简单交互模式
将交互式算法设计为简单的单步交互：
- **计算状态**：正在进行计算
- **等待确认状态**：需要用户输入确认
- **完成状态**：计算结束

### 2.2 回调机制集成
通过UseCase的回调机制处理用户交互：
- Strategy通过UseCase的回调机制处理用户交互
- 与MVVM架构无缝集成
- 支持取消和重试机制

## 3. 接口设计

### 3.1 UseCase层设计

```dart
/// 标准UseCase接口
abstract class UseCase<P, R> {
  Future<R> execute(P params);
}

/// 交互式UseCase接口
abstract class CallbackUseCase<P, R, D> {
  /// 开始执行，可能需要用户交互
  Future<CallbackUseCaseResult<R, D>> execute(
    P params,
    CallbackFunction<D> callback,
  );
  
  /// 处理用户输入后继续执行
  Future<R> next(D userData);
}

/// 回调函数类型定义
typedef CallbackFunction<D> = Future<D> Function(UserInteractionRequest request);

/// CallbackUseCase执行结果
class CallbackUseCaseResult<R, D> {
  final bool needsUserInput;
  final R? finalResult;
  final UserInteractionRequest? interactionRequest;
  
  const CallbackUseCaseResult({
    required this.needsUserInput,
    this.finalResult,
    this.interactionRequest,
  });
  
  /// 创建需要用户输入的结果
  factory CallbackUseCaseResult.needsInput(UserInteractionRequest request) {
    return CallbackUseCaseResult(
      needsUserInput: true,
      interactionRequest: request,
    );
  }
  
  /// 创建已完成的结果
  factory CallbackUseCaseResult.completed(R result) {
    return CallbackUseCaseResult(
      needsUserInput: false,
      finalResult: result,
    );
  }
}
```

### 3.2 交互式Strategy基础接口

```dart
/// 用户交互类型枚举
enum UserInteractionType {
  confirmation,     // 确认类型（是/否）
  selection,        // 选择类型（多选一）
  input,           // 输入类型（文本/数字）
  adjustment,      // 调整类型（递增/递减）
}

/// 用户交互请求
class UserInteractionRequest {
  final String id;
  final UserInteractionType type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final List<String>? options; // 选择类型时的选项
  final String? defaultValue;
  final Map<String, dynamic>? constraints; // 输入约束
  
  UserInteractionRequest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.data,
    this.options,
    this.defaultValue,
    this.constraints,
  });
}

/// 用户交互响应
class UserInteractionResponse {
  final String requestId;
  final bool confirmed;
  final String? selectedValue;
  final String? inputValue;
  final Map<String, dynamic>? additionalData;
  
  UserInteractionResponse({
    required this.requestId,
    required this.confirmed,
    this.selectedValue,
    this.inputValue,
    this.additionalData,
  });
}

/// 交互式计算状态
enum InteractiveCalculationStatus {
  calculating,      // 正在计算
  waitingForUser,   // 等待用户交互
  userCancelled,    // 用户取消
  completed,        // 计算完成
  error,           // 计算错误
}

/// 交互式计算结果
abstract class InteractiveCalculationResult<R extends BaseCalculationResult> {
  final String id;
  final InteractiveCalculationStatus status;
  final R? finalResult;
  final UserInteractionRequest? pendingRequest;
  final String? errorMessage;
  final List<String> executionLog;
  final Map<String, dynamic> intermediateData;
  
  InteractiveCalculationResult({
    required this.id,
    required this.status,
    this.finalResult,
    this.pendingRequest,
    this.errorMessage,
    this.executionLog = const [],
    this.intermediateData = const {},
  });
  
  bool get isCompleted => status == InteractiveCalculationStatus.completed;
  bool get needsUserInput => status == InteractiveCalculationStatus.waitingForUser;
  bool get hasError => status == InteractiveCalculationStatus.error;
}
```

### 3.2 交互式Strategy接口

```dart
/// 交互式计算策略接口
abstract class InteractiveCalculationStrategy<P extends BaseCalculationParams, R extends BaseCalculationResult> 
    extends CalculationStrategy<P, R> {
  
  /// 使用回调方式进行交互式计算
  Future<R> calculateWithCallback(
    P params,
    Future<UserInteractionResponse> Function(UserInteractionRequest) callback,
  );
  
  /// 验证用户响应是否有效
  bool validateUserResponse(
    UserInteractionRequest request,
    UserInteractionResponse response,
  );
  
  /// 是否支持交互式计算
  @override
  bool get supportsInteractiveMode => true;
}

/// 交互式计算上下文
class InteractiveCalculationContext<P extends BaseCalculationParams, R extends BaseCalculationResult> {
  final P params;
  final Map<String, dynamic> intermediateData;
  final Future<UserInteractionResponse> Function(UserInteractionRequest) callback;
  
  InteractiveCalculationContext({
    required this.params,
    required this.intermediateData,
    required this.callback,
  });
  
  /// 请求用户输入
  Future<UserInteractionResponse> requestUserInput(UserInteractionRequest request) {
    return callback(request);
  }
  
  /// 更新中间数据
  InteractiveCalculationContext<P, R> updateData(Map<String, dynamic> newData) {
    return InteractiveCalculationContext(
      params: params,
      intermediateData: {...intermediateData, ...newData},
      callback: callback,
    );
  }
}
```

## 4. 皇极取数法具体实现

### 4.1 参数和结果类

```dart
/// 皇极取数法参数
class HuangJiQuShuParams extends BaseCalculationParams {
  final FourZhu fourZhu;
  final String gender;
  final int method;
  
  HuangJiQuShuParams({
    required this.fourZhu,
    required this.gender,
    required this.method,
  });
  
  @override
  String get id => 'huangji_${method}_${fourZhu.hashCode}_${gender}';
  
  @override
  ValidationResult validate() {
    List<String> errors = [];
    if (![1, 2, 3].contains(method)) {
      errors.add('皇极取数法方法必须为1、2或3');
    }
    if (!['男', '女'].contains(gender)) {
      errors.add('性别必须为"男"或"女"');
    }
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
  
  @override
  String get description => '皇极取数法$method计算 - 性别:$gender';
}

/// 皇极取数法结果
class HuangJiQuShuResult extends BaseCalculationResult {
  final int yuanShu;          // 元数
  final int huiShu;           // 会数
  final int yunShu;           // 运数
  final int shiShu;           // 世数
  final List<int> candidateNumbers; // 候选条文数
  final int confirmedNumber;  // 用户确认的条文数
  final String finalReading; // 最终解读
  
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
    required this.yuanShu,
    required this.huiShu,
    required this.yunShu,
    required this.shiShu,
    required this.candidateNumbers,
    required this.confirmedNumber,
    required this.finalReading,
    required this.id,
    required this.completedAt,
    required this.executionTimeMs,
    required this.strategyName,
    required this.inputDigest,
    this.status = CalculationStatus.success,
    this.errorMessage,
  });
  
  @override
  String get summary => '皇极取数法结果 - 最终条文数:$confirmedNumber, 候选数量:${candidateNumbers.length}';
}
```

### 4.2 策略实现

```dart
/// 皇极取数法计算策略
class HuangJiQuShuCalculationStrategy 
    extends InteractiveCalculationStrategy<HuangJiQuShuParams, HuangJiQuShuResult> {
  
  @override
  String get name => '皇极取数法';
  
  @override
  String get description => '通过四柱计算元会运世数，生成条文数供用户确认';
  
  @override
  List<String> get detailedSteps => [
    '1. 排四柱，计算太玄数',
    '2. 计算元会运世基础数',
    '3. 计算初始条文数',
    '4. 等待用户确认条文数是否符合',
    '5. 如不符合，按30递增/递减调整',
    '6. 基于确认的条文数进行后续计算',
  ];
  
  @override
  String get category => '皇极取数法';
  
  @override
  Future<HuangJiQuShuResult> calculate(HuangJiQuShuParams params) async {
    // 非交互模式的简化实现
    throw UnsupportedError('请使用 calculateWithCallback 方法进行交互式计算');
  }
  
  @override
  Future<InteractiveCalculationResult<HuangJiQuShuResult>> calculateWithCallback(
    HuangJiQuShuParams params,
    CallbackFunction<UserInteractionResponse> callback,
  ) async {
    final context = InteractiveCalculationContext(
      params: params,
      intermediateData: {},
      callback: callback,
    );
    
    return await _executeCalculation(context);
  }
  
  Future<InteractiveCalculationResult<HuangJiQuShuResult>> _executeCalculation(
    InteractiveCalculationContext<HuangJiQuShuParams, HuangJiQuShuResult> context,
  ) async {
    // 第一阶段：计算基础数据
    final yuanShu = _calculateYuanShu(context.params.fourZhu);
    final huiShu = _calculateHuiShu(context.params.fourZhu);
    final yunShu = _calculateYunShu(context.params.fourZhu);
    final shiShu = _calculateShiShu(context.params.fourZhu);
    
    // 第二阶段：生成候选条文数
    final candidateNumbers = _generateCandidateNumbers(yuanShu, huiShu, yunShu, shiShu);
    
    // 创建用户交互请求
    final interactionRequest = UserInteractionRequest(
      id: _generateRequestId(),
      type: UserInteractionType.confirmation,
      title: "条文数确认",
      description: "请确认以下条文数是否符合您的情况：",
      data: {
        'candidateNumbers': candidateNumbers,
        'yuanShu': yuanShu,
        'huiShu': huiShu,
        'yunShu': yunShu,
        'shiShu': shiShu,
      },
      options: candidateNumbers.map((num) => "条文数：$num").toList(),
    );
    
    // 请求用户输入
    final userResponse = await context.requestUserInput(interactionRequest);
    final confirmedNumber = candidateNumbers[candidateNumbers.indexOf(
      int.parse(userResponse.selectedValue!.split('：')[1])
    )];
    
    // 生成最终解读
    final finalReading = await _generateFinalReading(
      confirmedNumber, yuanShu, huiShu, yunShu, shiShu,
    );
    
    // 创建最终结果
    final finalResult = HuangJiQuShuResult(
      yuanShu: yuanShu,
      huiShu: huiShu,
      yunShu: yunShu,
      shiShu: shiShu,
      candidateNumbers: candidateNumbers,
      confirmedNumber: confirmedNumber,
      finalReading: finalReading,
      id: context.params.id,
      completedAt: DateTime.now(),
      executionTimeMs: 0, // 实际应计算执行时间
      strategyName: name,
      inputDigest: context.params.id,
    );
    
    return InteractiveCalculationResult(
      needsInteraction: false,
      finalResult: finalResult,
    );
  }
  
  // 私有计算方法
  int _calculateYuanShu(FourZhu fourZhu) {
    // 实现元数计算逻辑
    return fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum;
  }
  
  int _calculateHuiShu(FourZhu fourZhu) {
    // 实现会数计算逻辑
    return fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum;
  }
  
  int _calculateYunShu(FourZhu fourZhu) {
    // 实现运数计算逻辑
    return fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum;
  }
  
  int _calculateShiShu(FourZhu fourZhu) {
    // 实现世数计算逻辑
    return fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum;
  }
  
  List<int> _generateCandidateNumbers(int yuan, int hui, int yun, int shi) {
    // 实现候选条文数生成逻辑
    final baseNumber = int.parse('$yuan$hui') + int.parse('$yun$shi');
    return [baseNumber, baseNumber + 30, baseNumber - 30].where((n) => n > 0).toList();
  }
  
  Future<String> _generateFinalReading(int number, int yuan, int hui, int yun, int shi) async {
    // 实现最终解读生成逻辑
    return "根据条文数 $number 的解读内容...";
  }
  
  String _generateRequestId() => 'req_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
}

### 4.3 UseCase实现

```dart
class HuangJiQuShuUseCase extends CallbackUseCase<HuangJiQuShuParams, HuangJiQuShuResult, UserInteractionResponse> {
  final HuangJiQuShuCalculationStrategy _strategy;
  final Repository _repository;
  
  HuangJiQuShuUseCase(this._strategy, this._repository);
  
  @override
  Future<CallbackUseCaseResult<HuangJiQuShuResult, UserInteractionResponse>> execute(
    HuangJiQuShuParams params,
    CallbackFunction<UserInteractionResponse> callback,
  ) async {
    try {
      final result = await _strategy.calculateWithCallback(params, callback);
      
      if (result.isCompleted) {
        // 保存结果到Repository
        await _repository.saveCalculationResult(result.finalResult!);
        return CallbackUseCaseResult.completed(result.finalResult!);
      } else {
        return CallbackUseCaseResult.needsInput(result.pendingRequest!);
      }
    } catch (e) {
      throw CalculationException("皇极取数法计算失败: $e");
    }
  }
  
  @override
  Future<HuangJiQuShuResult> next(UserInteractionResponse userData) async {
    // 在这个简化版本中，所有逻辑都在calculateWithCallback中处理
    // 如果需要多步交互，可以在这里实现状态恢复逻辑
    throw UnimplementedError("当前实现不需要next方法");
  }
}
```

## 5. 使用示例

### 5.1 ViewModel实现

```dart
/// 皇极取数法交互式计算ViewModel
class HuangJiQuShuInteractiveViewModel extends ChangeNotifier {
  final HuangJiQuShuInteractiveStrategy _strategy;
  
  HuangJiQuShuInteractiveViewModel(this._strategy);
  
  // 状态管理
  HuangJiQuShuInteractiveCalculationResult? _currentResult;
  bool _isCalculating = false;
  String? _error;
  
  // Getters
  HuangJiQuShuInteractiveCalculationResult? get currentResult => _currentResult;
  bool get isCalculating => _isCalculating;
  String? get error => _error;
  bool get needsUserInput => _currentResult?.needsUserInput == true;
  bool get isCompleted => _currentResult?.isCompleted == true;
  bool get hasError => _error != null;
  
  /// 开始交互式计算
  Future<void> startCalculation(HuangJiQuShuInteractiveParams params) async {
    _setCalculating(true);
    _clearError();
    
    try {
      final result = await _strategy.startInteractiveCalculation(params);
      _setCurrentResult(result);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCalculating(false);
    }
  }
  
  /// 处理用户交互响应
  Future<void> handleUserResponse(UserInteractionResponse response) async {
    if (_currentResult?.id == null) return;
    
    _setCalculating(true);
    _clearError();
    
    try {
      final result = await _strategy.continueCalculation(
        _currentResult!.id, 
        response,
      );
      _setCurrentResult(result);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCalculating(false);
    }
  }
  
  /// 取消计算
  Future<void> cancelCalculation() async {
    if (_currentResult?.id != null) {
      await _strategy.cancelCalculation(_currentResult!.id);
      _clearCurrentResult();
    }
  }
  
  /// 重新开始计算
  void resetCalculation() {
    _clearCurrentResult();
    _clearError();
  }
  
  // 私有状态更新方法
  void _setCurrentResult(HuangJiQuShuInteractiveCalculationResult result) {
    _currentResult = result;
    notifyListeners();
  }
  
  void _clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
  
  void _setCalculating(bool calculating) {
    _isCalculating = calculating;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### 5.2 UseCase层实现

```dart
/// 皇极取数法交互式计算用例
class HuangJiQuShuInteractiveUseCase {
  final HuangJiQuShuInteractiveStrategy _strategy;
  final CalculationHistoryRepository _historyRepository;
  
  HuangJiQuShuInteractiveUseCase(
    this._strategy,
    this._historyRepository,
  );
  
  /// 执行交互式计算
  Future<HuangJiQuShuInteractiveCalculationResult> execute(
    HuangJiQuShuInteractiveParams params,
  ) async {
    // 参数验证
    final validation = params.validate();
    if (!validation.isValid) {
      throw ArgumentError('参数验证失败: ${validation.errors.join(', ')}');
    }
    
    // 开始计算
    final result = await _strategy.startInteractiveCalculation(params);
    
    // 记录计算历史（如果需要）
    if (result.isCompleted && result.finalResult != null) {
      await _historyRepository.saveCalculationResult(result.finalResult!);
    }
    
    return result;
  }
  
  /// 继续计算
  Future<HuangJiQuShuInteractiveCalculationResult> continueCalculation(
    String calculationId,
    UserInteractionResponse response,
  ) async {
    // 验证响应
    final currentState = _strategy.getCalculationStatus(calculationId);
    if (currentState?.pendingRequest != null) {
      final isValid = _strategy.validateUserResponse(
        currentState!.pendingRequest!,
        response,
      );
      if (!isValid) {
        throw ArgumentError('用户响应无效');
      }
    }
    
    // 继续计算
    final result = await _strategy.continueCalculation(calculationId, response);
    
    // 记录计算历史（如果完成）
    if (result.isCompleted && result.finalResult != null) {
      await _historyRepository.saveCalculationResult(result.finalResult!);
    }
    
    return result;
  }
}
```

### 5.3 UI层集成

```dart
class HuangJiQuShuInteractivePage extends StatefulWidget {
  @override
  _HuangJiQuShuInteractivePageState createState() => _HuangJiQuShuInteractivePageState();
}

class _HuangJiQuShuInteractivePageState extends State<HuangJiQuShuInteractivePage> {
  late final HuangJiQuShuInteractiveViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  
  // 表单控制器
  final _genderController = TextEditingController();
  final _methodController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HuangJiQuShuInteractiveViewModel>();
  }
  
  @override
  void dispose() {
    _genderController.dispose();
    _methodController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('皇极取数法交互式计算'),
        actions: [
          if (_viewModel.currentResult != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _viewModel.resetCalculation(),
            ),
        ],
      ),
      body: Consumer<HuangJiQuShuInteractiveViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 参数输入区域
                if (viewModel.currentResult == null) _buildParameterInput(),
                
                // 加载状态
                if (viewModel.isCalculating) _buildLoadingWidget(),
                
                // 错误信息
                if (viewModel.hasError) _buildErrorWidget(viewModel.error!),
                
                // 用户交互界面
                if (viewModel.needsUserInput) 
                  _buildUserInteractionWidget(viewModel.currentResult!.pendingRequest!),
                
                // 计算完成结果
                if (viewModel.isCompleted) 
                  _buildCompletedResultWidget(viewModel.currentResult!.finalResult!),
                
                // 执行日志
                if (viewModel.currentResult != null)
                  _buildExecutionLogWidget(viewModel.currentResult!.executionLog),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildParameterInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '计算参数',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              // 四柱输入（简化示例）
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '四柱信息',
                  hintText: '请输入四柱信息',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return '请输入四柱信息';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 性别选择
              DropdownButtonFormField<String>(
                controller: _genderController,
                decoration: const InputDecoration(labelText: '性别'),
                items: const [
                  DropdownMenuItem(value: '男', child: Text('男')),
                  DropdownMenuItem(value: '女', child: Text('女')),
                ],
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return '请选择性别';
                  }
                  return null;
                },
                onChanged: (value) => _genderController.text = value ?? '',
              ),
              const SizedBox(height: 16),
              
              // 方法选择
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '计算方法'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('方法一')),
                  DropdownMenuItem(value: 2, child: Text('方法二')),
                  DropdownMenuItem(value: 3, child: Text('方法三')),
                ],
                validator: (value) {
                  if (value == null) {
                    return '请选择计算方法';
                  }
                  return null;
                },
                onChanged: (value) => _methodController.text = value?.toString() ?? '',
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _startCalculation,
                child: const Text('开始计算'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingWidget() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在计算中...'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  '计算错误',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(error, style: TextStyle(color: Colors.red[700])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInteractionWidget(UserInteractionRequest request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(request.description),
            const SizedBox(height: 16),
            
            if (request.type == UserInteractionType.confirmation) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleUserResponse(
                      request.id,
                      true,
                      '符合',
                    ),
                    child: const Text('符合'),
                  ),
                  OutlinedButton(
                    onPressed: () => _handleUserResponse(
                      request.id,
                      false,
                      '不符合',
                    ),
                    child: const Text('不符合'),
                  ),
                ],
              ),
            ],
            
            if (request.type == UserInteractionType.selection) ...[
              ...request.options!.map((option) => ListTile(
                title: Text(option),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _handleUserResponse(
                  request.id,
                  true,
                  option,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompletedResultWidget(HuangJiQuShuInteractiveResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  '计算完成',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildResultItem('最终条文数', '${result.finalTiaoWenNumber}'),
            _buildResultItem('候选条文数', result.candidateTiaoWenNumbers.join(', ')),
            _buildResultItem('计算耗时', '${result.executionTimeMs}ms'),
            
            const SizedBox(height: 16),
            Text(
              '用户确认记录:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result.userConfirmations.map((confirmation) => 
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(confirmation)),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildExecutionLogWidget(List<String> logs) {
    return Card(
      child: ExpansionTile(
        title: const Text('执行日志'),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logs.map((log) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    log,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  void _startCalculation() {
    if (_formKey.currentState?.validate() == true) {
      // 构建参数（简化示例）
      final params = HuangJiQuShuInteractiveParams(
        fourZhu: _buildFourZhu(), // 实际应从表单获取
        gender: _genderController.text,
        method: int.parse(_methodController.text),
      );
      
      _viewModel.startCalculation(params);
    }
  }
  
  void _handleUserResponse(String requestId, bool confirmed, String selectedValue) {
    final response = UserInteractionResponse(
      requestId: requestId,
      confirmed: confirmed,
      selectedValue: selectedValue,
    );
    
    _viewModel.handleUserResponse(response);
  }
  
  FourZhu _buildFourZhu() {
    // 简化示例，实际应从表单获取完整的四柱信息
    return FourZhu(
      // ... 四柱数据
    );
  }
}
```

### 5.4 依赖注入配置

```dart
/// 依赖注入配置
class DIContainer {
  static void setup() {
    // 注册Strategy
    GetIt.instance.registerLazySingleton<HuangJiQuShuInteractiveStrategy>(
      () => HuangJiQuShuInteractiveStrategy(),
    );
    
    // 注册Repository
    GetIt.instance.registerLazySingleton<CalculationHistoryRepository>(
      () => CalculationHistoryRepositoryImpl(),
    );
    
    // 注册UseCase
    GetIt.instance.registerLazySingleton<HuangJiQuShuInteractiveUseCase>(
      () => HuangJiQuShuInteractiveUseCase(
        GetIt.instance<HuangJiQuShuInteractiveStrategy>(),
        GetIt.instance<CalculationHistoryRepository>(),
      ),
    );
    
    // 注册ViewModel
    GetIt.instance.registerFactory<HuangJiQuShuInteractiveViewModel>(
      () => HuangJiQuShuInteractiveViewModel(
        GetIt.instance<HuangJiQuShuInteractiveStrategy>(),
      ),
    );
  }
}

/// Provider配置
class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<HuangJiQuShuInteractiveViewModel>(
      create: (_) => GetIt.instance<HuangJiQuShuInteractiveViewModel>(),
    ),
    // 其他Provider...
  ];
}
```

## 6. 优势总结

### 6.1 架构优势
- **完美的MVVM集成**：与现有的UI->ViewModel->UseCase->Strategy架构无缝集成
- **状态管理清晰**：通过状态机模式管理复杂的交互流程，ViewModel负责状态管理
- **异步支持**：完全支持异步用户交互，不阻塞UI
- **职责分离明确**：Strategy负责算法逻辑，ViewModel负责状态管理，UI负责展示
- **可扩展性**：可以轻松添加新的交互类型和算法

### 6.2 用户体验优势
- **响应式UI**：基于ChangeNotifier的状态管理，UI自动响应状态变化
- **流程透明**：用户可以清楚看到计算进度和交互要求
- **灵活调整**：支持多种调整方式（递增、递减、手动输入）
- **一致的交互模式**：遵循标准的MVVM交互模式，用户体验一致
- **可撤销**：支持取消计算和重新开始

### 6.3 开发优势
- **架构一致性**：完全符合现有的UI->ViewModel->UseCase->Strategy流程
- **测试友好**：每层职责明确，可以独立进行单元测试
- **错误处理**：完善的错误处理和状态恢复机制
- **日志记录**：详细的执行日志，便于调试和审计
- **易于维护**：清晰的架构分层，代码易于理解和维护

这个设计方案完美解决了铁板神数中需要用户交互确认的算法问题，既保持了Strategy模式的一致性，又完美集成到现有的MVVM架构中，提供了强大的交互能力。