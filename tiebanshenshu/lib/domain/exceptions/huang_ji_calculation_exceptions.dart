/// 皇极取数法计算相关异常
///
/// 定义皇极取数法特有的异常类型
library;

import 'tiao_wen_calculation_exceptions.dart';

/// 皇极取数法计算异常
class HuangJiCalculationException extends TiaoWenCalculationException {
  /// 计算步骤
  final String? calculationStep;

  /// 四柱信息
  final String? fourZhuInfo;

  const HuangJiCalculationException({
    this.calculationStep,
    this.fourZhuInfo,
    required super.message,
    super.code = 'HUANG_JI_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'HuangJiCalculationException('
        'step: $calculationStep, '
        'fourZhu: $fourZhuInfo, '
        'code: $code, '
        'message: $message)';
  }
}

/// 太玄数计算异常
class TaiXuanNumberCalculationException extends HuangJiCalculationException {
  /// 干支信息
  final String? ganZhiInfo;

  /// 计算类型（年、月、日、时）
  final String? calculationType;

  const TaiXuanNumberCalculationException({
    this.ganZhiInfo,
    this.calculationType,
    super.calculationStep,
    super.fourZhuInfo,
    required super.message,
    super.code = 'TAI_XUAN_NUMBER_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'TaiXuanNumberCalculationException('
        'ganZhi: $ganZhiInfo, '
        'type: $calculationType, '
        'step: $calculationStep, '
        'code: $code, '
        'message: $message)';
  }
}

/// 初刻数计算异常
class InitialNumberCalculationException extends HuangJiCalculationException {
  /// 年太玄数
  final int? yearTaiXuan;

  /// 月太玄数
  final int? monthTaiXuan;

  /// 日太玄数
  final int? dayTaiXuan;

  /// 时太玄数
  final int? hourTaiXuan;

  const InitialNumberCalculationException({
    this.yearTaiXuan,
    this.monthTaiXuan,
    this.dayTaiXuan,
    this.hourTaiXuan,
    super.calculationStep = '初刻数计算',
    super.fourZhuInfo,
    required super.message,
    super.code = 'INITIAL_NUMBER_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'InitialNumberCalculationException('
        'year: $yearTaiXuan, '
        'month: $monthTaiXuan, '
        'day: $dayTaiXuan, '
        'hour: $hourTaiXuan, '
        'code: $code, '
        'message: $message)';
  }
}

/// 次条文数计算异常
class SecondaryNumberCalculationException extends HuangJiCalculationException {
  /// 初刻数
  final int? initialNumber;

  /// 计算规则
  final String? calculationRule;

  const SecondaryNumberCalculationException({
    this.initialNumber,
    this.calculationRule,
    super.calculationStep = '次条文数计算',
    super.fourZhuInfo,
    required super.message,
    super.code = 'SECONDARY_NUMBER_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'SecondaryNumberCalculationException('
        'initialNumber: $initialNumber, '
        'rule: $calculationRule, '
        'code: $code, '
        'message: $message)';
  }
}

/// 基础数选择异常
class BaseNumberSelectionException extends HuangJiCalculationException {
  /// 候选数值
  final int? candidateNumber;

  /// 选择原因
  final String? selectionReason;

  const BaseNumberSelectionException({
    this.candidateNumber,
    this.selectionReason,
    super.calculationStep = '基础数选择',
    super.fourZhuInfo,
    required super.message,
    super.code = 'BASE_NUMBER_SELECTION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'BaseNumberSelectionException('
        'candidate: $candidateNumber, '
        'reason: $selectionReason, '
        'code: $code, '
        'message: $message)';
  }
}

/// 最终条文数计算异常
class FinalNumbersCalculationException extends HuangJiCalculationException {
  /// 基础数
  final int? baseNumber;

  /// 失败的计算规则
  final List<String>? failedRules;

  const FinalNumbersCalculationException({
    this.baseNumber,
    this.failedRules,
    super.calculationStep = '最终条文数计算',
    super.fourZhuInfo,
    required super.message,
    super.code = 'FINAL_NUMBERS_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'FinalNumbersCalculationException('
        'baseNumber: $baseNumber, '
        'failedRules: $failedRules, '
        'code: $code, '
        'message: $message)';
  }
}

/// 皇极取数法交互式会话异常
class HuangJiInteractiveSessionException extends HuangJiCalculationException {
  /// 会话ID
  final String? sessionId;

  /// 当前步骤
  final String? currentStep;

  /// 期望步骤
  final String? expectedStep;

  const HuangJiInteractiveSessionException({
    this.sessionId,
    this.currentStep,
    this.expectedStep,
    super.calculationStep,
    super.fourZhuInfo,
    required super.message,
    super.code = 'HUANG_JI_INTERACTIVE_SESSION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'HuangJiInteractiveSessionException('
        'sessionId: $sessionId, '
        'currentStep: $currentStep, '
        'expectedStep: $expectedStep, '
        'code: $code, '
        'message: $message)';
  }
}