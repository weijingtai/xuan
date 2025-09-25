/// 皇极取数法交互式UseCase
///
/// 负责处理皇极取数法交互式计算的业务逻辑编排
/// 实现ViewModel和Strategy之间的解耦，提供完整的交互式计算流程
library;

import 'package:flutter/foundation.dart';

import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/huang_ji_calculation_strategy.dart';
import '../../service/strategy/huang_ji_interactive_strategy.dart';
import 'base_interactive_use_case.dart';

/// 皇极取数法交互式UseCase实现
///
/// 负责编排皇极取数法的交互式计算流程：
/// 1. 会话管理和状态控制
/// 2. 候选项生成和验证
/// 3. 用户选择处理
/// 4. 最终结果计算和条文数据获取
class HuangJiInteractiveUseCase
    extends BaseInteractiveUseCase<HuangJiCalculationParams> {
  /// 皇极交互式策略
  final HuangJiInteractiveStrategy _interactiveStrategy;

  /// 皇极标准计算策略
  final HuangJiCalculationStrategy _calculationStrategy;

  /// 条文数据仓库
  final TiaoWenRepository _repository;

  /// 构造函数
  HuangJiInteractiveUseCase(
    this._interactiveStrategy,
    this._calculationStrategy,
    this._repository,
  );

  @override
  String get name => '皇极取数法交互式UseCase';

  @override
  String get description => '基于皇极取数法交互式策略的UseCase，支持用户参与式选择和计算';

  @override
  Future<InteractiveSession> startSession(
    HuangJiCalculationParams params, {
    InteractiveStrategyConfig? config,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 HuangJiInteractiveUseCase: 开始启动会话');
        print('📊 输入参数: ${params.eightChars.toString()}');
      }

      // 验证输入参数
      _validateParams(params);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 参数验证完成');
        print('📞 HuangJiInteractiveUseCase: 调用Strategy.startSession');
      }

      // 启动交互式会话
      final session = await _interactiveStrategy.startSession(
        params,
        config: config,
      );

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: Strategy.startSession 完成');
        print('🆔 会话ID: ${session.sessionId}');
        print('📊 会话状态: ${session.status}');
        print('🎉 HuangJiInteractiveUseCase: 会话启动成功');
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveUseCase: 启动会话失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }

      if (e is InputValidationException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '启动皇极交互式会话失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<List<TiaoWenCandidate>> getCandidates(
    InteractiveSession session,
  ) async {
    try {
      // 获取候选项
      final candidates = await _interactiveStrategy.getCandidates(session);
      return candidates;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '获取候选项失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> selectCandidate(
    InteractiveSession session,
    String candidateId,
  ) async {
    try {
      // 选择候选项
      final updatedSession = await _interactiveStrategy.selectCandidate(
        session,
        candidateId,
      );

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is InvalidCandidateException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '选择候选项失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> adjustStep(
    InteractiveSession session,
    Map<String, dynamic> adjustments,
  ) async {
    try {
      // 调整步骤
      final updatedSession = await _interactiveStrategy.adjustStep(
        session,
        adjustments,
      );

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '调整步骤失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> jumpTo(
    InteractiveSession session,
    int stepIndex,
  ) async {
    try {
      // 跳转到指定步骤
      final updatedSession = await _interactiveStrategy.jumpTo(
        session,
        stepIndex,
      );

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is InvalidStepIndexException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '跳转步骤失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> undo(InteractiveSession sessionId) async {
    try {
      // 撤销操作
      final updatedSession = await _interactiveStrategy.undo(sessionId);
      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '撤销操作失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<List<dynamic>> getInfiniteList(
    InteractiveSession session,
    int offset,
    int limit,
  ) async {
    try {
      // 获取无限列表数据
      final candidates = await _interactiveStrategy.getInfiniteList(
        session,
        offset,
        limit,
      );

      return candidates;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '获取无限列表数据失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  /// 完成交互式计算并获取最终结果
  ///
  /// [sessionId] 会话ID
  /// 返回包含条文数据的最终计算结果
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionNotCompletedException] 会话未完成
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<MultiBaseNumberResult> completeCalculation(
    InteractiveSession session,
  ) async {
    try {
      // 获取会话
      // final session = await _interactiveStrategy.getSession(sessionId);

      // 验证会话状态
      if (!session.isCompleted) {
        throw SessionNotCompletedException('会话尚未完成，无法生成最终结果');
      }

      // 完成计算
      final calculationResult = await _interactiveStrategy.completeCalculation(
        session,
      );
      // HuangJiCalculationResult.success(initialNumber: initialNumber, secondaryNumber: secondaryNumber, baseNumber: baseNumber, finalNumbers: finalNumbers, calculationSteps: calculationSteps)
      // 转换为MultiBaseNumberResult
      final multiResult = MultiBaseNumberResult.success(
        algorithmName: "皇极经世取数（一）",
        algorithmDescription: "基于皇极经世取数法的交互式计算",
        calculationParams: "交互式会话: ${session.sessionId}",
        baseNumbers: [], // 皇极取数法可能需要适配BaseNumberModel
        tiaoWenEntities: calculationResult.tiaoWenDataList!
            .map(
              (e) => TiaoWenDataModel(
                id: e.id,
                setName: e.setName,
                content1: e.content1,
                content2: e.content2,
                ageSet1: e.ageSet1,
                ageSet2: e.ageSet2,
              ),
            )
            .toList(),
        sourceData: calculationResult.calculationSteps,
      );

      return multiResult;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionNotCompletedException ||
          e is TiaoWenDataException ||
          e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: "皇极经世取数（一）",
        algorithmDescription: "基于皇极经世取数法的交互式计算",
        calculationParams: "会话ID: ${session.sessionId}",
        errorMessage: '完成交互式计算失败: ${e.toString()}',
      );
    }
  }

  /// 获取会话信息
  ///
  /// [sessionId] 会话ID
  /// 返回会话信息
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> getSession(String sessionId) async {
    try {
      InteractiveSession? session = await _interactiveStrategy.getSession(
        sessionId,
      );
      if (session == null) {
        throw SessionNotFoundException('会话不存在');
      }
      return session;
    } catch (e) {
      if (e is SessionNotFoundException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '获取会话信息失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  /// 取消会话
  ///
  /// [sessionId] 会话ID
  /// 返回取消后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<InteractiveSession> cancelSession(String sessionId) async {
    try {
      final session = await _interactiveStrategy.getSession(sessionId);
      if (session == null) {
        throw SessionNotFoundException('会话不存在');
      }
      return await _interactiveStrategy.cancelSession(session);
    } catch (e) {
      if (e is SessionNotFoundException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '取消会话失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  /// 验证输入参数
  ///
  /// [params] 待验证的参数
  /// 抛出 [InputValidationException] 如果参数无效
  void _validateParams(HuangJiCalculationParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        '四柱参数不能为空',
        parameterName: 'fourZhu',
        message: '四柱信息是皇极取数法计算的必需参数',
      );
    }

    // // 验证四柱的完整性
    // final fourZhu = params.eightChars;
    // if (fourZhu.year == null ||
    //     fourZhu.yearZhi.isEmpty ||
    //     fourZhu.monthGan.isEmpty ||
    //     fourZhu.monthZhi.isEmpty ||
    //     fourZhu.dayGan.isEmpty ||
    //     fourZhu.dayZhi.isEmpty ||
    //     fourZhu.timeGan.isEmpty ||
    //     fourZhu.timeZhi.isEmpty) {
    //   throw InputValidationException(
    //     '四柱信息不完整',
    //     parameterName: 'fourZhu',
    //     message: '年、月、日、时的干支信息都必须完整',
    //   );
    // }
  }

  @override
  void validateCandidateId(String candidateId) {
    // TODO: implement validateCandidateId
  }

  @override
  void validateParams(HuangJiCalculationParams params) {
    // TODO: implement validateParams
  }

  @override
  void validateSessionId(String sessionId) {
    // TODO: implement validateSessionId
  }

  @override
  void validateStepIndex(int stepIndex, int maxStepIndex) {
    // TODO: implement validateStepIndex
  }
}
