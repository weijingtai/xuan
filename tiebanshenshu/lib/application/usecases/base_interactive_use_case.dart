/// 交互式UseCase基类
///
/// 定义所有交互式UseCase的基础抽象类和接口
library;

import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

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
  Future<List<TiaoWenCandidate>> getCandidates(InteractiveSession session);

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
    InteractiveSession session,
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
    InteractiveSession sessionId,
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
    InteractiveSession sessionId,
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
  Future<InteractiveSession> undo(InteractiveSession session);

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
    InteractiveSession session,
    int offset,
    int limit,
  );

  /// 完成交互式计算并获取最终结果
  ///
  /// [sessionId] 会话ID
  /// 返回多基础数结果
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionNotCompletedException] 会话未完成
  /// - [StrategyCalculationException] Strategy计算失败
  /// - [TiaoWenListCalculationException] 条文列表计算失败
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<MultiBaseNumberResult> completeCalculation(InteractiveSession session);

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

  /// 批量查询条文数据的公共方法
  ///
  /// 适用于交互式UseCase中需要批量获取条文数据的场景
  /// [tiaoWenNumbers] 条文编号列表
  /// [repository] 条文数据仓库
  /// 返回条文数据列表
  Future<List<TiaoWenDataModel>> batchQueryTiaoWenData(
    List<int> tiaoWenNumbers,
    TiaoWenRepository repository,
  ) async {
    try {
      return await repository.getByIdList(queryList: tiaoWenNumbers);
    } catch (e) {
      throw TiaoWenDataException(
        message: '批量查询条文数据失败: ${e.toString()}',
        tiaoWenNumbers: tiaoWenNumbers,
        originalException: e,
      );
    }
  }

  /// 创建简单的BaseNumberTiaoWenListModel列表的公共方法
  ///
  /// 适用于交互式UseCase中需要将条文编号转换为BaseNumberTiaoWenListModel的场景
  /// [tiaoWenNumbers] 条文编号列表
  /// [tiaoWenEntities] 条文数据列表（可选，如果提供则直接使用，否则创建空的模型）
  /// 返回BaseNumberTiaoWenListModel列表
  List<BaseNumberTiaoWenListModel> createSimpleBaseNumberTiaoWenListModels(
    List<int> tiaoWenNumbers, {
    List<TiaoWenDataModel>? tiaoWenEntities,
  }) {
    final models = <BaseNumberTiaoWenListModel>[];

    for (int i = 0; i < tiaoWenNumbers.length; i++) {
      final tiaoWenNumber = tiaoWenNumbers[i];

      // 如果提供了条文数据，则查找对应的条文
      TiaoWenDataModel? tiaoWenEntity;
      if (tiaoWenEntities != null) {
        try {
          tiaoWenEntity = tiaoWenEntities.firstWhere(
            (entity) => entity.id == tiaoWenNumber,
          );
        } catch (e) {
          // 如果找不到对应的条文，则为null
          tiaoWenEntity = null;
        }
      }

      // 创建BaseNumberTiaoWenListModel
      final model = BaseNumberTiaoWenListModel(
        baseNumber: tiaoWenNumber,
        name: '条文$tiaoWenNumber',
        description: '条文编号: $tiaoWenNumber',
        source: BaseNumberSource.custom, // 交互式来源
        baseTiaoWen: tiaoWenEntity,
        tiaoWenNumbers: [tiaoWenNumber], // 简单模式下只包含自身
        tiaoWenDataList: tiaoWenEntity != null ? [tiaoWenEntity] : [],
      );

      models.add(model);
    }

    return models;
  }
}
