import 'package:json_annotation/json_annotation.dart';
import '../../features/huang_ji/huang_ji_formula_data_v2.dart';

part 'base_number_selection_record.g.dart';

/// 选择状态枚举
enum SelectionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// 候选项生成配置
@JsonSerializable()
class CandidateGenerationConfig {
  /// 初刻数
  final int initialNumber;

  /// 偏移量 (默认 30)
  final int offset;

  /// 生成数量 (前后各取)
  final int count;

  /// 最小值
  final int minValue;

  /// 最大值
  final int maxValue;

  const CandidateGenerationConfig({
    required this.initialNumber,
    this.offset = 30,
    this.count = 10,
    this.minValue = 1000,
    this.maxValue = 13000,
  });

  factory CandidateGenerationConfig.fromJson(Map<String, dynamic> json) =>
      _$CandidateGenerationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CandidateGenerationConfigToJson(this);

  CandidateGenerationConfig copyWith({
    int? initialNumber,
    int? offset,
    int? count,
    int? minValue,
    int? maxValue,
  }) {
    return CandidateGenerationConfig(
      initialNumber: initialNumber ?? this.initialNumber,
      offset: offset ?? this.offset,
      count: count ?? this.count,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }
}

/// 基础数候选项
@JsonSerializable()
class BaseNumberCandidate {
  /// 候选项 ID
  final String id;

  /// 条文数
  final int number;

  /// 相对初刻数的偏移
  final int offsetFromInitial;

  /// 条文内容
  final String tiaoWenContent;

  /// 是否为初刻数
  final bool isInitial;

  const BaseNumberCandidate({
    required this.id,
    required this.number,
    required this.offsetFromInitial,
    this.tiaoWenContent = '',
    this.isInitial = false,
  });

  factory BaseNumberCandidate.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberCandidateToJson(this);

  BaseNumberCandidate copyWith({
    String? id,
    int? number,
    int? offsetFromInitial,
    String? tiaoWenContent,
    bool? isInitial,
  }) {
    return BaseNumberCandidate(
      id: id ?? this.id,
      number: number ?? this.number,
      offsetFromInitial: offsetFromInitial ?? this.offsetFromInitial,
      tiaoWenContent: tiaoWenContent ?? this.tiaoWenContent,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  @override
  String toString() {
    return 'BaseNumberCandidate(number: $number, offset: ${offsetFromInitial >= 0 ? '+' : ''}$offsetFromInitial, isInitial: $isInitial)';
  }
}

/// 派生步骤
@JsonSerializable()
class DerivationStep {
  /// 操作描述 (例如: "+年干*1000")
  final String operation;

  /// 数值
  final int value;

  /// 详细描述
  final String description;

  const DerivationStep({
    required this.operation,
    required this.value,
    required this.description,
  });

  factory DerivationStep.fromJson(Map<String, dynamic> json) =>
      _$DerivationStepFromJson(json);

  Map<String, dynamic> toJson() => _$DerivationStepToJson(this);

  @override
  String toString() {
    return '$operation (value: $value)';
  }
}

/// 基础数派生链路
@JsonSerializable()
class BaseNumberDerivationChain {
  /// 原始基础数 (元会或运世)
  @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
  final DataPredefinedBaseNumber source;

  /// 派生步骤列表
  @JsonKey(fromJson: _derivationStepsFromJson, toJson: _derivationStepsToJson)
  final List<DerivationStep> derivationSteps;

  /// 最终基础数定义
  @JsonKey(
    fromJson: DataBaseNumberDefinitionConverter.fromJsonConvertor,
    toJson: DataBaseNumberDefinitionConverter.toJsonConvertor,
  )
  final DataBaseNumberDefinition finalDefinition;

  const BaseNumberDerivationChain({
    required this.source,
    required this.derivationSteps,
    required this.finalDefinition,
  });

  /// 获取完整路径描述
  String getFullPath() {
    final buffer = StringBuffer();
    buffer.write('${source.name}(${source.number})');

    for (final step in derivationSteps) {
      buffer.write(' → ${step.operation}(${step.value})');
    }

    buffer.write(' → ${finalDefinition.name}(${finalDefinition.number})');
    return buffer.toString();
  }

  /// 获取最终计算值
  int get finalValue {
    int value = source.number;
    for (final step in derivationSteps) {
      value += step.value;
    }
    return value;
  }

  factory BaseNumberDerivationChain.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberDerivationChainFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberDerivationChainToJson(this);

  // 辅助方法用于序列化 source
  static DataPredefinedBaseNumber _sourceFromJson(Map<String, dynamic> json) {
    final def = DataBaseNumberDefinitionConverter.fromJsonConvertor(json);
    if (def is DataPredefinedBaseNumber) {
      return def;
    }
    throw Exception(
      'Expected DataPredefinedBaseNumber but got ${def.runtimeType}',
    );
  }

  static Map<String, dynamic> _sourceToJson(DataPredefinedBaseNumber source) {
    return DataBaseNumberDefinitionConverter.toJsonConvertor(source);
  }

  // 辅助方法用于序列化 derivationSteps
  static List<DerivationStep> _derivationStepsFromJson(List<dynamic> json) {
    return json
        .map((e) => DerivationStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _derivationStepsToJson(
    List<DerivationStep> steps,
  ) {
    return steps.map((e) => e.toJson()).toList();
  }
}

/// 基础数选择记录
@JsonSerializable()
class BaseNumberSelectionRecord {
  /// 基础数定义 ID (基于 name)
  final String baseNumberDefinitionId;

  /// 名称
  final String name;

  /// 派生链路
  @JsonKey(fromJson: _derivationChainFromJson, toJson: _derivationChainToJson)
  final BaseNumberDerivationChain derivationChain;

  /// 候选项配置
  @JsonKey(fromJson: _candidateConfigFromJson, toJson: _candidateConfigToJson)
  final CandidateGenerationConfig candidateConfig;

  /// 候选列表
  @JsonKey(fromJson: _candidatesFromJson, toJson: _candidatesToJson)
  final List<BaseNumberCandidate> candidates;

  /// 用户选择的候选项
  @JsonKey(
    fromJson: _selectedCandidateFromJson,
    toJson: _selectedCandidateToJson,
  )
  final BaseNumberCandidate? selectedCandidate;

  /// 选择状态
  final SelectionStatus status;

  /// 关联的 groupIds
  final List<String> relatedGroupIds;

  const BaseNumberSelectionRecord({
    required this.baseNumberDefinitionId,
    required this.name,
    required this.derivationChain,
    required this.candidateConfig,
    required this.candidates,
    this.selectedCandidate,
    this.status = SelectionStatus.pending,
    required this.relatedGroupIds,
  });

  /// 是否已完成选择
  bool get isCompleted => status == SelectionStatus.completed;

  factory BaseNumberSelectionRecord.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberSelectionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberSelectionRecordToJson(this);

  BaseNumberSelectionRecord copyWith({
    String? baseNumberDefinitionId,
    String? name,
    BaseNumberDerivationChain? derivationChain,
    CandidateGenerationConfig? candidateConfig,
    List<BaseNumberCandidate>? candidates,
    BaseNumberCandidate? selectedCandidate,
    SelectionStatus? status,
    List<String>? relatedGroupIds,
  }) {
    return BaseNumberSelectionRecord(
      baseNumberDefinitionId:
          baseNumberDefinitionId ?? this.baseNumberDefinitionId,
      name: name ?? this.name,
      derivationChain: derivationChain ?? this.derivationChain,
      candidateConfig: candidateConfig ?? this.candidateConfig,
      candidates: candidates ?? this.candidates,
      selectedCandidate: selectedCandidate ?? this.selectedCandidate,
      status: status ?? this.status,
      relatedGroupIds: relatedGroupIds ?? this.relatedGroupIds,
    );
  }

  // 辅助序列化方法
  static BaseNumberDerivationChain _derivationChainFromJson(
    Map<String, dynamic> json,
  ) {
    return BaseNumberDerivationChain.fromJson(json);
  }

  static Map<String, dynamic> _derivationChainToJson(
    BaseNumberDerivationChain chain,
  ) {
    return chain.toJson();
  }

  static CandidateGenerationConfig _candidateConfigFromJson(
    Map<String, dynamic> json,
  ) {
    return CandidateGenerationConfig.fromJson(json);
  }

  static Map<String, dynamic> _candidateConfigToJson(
    CandidateGenerationConfig config,
  ) {
    return config.toJson();
  }

  static List<BaseNumberCandidate> _candidatesFromJson(List<dynamic> json) {
    return json
        .map((e) => BaseNumberCandidate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _candidatesToJson(
    List<BaseNumberCandidate> candidates,
  ) {
    return candidates.map((e) => e.toJson()).toList();
  }

  static BaseNumberCandidate? _selectedCandidateFromJson(
    Map<String, dynamic>? json,
  ) {
    return json != null ? BaseNumberCandidate.fromJson(json) : null;
  }

  static Map<String, dynamic>? _selectedCandidateToJson(
    BaseNumberCandidate? candidate,
  ) {
    return candidate?.toJson();
  }
}
