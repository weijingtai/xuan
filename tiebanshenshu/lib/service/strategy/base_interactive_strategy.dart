/// 交互式策略基类
///
/// 定义所有交互式策略的基础抽象类和接口
library;

import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import 'base_calculation_strategy.dart';

/// 交互式策略基类
///
/// 所有交互式策略都应该继承此抽象类
abstract class BaseInteractiveStrategy<
  P extends BaseCalculationParams,
  R extends BaseCalculationResult
>
    extends BaseCalculationStrategy<P, R> {
  @override
  StrategyCategory get category => StrategyCategory.interactive;

  /// 策略配置
  InteractiveStrategyConfig get config;

  /// 开始交互式会话
  ///
  /// [params] 计算参数
  /// [config] 可选的策略配置，如果为null则使用默认配置
  /// 返回新创建的会话
  Future<InteractiveSession> startSession(
    P params, {
    InteractiveStrategyConfig? config,
  });

  /// 获取当前步骤的候选项
  ///
  /// [session] 当前会话
  /// 返回候选项列表
  Future<List<TiaoWenCandidate>> getCandidates(InteractiveSession session);

  /// 选择候选项并进入下一步
  ///
  /// [session] 当前会话
  /// [candidateId] 选择的候选项ID
  /// 返回更新后的会话
  Future<InteractiveSession> selectCandidate(
    InteractiveSession session,
    String candidateId,
  );

  /// 调整当前步骤
  ///
  /// [session] 当前会话
  /// [adjustments] 调整参数
  /// 返回更新后的会话
  Future<InteractiveSession> adjustStep(
    InteractiveSession session,
    Map<String, dynamic> adjustments,
  );

  /// 跳转到指定步骤
  ///
  /// [session] 当前会话
  /// [stepIndex] 目标步骤索引
  /// 返回更新后的会话
  Future<InteractiveSession> jumpTo(InteractiveSession session, int stepIndex);

  /// 撤销到上一步
  ///
  /// [session] 当前会话
  /// 返回更新后的会话
  Future<InteractiveSession> undo(InteractiveSession session);

  /// 获取无限列表的下一批数据
  ///
  /// [session] 当前会话
  /// [offset] 偏移量
  /// [limit] 限制数量
  /// 返回数据列表
  Future<List<dynamic>> getInfiniteList(
    InteractiveSession session,
    int offset,
    int limit,
  );

  /// 完成交互式计算
  ///
  /// [session] 已完成的会话
  /// 返回最终计算结果
  Future<R> completeCalculation(InteractiveSession session);

  /// 验证会话状态
  ///
  /// [session] 待验证的会话
  /// 如果验证失败，抛出异常
  void validateSession(InteractiveSession session);

  /// 验证候选项选择
  ///
  /// [session] 当前会话
  /// [candidateId] 候选项ID
  /// 如果验证失败，抛出异常
  void validateCandidateSelection(
    InteractiveSession session,
    String candidateId,
  );

  /// 生成会话ID
  ///
  /// 返回唯一的会话标识符
  String generateSessionId() {
    return '${name}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 创建会话步骤
  ///
  /// [stepNumber] 步骤序号
  /// [stepName] 步骤名称
  /// [description] 步骤描述
  /// [candidates] 候选项列表
  /// [stepData] 额外的步骤数据
  /// 返回新创建的步骤
  InteractiveSessionStep createStep({
    required int stepNumber,
    required String stepName,
    required String description,
    required List<TiaoWenCandidate> candidates,
    Map<String, dynamic>? stepData,
  }) {
    return InteractiveSessionStep(
      stepNumber: stepNumber,
      stepName: stepName,
      description: description,
      candidates: candidates,
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.waitingForSelection,
      stepData: stepData,
    );
  }

  /// 完成步骤
  ///
  /// [step] 当前步骤
  /// [selectedCandidateId] 选择的候选项ID
  /// 返回完成的步骤
  InteractiveSessionStep completeStep(
    InteractiveSessionStep step,
    String selectedCandidateId,
  ) {
    return step.copyWith(
      selectedCandidateId: selectedCandidateId,
      completedTime: DateTime.now(),
      status: InteractiveSessionStatus.completed,
    );
  }

  /// 检查会话是否可以继续
  ///
  /// [session] 当前会话
  /// 返回是否可以继续
  bool canContinueSession(InteractiveSession session) {
    return session.isInProgress &&
        session.currentStep != null &&
        session.currentStep!.status ==
            InteractiveSessionStatus.waitingForSelection;
  }

  /// 检查是否为最后一步
  ///
  /// [session] 当前会话
  /// 返回是否为最后一步
  bool isLastStep(InteractiveSession session);

  /// 获取下一步的步骤信息
  ///
  /// [session] 当前会话
  /// 返回下一步的步骤信息，如果没有下一步则返回null
  Future<InteractiveSessionStep?> getNextStep(InteractiveSession session);
}
