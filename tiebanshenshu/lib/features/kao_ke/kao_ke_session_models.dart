import 'package:json_annotation/json_annotation.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/enums.dart';
import '../../constant/kao_ke_constants.dart';
import '../../domain/models/tiao_wen_result.dart';

part 'kao_ke_session_models.g.dart';

/// 考刻会话阶段
enum KaoKeSessionPhase {
  @JsonValue('initialized')
  initialized,

  @JsonValue('keSelectionReady')
  keSelectionReady,

  @JsonValue('keSelected')
  keSelected,

  @JsonValue('baseNumberCalculated')
  baseNumberCalculated,

  @JsonValue('finalCalculationComplete')
  finalCalculationComplete;

  const KaoKeSessionPhase();
}

/// 考刻会话状态
enum KaoKeSessionStatus {
  @JsonValue('notStarted')
  notStarted,

  @JsonValue('inProgress')
  inProgress,

  @JsonValue('waitingForSelection')
  waitingForSelection,

  @JsonValue('completed')
  completed,

  @JsonValue('cancelled')
  cancelled,

  @JsonValue('error')
  error;

  const KaoKeSessionStatus();
}

/// 考刻计算方法选择
enum KaoKeCalculationMethod {
  @JsonValue('baGuaJiaZe')
  baGuaJiaZe, // 八卦加则

  @JsonValue('liuYaoGanZhiHe')
  liuYaoGanZhiHe; // 爻干支和数法

  const KaoKeCalculationMethod();

  String get displayName {
    switch (this) {
      case KaoKeCalculationMethod.baGuaJiaZe:
        return '八卦加则';
      case KaoKeCalculationMethod.liuYaoGanZhiHe:
        return '爻干支和数法';
    }
  }
}

/// 用户的刻选择记录
@JsonSerializable()
class KeSelectionRecord {
  /// 选中的时辰
  final DiZhi shiChen;

  /// 选中的刻
  final EigthKe ke;

  /// 选中的条文编号(作为基础数)
  final int tiaoWenNumber;

  /// 条文密文
  final String cipherText;

  /// 条文原文
  final String originalText;

  /// 选择时间
  final DateTime selectedAt;

  const KeSelectionRecord({
    required this.shiChen,
    required this.ke,
    required this.tiaoWenNumber,
    required this.cipherText,
    required this.originalText,
    required this.selectedAt,
  });

  factory KeSelectionRecord.fromJson(Map<String, dynamic> json) =>
      _$KeSelectionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$KeSelectionRecordToJson(this);

  factory KeSelectionRecord.fromKaoEigthKeNumber(
    KaoEigthKeNumber kaoNumber,
    DateTime selectedAt,
  ) {
    return KeSelectionRecord(
      shiChen: kaoNumber.shiChen,
      ke: kaoNumber.ke,
      tiaoWenNumber: kaoNumber.tiaoWenNumber,
      cipherText: kaoNumber.cipherText,
      originalText: kaoNumber.originalText,
      selectedAt: selectedAt,
    );
  }
}

/// 斗甲乙宫刻选择记录
class DouJiaYiSelectionRecord {
  /// 出生时辰（如子时）
  final DiZhi birthShiChen;

  /// 三宫类型（斗/甲/乙）
  final DouJiaYiType palaceType;

  /// 所属刻的地支（如午刻）
  final DiZhi keDiZhi;

  /// 该宫内序号（1-5）
  final int order;

  /// 选中的条文编号(作为基础数)
  final int tiaoWenNumber;

  /// 选择时间
  final DateTime selectedAt;

  const DouJiaYiSelectionRecord({
    required this.birthShiChen,
    required this.palaceType,
    required this.keDiZhi,
    required this.order,
    required this.tiaoWenNumber,
    required this.selectedAt,
  });

  /// 辅助构造：由 DouJiaYiNumber 生成选择记录
  factory DouJiaYiSelectionRecord.fromDouJiaYiNumber({
    required DiZhi birthShiChen,
    required DouJiaYiType palaceType,
    required DouJiaYiNumber number,
    required DateTime selectedAt,
  }) {
    return DouJiaYiSelectionRecord(
      birthShiChen: birthShiChen,
      palaceType: palaceType,
      keDiZhi: number.ke,
      order: number.order,
      tiaoWenNumber: number.tiaoWenNumber,
      selectedAt: selectedAt,
    );
  }
}

/// 卦象计算结果
@JsonSerializable()
class GuaCalculationResult {
  /// 上卦数值
  final int shangGuaNumber;

  /// 下卦数值
  final int xiaGuaNumber;

  /// 上卦名称
  final String shangGuaName;

  /// 下卦名称
  final String xiaGuaName;

  /// 完整卦名
  final String fullGuaName;

  /// 计算详情
  final String calculationDetail;

  const GuaCalculationResult({
    required this.shangGuaNumber,
    required this.xiaGuaNumber,
    required this.shangGuaName,
    required this.xiaGuaName,
    required this.fullGuaName,
    required this.calculationDetail,
  });

  factory GuaCalculationResult.fromJson(Map<String, dynamic> json) =>
      _$GuaCalculationResultFromJson(json);

  Map<String, dynamic> toJson() => _$GuaCalculationResultToJson(this);
}

/// 会话快照
@JsonSerializable()
class KaoKeSessionSnapshot {
  final String snapshotId;
  final KaoKeSessionPhase phase;
  final DateTime timestamp;
  final Map<String, dynamic> state;

  const KaoKeSessionSnapshot({
    required this.snapshotId,
    required this.phase,
    required this.timestamp,
    required this.state,
  });

  factory KaoKeSessionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$KaoKeSessionSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$KaoKeSessionSnapshotToJson(this);
}

/// 考刻会话
@JsonSerializable()
class KaoKeSession {
  final String sessionId;
  final String sessionName;
  final EightChars eightChars;

  /// 用户选择的刻记录
  @JsonKey(
    fromJson: _keSelectionFromJson,
    toJson: _keSelectionToJson,
  )
  final KeSelectionRecord? keSelection;

  /// 斗甲乙宫刻选择记录（不参与快照序列化）
  @JsonKey(ignore: true)
  final DouJiaYiSelectionRecord? douJiaYiSelection;

  /// 卦象计算结果
  @JsonKey(
    fromJson: _guaResultFromJson,
    toJson: _guaResultToJson,
  )
  final GuaCalculationResult? guaResult;

  /// 选择的计算方法
  @JsonKey(
    fromJson: _selectedMethodsFromJson,
    toJson: _selectedMethodsToJson,
  )
  final Set<KaoKeCalculationMethod> selectedMethods;

  /// 最终条文结果(按计算方法分组)
  @JsonKey(
    fromJson: _finalResultsFromJson,
    toJson: _finalResultsToJson,
  )
  final Map<KaoKeCalculationMethod, List<TiaoWenResult>>? finalResults;

  final KaoKeSessionPhase currentPhase;

  @JsonKey(
    fromJson: _snapshotsFromJson,
    toJson: _snapshotsToJson,
  )
  final List<KaoKeSessionSnapshot> phaseHistory;

  final KaoKeSessionStatus status;
  final DateTime startTime;
  final DateTime lastActivityAt;
  final DateTime? endTime;
  final String? errorMessage;

  const KaoKeSession({
    required this.sessionId,
    required this.sessionName,
    required this.eightChars,
    this.keSelection,
    this.douJiaYiSelection,
    this.guaResult,
    this.selectedMethods = const {
      KaoKeCalculationMethod.baGuaJiaZe,
      KaoKeCalculationMethod.liuYaoGanZhiHe,
    },
    this.finalResults,
    this.currentPhase = KaoKeSessionPhase.initialized,
    this.phaseHistory = const [],
    this.status = KaoKeSessionStatus.notStarted,
    required this.startTime,
    required this.lastActivityAt,
    this.endTime,
    this.errorMessage,
  });

  factory KaoKeSession.create({
    required String sessionId,
    required String sessionName,
    required EightChars eightChars,
  }) {
    final now = DateTime.now();
    return KaoKeSession(
      sessionId: sessionId,
      sessionName: sessionName,
      eightChars: eightChars,
      startTime: now,
      lastActivityAt: now,
    );
  }

  factory KaoKeSession.fromJson(Map<String, dynamic> json) =>
      _$KaoKeSessionFromJson(json);

  Map<String, dynamic> toJson() => _$KaoKeSessionToJson(this);

  KaoKeSession copyWith({
    String? sessionId,
    String? sessionName,
    EightChars? eightChars,
    KeSelectionRecord? keSelection,
    DouJiaYiSelectionRecord? douJiaYiSelection,
    GuaCalculationResult? guaResult,
    Set<KaoKeCalculationMethod>? selectedMethods,
    Map<KaoKeCalculationMethod, List<TiaoWenResult>>? finalResults,
    KaoKeSessionPhase? currentPhase,
    List<KaoKeSessionSnapshot>? phaseHistory,
    KaoKeSessionStatus? status,
    DateTime? startTime,
    DateTime? lastActivityAt,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return KaoKeSession(
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      eightChars: eightChars ?? this.eightChars,
      keSelection: keSelection ?? this.keSelection,
      douJiaYiSelection: douJiaYiSelection ?? this.douJiaYiSelection,
      guaResult: guaResult ?? this.guaResult,
      selectedMethods: selectedMethods ?? this.selectedMethods,
      finalResults: finalResults ?? this.finalResults,
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
  bool get isCompleted => status == KaoKeSessionStatus.completed;
  bool get isInProgress => status == KaoKeSessionStatus.inProgress;

  /// 获取出生时辰
  DiZhi get birthShiChen => eightChars.time.zhi;

  // 序列化辅助方法
  static KeSelectionRecord? _keSelectionFromJson(Map<String, dynamic>? json) {
    return json != null ? KeSelectionRecord.fromJson(json) : null;
  }

  static Map<String, dynamic>? _keSelectionToJson(KeSelectionRecord? record) {
    return record?.toJson();
  }

  static GuaCalculationResult? _guaResultFromJson(Map<String, dynamic>? json) {
    return json != null ? GuaCalculationResult.fromJson(json) : null;
  }

  static Map<String, dynamic>? _guaResultToJson(GuaCalculationResult? result) {
    return result?.toJson();
  }

  static Set<KaoKeCalculationMethod> _selectedMethodsFromJson(
    List<dynamic> json,
  ) {
    return json.map((e) {
      final str = e as String;
      return KaoKeCalculationMethod.values.firstWhere(
        (m) => m.toString() == 'KaoKeCalculationMethod.$str' ||
               m.name == str,
      );
    }).toSet();
  }

  static List<String> _selectedMethodsToJson(
    Set<KaoKeCalculationMethod> methods,
  ) {
    return methods.map((m) => m.name).toList();
  }

  static Map<KaoKeCalculationMethod, List<TiaoWenResult>>? _finalResultsFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return null;

    return json.map((key, value) {
      final method = KaoKeCalculationMethod.values.firstWhere(
        (m) => m.name == key,
      );
      final results = (value as List)
          .map((e) => TiaoWenResult.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(method, results);
    });
  }

  static Map<String, dynamic>? _finalResultsToJson(
    Map<KaoKeCalculationMethod, List<TiaoWenResult>>? results,
  ) {
    if (results == null) return null;

    return results.map((key, value) {
      return MapEntry(
        key.name,
        value.map((e) => e.toJson()).toList(),
      );
    });
  }

  static List<KaoKeSessionSnapshot> _snapshotsFromJson(List<dynamic> json) {
    return json
        .map((e) => KaoKeSessionSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _snapshotsToJson(
    List<KaoKeSessionSnapshot> snapshots,
  ) {
    return snapshots.map((e) => e.toJson()).toList();
  }
}
