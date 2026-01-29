import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';

/// 来源类型：先天或后天
enum OriginKind {
  innate, // 先天
  acquired, // 后天
}

/// 六亲考刻的单个候选对象
class LiuQinKaoKeCandidate {
  /// 原始计算数值（可能 >13000）
  final int rawNumber;

  /// 最终用于查询的条文编号
  /// 当 rawNumber > 13000 时，返回 rawNumber - 12000，否则返回 rawNumber
  int get number => rawNumber > 13000 ? rawNumber - 12000 : rawNumber;

  /// 来源：先天或后天
  final OriginKind originKind;

  /// 变爻位置索引（0 代表不变，1-6 代表初爻到上爻）
  final int changeLineIndex;

  /// 基本卦（由天干地支计算得出）
  final Enum64Gua baseGua;

  /// 互卦（由基本卦衍生）
  final Enum64Gua huGua;

  /// 用于生成此候选的最终卦象（可能是基本卦自身或其变卦）
  final Enum64Gua derivedGua;

  LiuQinKaoKeCandidate({
    required this.rawNumber,
    required this.originKind,
    required this.changeLineIndex,
    required this.baseGua,
    required this.huGua,
    required this.derivedGua,
  });

  /// 便于调试的字符串表示
  @override
  String toString() {
    return 'LiuQinKaoKeCandidate{rawNumber: $rawNumber, number: $number, origin: $originKind, changeLine: $changeLineIndex}';
  }
}

/// 用于UI展示的候选项，结合了计算候选和条文内容
class LiuQinKaoKeSelectionItem {
  final LiuQinKaoKeCandidate candidate;
  final String? tiaoWenContent;

  LiuQinKaoKeSelectionItem({required this.candidate, this.tiaoWenContent});
}

/// 会话阶段
enum LiuQinKaoKeStage {
  /// 初始阶段
  initialized,

  /// 基础候选数字选择已就绪
  baseNumberSelectionReady,

  /// 基础候选数字选择已完成
  baseNumberSelectionCompleted,

  /// 最终条文列表已就绪
  finalTiaoWenListReady,
}

/// 六亲考刻会话模型
class LiuQinKaoKeSession {
  final String id;
  final int version;
  final LiuQinKaoKeStage stage;

  // 输入参数
  final EightChars eightChars;
  final Gender gender;
  final bool isYangGan; // 年干阴阳

  // 计算结果
  final List<LiuQinKaoKeSelectionItem>? candidateSet;
  final LiuQinKaoKeCandidate? selectedInnate;
  final LiuQinKaoKeCandidate? selectedAcquired;
  final List<FinalTiaoWenItem>? finalTiaoWenList; // 最终条文列表

  final DateTime createdAt;
  final DateTime updatedAt;

  LiuQinKaoKeSession({
    required this.id,
    this.version = 1,
    required this.stage,
    required this.eightChars,
    required this.gender,
    required this.isYangGan,
    this.candidateSet,
    this.selectedInnate,
    this.selectedAcquired,
    this.finalTiaoWenList,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// 最终展示的条文项
class FinalTiaoWenItem {
  final int number;
  final String content;
  final OriginKind originKind;
  final int offset;

  FinalTiaoWenItem({
    required this.number,
    required this.content,
    required this.originKind,
    required this.offset,
  });
}
