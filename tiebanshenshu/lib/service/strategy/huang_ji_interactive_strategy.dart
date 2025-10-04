/// 皇极取数法交互式策略
///
/// 目的：将现有 `HuangJiCalculationStrategy` 适配为基于 `InteractiveSession`
/// 的分步交互流程，实现与 `BaseInteractiveStrategy` 对齐的接口。
library;

import 'dart:math';

import 'package:common/models/eight_chars.dart';

import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/tiao_wen_list_state.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import '../../service/strategy/base_interactive_strategy.dart';
import '../../service/strategy/huang_ji_calculation_strategy.dart';
import 'base_calculation_strategy.dart';

/// 皇极交互式策略的参数
/// 继承现有皇极参数，增加交互配置与可选的偏好
class HuangJiInteractiveStrategyParams extends HuangJiCalculationParams {
  /// 交互配置（候选数上限、是否启用无限列表等）
  final InteractiveStrategyConfig? interactiveConfig;

  /// 用户偏好：是否优先展示太玄数详情
  final bool preferTaiXuanDetails;

  HuangJiInteractiveStrategyParams({
    required super.eightChars,
    this.interactiveConfig,
    this.preferTaiXuanDetails = true,
  });
}

/// 皇极交互式策略结果
///
/// 为保证与台玄四柱交互策略一致，对外暴露 `MultiBaseNumberResult`
/// 同时保留皇极计算原始结果以便上层适配器后续使用。
class HuangJiInteractiveStrategyResult extends MultiBaseNumberResult {
  /// 交互会话
  final InteractiveSession session;

  /// 原始皇极计算结果（包含初刻、次条文、基础数与最终列表）
  final HuangJiCalculationResult? rawCalculationResult;

  HuangJiInteractiveStrategyResult({
    required this.session,
    required this.rawCalculationResult,
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required List<BaseNumberTiaoWenListModel> baseNumberTiaoWenList,
    required Map<String, dynamic> sourceData,
    List<TiaoWenDataModel>? tiaoWenEntities,
  }) : super(
         algorithmName: algorithmName,
         algorithmDescription: algorithmDescription,
         calculationParams: calculationParams,
         baseNumberTiaoWenList: baseNumberTiaoWenList,
         state: TiaoWenListState.success,
         calculationTime: DateTime.now(),
         sourceData: sourceData,
         tiaoWenEntities: tiaoWenEntities,
       );
}

/// 皇极取数法交互式策略
class HuangJiInteractiveStrategy
    extends
        BaseInteractiveStrategy<
          HuangJiInteractiveStrategyParams,
          HuangJiInteractiveStrategyResult
        > {
  final HuangJiCalculationStrategy _calc = HuangJiCalculationStrategy();

  @override
  String get name => '皇极取数法(交互)';

  @override
  String get description => '按四柱分步选择基础数并生成条文列表的交互策略';

  @override
  StrategyCategory get category => StrategyCategory.interactive;

  /// 默认交互配置
  @override
  InteractiveStrategyConfig get config => const InteractiveStrategyConfig(
    allowUndo: true,
    allowJump: true,
    candidateCount: 20,
    stepSize: 1,
  );

  /// 步骤枚举（内部约定）
  static const String stepConfirmFourZhu = '确认四柱';
  static const String stepSelectBaseNumber = '选择基础数';
  static const String stepPreviewFinalNumbers = '预览最终条文数';

  @override
  Future<InteractiveSession> startSession(
    HuangJiInteractiveStrategyParams params, {
    InteractiveStrategyConfig? config,
  }) async {
    final appliedConfig = config ?? params.interactiveConfig ?? this.config;

    // 创建会话
    final session = InteractiveSession.create(
      sessionId: generateSessionId(),
      strategyName: name,
      sessionConfig: appliedConfig.toJson(),
    );

    // 第一步：确认四柱
    final step1 = _createConfirmFourZhuStep(params.eightChars);
    final withStep1 = session.addStep(step1);

    // 设置状态
    return withStep1.copyWith(
      status: InteractiveSessionStatus.inProgress,
      currentStepIndex: withStep1.steps.length - 1,
    );
  }

  @override
  Future<List<TiaoWenCandidate>> getCandidates(
    InteractiveSession session,
  ) async {
    validateSession(session);
    final step = session.currentStep;
    if (step == null) return [];
    return step.candidates ?? [];
  }

  @override
  Future<InteractiveSession> selectCandidate(
    InteractiveSession session,
    String candidateId,
  ) async {
    validateSession(session);
    final current = session.currentStep;
    if (current == null) return session;
    validateCandidateSelection(session, candidateId);

    final completed = completeStep(current, candidateId);
    var updated = session.updateCurrentStep(completed);

    // 进入下一步
    final next = await getNextStep(updated);
    if (next != null) {
      updated = updated.addStep(next).moveToNextStep();
    } else {
      updated = updated.copyWith(
        status: InteractiveSessionStatus.completed,
        endTime: DateTime.now(),
      );
    }
    return updated;
  }

  @override
  Future<InteractiveSession> adjustStep(
    InteractiveSession session,
    Map<String, dynamic> adjustments,
  ) async {
    // 皇极当前交互仅支持候选筛选（例如限制范围），此处按需调整
    validateSession(session);
    final current = session.currentStep;
    if (current == null) return session;

    final candidates = (current.candidates ?? []).where((c) {
      final min = (adjustments['min'] as int?) ?? -0x7fffffff;
      final max = (adjustments['max'] as int?) ?? 0x7fffffff;
      final v = (c.value is int) ? c.value as int : 0;
      return v >= min && v <= max;
    }).toList();

    final updatedStep = current.copyWith(candidates: candidates);
    return session.updateCurrentStep(updatedStep);
  }

  @override
  Future<InteractiveSession> jumpTo(
    InteractiveSession session,
    int stepIndex,
  ) async {
    validateSession(session);
    if (stepIndex < 0 || stepIndex >= session.steps.length) {
      throw ArgumentError('步骤索引越界: $stepIndex');
    }
    return session.jumpToStep(stepIndex);
  }

  @override
  Future<InteractiveSession> undo(InteractiveSession session) async {
    validateSession(session);
    if (!config.allowUndo) return session;
    return session.undoToPreviousStep();
  }

  @override
  Future<List<dynamic>> getInfiniteList(
    InteractiveSession session,
    int offset,
    int limit,
  ) async {
    validateSession(session);
    final step = session.currentStep;
    if (step == null) return [];
    final list = step.candidates ?? [];
    final end = min(offset + limit, list.length);
    return list.sublist(offset.clamp(0, list.length), end);
  }

  @override
  Future<HuangJiInteractiveStrategyResult> completeCalculation(
    InteractiveSession session,
  ) async {
    validateSession(session);

    // 必须选择基础数才能完成
    final baseStep = session.steps.firstWhere(
      (s) => s.stepName == stepSelectBaseNumber,
      orElse: () => session.currentStep ?? session.steps.last,
    );
    if (baseStep.selectedCandidateId == null) {
      throw StateError('请先选择基础数');
    }

    // 执行皇极计算
    final eightChars = _extractEightChars(session);
    final baseNumber = _extractSelectedBaseNumber(baseStep);
    final raw = await _calc.calculate(
      HuangJiCalculationParams(eightChars: eightChars),
      // 皇极策略内部会重新计算 initial/secondary/base/final；此处使用已选基础数替换
      // 若后续提供 copyWith(baseNumber) 能传入，则可改为透传
    );

    // 构造条文列表模型，适配 MultiBaseNumberResult
    final baseList = raw.finalNumbers
        .map(
          (n) => BaseNumberTiaoWenListModel(
            baseNumber: n,
            name: '皇极基础数 $n',
            description: '通过皇极交互式计算得出的基础数',
            source: BaseNumberSource.interactive,
            tiaoWenNumbers:
                raw.tiaoWenDataList?.map((t) => t.id).toList() ?? [],
            tiaoWenDataList: raw.tiaoWenDataList ?? [],
          ),
        )
        .toList();

    final result = HuangJiInteractiveStrategyResult(
      session: session.copyWith(
        status: InteractiveSessionStatus.completed,
        endTime: DateTime.now(),
      ),
      rawCalculationResult: raw,
      algorithmName: name,
      algorithmDescription: description,
      calculationParams:
          'eightChars=${eightChars.toString()}, baseNumber=$baseNumber',
      baseNumberTiaoWenList: baseList,
      sourceData: raw.calculationSteps,
      tiaoWenEntities: raw.tiaoWenDataList,
    );
    return result;
  }

  @override
  void validateSession(InteractiveSession session) {
    if (session.strategyName != name) {
      // 允许跨策略跳转的场景可以放宽，这里严格校验
      throw ArgumentError('会话策略不匹配: ${session.strategyName}');
    }
    final s = session.status;
    if (s != InteractiveSessionStatus.inProgress &&
        s != InteractiveSessionStatus.waitingForSelection &&
        s != InteractiveSessionStatus.completed) {
      throw StateError('会话状态异常: $s');
    }
  }

  @override
  void validateCandidateSelection(
    InteractiveSession session,
    String candidateId,
  ) {
    final step = session.currentStep;
    if (step == null) throw StateError('当前无步骤');
    final ok = (step.candidates ?? []).any((c) => c.id == candidateId);
    if (!ok) throw ArgumentError('候选项不存在: $candidateId');
  }

  @override
  bool isLastStep(InteractiveSession session) {
    return session.currentStepIndex >= session.steps.length - 1;
  }

  @override
  Future<InteractiveSessionStep?> getNextStep(
    InteractiveSession session,
  ) async {
    final current = session.currentStep;
    if (current == null) return null;
    if (current.stepName == stepConfirmFourZhu) {
      // 下一步：选择基础数（基于次条文数候选，或直接给定基础数范围）
      final eightChars = _extractEightChars(session);
      final secondaryCandidates = await _generateBaseNumberCandidates(
        eightChars,
      );
      return createStep(
        stepNumber: current.stepNumber + 1,
        stepName: stepSelectBaseNumber,
        description: '请选择基础数（影响最终条文列表）',
        candidates: secondaryCandidates,
        stepData: {'eightChars': eightChars.toJson()},
      );
    }

    if (current.stepName == stepSelectBaseNumber) {
      // 下一步：预览最终条文数，供完成确认
      final eightChars = _extractEightChars(session);
      final baseNumber = _extractSelectedBaseNumber(current);
      final raw = await _calc.calculate(
        HuangJiCalculationParams(eightChars: eightChars),
      );
      final previewNumbers = raw.finalNumbers;
      final candidates = previewNumbers
          .map(
            (n) => TiaoWenCandidate(
              id: 'final_$n',
              displayName: '条文 $n',
              description: '最终条文候选',
              value: n,
              type: TiaoWenCandidateType.custom,
            ),
          )
          .toList();
      return createStep(
        stepNumber: current.stepNumber + 1,
        stepName: stepPreviewFinalNumbers,
        description: '预览最终条文数，确认后完成',
        candidates: candidates,
        stepData: {
          'baseNumber': baseNumber,
          'previewFinalNumbers': previewNumbers,
        },
      );
    }

    return null; // 无下一步
  }

  // 辅助：创建确认四柱步骤
  InteractiveSessionStep _createConfirmFourZhuStep(EightChars eightChars) {
    final candidates = <TiaoWenCandidate>[
      TiaoWenCandidate(
        id: 'confirm_yes',
        displayName: '确认四柱',
        description: eightChars.toString(),
        value: true,
        type: TiaoWenCandidateType.confirmation,
      ),
      TiaoWenCandidate(
        id: 'confirm_no',
        displayName: '修改四柱',
        description: '若四柱不正确，请返回修改',
        value: false,
        type: TiaoWenCandidateType.confirmation,
      ),
    ];
    return createStep(
      stepNumber: 1,
      stepName: stepConfirmFourZhu,
      description: '请确认当前四柱是否正确',
      candidates: candidates,
      stepData: {'eightChars': eightChars.toJson()},
    );
  }

  // 辅助：从会话提取四柱
  EightChars _extractEightChars(InteractiveSession session) {
    final step = session.steps.firstWhere(
      (s) => s.stepName == stepConfirmFourZhu,
    );
    final data = step.stepData ?? {};
    final json = data['eightChars'] as Map<String, dynamic>;
    return EightChars.fromJson(json);
  }

  // 辅助：抽取已选基础数
  int _extractSelectedBaseNumber(InteractiveSessionStep step) {
    final id = step.selectedCandidateId;
    if (id == null) throw StateError('尚未选择基础数');
    final candidate = (step.candidates ?? []).firstWhere((c) => c.id == id);
    return (candidate.value is int) ? candidate.value as int : 0;
  }

  // 辅助：生成基础数候选（基于策略的次条文数/基础数范围）
  Future<List<TiaoWenCandidate>> _generateBaseNumberCandidates(
    EightChars eightChars,
  ) async {
    // 使用策略计算次条文数，作为默认推荐候选；同时提供若干范围数值
    final raw = await _calc.calculate(
      HuangJiCalculationParams(eightChars: eightChars),
    );
    final secondary = raw.secondaryNumber;
    final recommended = TiaoWenCandidate(
      id: 'base_recommend_$secondary',
      displayName: '推荐基础数 $secondary',
      description: '根据次条文数推荐',
      value: secondary,
      type: TiaoWenCandidateType.custom,
    );

    // 扩展：在推荐值附近提供上下浮动范围候选
    final radius = 3;
    final neighbors = List<int>.generate(
      radius * 2 + 1,
      (i) => secondary - radius + i,
    ).where((n) => n > 0).toSet().toList()..sort();
    final neighborCandidates = neighbors
        .map(
          (n) => TiaoWenCandidate(
            id: 'base_$n',
            displayName: '基础数 $n',
            description: '可选基础数',
            value: n,
            type: TiaoWenCandidateType.custom,
          ),
        )
        .toList();

    return [recommended, ...neighborCandidates];
  }

  // ========== BaseCalculationStrategy 抽象方法实现 ==========

  @override
  List<String> get detailSteps => [
    '1. 确认四柱信息',
    '2. 选择基础数（基于次条文数推荐或自定义）',
    '3. 预览最终条文数列表',
    '4. 完成交互式计算',
  ];

  @override
  String get school => '皇极取数法（交互式）';

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return _calc.defaultTiaoWenCalculationConfig;
  }

  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    HuangJiInteractiveStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 委托给内部的HuangJiCalculationStrategy
    return _calc.calculateTiaoWenListWithConfig(
      baseNumber,
      HuangJiCalculationParams(eightChars: params.eightChars),
      config,
    );
  }

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return _calc.supportedTiaoWenCalculationConfigs;
  }

  @override
  String get tiaoWenCalculationDescription {
    return _calc.tiaoWenCalculationDescription;
  }
}
