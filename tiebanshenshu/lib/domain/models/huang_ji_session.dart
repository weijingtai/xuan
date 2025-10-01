/// 皇极取数法会话管理 - V2架构
///
/// 基于huang_ji_formula_v2.dart和huang_ji_formula_data_v2.dart的新架构
/// 支持公式模板与数据分离、多种基础数定义类型、完整的用户选择流程
///
/// 主要特性：
/// - 支持PredefinedBaseNumber、DerivedBaseNumber、SelectableBaseNumber
/// - 完整的用户选择历史记录和恢复
/// - 基于V2架构的计算步骤管理
/// - 支持条文内容的加减30操作
library;

import 'package:json_annotation/json_annotation.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';

import 'huang_ji_formula_data_v2.dart';
import 'huang_ji_formula_v2.dart';
import 'interactive_session.dart';
import 'multi_base_number_selection.dart';
import 'tiao_wen_candidate.dart';
import 'yuan_hui_yun_shi.dart';

part 'huang_ji_session.g.dart';

/// 皇极取数计算步骤类型
enum HuangJiStepType {
  /// 初始化四柱
  initializeFourZhu,

  /// 计算元会运世数
  calculateYuanHuiYunShi,

  /// 计算初刻数
  calculateInitialNumber,

  /// 计算次条文数
  calculateSecondaryNumber,

  /// 选择基础数
  selectBaseNumber,

  /// 计算最终条文数
  calculateFinalNumbers,

  /// 获取条文内容
  getTiaoWenContent,

  /// 用户选择候选项（通用选择步骤）
  userSelection,

  /// 完成计算
  completed,
}

/// 用户选择的类型 - 基于V2架构
enum SelectionType {
  /// 预定义基础数选择（元会、运世等）
  predefinedBaseNumber,

  /// 派生基础数选择
  derivedBaseNumber,

  /// 可选择基础数选择（初刻数 +/- 30）
  selectableBaseNumber,

  /// 条文内容选择（加减30）
  tiaoWenContent,

  /// 自定义选择
  custom,
}

/// 候选项信息 - V2架构
@JsonSerializable()
class SelectionCandidate {
  final String id;
  final String name;
  final String description;
  // @JsonKey(
  //   fromJson: DataBaseNumberDefinitionConverter.fromJsonConvertor,
  //   toJson: DataBaseNumberDefinitionConverter.toJsonConvertor,
  // )
  final DataSelectableBaseNumber selectableBaseNumber;
  final String? tiaoWenContent;
  final BaseNumberDefinitionType? baseNumberType;
  final NumberSource? numberSource;
  final int? offset;
  final bool isDefault;
  final Map<String, dynamic>? metadata;

  const SelectionCandidate({
    required this.id,
    required this.name,
    required this.description,
    required this.selectableBaseNumber,
    this.tiaoWenContent,
    this.baseNumberType,
    this.numberSource,
    this.offset,
    this.isDefault = false,
    this.metadata,
  });

  /// 获取候选项的数值（兼容性getter）
  int get number => selectableBaseNumber.number;

  /// 获取候选项的原始数值（兼容性getter）
  int? get rawNumber => selectableBaseNumber.rawNumber;

  /// 从基础数定义创建候选项
  factory SelectionCandidate.fromBaseNumberDefinition(
    DataBaseNumberDefinition baseNumber, {
    bool isDefault = false,
  }) {
    // 如果已经是DataSelectableBaseNumber，直接使用
    DataSelectableBaseNumber selectableBaseNumber;
    if (baseNumber is DataSelectableBaseNumber) {
      selectableBaseNumber = baseNumber;
    } else {
      // 否则创建一个新的DataSelectableBaseNumber包装原始基础数
      selectableBaseNumber = DataSelectableBaseNumber(
        rawNumber: baseNumber.rawNumber,
        name: baseNumber.name,
        description: baseNumber.description,
        initialCandidate: baseNumber,
        candidateValue: baseNumber.number,
      );
    }

    return SelectionCandidate(
      id: '${baseNumber.name}_${baseNumber.number}',
      name: baseNumber.name,
      description: baseNumber.description,
      selectableBaseNumber: selectableBaseNumber,
      baseNumberType: baseNumber.type,
      numberSource: baseNumber is DataPredefinedBaseNumber
          ? baseNumber.source
          : null,
      isDefault: isDefault,
    );
  }

  /// 从条文公式创建候选项
  factory SelectionCandidate.fromTiaoWenFormula(
    TiaoWenFormulaData tiaoWenData, {
    bool isDefault = false,
  }) {
    // 创建一个基础的DataPredefinedBaseNumber作为初始候选项
    final initialCandidate = DataPredefinedBaseNumber(
      rawNumber: tiaoWenData.rawNumber,
      name: tiaoWenData.name,
      description: tiaoWenData.description,
      source: NumberSource.yunShi, // 默认来源，可根据实际情况调整
    );

    // 创建DataSelectableBaseNumber
    final selectableBaseNumber = DataSelectableBaseNumber(
      rawNumber: tiaoWenData.rawNumber,
      name: tiaoWenData.name,
      description: tiaoWenData.description,
      initialCandidate: initialCandidate,
      candidateValue: tiaoWenData.number,
    );

    return SelectionCandidate(
      id: '${tiaoWenData.name}_${tiaoWenData.number}',
      name: tiaoWenData.name,
      description: tiaoWenData.description,
      selectableBaseNumber: selectableBaseNumber,
      tiaoWenContent: tiaoWenData.description,
      isDefault: isDefault,
    );
  }

  factory SelectionCandidate.fromJson(Map<String, dynamic> json) =>
      _$SelectionCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$SelectionCandidateToJson(this);
}

/// 用户选择记录 - V2架构
@JsonSerializable()
class UserSelectionRecord {
  final String selectionId;
  final SelectionType selectionType;
  final String groupId;
  final String stepName;
  final String formulaName;
  final String? baseNumberDefinitionName;
  final String? tiaoWenFormulaName;
  final List<SelectionCandidate> candidates;
  final SelectionCandidate? selectedCandidate;
  final DateTime selectionTime;
  final String? selectionReason;
  final bool isCompleted;

  const UserSelectionRecord({
    required this.selectionId,
    required this.selectionType,
    required this.groupId,
    required this.stepName,
    required this.formulaName,
    this.baseNumberDefinitionName,
    this.tiaoWenFormulaName,
    required this.candidates,
    this.selectedCandidate,
    required this.selectionTime,
    this.selectionReason,
    this.isCompleted = false,
  });

  /// 创建待完成的选择记录
  factory UserSelectionRecord.pending({
    required String selectionId,
    required SelectionType selectionType,
    required String groupId,
    required String stepName,
    required String formulaName,
    String? baseNumberDefinitionName,
    String? tiaoWenFormulaName,
    required List<SelectionCandidate> candidates,
    String? selectionReason,
  }) {
    return UserSelectionRecord(
      selectionId: selectionId,
      selectionType: selectionType,
      groupId: groupId,
      stepName: stepName,
      formulaName: formulaName,
      baseNumberDefinitionName: baseNumberDefinitionName,
      tiaoWenFormulaName: tiaoWenFormulaName,
      candidates: candidates,
      selectionTime: DateTime.now(),
      selectionReason: selectionReason,
      isCompleted: false,
    );
  }

  factory UserSelectionRecord.fromJson(Map<String, dynamic> json) =>
      _$UserSelectionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$UserSelectionRecordToJson(this);

  /// 创建选择记录的副本，更新选择结果
  UserSelectionRecord copyWithSelection(
    SelectionCandidate candidate,
    String? reason,
  ) {
    return UserSelectionRecord(
      selectionId: selectionId,
      selectionType: selectionType,
      groupId: groupId,
      stepName: stepName,
      formulaName: formulaName,
      baseNumberDefinitionName: baseNumberDefinitionName,
      tiaoWenFormulaName: tiaoWenFormulaName,
      candidates: candidates,
      selectedCandidate: candidate,
      selectionTime: DateTime.now(),
      selectionReason: reason,
      isCompleted: true,
    );
  }
}

/// 皇极取数计算步骤状态
enum HuangJiStepStatus {
  /// 未开始
  notStarted,

  /// 进行中
  inProgress,

  /// 等待用户选择
  waitingForSelection,

  /// 已完成
  completed,

  /// 出错
  error,
}

/// 皇极取数计算步骤 - V2架构
@JsonSerializable()
class HuangJiCalculationStep {
  /// 步骤ID
  final String stepId;

  /// 步骤类型
  final HuangJiStepType stepType;

  /// 步骤名称
  final String stepName;

  /// 步骤描述
  final String description;

  /// 步骤序号
  final int stepNumber;

  /// 输入数据
  final Map<String, dynamic> inputData;

  /// 输出数据
  final Map<String, dynamic> outputData;

  /// 计算结果
  final int? result;

  /// 原始计算结果
  final int? rawResult;

  /// 计算公式或规则
  final String? formula;

  /// 分组ID（必需）
  final String groupId;

  /// 基础数定义名称
  final String? baseNumberDefinitionName;

  /// 条文公式名称
  final String? tiaoWenFormulaName;

  /// 关联的数据组
  final DataCalculationGroup? dataGroup;

  /// 关联的条文数据
  final TiaoWenFormulaData? tiaoWenData;

  /// 候选项（如果有选择）
  final List<TiaoWenCandidate>? candidates;

  /// 选择的候选项ID
  final String? selectedCandidateId;

  /// 用户选择记录
  final UserSelectionRecord? selectionRecord;

  /// 步骤状态
  final HuangJiStepStatus status;

  /// 步骤开始时间
  final DateTime startTime;

  /// 步骤完成时间
  final DateTime? completedTime;

  /// 错误信息（如果有）
  final String? errorMessage;

  /// 是否需要用户选择
  final bool requiresUserSelection;

  /// 选择类型（如果需要选择）
  final SelectionType? selectionType;

  const HuangJiCalculationStep({
    required this.stepId,
    required this.stepType,
    required this.stepName,
    required this.description,
    required this.stepNumber,
    required this.inputData,
    required this.outputData,
    this.result,
    this.rawResult,
    this.formula,
    required this.groupId,
    this.baseNumberDefinitionName,
    this.tiaoWenFormulaName,
    this.dataGroup,
    this.tiaoWenData,
    this.candidates,
    this.selectedCandidateId,
    this.selectionRecord,
    this.status = HuangJiStepStatus.notStarted,
    required this.startTime,
    this.completedTime,
    this.errorMessage,
    this.requiresUserSelection = false,
    this.selectionType,
  });

  /// 为基础数计算创建步骤
  factory HuangJiCalculationStep.forBaseNumber({
    required String stepId,
    required String groupId,
    required DataCalculationGroup dataGroup,
    required HuangJiStepType stepType,
    bool requiresUserSelection = false,
    SelectionType? selectionType,
  }) {
    return HuangJiCalculationStep(
      stepId: stepId,
      stepType: stepType,
      stepName: '${dataGroup.baseNumberDefinition.name} 计算',
      description: dataGroup.baseNumberDefinition.description,
      stepNumber: 0, // 将在会话中重新分配
      inputData: {},
      outputData: {},
      groupId: groupId,
      baseNumberDefinitionName: dataGroup.baseNumberDefinition.name,
      dataGroup: dataGroup,
      startTime: DateTime.now(),
      requiresUserSelection: requiresUserSelection,
      selectionType: selectionType,
    );
  }

  /// 为条文公式计算创建步骤
  factory HuangJiCalculationStep.forTiaoWenFormula({
    required String stepId,
    required String groupId,
    required TiaoWenFormulaData tiaoWenData,
    required HuangJiStepType stepType,
    bool requiresUserSelection = false,
    SelectionType? selectionType,
  }) {
    return HuangJiCalculationStep(
      stepId: stepId,
      stepType: stepType,
      stepName: '${tiaoWenData.name} 计算',
      description: tiaoWenData.description,
      stepNumber: 0, // 将在会话中重新分配
      inputData: {},
      outputData: {},
      groupId: groupId,
      tiaoWenFormulaName: tiaoWenData.name,
      tiaoWenData: tiaoWenData,
      startTime: DateTime.now(),
      requiresUserSelection: requiresUserSelection,
      selectionType: selectionType,
    );
  }

  /// 是否已完成
  bool get isCompleted => status == HuangJiStepStatus.completed;

  factory HuangJiCalculationStep.fromJson(Map<String, dynamic> json) =>
      _$HuangJiCalculationStepFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiCalculationStepToJson(this);

  /// 获取选中的候选项
  TiaoWenCandidate? get selectedCandidate {
    if (selectedCandidateId == null || candidates == null) return null;
    try {
      return candidates!.firstWhere((c) => c.id == selectedCandidateId);
    } catch (e) {
      return null;
    }
  }

  /// 复制并修改步骤
  HuangJiCalculationStep copyWith({
    String? stepId,
    HuangJiStepType? stepType,
    String? stepName,
    String? description,
    int? stepNumber,
    Map<String, dynamic>? inputData,
    Map<String, dynamic>? outputData,
    int? result,
    int? rawResult,
    String? formula,
    String? groupId,
    String? baseNumberDefinitionName,
    String? tiaoWenFormulaName,
    DataCalculationGroup? dataGroup,
    TiaoWenFormulaData? tiaoWenData,
    List<TiaoWenCandidate>? candidates,
    String? selectedCandidateId,
    UserSelectionRecord? selectionRecord,
    HuangJiStepStatus? status,
    DateTime? startTime,
    DateTime? completedTime,
    String? errorMessage,
    bool? requiresUserSelection,
    SelectionType? selectionType,
  }) {
    return HuangJiCalculationStep(
      stepId: stepId ?? this.stepId,
      stepType: stepType ?? this.stepType,
      stepName: stepName ?? this.stepName,
      description: description ?? this.description,
      stepNumber: stepNumber ?? this.stepNumber,
      inputData: inputData ?? this.inputData,
      outputData: outputData ?? this.outputData,
      result: result ?? this.result,
      rawResult: rawResult ?? this.rawResult,
      formula: formula ?? this.formula,
      groupId: groupId ?? this.groupId,
      baseNumberDefinitionName:
          baseNumberDefinitionName ?? this.baseNumberDefinitionName,
      tiaoWenFormulaName: tiaoWenFormulaName ?? this.tiaoWenFormulaName,
      dataGroup: dataGroup ?? this.dataGroup,
      tiaoWenData: tiaoWenData ?? this.tiaoWenData,
      candidates: candidates ?? this.candidates,
      selectedCandidateId: selectedCandidateId ?? this.selectedCandidateId,
      selectionRecord: selectionRecord ?? this.selectionRecord,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      errorMessage: errorMessage ?? this.errorMessage,
      requiresUserSelection:
          requiresUserSelection ?? this.requiresUserSelection,
      selectionType: selectionType ?? this.selectionType,
    );
  }
}

/// 皇极取数会话状态
enum HuangJiSessionStatus {
  /// 未开始
  notStarted,

  /// 进行中
  inProgress,

  /// 等待用户选择
  waitingForSelection,

  /// 已暂停
  paused,

  /// 已完成
  completed,

  /// 已取消
  cancelled,

  /// 出错
  error,
}

/// 公式实例 - 管理单个计算公式及其相关数据
@JsonSerializable()
class FormulaInstance {
  /// 公式实例ID
  final String instanceId;

  /// 公式名称（如"元会"、"运世"、"元会基础数"等）
  final String formulaName;

  /// 公式模板（来自huang_ji_formula_v2.dart）
  final HuangJiCalculationFormula formulaTemplate;

  /// 数据公式（来自huang_ji_formula_data_v2.dart）
  final HuangJiDataCalculationFormula dataFormula;

  /// 该公式的计算步骤
  final List<HuangJiCalculationStep> calculationSteps;

  /// 该公式的用户选择记录
  final List<UserSelectionRecord> selectionHistory;

  /// 当前步骤索引
  final int currentStepIndex;

  /// 公式状态
  final HuangJiSessionStatus status;

  /// 公式结果数据
  final Map<String, dynamic>? resultData;

  const FormulaInstance({
    required this.instanceId,
    required this.formulaName,
    required this.formulaTemplate,
    required this.dataFormula,
    required this.calculationSteps,
    required this.selectionHistory,
    required this.currentStepIndex,
    required this.status,
    this.resultData,
  });

  factory FormulaInstance.fromJson(Map<String, dynamic> json) =>
      _$FormulaInstanceFromJson(json);

  Map<String, dynamic> toJson() => _$FormulaInstanceToJson(this);

  /// 创建新的公式实例
  factory FormulaInstance.create({
    required String instanceId,
    required String formulaName,
    required HuangJiCalculationFormula formulaTemplate,
    required YuanHuiYunShi yuanHuiYunShi,
  }) {
    final dataFormula = formulaTemplate.toData(yuanHuiYunShi);

    return FormulaInstance(
      instanceId: instanceId,
      formulaName: formulaName,
      formulaTemplate: formulaTemplate,
      dataFormula: dataFormula,
      calculationSteps: [],
      selectionHistory: [],
      currentStepIndex: -1,
      status: HuangJiSessionStatus.notStarted,
    );
  }

  /// 获取当前步骤
  HuangJiCalculationStep? get currentStep {
    if (currentStepIndex < 0 || currentStepIndex >= calculationSteps.length) {
      return null;
    }
    return calculationSteps[currentStepIndex];
  }

  /// 检查是否需要用户选择
  bool get needsUserSelection {
    return currentStep?.requiresUserSelection == true;
  }

  /// 检查是否已完成
  bool get isCompleted {
    return status == HuangJiSessionStatus.completed;
  }

  /// 复制并修改公式实例
  FormulaInstance copyWith({
    String? instanceId,
    String? formulaName,
    HuangJiCalculationFormula? formulaTemplate,
    HuangJiDataCalculationFormula? dataFormula,
    List<HuangJiCalculationStep>? calculationSteps,
    List<UserSelectionRecord>? selectionHistory,
    int? currentStepIndex,
    HuangJiSessionStatus? status,
    Map<String, dynamic>? resultData,
  }) {
    return FormulaInstance(
      instanceId: instanceId ?? this.instanceId,
      formulaName: formulaName ?? this.formulaName,
      formulaTemplate: formulaTemplate ?? this.formulaTemplate,
      dataFormula: dataFormula ?? this.dataFormula,
      calculationSteps: calculationSteps ?? this.calculationSteps,
      selectionHistory: selectionHistory ?? this.selectionHistory,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      status: status ?? this.status,
      resultData: resultData ?? this.resultData,
    );
  }
}

/// 皇极取数法会话 - V2架构（支持多个计算公式）
@JsonSerializable()
class HuangJiSession {
  /// 会话唯一标识
  final String sessionId;

  /// 会话名称
  final String sessionName;

  /// 输入的八字
  final EightChars eightChars;

  /// 元会运世数据
  final YuanHuiYunShi yuanHuiYunShi;

  /// 公式实例列表（每个实例对应一个计算公式）
  final List<FormulaInstance> formulaInstances;

  /// 当前活跃的公式实例索引
  final int currentFormulaIndex;

  /// 多基础数选择管理器（新增）
  final MultiBaseNumberSelectionManager? multiSelectionManager;

  /// 会话开始时间
  final DateTime startTime;

  /// 最后活动时间
  final DateTime lastActivityAt;

  /// 会话结束时间
  final DateTime? endTime;

  /// 会话状态
  final HuangJiSessionStatus status;

  /// 最终结果数据
  final Map<String, dynamic>? resultData;

  /// 会话元数据
  final Map<String, dynamic>? metadata;

  const HuangJiSession({
    required this.sessionId,
    required this.sessionName,
    required this.eightChars,
    required this.yuanHuiYunShi,
    required this.formulaInstances,
    required this.currentFormulaIndex,
    this.multiSelectionManager,
    required this.startTime,
    required this.lastActivityAt,
    this.endTime,
    required this.status,
    this.resultData,
    this.metadata,
  });

  factory HuangJiSession.fromJson(Map<String, dynamic> json) =>
      _$HuangJiSessionFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiSessionToJson(this);

  /// 创建新会话 - V2架构（支持多个计算公式）
  factory HuangJiSession.create({
    required String sessionId,
    required String sessionName,
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulaTemplates,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final yuanHuiYunShi = YuanHuiYunShi.fromEightChars(eightChars);

    // 为每个公式模板创建公式实例
    final formulaInstances = formulaTemplates.asMap().entries.map((entry) {
      final index = entry.key;
      final template = entry.value;

      return FormulaInstance.create(
        instanceId: '${sessionId}_formula_$index',
        formulaName: template.name,
        formulaTemplate: template,
        yuanHuiYunShi: yuanHuiYunShi,
      );
    }).toList();

    return HuangJiSession(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      yuanHuiYunShi: yuanHuiYunShi,
      formulaInstances: formulaInstances,
      currentFormulaIndex: 0,
      startTime: now,
      lastActivityAt: now,
      status: HuangJiSessionStatus.notStarted,
      metadata: metadata,
    );
  }

  /// 从单个公式模板创建会话（向后兼容）
  factory HuangJiSession.createFromSingleFormula({
    required String sessionId,
    required String sessionName,
    required EightChars eightChars,
    required HuangJiCalculationFormula formulaTemplate,
    Map<String, dynamic>? metadata,
  }) {
    return HuangJiSession.create(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      formulaTemplates: [formulaTemplate],
      metadata: metadata,
    );
  }

  /// 获取当前活跃的公式实例
  FormulaInstance? get currentFormulaInstance {
    if (currentFormulaIndex < 0 ||
        currentFormulaIndex >= formulaInstances.length) {
      return null;
    }
    return formulaInstances[currentFormulaIndex];
  }

  /// 获取当前步骤
  HuangJiCalculationStep? get currentStep {
    return currentFormulaInstance?.currentStep;
  }

  /// 获取上一步骤
  HuangJiCalculationStep? get previousStep {
    final instance = currentFormulaInstance;
    if (instance == null || instance.currentStepIndex <= 0) return null;
    return instance.calculationSteps[instance.currentStepIndex - 1];
  }

  /// 获取指定公式实例
  FormulaInstance? getFormulaInstance(String formulaName) {
    try {
      return formulaInstances.firstWhere(
        (instance) => instance.formulaName == formulaName,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取指定公式实例的索引
  int getFormulaInstanceIndex(String formulaName) {
    return formulaInstances.indexWhere(
      (instance) => instance.formulaName == formulaName,
    );
  }

  /// 获取下一步骤
  HuangJiCalculationStep? get nextStep {
    final instance = currentFormulaInstance;
    if (instance == null) return null;
    if (instance.currentStepIndex + 1 >= instance.calculationSteps.length)
      return null;
    return instance.calculationSteps[instance.currentStepIndex + 1];
  }

  /// 获取所有需要用户选择的步骤
  List<HuangJiCalculationStep> get pendingSelectionSteps {
    final instance = currentFormulaInstance;
    if (instance == null) return [];
    return instance.calculationSteps
        .where(
          (step) =>
              step.requiresUserSelection &&
              step.status != HuangJiStepStatus.completed,
        )
        .toList();
  }

  /// 获取当前待选择的步骤
  HuangJiCalculationStep? get currentPendingSelection {
    return pendingSelectionSteps.isNotEmpty
        ? pendingSelectionSteps.first
        : null;
  }

  /// 检查是否有未完成的选择
  bool get hasPendingSelections {
    return pendingSelectionSteps.isNotEmpty;
  }

  /// 获取已选择的候选项列表（所有公式实例）
  List<TiaoWenCandidate> get selectedCandidates {
    return formulaInstances
        .expand((instance) => instance.calculationSteps)
        .where((step) => step.selectedCandidate != null)
        .map((step) => step.selectedCandidate!)
        .toList();
  }

  /// 根据公式名称和步骤类型获取选择的候选项
  TiaoWenCandidate? getSelectedCandidateByStepType(
    String formulaName,
    HuangJiStepType stepType,
  ) {
    final instance = getFormulaInstance(formulaName);
    if (instance == null) return null;

    final step = instance.calculationSteps
        .where((s) => s.stepType == stepType)
        .firstOrNull;
    return step?.selectedCandidate;
  }

  /// 是否可以前进到下一步
  bool get canMoveNext {
    final instance = currentFormulaInstance;
    if (instance == null) return false;
    return instance.currentStepIndex + 1 < instance.calculationSteps.length;
  }

  /// 是否可以回退到上一步
  bool get canMovePrevious {
    final instance = currentFormulaInstance;
    if (instance == null) return false;
    return instance.currentStepIndex > 0;
  }

  /// 是否已完成
  bool get isCompleted {
    return status == HuangJiSessionStatus.completed;
  }

  /// 是否需要用户选择
  bool get needsUserSelection {
    return hasPendingSelections;
  }

  /// 获取已完成的步骤数（所有公式实例）
  int get completedStepsCount {
    return formulaInstances
        .expand((instance) => instance.calculationSteps)
        .where((step) => step.isCompleted)
        .length;
  }

  /// 获取总步骤数（所有公式实例）
  int get totalStepsCount {
    return formulaInstances
        .expand((instance) => instance.calculationSteps)
        .length;
  }

  /// 获取进度百分比
  double get progressPercentage {
    if (totalStepsCount == 0) return 0.0;
    return completedStepsCount / totalStepsCount;
  }

  /// 获取选择进度百分比
  double get selectionProgressPercentage {
    final stepsWithSelection = formulaInstances
        .expand((instance) => instance.calculationSteps)
        .where((step) => step.requiresUserSelection)
        .length;
    if (stepsWithSelection == 0) return 1.0;
    final completedSelections = formulaInstances
        .expand((instance) => instance.calculationSteps)
        .where(
          (step) =>
              step.requiresUserSelection &&
              step.status == HuangJiStepStatus.completed,
        )
        .length;
    return completedSelections / stepsWithSelection;
  }

  /// 获取所有选择记录（所有公式实例）
  List<UserSelectionRecord> getAllSelections() {
    return formulaInstances
        .expand((instance) => instance.selectionHistory)
        .toList();
  }

  /// 根据公式名称获取选择记录
  List<UserSelectionRecord> getSelectionsByFormula(String formulaName) {
    final instance = getFormulaInstance(formulaName);
    return instance?.selectionHistory ?? [];
  }

  /// 根据选择类型获取选择记录（所有公式实例）
  List<UserSelectionRecord> getSelectionsByType(SelectionType type) {
    return getAllSelections()
        .where((record) => record.selectionType == type)
        .toList();
  }

  /// 根据公式名称和选择类型获取选择记录
  List<UserSelectionRecord> getSelectionsByFormulaAndType(
    String formulaName,
    SelectionType type,
  ) {
    return getSelectionsByFormula(
      formulaName,
    ).where((record) => record.selectionType == type).toList();
  }

  /// V2架构 - 获取可选择基础数的选择记录（指定公式）
  List<UserSelectionRecord> getSelectableBaseNumberSelections(
    String formulaName,
  ) {
    return getSelectionsByFormulaAndType(
      formulaName,
      SelectionType.selectableBaseNumber,
    );
  }

  /// V2架构 - 获取条文内容的选择记录（指定公式）
  List<UserSelectionRecord> getTiaoWenContentSelections(String formulaName) {
    return getSelectionsByFormulaAndType(
      formulaName,
      SelectionType.tiaoWenContent,
    );
  }

  /// V2架构 - 检查指定公式的可选择基础数是否已完成
  bool isSelectableBaseNumberCompleted(String formulaName) {
    return getSelectableBaseNumberSelections(
      formulaName,
    ).any((record) => record.isCompleted);
  }

  /// V2架构 - 获取指定公式和组的可选择基础数选择记录
  UserSelectionRecord? getSelectableBaseNumberSelection(
    String formulaName,
    String groupId,
  ) {
    return getSelectableBaseNumberSelections(
      formulaName,
    ).where((record) => record.groupId == groupId).firstOrNull;
  }

  /// 获取最新的选择记录
  UserSelectionRecord? getLatestSelection() {
    final allSelections = getAllSelections();
    if (allSelections.isEmpty) return null;

    // 按时间排序，返回最新的
    allSelections.sort((a, b) => a.selectionTime.compareTo(b.selectionTime));
    return allSelections.last;
  }

  /// 获取指定公式的最新选择记录
  UserSelectionRecord? getLatestSelectionByFormula(String formulaName) {
    final selections = getSelectionsByFormula(formulaName);
    if (selections.isEmpty) return null;

    selections.sort((a, b) => a.selectionTime.compareTo(b.selectionTime));
    return selections.last;
  }

  /// 根据选择ID获取选择记录
  UserSelectionRecord? getSelectionRecord(String selectionId) {
    try {
      return getAllSelections().firstWhere(
        (record) => record.selectionId == selectionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取最后一条选择记录
  UserSelectionRecord? get lastSelectionRecord {
    return getLatestSelection();
  }

  /// 复制并修改会话
  HuangJiSession copyWith({
    String? sessionId,
    String? sessionName,
    EightChars? eightChars,
    YuanHuiYunShi? yuanHuiYunShi,
    List<FormulaInstance>? formulaInstances,
    int? currentFormulaIndex,
    DateTime? startTime,
    DateTime? lastActivityAt,
    DateTime? endTime,
    HuangJiSessionStatus? status,
    Map<String, dynamic>? resultData,
    Map<String, dynamic>? metadata,
  }) {
    return HuangJiSession(
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      eightChars: eightChars ?? this.eightChars,
      yuanHuiYunShi: yuanHuiYunShi ?? this.yuanHuiYunShi,
      formulaInstances: formulaInstances ?? this.formulaInstances,
      currentFormulaIndex: currentFormulaIndex ?? this.currentFormulaIndex,
      startTime: startTime ?? this.startTime,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      resultData: resultData ?? this.resultData,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'HuangJiSession('
        'sessionId: $sessionId, '
        'sessionName: $sessionName, '
        'status: $status, '
        'currentFormulaIndex: $currentFormulaIndex, '
        'formulaInstances: ${formulaInstances.length}, '
        'totalSelections: ${getAllSelections().length})';
  }
}

/// 皇极取数会话管理器 - V2架构（支持多个公式实例）
class HuangJiSessionManager {
  /// 创建新会话（从多个公式模板）
  static HuangJiSession createFromTemplates({
    required String sessionId,
    required String sessionName,
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulaTemplates,
    Map<String, dynamic>? metadata,
  }) {
    return HuangJiSession.create(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      formulaTemplates: formulaTemplates,
      metadata: metadata,
    );
  }

  /// 创建新会话（从单个公式模板，向后兼容）
  static HuangJiSession createFromTemplate({
    required String sessionId,
    required String sessionName,
    required HuangJiCalculationFormula formulaTemplate,
    required EightChars eightChars,
    Map<String, dynamic>? metadata,
  }) {
    return HuangJiSession.createFromSingleFormula(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      formulaTemplate: formulaTemplate,
      metadata: metadata,
    );
  }

  /// 初始化指定公式实例的计算步骤
  static HuangJiSession initializeFormulaSteps(
    HuangJiSession session,
    String formulaName,
  ) {
    final instanceIndex = session.getFormulaInstanceIndex(formulaName);
    if (instanceIndex == -1) {
      throw ArgumentError('Formula instance not found: $formulaName');
    }

    final instance = session.formulaInstances[instanceIndex];
    final steps = <HuangJiCalculationStep>[];
    int stepNumber = 0;

    // 为每个数据组创建步骤
    for (final group in instance.dataFormula.groups) {
      // 基础数计算步骤
      final baseNumberStep = HuangJiCalculationStep.forBaseNumber(
        stepId: '${session.sessionId}_${formulaName}_step_${stepNumber++}',
        groupId: group.groupId,
        dataGroup: group,
        stepType: HuangJiStepType.selectBaseNumber,
        requiresUserSelection:
            group.baseNumberDefinition.type ==
            BaseNumberDefinitionType.selectable,
        selectionType:
            group.baseNumberDefinition.type ==
                BaseNumberDefinitionType.selectable
            ? SelectionType.selectableBaseNumber
            : null,
      );
      steps.add(baseNumberStep);

      // 条文公式计算步骤
      for (int i = 0; i < group.dataFormulas.length; i++) {
        final formula = group.dataFormulas[i];
        final formulaStep = HuangJiCalculationStep.forTiaoWenFormula(
          stepId: '${session.sessionId}_${formulaName}_formula_${stepNumber++}',
          groupId: group.groupId,
          tiaoWenData: formula,
          stepType: HuangJiStepType.calculateFinalNumbers,
          requiresUserSelection: false, // 条文公式本身不需要选择，但可能需要后续的加减30选择
        );
        steps.add(formulaStep);
      }
    }

    // 更新公式实例
    final updatedInstance = instance.copyWith(
      calculationSteps: steps,
      currentStepIndex: 0,
      status: HuangJiSessionStatus.inProgress,
    );

    // 更新会话中的公式实例
    final updatedInstances = List<FormulaInstance>.from(
      session.formulaInstances,
    );
    updatedInstances[instanceIndex] = updatedInstance;

    return session.copyWith(
      formulaInstances: updatedInstances,
      status: HuangJiSessionStatus.inProgress,
      lastActivityAt: DateTime.now(),
    );
  }

  /// 初始化所有公式实例的计算步骤
  static HuangJiSession initializeAllFormulaSteps(HuangJiSession session) {
    HuangJiSession updatedSession = session;

    for (final instance in session.formulaInstances) {
      updatedSession = initializeFormulaSteps(
        updatedSession,
        instance.formulaName,
      );
    }

    return updatedSession;
  }

  /// 为指定公式实例添加选择记录
  static HuangJiSession addSelectionRecordToFormula(
    HuangJiSession session,
    String formulaName,
    UserSelectionRecord record,
  ) {
    final instanceIndex = session.getFormulaInstanceIndex(formulaName);
    if (instanceIndex == -1) {
      throw ArgumentError('Formula instance not found: $formulaName');
    }

    final instance = session.formulaInstances[instanceIndex];
    final updatedHistory = List<UserSelectionRecord>.from(
      instance.selectionHistory,
    )..add(record);

    final updatedInstance = instance.copyWith(selectionHistory: updatedHistory);
    final updatedInstances = List<FormulaInstance>.from(
      session.formulaInstances,
    );
    updatedInstances[instanceIndex] = updatedInstance;

    return session.copyWith(
      formulaInstances: updatedInstances,
      lastActivityAt: DateTime.now(),
    );
  }

  /// 处理用户选择（支持多个公式实例）
  static HuangJiSession makeUserSelection({
    required HuangJiSession session,
    required String formulaName,
    required String stepId,
    required SelectionCandidate selectedCandidate,
  }) {
    final instanceIndex = session.getFormulaInstanceIndex(formulaName);
    if (instanceIndex == -1) {
      throw ArgumentError('Formula instance not found: $formulaName');
    }

    final instance = session.formulaInstances[instanceIndex];

    // 找到对应的步骤
    final stepIndex = instance.calculationSteps.indexWhere(
      (step) => step.stepId == stepId,
    );
    if (stepIndex == -1) {
      throw ArgumentError('Step not found: $stepId');
    }

    final step = instance.calculationSteps[stepIndex];
    if (!step.requiresUserSelection) {
      throw ArgumentError('Step $stepId does not require user selection');
    }

    // 创建选择记录
    final selectionRecord = UserSelectionRecord(
      selectionId:
          '${session.sessionId}_${formulaName}_selection_${DateTime.now().millisecondsSinceEpoch}',
      selectionType: step.selectionType!,
      groupId: step.groupId,
      stepName: step.stepName,
      formulaName: formulaName,
      baseNumberDefinitionName: step.baseNumberDefinitionName,
      tiaoWenFormulaName: step.tiaoWenFormulaName,
      candidates: [], // 这里需要从步骤中获取候选项
      selectedCandidate: selectedCandidate,
      selectionTime: DateTime.now(),
      isCompleted: true,
    );

    // 更新步骤
    final updatedStep = step.copyWith(
      selectionRecord: selectionRecord,
      status: HuangJiStepStatus.completed,
      completedTime: DateTime.now(),
      result: selectedCandidate.number,
      rawResult: selectedCandidate.rawNumber,
    );

    // 更新步骤列表
    final updatedSteps = List<HuangJiCalculationStep>.from(
      instance.calculationSteps,
    );
    updatedSteps[stepIndex] = updatedStep;

    // 添加选择记录到历史
    final updatedHistory = List<UserSelectionRecord>.from(
      instance.selectionHistory,
    )..add(selectionRecord);

    // 更新公式实例
    final updatedInstance = instance.copyWith(
      calculationSteps: updatedSteps,
      selectionHistory: updatedHistory,
    );

    // 更新会话中的公式实例
    final updatedInstances = List<FormulaInstance>.from(
      session.formulaInstances,
    );
    updatedInstances[instanceIndex] = updatedInstance;

    return session.copyWith(
      formulaInstances: updatedInstances,
      lastActivityAt: DateTime.now(),
    );
  }

  /// 切换到指定的公式实例
  static HuangJiSession switchToFormula(
    HuangJiSession session,
    String formulaName,
  ) {
    final instanceIndex = session.getFormulaInstanceIndex(formulaName);
    if (instanceIndex == -1) {
      throw ArgumentError('Formula instance not found: $formulaName');
    }

    return session.copyWith(
      currentFormulaIndex: instanceIndex,
      lastActivityAt: DateTime.now(),
    );
  }

  /// 获取指定公式实例的当前候选项
  static List<SelectionCandidate> getCurrentStepCandidatesForFormula(
    HuangJiSession session,
    String formulaName,
  ) {
    final instance = session.getFormulaInstance(formulaName);
    if (instance == null) return [];

    final currentStep = instance.currentStep;
    if (currentStep?.candidates == null) return [];

    return currentStep!.candidates!.map((candidate) {
      // 从TiaoWenCandidate的value创建DataSelectableBaseNumber
      final initialCandidate = DataPredefinedBaseNumber(
        rawNumber: candidate.value,
        name: candidate.displayName,
        description: candidate.description,
        source: NumberSource.yunShi, // 默认来源
      );

      final selectableBaseNumber = DataSelectableBaseNumber(
        rawNumber: candidate.value,
        name: candidate.displayName,
        description: candidate.description,
        initialCandidate: initialCandidate,
        candidateValue: candidate.value,
      );

      return SelectionCandidate(
        id: candidate.id,
        name: candidate.displayName,
        description: candidate.description,
        selectableBaseNumber: selectableBaseNumber,
        isDefault: candidate.isDefault,
      );
    }).toList();
  }

  /// 检查指定公式实例是否需要用户选择
  static bool needsUserSelectionForFormula(
    HuangJiSession session,
    String formulaName,
  ) {
    final instance = session.getFormulaInstance(formulaName);
    return instance?.needsUserSelection ?? false;
  }

  /// 为可选择基础数生成候选项（指定公式实例）
  static List<SelectionCandidate> generateSelectableBaseNumberCandidates(
    String formulaName,
    DataSelectableBaseNumber selectableBase,
  ) {
    final candidates = <SelectionCandidate>[];
    final initialNumber = selectableBase.initialCandidate.number;

    // 基础候选项（初刻数）
    candidates.add(
      SelectionCandidate.fromBaseNumberDefinition(
        selectableBase.initialCandidate,
        isDefault: true,
      ),
    );

    // 加减30的候选项
    for (int offset in [-30, 30]) {
      // 创建调整后的基础数定义
      final adjustedInitialCandidate = DataPredefinedBaseNumber(
        rawNumber: (selectableBase.initialCandidate.rawNumber ?? 0) + offset,
        name: '${selectableBase.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${selectableBase.description} (${offset > 0 ? '+' : ''}$offset)',
        source: selectableBase.initialCandidate is DataPredefinedBaseNumber
            ? (selectableBase.initialCandidate as DataPredefinedBaseNumber)
                  .source
            : NumberSource.yunShi,
      );

      // 创建调整后的DataSelectableBaseNumber
      final adjustedSelectableBaseNumber = DataSelectableBaseNumber(
        rawNumber: (selectableBase.initialCandidate.rawNumber ?? 0) + offset,
        name: '${selectableBase.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${selectableBase.description} (${offset > 0 ? '+' : ''}$offset)',
        initialCandidate: adjustedInitialCandidate,
        candidateValue: initialNumber + offset,
      );

      final candidate = SelectionCandidate(
        id: '${formulaName}_${selectableBase.name}_offset_$offset',
        name: '${selectableBase.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${selectableBase.description} (${offset > 0 ? '+' : ''}$offset)',
        selectableBaseNumber: adjustedSelectableBaseNumber,
        baseNumberType: selectableBase.type,
        offset: offset,
      );
      candidates.add(candidate);
    }

    return candidates;
  }

  /// 为条文内容生成候选项（加减30操作，指定公式实例）
  static List<SelectionCandidate> generateTiaoWenContentCandidates(
    String formulaName,
    TiaoWenFormulaData tiaoWenData,
  ) {
    final candidates = <SelectionCandidate>[];
    final baseNumber = tiaoWenData.number;

    // 基础候选项
    candidates.add(
      SelectionCandidate.fromTiaoWenFormula(tiaoWenData, isDefault: true),
    );

    // 加减30的候选项
    for (int offset in [-30, 30]) {
      // 创建调整后的基础数定义
      final adjustedInitialCandidate = DataPredefinedBaseNumber(
        rawNumber: (tiaoWenData.rawNumber ?? 0) + offset,
        name: '${tiaoWenData.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${tiaoWenData.description} (${offset > 0 ? '+' : ''}$offset)',
        source: NumberSource.yunShi, // 条文数据默认来源
      );

      // 创建调整后的DataSelectableBaseNumber
      final adjustedSelectableBaseNumber = DataSelectableBaseNumber(
        rawNumber: (tiaoWenData.rawNumber ?? 0) + offset,
        name: '${tiaoWenData.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${tiaoWenData.description} (${offset > 0 ? '+' : ''}$offset)',
        initialCandidate: adjustedInitialCandidate,
        candidateValue: baseNumber + offset,
      );

      final candidate = SelectionCandidate(
        id: '${formulaName}_${tiaoWenData.name}_offset_$offset',
        name: '${tiaoWenData.name} ${offset > 0 ? '+' : ''}$offset',
        description:
            '${tiaoWenData.description} (${offset > 0 ? '+' : ''}$offset)',
        selectableBaseNumber: adjustedSelectableBaseNumber,
        tiaoWenContent: tiaoWenData.description,
        offset: offset,
      );
      candidates.add(candidate);
    }

    return candidates;
  }

  /// 创建用户选择步骤（指定公式实例）
  static HuangJiSession createUserSelectionStep({
    required HuangJiSession session,
    required String formulaName,
    required String selectionId,
    required SelectionType selectionType,
    required String groupId,
    required String stepName,
    required List<SelectionCandidate> candidates,
    String? baseNumberDefinitionName,
    String? tiaoWenFormulaName,
    String? selectionReason,
  }) {
    final selectionRecord = UserSelectionRecord.pending(
      selectionId: '${formulaName}_$selectionId',
      selectionType: selectionType,
      groupId: groupId,
      stepName: stepName,
      formulaName: formulaName,
      baseNumberDefinitionName: baseNumberDefinitionName,
      tiaoWenFormulaName: tiaoWenFormulaName,
      candidates: candidates,
      selectionReason: selectionReason,
    );

    return addSelectionRecordToFormula(session, formulaName, selectionRecord);
  }

  /// 获取指定公式实例的待选择步骤
  static List<HuangJiCalculationStep> getPendingSelectionStepsForFormula(
    HuangJiSession session,
    String formulaName,
  ) {
    final instance = session.getFormulaInstance(formulaName);
    if (instance == null) return [];

    return instance.calculationSteps
        .where(
          (step) =>
              step.requiresUserSelection &&
              step.status != HuangJiStepStatus.completed,
        )
        .toList();
  }

  /// 检查指定公式实例是否有待选择的步骤
  static bool hasFormulaInstancePendingSelections(
    HuangJiSession session,
    String formulaName,
  ) {
    return getPendingSelectionStepsForFormula(session, formulaName).isNotEmpty;
  }

  /// 获取所有公式实例的待选择步骤
  static Map<String, List<HuangJiCalculationStep>> getAllPendingSelectionSteps(
    HuangJiSession session,
  ) {
    final result = <String, List<HuangJiCalculationStep>>{};

    for (final instance in session.formulaInstances) {
      final pendingSteps = getPendingSelectionStepsForFormula(
        session,
        instance.formulaName,
      );
      if (pendingSteps.isNotEmpty) {
        result[instance.formulaName] = pendingSteps;
      }
    }

    return result;
  }

  /// 检查会话是否有任何待选择的步骤
  static bool hasAnyPendingSelections(HuangJiSession session) {
    return getAllPendingSelectionSteps(session).isNotEmpty;
  }
}
