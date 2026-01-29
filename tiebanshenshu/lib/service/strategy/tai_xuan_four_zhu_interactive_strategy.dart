/// 太玄四柱交互式策略实现
///
/// 实现太玄四柱的交互式计算策略，支持用户参与式选择
library;

import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_state.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import 'tiao_wen_list_calculation.dart';
import 'base_calculation_strategy.dart';
import 'base_interactive_strategy.dart';
import 'tai_xuan_four_zhu_strategy.dart';

/// 太玄四柱交互式策略参数
///
/// 继承标准策略参数，添加交互式特定配置
class TaiXuanFourZhuInteractiveStrategyParams
    extends TaiXuanFourZhuStrategyParams {
  /// 交互式配置
  final InteractiveStrategyConfig? interactiveConfig;

  /// 是否允许用户修改四柱
  final bool allowFourZhuModification;

  /// 是否允许用户选择计算方法
  final bool allowCalculationMethodSelection;

  /// 是否允许用户选择卦象映射
  final bool allowGuaMappingSelection;

  TaiXuanFourZhuInteractiveStrategyParams({
    required super.eightChars,
    this.interactiveConfig,
    this.allowFourZhuModification = true,
    this.allowCalculationMethodSelection = true,
    this.allowGuaMappingSelection = false,
  });

  @override
  String get description =>
      "太玄四柱交互式计算参数：四柱信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})，"
      "允许四柱修改: $allowFourZhuModification，允许方法选择: $allowCalculationMethodSelection";
}

/// 太玄四柱交互式策略结果
///
/// 包含交互式计算的完整结果和过程信息
/// 现在继承自MultiBaseNumberResult以统一结果类型
class TaiXuanFourZhuInteractiveStrategyResult extends MultiBaseNumberResult {
  /// 交互式会话信息
  final InteractiveSession session;

  /// 用户选择的四柱信息
  final EightChars selectedEightChars;

  /// 用户选择的计算方法
  final String selectedCalculationMethod;

  /// 每一步的选择记录
  final Map<String, dynamic> selectionHistory;

  TaiXuanFourZhuInteractiveStrategyResult({
    required super.algorithmName,
    required super.algorithmDescription,
    required super.calculationParams,
    required super.baseNumberTiaoWenList,
    required super.state,
    super.errorMessage,
    required super.calculationTime,
    required super.sourceData,
    required this.session,
    required this.selectedEightChars,
    required this.selectedCalculationMethod,
    required this.selectionHistory,
  });

  /// 兼容性属性：获取基础条文列表
  List<int> get baseTiaoWenList {
    return baseNumberTiaoWenList.map((bn) => bn.baseNumber).toList();
  }

  /// 适配器方法：转换为BaseNumberModelResult兼容格式
  ///
  /// 这个方法提供了与BaseNumberModelResult的兼容性，
  /// 允许交互式结果在需要BaseNumberModelResult的地方使用
  BaseNumberModelResult toBaseNumberModelResult() {
    // 从BaseNumberTiaoWenListModel提取BaseNumberModel
    final baseNumbers = baseNumberTiaoWenList.map((tiaoWenModel) {
      return BaseNumberModel.create(
        baseNumber: tiaoWenModel.baseNumber,
        name: tiaoWenModel.name,
        description: tiaoWenModel.description,
        source: tiaoWenModel.source,
      );
    }).toList();

    return BaseNumberModelResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: baseNumbers,
      calculationTime: calculationTime,
      sourceData: {
        ...sourceData,
        'interactiveSession': session.sessionId,
        'selectedEightChars': selectedEightChars.toString(),
        'selectedCalculationMethod': selectedCalculationMethod,
        'adaptedFromInteractiveResult': true,
      },
      errorMessage: errorMessage,
    );
  }

  /// 适配器方法：从BaseNumberModelResult创建交互式结果
  ///
  /// 这个静态方法允许从BaseNumberModelResult创建交互式结果，
  /// 用于向后兼容或数据转换场景
  static TaiXuanFourZhuInteractiveStrategyResult fromBaseNumberModelResult(
    BaseNumberModelResult baseResult,
    InteractiveSession session,
    EightChars selectedEightChars,
    String selectedCalculationMethod,
    Map<String, dynamic> selectionHistory,
  ) {
    // 将BaseNumberModel转换为BaseNumberTiaoWenListModel
    final baseNumberTiaoWenList = baseResult.baseNumbers.map((baseModel) {
      return BaseNumberTiaoWenListModel.fromBaseModelWithData(
        baseModel: baseModel,

        tiaoWenDataList: [], // 空的条文数据列表，需要后续填充
        calculationConfig: TiaoWenListCalculationConfig.fromMultiples(
          baseNumber: 96,
          multipleList: [1, 2, 3, 4],
        ),
      );
    }).toList();

    return TaiXuanFourZhuInteractiveStrategyResult(
      algorithmName: baseResult.algorithmName,
      algorithmDescription: "${baseResult.algorithmDescription}（交互式适配）",
      calculationParams: baseResult.calculationParams,
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      state: baseResult.hasError
          ? TiaoWenListState.error
          : TiaoWenListState.success,
      errorMessage: baseResult.errorMessage,
      calculationTime: baseResult.calculationTime,
      sourceData: {
        ...baseResult.sourceData,
        'adaptedFromBaseNumberModelResult': true,
      },
      session: session,
      selectedEightChars: selectedEightChars,
      selectedCalculationMethod: selectedCalculationMethod,
      selectionHistory: selectionHistory,
    );
  }
}

/// 太玄四柱交互式策略
///
/// 实现太玄四柱的交互式计算策略
class TaiXuanFourZhuInteractiveStrategy
    extends
        BaseInteractiveStrategy<
          TaiXuanFourZhuInteractiveStrategyParams,
          TaiXuanFourZhuInteractiveStrategyResult
        > {
  /// 标准策略实例，用于复用计算逻辑
  final TaiXuanFourZhuStrategy _standardStrategy = TaiXuanFourZhuStrategy();

  /// 策略配置
  final InteractiveStrategyConfig _config;

  /// 会话存储
  final Map<String, InteractiveSession> _sessions = {};

  /// 构造函数
  TaiXuanFourZhuInteractiveStrategy({InteractiveStrategyConfig? config})
    : _config = config ?? InteractiveStrategyConfig.defaultConfig();

  @override
  String get name => "太玄四柱交互式策略";

  @override
  String get description => "太玄四柱的交互式计算策略，支持用户参与式选择四柱、卦象映射和计算方法";

  @override
  List<String> get detailSteps => [
    "1. 确认或修改四柱信息",
    "2. 选择天干地支配卦方法",
    "3. 选择纳甲配干支方法",
    "4. 选择太玄数计算方法",
    "5. 确认计算结果并生成条文列表",
  ];

  @override
  String get school => "太玄取数流派（交互式）";

  @override
  InteractiveStrategyConfig get config => _config;

  /// 获取默认的条文计算配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return _standardStrategy.defaultTiaoWenCalculationConfig;
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    TaiXuanFourZhuInteractiveStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 将交互式参数转换为标准参数
    final standardParams = TaiXuanFourZhuStrategyParams(
      eightChars: params.eightChars,
    );

    return _standardStrategy.calculateTiaoWenListWithConfig(
      baseNumber,
      standardParams,
      config,
    );
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return _standardStrategy.supportedTiaoWenCalculationConfigs;
  }

  @override
  String get tiaoWenCalculationDescription =>
      _standardStrategy.tiaoWenCalculationDescription;

  /// 实现基础的calculate方法（用于兼容性）
  ///
  /// 交互式策略的主要计算逻辑在completeCalculation中，
  /// 这个方法提供基础的非交互式计算能力
  @override
  TaiXuanFourZhuInteractiveStrategyResult calculate(
    TaiXuanFourZhuInteractiveStrategyParams params,
  ) {
    // 使用标准策略进行计算
    final standardParams = TaiXuanFourZhuStrategyParams(
      eightChars: params.eightChars,
    );
    final standardResult = _standardStrategy.calculate(standardParams);

    // 创建一个简化的交互式结果（无实际交互）
    final mockSession = InteractiveSession.create(
      sessionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      strategyName: name,
      sessionConfig: {'originalParams': params},
    );

    return TaiXuanFourZhuInteractiveStrategyResult(
      algorithmName: standardResult.algorithmName,
      algorithmDescription: "${standardResult.algorithmDescription}（非交互模式）",
      calculationParams: standardResult.calculationParams,
      baseNumberTiaoWenList: standardResult.baseNumbers
          .map(
            (e) => BaseNumberTiaoWenListModel.fromBaseModel(
              baseModel: e,
              calculationConfig:
                  (defaultTiaoWenCalculationConfig
                          as GenericTiaoWenCalculationConfig)
                      .toTiaoWenListCalculationConfig(),
            ),
          )
          .toList(),
      errorMessage: standardResult.errorMessage,
      calculationTime: standardResult.calculationTime,
      sourceData: {
        ...standardResult.sourceData,
        'interactive': false,
        'mode': 'direct_calculation',
      },
      session: mockSession,
      selectedEightChars: params.eightChars,
      selectedCalculationMethod: 'standard',
      selectionHistory: {},
      state: TiaoWenListState.success,
    );
  }

  @override
  Future<InteractiveSession> startSession(
    TaiXuanFourZhuInteractiveStrategyParams params, {
    InteractiveStrategyConfig? config,
  }) async {
    // 验证参数
    _validateParams(params);

    // 使用传入的配置或默认配置
    final sessionConfig = config ?? params.interactiveConfig ?? _config;

    // 创建会话
    final sessionId = generateSessionId();
    final session = InteractiveSession.create(
      sessionId: sessionId,
      strategyName: name,
      sessionConfig: {
        'originalParams': params,
        'config': sessionConfig,
        'allowFourZhuModification': params.allowFourZhuModification,
        'allowCalculationMethodSelection':
            params.allowCalculationMethodSelection,
        'allowGuaMappingSelection': params.allowGuaMappingSelection,
      },
    );

    // 存储会话
    _sessions[sessionId] = session;

    // 创建第一步：确认四柱信息
    final firstStep = await _createFourZhuConfirmationStep(
      params,
      sessionConfig,
    );
    final updatedSession = session.addStep(firstStep);
    _sessions[sessionId] = updatedSession;

    return updatedSession;
  }

  @override
  Future<List<TiaoWenCandidate>> getCandidates(
    InteractiveSession session,
  ) async {
    validateSession(session);

    final currentStep = session.currentStep;
    if (currentStep == null) {
      throw SessionStateException("当前会话没有活动步骤");
    }

    return currentStep.candidates;
  }

  @override
  Future<InteractiveSession> selectCandidate(
    InteractiveSession session,
    String candidateId,
  ) async {
    validateSession(session);
    validateCandidateSelection(session, candidateId);

    final currentStep = session.currentStep!;
    final selectedCandidate = currentStep.candidates.firstWhere(
      (c) => c.id == candidateId,
      orElse: () => throw InvalidCandidateException("候选项不存在: $candidateId"),
    );

    // 完成当前步骤
    final completedStep = completeStep(currentStep, candidateId);
    var updatedSession = session.updateCurrentStep(completedStep);

    // 根据当前步骤类型，创建下一步
    final nextStep = await _createNextStep(updatedSession, selectedCandidate);
    if (nextStep != null) {
      updatedSession = updatedSession.addStep(nextStep);
    } else {
      // 没有下一步，完成会话
      updatedSession = updatedSession.complete();
    }

    // 更新会话存储
    _sessions[session.sessionId] = updatedSession;

    return updatedSession;
  }

  @override
  Future<InteractiveSession> adjustStep(
    InteractiveSession session,
    Map<String, dynamic> adjustments,
  ) async {
    validateSession(session);

    // 根据调整参数更新当前步骤
    final currentStep = session.currentStep;
    if (currentStep == null) {
      throw SessionStateException("当前会话没有活动步骤");
    }

    // 这里可以根据adjustments重新生成候选项
    final adjustedCandidates = await _adjustCandidates(
      currentStep,
      adjustments,
    );
    final adjustedStep = currentStep.copyWith(candidates: adjustedCandidates);

    final updatedSession = session.updateCurrentStep(adjustedStep);
    _sessions[session.sessionId] = updatedSession;

    return updatedSession;
  }

  @override
  Future<InteractiveSession> jumpTo(
    InteractiveSession session,
    int stepIndex,
  ) async {
    validateSession(session);

    if (stepIndex < 0 || stepIndex >= session.steps.length) {
      throw InvalidStepIndexException("无效的步骤索引: $stepIndex");
    }

    final updatedSession = session.jumpToStep(stepIndex);
    _sessions[session.sessionId] = updatedSession;

    return updatedSession;
  }

  @override
  Future<InteractiveSession> undo(InteractiveSession session) async {
    validateSession(session);

    if (!session.canUndo) {
      throw SessionStateException("无法撤销，已经是第一步");
    }

    final updatedSession = session.undoToPreviousStep();
    _sessions[session.sessionId] = updatedSession;

    return updatedSession;
  }

  @override
  Future<List<dynamic>> getInfiniteList(
    InteractiveSession session,
    int offset,
    int limit,
  ) async {
    validateSession(session);

    // 如果会话已完成，返回条文列表的分页数据
    if (session.isCompleted && session.resultData != null) {
      final baseTiaoWenList =
          session.resultData!['baseTiaoWenList'] as List<int>?;
      if (baseTiaoWenList != null) {
        // 使用太玄四柱标准配置创建TiaoWenListCalculator
        final defaultConfig = TiaoWenListCalculationConfig.listAdd(
          customList: [96, 192, 384, 768],
          withSub: true,
        );

        final allTiaoWenList = <int>[];
        for (final baseNumber in baseTiaoWenList) {
          final calculator = TiaoWenListCalculator(defaultConfig);
          final calculationResult = calculator.calculate(baseNumber);
          allTiaoWenList.addAll(calculationResult.tiaoWenNumbers);
        }
        final startIndex = offset;
        final endIndex = (offset + limit).clamp(0, allTiaoWenList.length);
        return allTiaoWenList.sublist(startIndex, endIndex);
      }
    }

    return [];
  }

  @override
  Future<TaiXuanFourZhuInteractiveStrategyResult> completeCalculation(
    InteractiveSession session,
  ) async {
    if (!session.isCompleted) {
      throw SessionNotCompletedException("会话尚未完成");
    }

    // 从会话中提取用户选择
    final selectionHistory = _extractSelectionHistory(session);
    final selectedEightChars = _extractSelectedEightChars(session);
    final selectedCalculationMethod = _extractSelectedCalculationMethod(
      session,
    );

    // 使用标准策略进行计算
    final standardParams = TaiXuanFourZhuStrategyParams(
      eightChars: selectedEightChars,
    );
    final standardResult = _standardStrategy.calculate(standardParams);

    // 合并会话信息到源数据
    final enhancedSourceData = Map<String, dynamic>.from(
      standardResult.sourceData,
    );
    enhancedSourceData.addAll({
      'session': session,
      'selectionHistory': selectionHistory,
      'selectedCalculationMethod': selectedCalculationMethod,
      'interactive': true,
    });

    return TaiXuanFourZhuInteractiveStrategyResult(
      algorithmName: standardResult.algorithmName,
      algorithmDescription: "${standardResult.algorithmDescription}（交互式）",
      calculationParams: standardResult.calculationParams,
      baseNumberTiaoWenList: standardResult.baseNumbers
          .map(
            (e) => BaseNumberTiaoWenListModel.fromBaseModel(
              baseModel: e,
              calculationConfig: TiaoWenListCalculationConfig.listAdd(
                customList: [96, 192, 384, 768],
                withSub: true,
              ),
            ),
          )
          .toList(),
      errorMessage: standardResult.errorMessage,
      calculationTime: standardResult.calculationTime,
      sourceData: enhancedSourceData,
      session: session,
      selectedEightChars: selectedEightChars,
      selectedCalculationMethod: selectedCalculationMethod,
      selectionHistory: selectionHistory,
      state: TiaoWenListState.success,
    );
  }

  @override
  void validateSession(InteractiveSession session) {
    if (!_sessions.containsKey(session.sessionId)) {
      throw SessionNotFoundException("会话不存在: ${session.sessionId}");
    }
  }

  @override
  void validateCandidateSelection(
    InteractiveSession session,
    String candidateId,
  ) {
    final currentStep = session.currentStep;
    if (currentStep == null) {
      throw SessionStateException("当前会话没有活动步骤");
    }

    final candidateExists = currentStep.candidates.any(
      (c) => c.id == candidateId,
    );
    if (!candidateExists) {
      throw InvalidCandidateException("候选项不存在: $candidateId");
    }
  }

  @override
  bool isLastStep(InteractiveSession session) {
    // 根据会话配置和当前步骤判断是否为最后一步
    final currentStepIndex = session.currentStepIndex;
    final params =
        session.sessionConfig?['originalParams']
            as TaiXuanFourZhuInteractiveStrategyParams?;

    if (params == null) return true;

    // 计算总步骤数
    int totalSteps = 1; // 四柱确认步骤
    if (params.allowCalculationMethodSelection) totalSteps++;
    if (params.allowGuaMappingSelection) totalSteps++;

    return currentStepIndex >= totalSteps - 1;
  }

  @override
  Future<InteractiveSessionStep?> getNextStep(
    InteractiveSession session,
  ) async {
    if (isLastStep(session)) return null;

    final currentStep = session.currentStep;
    if (currentStep == null) return null;

    // 根据当前步骤创建下一步
    return await _createNextStepByType(session, currentStep);
  }

  /// 创建四柱确认步骤
  Future<InteractiveSessionStep> _createFourZhuConfirmationStep(
    TaiXuanFourZhuInteractiveStrategyParams params,
    InteractiveStrategyConfig config,
  ) async {
    final candidates = <TiaoWenCandidate>[];

    // 默认选项：使用原始四柱
    candidates.add(
      TiaoWenCandidate(
        id: 'original_four_zhu',
        displayName: '使用原始四柱',
        description:
            '使用输入的四柱信息：${params.eightChars.year.name} ${params.eightChars.month.name} ${params.eightChars.day.name} ${params.eightChars.time.name}',
        type: TiaoWenCandidateType.custom,
        value: params.eightChars,
        isDefault: true,
      ),
    );

    // 如果允许修改四柱，添加修改选项
    if (params.allowFourZhuModification) {
      // 添加一些常见的四柱变体选项
      candidates.addAll(await _generateFourZhuVariants(params.eightChars));
    }

    return createStep(
      stepNumber: 1,
      stepName: '确认四柱信息',
      description: '请确认或选择要使用的四柱信息',
      candidates: candidates,
      stepData: {'stepType': 'four_zhu_confirmation'},
    );
  }

  /// 生成四柱变体选项
  Future<List<TiaoWenCandidate>> _generateFourZhuVariants(
    EightChars originalEightChars,
  ) async {
    final variants = <TiaoWenCandidate>[];

    // 这里可以添加一些四柱的变体逻辑
    // 例如：时辰前后调整、节气边界调整等

    return variants;
  }

  /// 创建下一步
  Future<InteractiveSessionStep?> _createNextStep(
    InteractiveSession session,
    TiaoWenCandidate selectedCandidate,
  ) async {
    final currentStep = session.currentStep!;
    final stepType = currentStep.stepData?['stepType'] as String?;

    switch (stepType) {
      case 'four_zhu_confirmation':
        return await _createCalculationMethodStep(session);
      case 'calculation_method':
        return await _createGuaMappingStep(session);
      case 'gua_mapping':
        return null; // 最后一步
      default:
        return null;
    }
  }

  /// 创建计算方法选择步骤
  Future<InteractiveSessionStep?> _createCalculationMethodStep(
    InteractiveSession session,
  ) async {
    final params =
        session.sessionConfig?['originalParams']
            as TaiXuanFourZhuInteractiveStrategyParams?;
    if (params == null || !params.allowCalculationMethodSelection) {
      return await _createGuaMappingStep(session);
    }

    final candidates = <TiaoWenCandidate>[
      TiaoWenCandidate.calculationMethod(
        id: 'standard_method',
        displayName: '标准太玄取数法',
        description: '使用标准的太玄取数计算方法',
        methodName: 'standard',
        isDefault: true,
      ),
      TiaoWenCandidate.calculationMethod(
        id: 'enhanced_method',
        displayName: '增强太玄取数法',
        description: '使用增强的太玄取数计算方法，包含更多变化',
        methodName: 'enhanced',
      ),
    ];

    return createStep(
      stepNumber: session.steps.length + 1,
      stepName: '选择计算方法',
      description: '请选择太玄取数的计算方法',
      candidates: candidates,
      stepData: {'stepType': 'calculation_method'},
    );
  }

  /// 创建卦象映射选择步骤
  Future<InteractiveSessionStep?> _createGuaMappingStep(
    InteractiveSession session,
  ) async {
    final params =
        session.sessionConfig?['originalParams']
            as TaiXuanFourZhuInteractiveStrategyParams?;
    if (params == null || !params.allowGuaMappingSelection) {
      return null;
    }

    final candidates = <TiaoWenCandidate>[
      TiaoWenCandidate.gua(
        id: 'standard_gua_mapping',
        displayName: '标准卦象映射',
        description: '使用标准的天干地支配卦方法',
        guaValue: 'standard',
        isDefault: true,
      ),
    ];

    return createStep(
      stepNumber: session.steps.length + 1,
      stepName: '选择卦象映射',
      description: '请选择天干地支配卦的方法',
      candidates: candidates,
      stepData: {'stepType': 'gua_mapping'},
    );
  }

  /// 根据步骤类型创建下一步
  Future<InteractiveSessionStep?> _createNextStepByType(
    InteractiveSession session,
    InteractiveSessionStep currentStep,
  ) async {
    final stepType = currentStep.stepData?['stepType'] as String?;

    switch (stepType) {
      case 'four_zhu_confirmation':
        return await _createCalculationMethodStep(session);
      case 'calculation_method':
        return await _createGuaMappingStep(session);
      default:
        return null;
    }
  }

  /// 调整候选项
  Future<List<TiaoWenCandidate>> _adjustCandidates(
    InteractiveSessionStep step,
    Map<String, dynamic> adjustments,
  ) async {
    // 根据调整参数重新生成候选项
    // 这里可以实现具体的调整逻辑
    return step.candidates;
  }

  /// 提取选择历史
  Map<String, dynamic> _extractSelectionHistory(InteractiveSession session) {
    final history = <String, dynamic>{};

    for (final step in session.completedSteps) {
      if (step.selectedCandidate != null) {
        history[step.stepName] = {
          'candidateId': step.selectedCandidateId,
          'candidateName': step.selectedCandidate!.displayName,
          'candidateValue': step.selectedCandidate!.value,
        };
      }
    }

    return history;
  }

  /// 提取选择的四柱信息
  EightChars _extractSelectedEightChars(InteractiveSession session) {
    final fourZhuStep = session.completedSteps.firstWhereOrNull(
      (step) => step.stepData?['stepType'] == 'four_zhu_confirmation',
    );

    if (fourZhuStep?.selectedCandidate != null) {
      return fourZhuStep!.selectedCandidate!.value as EightChars;
    }

    // 如果没有找到，返回原始参数
    final params =
        session.sessionConfig?['originalParams']
            as TaiXuanFourZhuInteractiveStrategyParams?;
    if (params?.eightChars == null) {
      throw InputValidationException(
        "无法提取四柱信息",
        parameterName: "eightChars",
        message: '无法提取四柱信息',
      );
    }
    return params!.eightChars;
  }

  /// 提取选择的计算方法
  String _extractSelectedCalculationMethod(InteractiveSession session) {
    final methodStep = session.completedSteps.firstWhereOrNull(
      (step) => step.stepData?['stepType'] == 'calculation_method',
    );

    if (methodStep?.selectedCandidate != null) {
      return methodStep!.selectedCandidate!.value as String;
    }

    return 'standard'; // 默认方法
  }

  /// 验证参数
  void _validateParams(TaiXuanFourZhuInteractiveStrategyParams params) {
    if (params.eightChars.year.name.isEmpty ||
        params.eightChars.month.name.isEmpty ||
        params.eightChars.day.name.isEmpty ||
        params.eightChars.time.name.isEmpty) {
      throw InputValidationException(
        "四柱信息不完整",
        parameterName: '太玄四柱',
        message: '太玄四柱信息不完整',
      );
    }
  }
}
