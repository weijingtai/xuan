/// 交互式策略配置模型
///
/// 定义交互式计算的配置参数
library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'interactive_strategy_config.g.dart';

/// 交互式策略配置
///
@JsonSerializable()
class InteractiveStrategyConfig extends Equatable {
  /// 是否启用四柱确认步骤
  final bool enableFourZhuConfirmation;

  /// 是否启用计算方法选择
  final bool enableCalculationMethodSelection;

  /// 是否启用卦象映射选择
  final bool enableGuaMappingSelection;

  /// 是否允许撤销操作
  final bool allowUndo;

  /// 是否允许跳转到指定步骤
  final bool allowJump;

  /// 最大撤销步数
  final int maxUndoSteps;

  /// 会话超时时间（分钟）
  final int sessionTimeoutMinutes;

  /// 是否自动保存会话状态
  final bool autoSaveSession;

  /// 是否显示详细进度
  final bool showDetailedProgress;

  /// 是否启用动画效果
  final bool enableAnimations;

  /// 调整步长（如30、1、5等）
  final int stepSize;

  /// 候选条文数量（一次展示多少个）
  final int candidateCount;

  /// 最大步骤数
  final int maxSteps;

  const InteractiveStrategyConfig({
    this.enableFourZhuConfirmation = true,
    this.enableCalculationMethodSelection = true,
    this.enableGuaMappingSelection = false,
    this.allowUndo = true,
    this.allowJump = false,
    this.maxUndoSteps = 10,
    this.sessionTimeoutMinutes = 30,
    this.autoSaveSession = true,
    this.showDetailedProgress = true,
    this.enableAnimations = true,
    this.stepSize = 30,
    this.candidateCount = 10,
    this.maxSteps = 5,
  });

  /// 创建默认配置
  factory InteractiveStrategyConfig.defaultConfig() {
    return const InteractiveStrategyConfig();
  }

  /// 创建简化配置（最少交互）
  factory InteractiveStrategyConfig.minimal() {
    return const InteractiveStrategyConfig(
      enableFourZhuConfirmation: false,
      enableCalculationMethodSelection: false,
      enableGuaMappingSelection: false,
      allowUndo: false,
      allowJump: false,
      showDetailedProgress: false,
      enableAnimations: false,
      stepSize: 1,
      candidateCount: 3,
      maxSteps: 3,
    );
  }

  /// 创建完整配置（最多交互）
  factory InteractiveStrategyConfig.full() {
    return const InteractiveStrategyConfig(
      enableFourZhuConfirmation: true,
      enableCalculationMethodSelection: true,
      enableGuaMappingSelection: true,
      allowUndo: true,
      allowJump: true,
      showDetailedProgress: true,
      enableAnimations: true,
      stepSize: 30,
      candidateCount: 15,
      maxSteps: 10,
    );
  }

  /// 复制并修改配置
  InteractiveStrategyConfig copyWith({
    bool? enableFourZhuConfirmation,
    bool? enableCalculationMethodSelection,
    bool? enableGuaMappingSelection,
    bool? allowUndo,
    bool? allowJump,
    int? maxUndoSteps,
    int? sessionTimeoutMinutes,
    bool? autoSaveSession,
    bool? showDetailedProgress,
    bool? enableAnimations,
    int? stepSize,
    int? candidateCount,
    int? maxSteps,
  }) {
    return InteractiveStrategyConfig(
      enableFourZhuConfirmation:
          enableFourZhuConfirmation ?? this.enableFourZhuConfirmation,
      enableCalculationMethodSelection:
          enableCalculationMethodSelection ??
          this.enableCalculationMethodSelection,
      enableGuaMappingSelection:
          enableGuaMappingSelection ?? this.enableGuaMappingSelection,
      allowUndo: allowUndo ?? this.allowUndo,
      allowJump: allowJump ?? this.allowJump,
      maxUndoSteps: maxUndoSteps ?? this.maxUndoSteps,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      autoSaveSession: autoSaveSession ?? this.autoSaveSession,
      showDetailedProgress: showDetailedProgress ?? this.showDetailedProgress,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      stepSize: stepSize ?? this.stepSize,
      candidateCount: candidateCount ?? this.candidateCount,
      maxSteps: maxSteps ?? this.maxSteps,
    );
  }

  /// 验证配置的有效性
  bool isValid() {
    return maxUndoSteps >= 0 &&
        sessionTimeoutMinutes > 0 &&
        sessionTimeoutMinutes <= 1440; // 最多24小时
  }

  /// 获取配置描述
  String getDescription() {
    final features = <String>[];

    if (enableFourZhuConfirmation) features.add('四柱确认');
    if (enableCalculationMethodSelection) features.add('计算方法选择');
    if (enableGuaMappingSelection) features.add('卦象映射');
    if (allowUndo) features.add('撤销操作');
    if (allowJump) features.add('步骤跳转');

    if (features.isEmpty) {
      return '简化模式';
    } else if (features.length >= 4) {
      return '完整交互模式';
    } else {
      return '标准模式 (${features.join(', ')})';
    }
  }

  @override
  List<Object?> get props => [
    enableFourZhuConfirmation,
    enableCalculationMethodSelection,
    enableGuaMappingSelection,
    allowUndo,
    allowJump,
    maxUndoSteps,
    sessionTimeoutMinutes,
    autoSaveSession,
    showDetailedProgress,
    enableAnimations,
    stepSize,
    candidateCount,
    maxSteps,
  ];

  @override
  String toString() {
    return 'InteractiveStrategyConfig('
        'enableFourZhuConfirmation: $enableFourZhuConfirmation, '
        'enableCalculationMethodSelection: $enableCalculationMethodSelection, '
        'enableGuaMappingSelection: $enableGuaMappingSelection, '
        'allowUndo: $allowUndo, '
        'allowJump: $allowJump, '
        'maxUndoSteps: $maxUndoSteps, '
        'sessionTimeoutMinutes: $sessionTimeoutMinutes, '
        'autoSaveSession: $autoSaveSession, '
        'showDetailedProgress: $showDetailedProgress, '
        'enableAnimations: $enableAnimations, '
        'stepSize: $stepSize, '
        'candidateCount: $candidateCount, '
        'maxSteps: $maxSteps'
        ')';
  }

  factory InteractiveStrategyConfig.fromJson(Map<String, dynamic> json) =>
      _$InteractiveStrategyConfigFromJson(json);

  Map<String, dynamic> toJson() => _$InteractiveStrategyConfigToJson(this);
}
