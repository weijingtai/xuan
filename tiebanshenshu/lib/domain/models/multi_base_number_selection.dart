/// 多基础数选择模型
///
/// 支持同时选择多个基础数（如元会基础数、运世基础数）
/// 以及基于这些基础数的派生选择（如元会基础数一、运世基础数一）
library;

import 'package:json_annotation/json_annotation.dart';
import 'huang_ji_number.dart';
import 'tiao_wen_candidate.dart';

part 'multi_base_number_selection.g.dart';

/// 基础数选择类型
enum BaseNumberSelectionType {
  /// 元会基础数
  @JsonValue('yuan_hui')
  yuanHui('yuan_hui', '元会基础数'),

  /// 运世基础数
  @JsonValue('yun_shi')
  yunShi('yun_shi', '运世基础数'),

  /// 元会基础数一（基于元会基础数的派生）
  @JsonValue('yuan_hui_one')
  yuanHuiOne('yuan_hui_one', '元会基础数一'),

  /// 运世基础数一（基于运世基础数的派生）
  @JsonValue('yun_shi_one')
  yunShiOne('yun_shi_one', '运世基础数一'),

  /// 元会基础数二
  @JsonValue('yuan_hui_two')
  yuanHuiTwo('yuan_hui_two', '元会基础数二'),

  /// 运世基础数二
  @JsonValue('yun_shi_two')
  yunShiTwo('yun_shi_two', '运世基础数二');

  const BaseNumberSelectionType(this.value, this.displayName);

  final String value;
  final String displayName;

  /// 是否为主基础数（元会、运世）
  bool get isPrimary => this == yuanHui || this == yunShi;

  /// 是否为派生基础数
  bool get isDerived => !isPrimary;

  /// 获取父基础数类型
  BaseNumberSelectionType? get parentType {
    switch (this) {
      case yuanHuiOne:
      case yuanHuiTwo:
        return yuanHui;
      case yunShiOne:
      case yunShiTwo:
        return yunShi;
      default:
        return null;
    }
  }

  /// 获取同组的派生类型
  List<BaseNumberSelectionType> get derivedTypes {
    switch (this) {
      case yuanHui:
        return [yuanHuiOne, yuanHuiTwo];
      case yunShi:
        return [yunShiOne, yunShiTwo];
      default:
        return [];
    }
  }
}

/// 单个基础数的选择状态
@JsonSerializable()
class BaseNumberSelection {
  /// 选择类型
  final BaseNumberSelectionType type;

  /// 当前选择的基础数
  final HuangJiBaseNumber? selectedNumber;

  /// 可选候选项列表
  final List<TiaoWenCandidate> candidates;

  /// 选择状态
  final BaseNumberSelectionStatus status;

  /// 是否必需选择
  final bool isRequired;

  /// 选择顺序（用于UI排序）
  final int order;

  /// 依赖的父选择类型（对于派生基础数）
  final BaseNumberSelectionType? dependsOn;

  /// 错误信息
  final String? errorMessage;

  const BaseNumberSelection({
    required this.type,
    this.selectedNumber,
    required this.candidates,
    required this.status,
    required this.isRequired,
    required this.order,
    this.dependsOn,
    this.errorMessage,
  });

  factory BaseNumberSelection.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberSelectionFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberSelectionToJson(this);

  /// 创建初始状态
  factory BaseNumberSelection.initial({
    required BaseNumberSelectionType type,
    required bool isRequired,
    required int order,
    BaseNumberSelectionType? dependsOn,
  }) {
    return BaseNumberSelection(
      type: type,
      candidates: [],
      status: BaseNumberSelectionStatus.pending,
      isRequired: isRequired,
      order: order,
      dependsOn: dependsOn,
    );
  }

  /// 更新选择
  BaseNumberSelection copyWith({
    HuangJiBaseNumber? selectedNumber,
    List<TiaoWenCandidate>? candidates,
    BaseNumberSelectionStatus? status,
    String? errorMessage,
  }) {
    return BaseNumberSelection(
      type: type,
      selectedNumber: selectedNumber ?? this.selectedNumber,
      candidates: candidates ?? this.candidates,
      status: status ?? this.status,
      isRequired: isRequired,
      order: order,
      dependsOn: dependsOn,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 是否已完成选择
  bool get isCompleted =>
      status == BaseNumberSelectionStatus.completed && selectedNumber != null;

  /// 是否可以进行选择
  bool get canSelect =>
      status == BaseNumberSelectionStatus.ready && candidates.isNotEmpty;

  /// 是否正在等待依赖
  bool get isWaitingForDependency =>
      status == BaseNumberSelectionStatus.waitingForDependency;
}

/// 基础数选择状态
enum BaseNumberSelectionStatus {
  /// 等待开始
  @JsonValue('pending')
  pending,

  /// 等待依赖完成
  @JsonValue('waiting_for_dependency')
  waitingForDependency,

  /// 准备选择
  @JsonValue('ready')
  ready,

  /// 正在加载候选项
  @JsonValue('loading')
  loading,

  /// 已完成选择
  @JsonValue('completed')
  completed,

  /// 出错
  @JsonValue('error')
  error,
}

/// 多基础数选择管理器
@JsonSerializable()
class MultiBaseNumberSelectionManager {
  /// 所有基础数选择
  final Map<BaseNumberSelectionType, BaseNumberSelection> selections;

  /// 当前活跃的选择类型
  final BaseNumberSelectionType? currentActiveType;

  /// 整体选择状态
  final MultiSelectionStatus overallStatus;

  /// 选择阶段（主基础数阶段 -> 派生基础数阶段）
  final SelectionPhase currentPhase;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime lastUpdatedAt;

  const MultiBaseNumberSelectionManager({
    required this.selections,
    this.currentActiveType,
    required this.overallStatus,
    required this.currentPhase,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory MultiBaseNumberSelectionManager.fromJson(Map<String, dynamic> json) =>
      _$MultiBaseNumberSelectionManagerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MultiBaseNumberSelectionManagerToJson(this);

  /// 创建初始管理器
  factory MultiBaseNumberSelectionManager.create({
    required List<BaseNumberSelectionType> requiredTypes,
    required List<BaseNumberSelectionType> optionalTypes,
  }) {
    final now = DateTime.now();
    final Map<BaseNumberSelectionType, BaseNumberSelection> selections = {};

    // 添加必需的选择
    for (int i = 0; i < requiredTypes.length; i++) {
      final type = requiredTypes[i];
      selections[type] = BaseNumberSelection.initial(
        type: type,
        isRequired: true,
        order: i,
        dependsOn: type.parentType,
      );
    }

    // 添加可选的选择
    for (int i = 0; i < optionalTypes.length; i++) {
      final type = optionalTypes[i];
      selections[type] = BaseNumberSelection.initial(
        type: type,
        isRequired: false,
        order: requiredTypes.length + i,
        dependsOn: type.parentType,
      );
    }

    return MultiBaseNumberSelectionManager(
      selections: selections,
      overallStatus: MultiSelectionStatus.inProgress,
      currentPhase: SelectionPhase.primaryNumbers,
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  /// 获取主基础数选择（元会、运世）
  List<BaseNumberSelection> get primarySelections {
    return selections.values.where((s) => s.type.isPrimary).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取派生基础数选择
  List<BaseNumberSelection> get derivedSelections {
    return selections.values.where((s) => s.type.isDerived).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取当前阶段的选择
  List<BaseNumberSelection> get currentPhaseSelections {
    switch (currentPhase) {
      case SelectionPhase.primaryNumbers:
        return primarySelections;
      case SelectionPhase.derivedNumbers:
        return derivedSelections;
      case SelectionPhase.completed:
        return [];
    }
  }

  /// 获取下一个需要选择的类型
  BaseNumberSelectionType? get nextSelectionType {
    final currentSelections = currentPhaseSelections;

    for (final selection in currentSelections) {
      if (!selection.isCompleted && selection.canSelect) {
        return selection.type;
      }
    }

    return null;
  }

  /// 是否所有主基础数都已完成
  bool get isPrimaryPhaseCompleted {
    return primarySelections.every((s) => s.isCompleted || !s.isRequired);
  }

  /// 是否所有派生基础数都已完成
  bool get isDerivedPhaseCompleted {
    return derivedSelections.every((s) => s.isCompleted || !s.isRequired);
  }

  /// 是否整体选择已完成
  bool get isCompleted {
    return overallStatus == MultiSelectionStatus.completed;
  }

  /// 更新选择
  MultiBaseNumberSelectionManager updateSelection(
    BaseNumberSelectionType type,
    BaseNumberSelection newSelection,
  ) {
    final updatedSelections =
        Map<BaseNumberSelectionType, BaseNumberSelection>.from(selections);
    updatedSelections[type] = newSelection;

    // 创建临时管理器来检查阶段状态
    final tempManager = MultiBaseNumberSelectionManager(
      selections: updatedSelections,
      currentActiveType: currentActiveType,
      overallStatus: overallStatus,
      currentPhase: currentPhase,
      createdAt: createdAt,
      lastUpdatedAt: DateTime.now(),
    );

    // 检查是否需要更新阶段
    SelectionPhase newPhase = currentPhase;
    MultiSelectionStatus newStatus = overallStatus;

    if (currentPhase == SelectionPhase.primaryNumbers &&
        tempManager.isPrimaryPhaseCompleted) {
      newPhase = SelectionPhase.derivedNumbers;
    }

    if (newPhase == SelectionPhase.derivedNumbers && 
        tempManager.isDerivedPhaseCompleted) {
      newPhase = SelectionPhase.completed;
      newStatus = MultiSelectionStatus.completed;
    }

    // 创建最终的管理器
    final finalManager = MultiBaseNumberSelectionManager(
      selections: updatedSelections,
      currentActiveType: currentActiveType,
      overallStatus: newStatus,
      currentPhase: newPhase,
      createdAt: createdAt,
      lastUpdatedAt: DateTime.now(),
    );

    return finalManager.copyWith(
      currentActiveType: finalManager.nextSelectionType,
    );
  }

  /// 获取指定类型的选择
  BaseNumberSelection? getSelection(BaseNumberSelectionType type) {
    return selections[type];
  }

  /// 获取已完成的选择结果
  Map<BaseNumberSelectionType, HuangJiBaseNumber> get completedSelections {
    final Map<BaseNumberSelectionType, HuangJiBaseNumber> result = {};

    for (final entry in selections.entries) {
      if (entry.value.isCompleted && entry.value.selectedNumber != null) {
        result[entry.key] = entry.value.selectedNumber!;
      }
    }

    return result;
  }

  /// 复制并更新部分字段
  MultiBaseNumberSelectionManager copyWith({
    Map<BaseNumberSelectionType, BaseNumberSelection>? selections,
    BaseNumberSelectionType? currentActiveType,
    MultiSelectionStatus? overallStatus,
    SelectionPhase? currentPhase,
    DateTime? lastUpdatedAt,
  }) {
    return MultiBaseNumberSelectionManager(
      selections: selections ?? this.selections,
      currentActiveType: currentActiveType ?? this.currentActiveType,
      overallStatus: overallStatus ?? this.overallStatus,
      currentPhase: currentPhase ?? this.currentPhase,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
    );
  }
}

/// 多选择整体状态
enum MultiSelectionStatus {
  /// 进行中
  @JsonValue('in_progress')
  inProgress,

  /// 已完成
  @JsonValue('completed')
  completed,

  /// 已取消
  @JsonValue('cancelled')
  cancelled,

  /// 出错
  @JsonValue('error')
  error,
}

/// 选择阶段
enum SelectionPhase {
  /// 主基础数阶段（元会、运世）
  @JsonValue('primary_numbers')
  primaryNumbers,

  /// 派生基础数阶段（元会基础数一、运世基础数一等）
  @JsonValue('derived_numbers')
  derivedNumbers,

  /// 已完成
  @JsonValue('completed')
  completed,
}
