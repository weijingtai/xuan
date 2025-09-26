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
import '../services/interactive_session_service.dart';
import '../services/candidate_generation_service.dart';
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
  /// 皇极标准计算策略（只负责baseNumber计算）
  final HuangJiCalculationStrategy _calculationStrategy;

  /// 条文数据仓库
  final TiaoWenRepository _repository;

  /// 交互式会话服务
  final InteractiveSessionService _sessionService;

  /// 候选项生成服务
  final CandidateGenerationService _candidateService;

  /// 构造函数
  HuangJiInteractiveUseCase(
    this._calculationStrategy,
    this._repository,
    this._sessionService,
    this._candidateService,
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
      }

      // 创建会话
      final session = await _sessionService.createSession(
        strategyName: 'HuangJiCalculationStrategy',
        sessionConfig: {'params': params.toJson(), 'config': config?.toJson()},
      );

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 会话创建完成');
        print('🆔 会话ID: ${session.sessionId}');
      }

      // 使用标准策略进行初始计算
      final initialResult = await _calculationStrategy.calculate(params);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 初始计算完成');
        print('📊 初始结果: ${initialResult.toString()}');
      }

      // 创建基础数选择步骤
      final baseNumberStep = await _createBaseNumberSelectionStep(
        session,
        initialResult,
      );

      // 添加步骤到会话
      final updatedSession = await _sessionService.addStepToSession(
        session.sessionId,
        baseNumberStep,
      );

      if (kDebugMode) {
        print('✅ HuangJiInteractiveUseCase: 基础数选择步骤已添加');
        print('📊 会话状态: ${updatedSession.status}');
        print('🎉 HuangJiInteractiveUseCase: 会话启动成功');
      }

      return updatedSession;
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

      // 验证会话状态
      if (session.currentStep == null) {
        if (kDebugMode) {
          print('❌ HuangJiInteractiveUseCase: 当前步骤不存在');
        }
        throw SessionStateException('当前步骤不存在');
      }

      final currentStep = session.currentStep!;

      if (kDebugMode) {
        print('📊 当前步骤信息:');
        print('   - 步骤编号: ${currentStep.stepNumber}');
        print('   - 步骤名称: ${currentStep.stepName}');
        print('   - 步骤描述: ${currentStep.description}');
        print('   - 步骤状态: ${currentStep.status}');
        print('   - 候选项数量: ${currentStep.candidates.length}');
      }

      // 根据步骤类型生成候选项
      List<TiaoWenCandidate> candidates;

      if (currentStep.stepName == 'base_number_selection') {
        // 基础数选择步骤
        if (kDebugMode) {
          print('🔧 HuangJiInteractiveUseCase: 调用候选项生成服务 - 基础数选择');
        }

        // 准备包含计算结果的上下文
        final contextWithCalculationResult = Map<String, dynamic>.from(
          session.sessionConfig ?? {},
        );

        // 从当前步骤的stepData中获取计算结果
        if (currentStep.stepData != null &&
            currentStep.stepData!['calculationResult'] != null) {
          final calculationResult =
              currentStep.stepData!['calculationResult']
                  as Map<String, dynamic>;
          contextWithCalculationResult['params'] = {
            ...contextWithCalculationResult['params']
                    as Map<String, dynamic>? ??
                {},
            'initialNumber': calculationResult['initialNumber'],
            'secondaryNumber': calculationResult['secondaryNumber'],
            'finalNumbers': calculationResult['finalNumbers'],
          };

          if (kDebugMode) {
            print(
              '📊 从stepData获取计算结果: initialNumber=${calculationResult['initialNumber']}, secondaryNumber=${calculationResult['secondaryNumber']}',
            );
          }
        }

        if (kDebugMode) {
          print('📊 传递给候选项生成服务的上下文: $contextWithCalculationResult');
        }

        candidates = await _candidateService.generateBaseNumberCandidates(
          strategyName: 'HuangJiCalculationStrategy',
          context: contextWithCalculationResult,
        );
        if (kDebugMode) {
          print(
            '✅ HuangJiInteractiveUseCase: 候选项生成完成，数量: ${candidates.length}',
          );
        }
      } else if (currentStep.stepName == 'user_selection') {
        // 用户选择步骤
        final selectionHistory = _extractSelectionHistory(session);

        // 准备包含计算结果的上下文
        final contextWithCalculationResult = Map<String, dynamic>.from(
          session.sessionConfig ?? {},
        );

        // 从当前步骤的stepData中获取计算结果
        if (currentStep.stepData != null &&
            currentStep.stepData!['calculationResult'] != null) {
          final calculationResult =
              currentStep.stepData!['calculationResult']
                  as Map<String, dynamic>;
          contextWithCalculationResult['params'] = {
            ...contextWithCalculationResult['params']
                    as Map<String, dynamic>? ??
                {},
            'initialNumber': calculationResult['initialNumber'],
            'secondaryNumber': calculationResult['secondaryNumber'],
            'finalNumbers': calculationResult['finalNumbers'],
          };
        }

        candidates = await _candidateService.generateUserSelectionCandidates(
          strategyName: 'HuangJiCalculationStrategy',
          selectionHistory: selectionHistory,
          context: contextWithCalculationResult,
        );
      } else {
        // 返回当前步骤的候选项
        if (kDebugMode) {
          print('🔧 HuangJiInteractiveUseCase: 使用步骤中已存储的候选项');
          print('📊 步骤名称: ${currentStep.stepName}');
          print('📊 步骤候选项数量: ${currentStep.candidates.length}');
        }
        candidates = currentStep.candidates;
      }

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
      // 验证会话状态
      if (session.currentStep == null) {
        throw SessionStateException('当前步骤不存在');
      }

      final currentStep = session.currentStep!;

      // 验证候选项ID
      final selectedCandidate = currentStep.candidates
          .where((c) => c.id == candidateId)
          .firstOrNull;

      if (selectedCandidate == null) {
        throw InvalidCandidateException('无效的候选项ID: $candidateId');
      }

      // 更新当前步骤，标记为已完成
      final completedStep = currentStep.copyWith(
        selectedCandidateId: candidateId,
        completedTime: DateTime.now(),
        status: InteractiveSessionStatus.completed,
      );

      // 更新会话中的步骤
      var updatedSession = await _sessionService.updateSessionStep(
        session.sessionId,
        session.currentStepIndex,
        completedStep,
      );

      // 根据当前步骤类型决定下一步
      if (currentStep.stepName == 'base_number_selection') {
        // 基础数选择完成，直接完成会话
        updatedSession = await _sessionService.completeSession(
          updatedSession.sessionId,
          resultData: {
            'selectedBaseNumber': selectedCandidate.value,
            'completedAt': DateTime.now().toIso8601String(),
          },
        );
      } else if (currentStep.stepName == 'final_confirmation') {
        // 最终确认完成，标记会话为完成状态
        updatedSession = await _sessionService.completeSession(
          updatedSession.sessionId,
          resultData: {
            'selectedBaseNumber': selectedCandidate.value,
            'completedAt': DateTime.now().toIso8601String(),
          },
        );
      }

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
      // 验证会话状态
      if (session.currentStep == null) {
        throw SessionStateException('当前步骤不存在');
      }

      final currentStep = session.currentStep!;

      // 根据调整参数更新步骤数据
      final updatedStepData = Map<String, dynamic>.from(
        currentStep.stepData ?? {},
      )..addAll(adjustments);

      final adjustedStep = currentStep.copyWith(stepData: updatedStepData);

      // 更新会话中的步骤
      final updatedSession = await _sessionService.updateSessionStep(
        session.sessionId,
        session.currentStepIndex,
        adjustedStep,
      );

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

      // 验证步骤索引
      if (stepIndex < 0 || stepIndex >= session.steps.length) {
        if (kDebugMode) {
          print('❌ 无效的步骤索引: $stepIndex，有效范围: 0-${session.steps.length - 1}');
        }
        throw InvalidStepIndexException(
          '无效的步骤索引: $stepIndex，有效范围: 0-${session.steps.length - 1}',
        );
      }

      // 跳转到指定步骤
      final updatedSession = session.jumpToStep(stepIndex);

      if (kDebugMode) {
        print('✅ 步骤跳转成功');
        print('📊 更新后的当前步骤索引: ${updatedSession.currentStepIndex}');
      }

      // 保存会话状态
      await _sessionService.saveSession(updatedSession);

      if (kDebugMode) {
        print('✅ 会话状态保存成功');
      }

      return updatedSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveUseCase: jumpTo 失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }

      if (e is SessionNotFoundException ||
          e is InvalidStepIndexException ||
          e is SessionStateException) {
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
      // 验证是否可以撤销
      if (!session.canUndo) {
        throw SessionStateException('无法撤销，已在第一步');
      }

      // 撤销到上一步
      final undoSession = session.undoToPreviousStep();

      // 保存会话状态
      await _sessionService.saveSession(undoSession);

      return undoSession;
    } catch (e) {
      if (e is SessionNotFoundException || e is SessionStateException) {
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
      // 生成分页的候选项列表
      final allCandidates = await getCandidates(session);

      // 计算分页范围
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, allCandidates.length);

      if (startIndex >= allCandidates.length) {
        return [];
      }

      return allCandidates.sublist(startIndex, endIndex);
    } catch (e) {
      if (e is SessionNotFoundException || e is SessionStateException) {
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
  /// [session] 会话对象
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
      // 验证会话状态
      if (!session.isCompleted) {
        throw SessionNotCompletedException('会话尚未完成，无法生成最终结果');
      }

      // 从会话结果中获取选择的基础数
      final selectedBaseNumber =
          session.resultData?['selectedBaseNumber'] as int?;
      if (selectedBaseNumber == null) {
        throw SessionStateException('会话结果中缺少选择的基础数');
      }

      // 从会话配置中恢复原始参数
      final paramsJson =
          session.sessionConfig?['params'] as Map<String, dynamic>?;
      if (paramsJson == null) {
        throw SessionStateException('会话配置中缺少原始参数');
      }

      final originalParams = HuangJiCalculationParams.fromJson(paramsJson);

      // 使用选择的基础数创建新的计算参数
      final finalParams = originalParams.copyWith(
        baseNumber: selectedBaseNumber,
      );

      // 使用标准策略进行最终计算
      final calculationResult = await _calculationStrategy.calculate(
        finalParams,
      );

      // 获取条文数据
      final tiaoWenDataList = <TiaoWenDataModel>[];
      if (calculationResult.finalNumbers.isNotEmpty) {
        for (final number in calculationResult.finalNumbers) {
          try {
            final tiaoWenData = await _repository.getById(number);
            if (tiaoWenData != null) {
              tiaoWenDataList.add(tiaoWenData);
            }
          } catch (e) {
            if (kDebugMode) {
              print('警告: 获取条文数据失败 (数字: $number): $e');
            }
          }
        }
      }

      // 将TiaoWenDataModel列表转换为BaseNumberTiaoWenListModel列表
      final tiaoWenNumbers = tiaoWenDataList.map((data) => data.id).toList();
      final baseNumberTiaoWenList = createSimpleBaseNumberTiaoWenListModels(
        tiaoWenNumbers,
        tiaoWenEntities: tiaoWenDataList,
      );

      // 转换为MultiBaseNumberResult
      final multiResult = MultiBaseNumberResult.success(
        algorithmName: "皇极经世取数（一）",
        algorithmDescription: "基于皇极经世取数法的交互式计算",
        calculationParams: "交互式会话: ${session.sessionId}",
        sourceData: calculationResult.calculationSteps,
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
      );

      return multiResult;
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

  /// 创建基础数选择步骤
  ///
  /// [session] 当前会话
  /// [calculationResult] 初始计算结果
  /// 返回基础数选择步骤
  Future<InteractiveSessionStep> _createBaseNumberSelectionStep(
    InteractiveSession session,
    HuangJiCalculationResult calculationResult,
  ) async {
    if (kDebugMode) {
      print('🔧 HuangJiInteractiveUseCase: 创建基础数选择步骤');
      print('📊 计算结果 - 初始条文数: ${calculationResult.initialNumber}');
      print('📊 计算结果 - 次条文数: ${calculationResult.secondaryNumber}');
    }

    // 准备包含计算结果的上下文
    final contextWithCalculationResult = Map<String, dynamic>.from(
      session.sessionConfig ?? {},
    );
    contextWithCalculationResult['params'] = {
      ...contextWithCalculationResult['params'] as Map<String, dynamic>? ?? {},
      'initialNumber': calculationResult.initialNumber,
      'secondaryNumber': calculationResult.secondaryNumber,
      'finalNumbers': calculationResult.finalNumbers,
    };

    if (kDebugMode) {
      print('📊 传递给候选项生成服务的上下文: $contextWithCalculationResult');
    }

    // 生成基础数候选项
    final candidates = await _candidateService.generateBaseNumberCandidates(
      strategyName: 'HuangJiCalculationStrategy',
      context: contextWithCalculationResult,
    );

    if (kDebugMode) {
      print('✅ HuangJiInteractiveUseCase: 基础数候选项生成完成');
      print('📊 候选项数量: ${candidates.length}');
      print(
        '📋 第一个候选项: ${candidates.isNotEmpty ? candidates.first.displayName : 'N/A'}',
      );
      print(
        '📋 最后一个候选项: ${candidates.isNotEmpty ? candidates.last.displayName : 'N/A'}',
      );
    }

    return InteractiveSessionStep(
      stepNumber: 1,
      stepName: 'base_number_selection',
      description: '请选择基础数',
      candidates: candidates,
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.waitingForSelection,
      stepData: {
        'calculationResult': calculationResult.toJson(),
        'availableNumbers': calculationResult.finalNumbers,
      },
    );
  }

  /// 提取选择历史
  ///
  /// [session] 当前会话
  /// 返回用户的选择历史
  Map<String, dynamic> _extractSelectionHistory(InteractiveSession session) {
    final history = <String, dynamic>{};

    // 提取基础数选择
    for (final step in session.steps) {
      if (step.stepName == 'base_number_selection' &&
          step.selectedCandidateId != null) {
        // 从候选项中找到选择的基础数
        final selectedCandidate = step.candidates?.firstWhere(
          (candidate) => candidate.id == step.selectedCandidateId,
          orElse: () => throw Exception('Selected candidate not found'),
        );
        if (selectedCandidate != null) {
          history['baseNumber'] = selectedCandidate.value;
        }
      }
    }

    // 如果没有找到基础数，使用默认值
    if (!history.containsKey('baseNumber')) {
      history['baseNumber'] = 1;
    }

    // 添加其他选择历史信息
    final selectedCandidateIds = <String>[];
    for (final step in session.steps) {
      if (step.selectedCandidateId != null) {
        selectedCandidateIds.add(step.selectedCandidateId!);
      }
    }
    history['selectedCandidateIds'] = selectedCandidateIds;

    return history;
  }

  /// 创建最终确认步骤
  ///
  /// [session] 当前会话
  /// [selectedCandidate] 用户选择的候选项
  /// 返回最终确认步骤
  Future<InteractiveSessionStep> _createFinalConfirmationStep(
    InteractiveSession session,
    TiaoWenCandidate selectedCandidate,
  ) async {
    // 创建确认候选项
    final confirmationCandidates = [
      TiaoWenCandidate(
        id: 'confirm_${selectedCandidate.id}',
        value: selectedCandidate.value,
        displayName: '确认选择: ${selectedCandidate.displayName}',
        description: '确认使用此基础数进行最终计算',
        type: TiaoWenCandidateType.confirmation,
        metadata: {
          'action': 'confirm',
          'originalCandidate': selectedCandidate.toJson(),
        },
      ),
      TiaoWenCandidate(
        id: 'cancel_selection',
        value: -1,
        displayName: '重新选择',
        description: '返回上一步重新选择基础数',
        type: TiaoWenCandidateType.confirmation,
        metadata: {'action': 'cancel'},
      ),
    ];

    return InteractiveSessionStep(
      stepNumber: session.steps.length + 1,
      stepName: 'final_confirmation',
      description: '请确认您的选择',
      candidates: confirmationCandidates,
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.waitingForSelection,
      stepData: {
        'selectedBaseNumber': selectedCandidate.value,
        'selectedCandidateId': selectedCandidate.id,
      },
    );
  }
}
