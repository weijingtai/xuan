/// 皇极取数法交互式UseCase
///
/// 负责处理皇极取数法交互式计算的业务逻辑编排
/// 实现ViewModel和Strategy之间的解耦，提供完整的交互式计算流程
library;

import 'package:flutter/foundation.dart';

import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../service/strategy/huang_ji_interactive_strategy.dart';
import '../services/interactive_session_service.dart';
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
  /// 皇极交互式策略（负责完整的交互式计算流程）
  final HuangJiInteractiveStrategy _strategy;

  /// 交互式会话服务（用于会话持久化和管理）
  final InteractiveSessionService _sessionService;

  /// 构造函数
  HuangJiInteractiveUseCase(
    this._strategy,
    this._sessionService,
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
      validateParams(params);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 参数验证完成');
      }

      // 转换参数为策略参数
      final strategyParams = HuangJiInteractiveStrategyParams(
        eightChars: params.eightChars,
        interactiveConfig: config,
      );

      // 委托到策略启动会话
      final session = await _strategy.startSession(strategyParams, config: config);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 会话创建完成');
        print('🆔 会话ID: ${session.sessionId}');
        print('📊 会话状态: ${session.status}');
        print('🎉 HuangJiInteractiveUseCase: 会话启动成功');
      }

      // 可选：将会话保存到会话服务中进行持久化
      await _sessionService.saveSession(session);

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveUseCase: 启动会话失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }

      if (e is InputValidationException) {
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
      if (kDebugMode) {
        print('🔧 HuangJiInteractiveUseCase: getCandidates 开始');
        print('🆔 会话ID: ${session.sessionId}');
        print('📊 会话状态: ${session.status}');
        print('📊 会话步骤数量: ${session.steps.length}');
      }

      // 委托到策略获取候选项
      final candidates = await _strategy.getCandidates(session);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: getCandidates 返回结果');
        print('📊 最终候选项数量: ${candidates.length}');
      }

      return candidates;
    } catch (e) {
      if (e is SessionNotFoundException || e is SessionStateException) {
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
      if (kDebugMode) {
        print('🔧 HuangJiInteractiveUseCase: selectCandidate 开始');
        print('🆔 会话ID: ${session.sessionId}');
        print('📊 候选项ID: $candidateId');
      }

      // 委托到策略选择候选项
      final updatedSession = await _strategy.selectCandidate(session, candidateId);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: selectCandidate 完成');
        print('📊 会话状态: ${updatedSession.status}');
      }

      // 可选：将更新后的会话保存到会话服务中
      await _sessionService.saveSession(updatedSession);

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is InvalidCandidateException ||
          e is SessionStateException) {
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
      // 委托到策略调整步骤
      final updatedSession = await _strategy.adjustStep(session, adjustments);

      // 可选：将更新后的会话保存到会话服务中
      await _sessionService.saveSession(updatedSession);

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException || e is SessionStateException) {
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
      if (kDebugMode) {
        print('🔄 HuangJiInteractiveUseCase: jumpTo 开始');
        print('📊 会话ID: ${session.sessionId}');
        print('📊 请求的步骤索引: $stepIndex');
        print('📊 会话步骤数: ${session.steps.length}');
        print('📊 当前步骤索引: ${session.currentStepIndex}');
        print('📊 会话状态: ${session.status}');
      }

      // 委托到策略跳转步骤
      final updatedSession = await _strategy.jumpTo(session, stepIndex);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: jumpTo 完成');
        print('📊 新的当前步骤索引: ${updatedSession.currentStepIndex}');
        print('📊 会话状态: ${updatedSession.status}');
      }

      // 可选：将更新后的会话保存到会话服务中
      await _sessionService.saveSession(updatedSession);

      return updatedSession;
    } catch (e) {
      if (e is InvalidStepIndexException || e is SessionStateException) {
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
  Future<InteractiveSession> undo(InteractiveSession session) async {
    try {
      if (kDebugMode) {
        print('🔄 HuangJiInteractiveUseCase: undo 开始');
        print('📊 会话ID: ${session.sessionId}');
        print('📊 当前步骤索引: ${session.currentStepIndex}');
      }

      // 委托到策略撤销操作
      final updatedSession = await _strategy.undo(session);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: undo 完成');
        print('📊 新的当前步骤索引: ${updatedSession.currentStepIndex}');
      }

      // 可选：将更新后的会话保存到会话服务中
      await _sessionService.saveSession(updatedSession);

      return updatedSession;
    } catch (e) {
      if (e is SessionStateException) {
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
      // 委托到策略获取无限列表
      return await _strategy.getInfiniteList(session, offset, limit);
    } catch (e) {
      throw UseCaseExecutionException(
        message: '获取无限列表失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  /// 完成交互式计算并获取最终结果
  ///
  /// [session] 会话对象
  /// 返回包含条文数据的最终计算结果
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [SessionNotCompletedException] 会话未完成
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  @override
  Future<MultiBaseNumberResult> completeCalculation(
    InteractiveSession session,
  ) async {
    try {
      if (kDebugMode) {
        print('🎯 HuangJiInteractiveUseCase: completeCalculation 开始');
        print('📊 会话ID: ${session.sessionId}');
        print('📊 会话状态: ${session.status}');
      }

      // 委托到策略完成计算
      final strategyResult = await _strategy.completeCalculation(session);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: completeCalculation 完成');
        print('📊 算法名称: ${strategyResult.algorithmName}');
        print('📊 基础数条文列表数量: ${strategyResult.baseNumberTiaoWenList.length}');
      }

      // 策略结果已经是 MultiBaseNumberResult 的子类，直接返回
      return strategyResult;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionNotCompletedException ||
          e is SessionStateException ||
          e is TiaoWenDataException) {
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
  @override
  Future<InteractiveSession> getSession(String sessionId) async {
    try {
      final session = await _sessionService.getSession(sessionId);
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
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  /// - [UseCaseExecutionException] UseCase执行失败
  @override
  Future<InteractiveSession> cancelSession(String sessionId) async {
    try {
      return await _sessionService.cancelSession(sessionId);
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
