/// 皇极取数法交互式会话步骤
///
/// 定义皇极取数法交互式计算的各个步骤
library;

/// 皇极取数法交互式步骤
///
/// 定义了皇极取数法交互式计算过程中的各个步骤
enum HuangJiInteractiveStep {
  /// 初始化：计算初刻数（规则1-4）
  initialization('initialization', '初始化计算', '计算年月日时的太玄数并求和得到初刻数'),

  /// 次条文数计算：基于初刻数计算次条文数（规则5前半部分）
  secondaryCalculation('secondary_calculation', '次条文数计算', '基于初刻数计算次条文数'),

  /// 用户选择：用户确认或调整基础数（规则5后半部分）
  userSelection('user_selection', '用户选择基础数', '用户确认次条文数或选择调整后的候选数'),

  /// 最终计算：基于确定的基础数计算12种条文数（规则6-17）
  finalCalculation('final_calculation', '最终计算', '基于确定的基础数计算12种不同的条文数'),

  /// 完成：计算完成，返回结果
  completed('completed', '计算完成', '所有计算步骤完成，返回最终结果');

  /// 步骤标识符
  final String id;

  /// 步骤名称
  final String name;

  /// 步骤描述
  final String description;

  const HuangJiInteractiveStep(this.id, this.name, this.description);

  /// 获取下一个步骤
  HuangJiInteractiveStep? get next {
    final currentIndex = values.indexOf(this);
    if (currentIndex < values.length - 1) {
      return values[currentIndex + 1];
    }
    return null;
  }

  /// 获取上一个步骤
  HuangJiInteractiveStep? get previous {
    final currentIndex = values.indexOf(this);
    if (currentIndex > 0) {
      return values[currentIndex - 1];
    }
    return null;
  }

  /// 是否为最后一个步骤
  bool get isLast => this == completed;

  /// 是否为第一个步骤
  bool get isFirst => this == initialization;

  /// 是否可以撤销到上一步
  bool get canUndo => !isFirst;

  /// 是否可以进入下一步
  bool get canProceed => !isLast;

  /// 从字符串创建步骤
  static HuangJiInteractiveStep? fromString(String id) {
    for (final step in values) {
      if (step.id == id) {
        return step;
      }
    }
    return null;
  }

  @override
  String toString() => id;
}

/// 皇极取数法交互式步骤扩展
extension HuangJiInteractiveStepExtension on HuangJiInteractiveStep {
  /// 获取步骤索引
  int get index => HuangJiInteractiveStep.values.indexOf(this);

  /// 获取进度百分比
  double get progress => (index + 1) / HuangJiInteractiveStep.values.length;

  /// 是否需要用户交互
  bool get requiresUserInteraction =>
      this == HuangJiInteractiveStep.userSelection;

  /// 是否为计算步骤
  bool get isCalculationStep => [
    HuangJiInteractiveStep.initialization,
    HuangJiInteractiveStep.secondaryCalculation,
    HuangJiInteractiveStep.finalCalculation,
  ].contains(this);
}
