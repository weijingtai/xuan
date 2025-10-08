import 'package:json_annotation/json_annotation.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/models/base_number_selection_record.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import 'huang_ji_formula_v2.dart';
import '../../domain/models/tiao_wen_result.dart';

part 'huang_ji_v2_session_models.g.dart';

/// 会话阶段
enum SessionPhase {
  @JsonValue('initialized')
  initialized,

  @JsonValue('yuanHuiYunShiCalculated')
  yuanHuiYunShiCalculated,

  @JsonValue('baseNumberSelectionReady')
  baseNumberSelectionReady,

  @JsonValue('baseNumberSelected')
  baseNumberSelected,

  @JsonValue('finalCalculationComplete')
  finalCalculationComplete;

  const SessionPhase();
}

/// 会话状态
enum HuangJiSessionStatus {
  @JsonValue('notStarted')
  notStarted,

  @JsonValue('inProgress')
  inProgress,

  @JsonValue('waitingForSelection')
  waitingForSelection,

  @JsonValue('paused')
  paused,

  @JsonValue('completed')
  completed,

  @JsonValue('cancelled')
  cancelled,

  @JsonValue('error')
  error;

  const HuangJiSessionStatus();
}

/// 会话快照 (用于回滚)
@JsonSerializable()
class SessionSnapshot {
  final String snapshotId;
  final SessionPhase phase;
  final DateTime timestamp;
  final Map<String, dynamic> state;

  const SessionSnapshot({
    required this.snapshotId,
    required this.phase,
    required this.timestamp,
    required this.state,
  });

  factory SessionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$SessionSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSnapshotToJson(this);
}

/// 皇极取数法会话 V2 (完整版)
@JsonSerializable()
class HuangJiSession {
  final String sessionId;
  final String sessionName;
  final EightChars eightChars;

  @JsonKey(fromJson: _yuanHuiYunShiFromJson, toJson: _yuanHuiYunShiToJson)
  final YuanHuiYunShi? yuanHuiYunShi;

  @JsonKey(fromJson: _formulasFromJson, toJson: _formulasToJson)
  final List<HuangJiCalculationFormula> formulas;

  @JsonKey(fromJson: _selectionsFromJson, toJson: _selectionsToJson)
  final Map<String, BaseNumberSelectionRecord> baseNumberSelections;

  @JsonKey(fromJson: _resultsFromJson, toJson: _resultsToJson)
  final List<TiaoWenResult>? finalTiaoWenList;

  final SessionPhase currentPhase;

  @JsonKey(fromJson: _snapshotsFromJson, toJson: _snapshotsToJson)
  final List<SessionSnapshot> phaseHistory;

  final HuangJiSessionStatus status;
  final DateTime startTime;
  final DateTime lastActivityAt;
  final DateTime? endTime;
  final String? errorMessage;

  const HuangJiSession({
    required this.sessionId,
    required this.sessionName,
    required this.eightChars,
    this.yuanHuiYunShi,
    required this.formulas,
    this.baseNumberSelections = const {},
    this.finalTiaoWenList,
    this.currentPhase = SessionPhase.initialized,
    this.phaseHistory = const [],
    this.status = HuangJiSessionStatus.notStarted,
    required this.startTime,
    required this.lastActivityAt,
    this.endTime,
    this.errorMessage,
  });

  factory HuangJiSession.create({
    required String sessionId,
    required String sessionName,
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulas,
  }) {
    final now = DateTime.now();
    return HuangJiSession(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      formulas: formulas,
      startTime: now,
      lastActivityAt: now,
    );
  }

  factory HuangJiSession.fromJson(Map<String, dynamic> json) =>
      _$HuangJiSessionFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiSessionToJson(this);

  HuangJiSession copyWith({
    String? sessionId,
    String? sessionName,
    EightChars? eightChars,
    YuanHuiYunShi? yuanHuiYunShi,
    List<HuangJiCalculationFormula>? formulas,
    Map<String, BaseNumberSelectionRecord>? baseNumberSelections,
    List<TiaoWenResult>? finalTiaoWenList,
    SessionPhase? currentPhase,
    List<SessionSnapshot>? phaseHistory,
    HuangJiSessionStatus? status,
    DateTime? startTime,
    DateTime? lastActivityAt,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return HuangJiSession(
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      eightChars: eightChars ?? this.eightChars,
      yuanHuiYunShi: yuanHuiYunShi ?? this.yuanHuiYunShi,
      formulas: formulas ?? this.formulas,
      baseNumberSelections: baseNumberSelections ?? this.baseNumberSelections,
      finalTiaoWenList: finalTiaoWenList ?? this.finalTiaoWenList,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseHistory: phaseHistory ?? this.phaseHistory,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get canRollback => phaseHistory.isNotEmpty;
  bool get isCompleted => status == HuangJiSessionStatus.completed;
  bool get isInProgress => status == HuangJiSessionStatus.inProgress;

  // 序列化辅助方法
  static YuanHuiYunShi? _yuanHuiYunShiFromJson(Map<String, dynamic>? json) {
    return json != null ? YuanHuiYunShi.fromJson(json) : null;
  }

  static Map<String, dynamic>? _yuanHuiYunShiToJson(YuanHuiYunShi? yhys) {
    return yhys?.toJson();
  }

  static List<HuangJiCalculationFormula> _formulasFromJson(List<dynamic> json) {
    return json
        .map(
          (e) => HuangJiCalculationFormula.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  static List<Map<String, dynamic>> _formulasToJson(
    List<HuangJiCalculationFormula> formulas,
  ) {
    return formulas.map((e) => e.toJson()).toList();
  }

  static Map<String, BaseNumberSelectionRecord> _selectionsFromJson(
    Map<String, dynamic> json,
  ) {
    return json.map(
      (key, value) => MapEntry(
        key,
        BaseNumberSelectionRecord.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  static Map<String, dynamic> _selectionsToJson(
    Map<String, BaseNumberSelectionRecord> selections,
  ) {
    return selections.map((key, value) => MapEntry(key, value.toJson()));
  }

  static List<TiaoWenResult>? _resultsFromJson(List<dynamic>? json) {
    return json
        ?.map((e) => TiaoWenResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>>? _resultsToJson(
    List<TiaoWenResult>? results,
  ) {
    return results?.map((e) => e.toJson()).toList();
  }

  static List<SessionSnapshot> _snapshotsFromJson(List<dynamic> json) {
    return json
        .map((e) => SessionSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _snapshotsToJson(
    List<SessionSnapshot> snapshots,
  ) {
    return snapshots.map((e) => e.toJson()).toList();
  }
}
