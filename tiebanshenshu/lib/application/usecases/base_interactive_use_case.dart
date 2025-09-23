/// 交互式UseCase基类
///
/// 定义所有交互式UseCase的基础抽象类和接口
library;

import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/tiao_wen_list_result.dart';

/// 交互式UseCase的基础抽象类
///
/// 定义了交互式UseCase的通用接口，所有具体的交互式UseCase都应该实现此接口
abstract class BaseInteractiveUseCase<TParams> {
  /// UseCase名称
  String get name;

  /// UseCase描述
  String get description;

  /// 开始交互式会话
  ///
  /// [params] 计算参数
  /// [config] 可选的策略配置，如果为null则使用默认配置
  /// 返回新创建的会话
  ///
  /// 抛出异常：
  /// - [InputValidationException] 输入参数验证失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> startSession(
    TParams params, {
    InteractiveStrategyConfig? config,
  });

  /// 获取当前步骤的候选项
  ///
  /// [sessionId] 会话ID
  /// 返回候选项列表
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionStateException] 会话状态异常
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<List<TiaoWenCandidate>> getCandidates(String sessionId);

  /// 选择候选项并进入下一步
  ///
  /// [sessionId] 会话ID
  /// [candidateId] 选择的候选项ID
  /// 返回更新后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [InvalidCandidateException] 无效的候选项
  /// - [SessionStateException] 会话状态异常
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> selectCandidate(
    String sessionId,
    String candidateId,
  );

  /// 调整当前步骤
  ///
  /// [sessionId] 会话ID
  /// [adjustments] 调整参数
  /// 返回更新后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionStateException] 会话状态异常
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> adjustStep(
    String sessionId,
    Map<String, dynamic> adjustments,
  );

  /// 跳转到指定步骤
  ///
  /// [sessionId] 会话ID
  /// [stepIndex] 目标步骤索引
  /// 返回更新后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [InvalidStepIndexException] 无效的步骤索引
  /// - [SessionStateException] 会话状态异常
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> jumpTo(
    String sessionId,
    int stepIndex,
  );

  /// 撤销到上一步
  ///
  /// [sessionId] 会话ID
  /// 返回更新后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionStateException] 会话状态异常（如无法撤销）
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> undo(String sessionId);

  /// 获取无限列表的下一批数据
  ///
  /// [sessionId] 会话ID
  /// [offset] 偏移量
  /// [limit] 限制数量
  /// 返回数据列表
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionStateException] 会话状态异常
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<List<dynamic>> getInfiniteList(
    String sessionId,
    int offset,
    int limit,
  );

  /// 完成交互式计算并获取最终结果
  ///
  /// [sessionId] 会话ID
  /// 返回条文列表结果
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionNotCompletedException] 会话未完成
  /// - [StrategyCalculationException] Strategy计算失败
  /// - [TiaoWenListCalculationException] 条文列表计算失败
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<TiaoWenListResult> completeCalculation(String sessionId);

  /// 获取会话信息
  ///
  /// [sessionId] 会话ID
  /// 返回会话信息
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  Future<InteractiveSession> getSession(String sessionId);

  /// 取消会话
  ///
  /// [sessionId] 会话ID
  /// 返回取消后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> cancelSession(String sessionId);

  /// 验证输入参数
  ///
  /// [params] 待验证的参数
  /// 如果验证失败，抛出[InputValidationException]
  void validateParams(TParams params);

  /// 验证会话ID
  ///
  /// [sessionId] 待验证的会话ID
  /// 如果验证失败，抛出异常
  void validateSessionId(String sessionId);

  /// 验证候选项ID
  ///
  /// [candidateId] 待验证的候选项ID
  /// 如果验证失败，抛出异常
  void validateCandidateId(String candidateId);

  /// 验证步骤索引
  ///
  /// [stepIndex] 待验证的步骤索引
  /// [maxStepIndex] 最大步骤索引
  /// 如果验证失败，抛出异常
  void validateStepIndex(int stepIndex, int maxStepIndex);
}