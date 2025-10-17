/// 卦中取数法基础数模型
///
/// 用于保存卦中取数法的完整计算过程和结果
///
/// ⚠️ **重要说明：千位计算三种方案**
///
/// 问题：当 `(上卦先天数 + 6) = 10` 时，按照 `%10` 运算结果为 `0`，
/// 导致条文编号变为三位数（如 484），不符合铁板神数四位数规范。
///
/// 解决方案（同时支持三种）：
/// - **方案1（推荐）**: 取 `1` 代替 `0`
///   - 逻辑: `qianWei = (xiantianNumber + 6) == 10 ? 1 : (xiantianNumber + 6) % 10`
///   - 示例: 震卦(4) → (4+6)=10 → 千位=1 → 条文=1484
///   - 优点: 保持四位数格式，符合铁板神数规范
///   - 触发: 当上卦为震(4)时
///
/// - **方案2**: 取卦本身先天数代替
///   - 逻辑: `qianWei = (xiantianNumber + 6) == 10 ? xiantianNumber : (xiantianNumber + 6) % 10`
///   - 示例: 震卦(4) → (4+6)=10 → 千位=4 → 条文=4484
///   - 优点: 保留卦象数字特征
///
/// - **方案3**: 保留 `10` 让结果为五位数
///   - 逻辑: `qianWei = xiantianNumber + 6` (不取模)
///   - 示例: 震卦(4) → (4+6)=10 → 千位=10 → 条文=10484 (五位数)
///   - 优点: 完全按照原始算法
///   - 缺点: 打破四位数规范
///
/// **算法步骤**：
/// - 步骤1：排四柱，配太玄数
/// - 步骤2：年月卦计算（年柱+月柱 mod 8）→ 主卦+互卦 × 3种方案 = 6个条文
/// - 步骤3：日时卦计算（日柱+时柱 > 8减8）→ 主卦+互卦 × 3种方案 = 6个条文
/// - **总计产生12个条文编号**（4个位置 × 3种方案）
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';

/// 卦中取数法基础数模型
class GuaZhongBaseNumberModel extends BaseNumberModel {
  // ========== 输入参数 (1个字段) ==========

  /// 四柱信息（八字）
  final EightChars eightChars;

  // ========== 步骤1: 四柱干支太玄数 (8个字段) ==========

  /// 年干太玄数
  final int yearGanTaixuanNumber;

  /// 年支太玄数
  final int yearZhiTaixuanNumber;

  /// 月干太玄数
  final int monthGanTaixuanNumber;

  /// 月支太玄数
  final int monthZhiTaixuanNumber;

  /// 日干太玄数
  final int dayGanTaixuanNumber;

  /// 日支太玄数
  final int dayZhiTaixuanNumber;

  /// 时干太玄数
  final int timeGanTaixuanNumber;

  /// 时支太玄数
  final int timeZhiTaixuanNumber;

  // ========== 步骤2: 年月卦计算 (10个字段) ==========

  /// 年柱干支太玄数之和（用于计算上卦）
  final int yearSum;

  /// 月柱干支太玄数之和（用于计算下卦）
  final int monthSum;

  /// 年月卦上卦先天数 (yearSum mod 8)，范围: 1-8
  final int nianYueUpperGuaXiantianNumber;

  /// 年月卦下卦先天数 (monthSum mod 8)，范围: 1-8
  final int nianYueLowerGuaXiantianNumber;

  /// 年月卦上卦名称
  final Enum8Gua nianYueUpperGuaName;

  /// 年月卦下卦名称
  final Enum8Gua nianYueLowerGuaName;

  /// 年月卦主卦名称（双经卦，如"震坤"）
  final Enum64Gua nianYueZhuGuaName;

  /// 年月卦互卦名称（双经卦）
  final Enum64Gua nianYueHuGuaName;

  /// 年月卦互卦上卦先天数
  final int nianYueHuGuaUpperXiantianNumber;

  /// 年月卦互卦下卦先天数
  final int nianYueHuGuaLowerXiantianNumber;

  // ========== 步骤3: 年月卦条文编号 - 三种方案 (6个字段) ==========

  /// 年月卦主卦条文编号 - 方案1（取1代替0）
  /// 当千位=10时，使用1代替
  final int nianYueZhuGuaTiaoWenNumber_Plan1;

  /// 年月卦主卦条文编号 - 方案2（取先天数）
  /// 当千位=10时，使用上卦先天数代替
  final int nianYueZhuGuaTiaoWenNumber_Plan2;

  /// 年月卦主卦条文编号 - 方案3（保留10，五位数）
  /// 当千位=10时，不取模，保留10
  final int nianYueZhuGuaTiaoWenNumber_Plan3;

  /// 年月卦互卦条文编号 - 方案1
  final int nianYueHuGuaTiaoWenNumber_Plan1;

  /// 年月卦互卦条文编号 - 方案2
  final int nianYueHuGuaTiaoWenNumber_Plan2;

  /// 年月卦互卦条文编号 - 方案3
  final int nianYueHuGuaTiaoWenNumber_Plan3;

  // ========== 步骤4: 日时卦计算 (10个字段) ==========

  /// 日柱干支太玄数之和（用于计算上卦，大于8则减8）
  final int daySum;

  /// 时柱干支太玄数之和（用于计算下卦，大于8则减8）
  final int timeSum;

  /// 日时卦上卦先天数 (daySum > 8 ? daySum - 8 : daySum)，范围: 1-8
  final int riShiUpperGuaXiantianNumber;

  /// 日时卦下卦先天数 (timeSum > 8 ? timeSum - 8 : timeSum)，范围: 1-8
  final int riShiLowerGuaXiantianNumber;

  /// 日时卦上卦名称
  final Enum8Gua riShiUpperGuaName;

  /// 日时卦下卦名称
  final Enum8Gua riShiLowerGuaName;

  /// 日时卦主卦名称（双经卦，如"震艮"）
  final Enum64Gua riShiZhuGuaName;

  /// 日时卦互卦名称（双经卦）
  final Enum64Gua riShiHuGuaName;

  /// 日时卦互卦上卦先天数
  final int riShiHuGuaUpperXiantianNumber;

  /// 日时卦互卦下卦先天数
  final int riShiHuGuaLowerXiantianNumber;

  // ========== 步骤5: 日时卦条文编号 - 三种方案 (6个字段) ==========

  /// 日时卦主卦条文编号 - 方案1（取1代替0）
  final int riShiZhuGuaTiaoWenNumber_Plan1;

  /// 日时卦主卦条文编号 - 方案2（取先天数）
  final int riShiZhuGuaTiaoWenNumber_Plan2;

  /// 日时卦主卦条文编号 - 方案3（保留10，五位数）
  final int riShiZhuGuaTiaoWenNumber_Plan3;

  /// 日时卦互卦条文编号 - 方案1
  final int riShiHuGuaTiaoWenNumber_Plan1;

  /// 日时卦互卦条文编号 - 方案2
  final int riShiHuGuaTiaoWenNumber_Plan2;

  /// 日时卦互卦条文编号 - 方案3
  final int riShiHuGuaTiaoWenNumber_Plan3;

  /// 构造函数
  const GuaZhongBaseNumberModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    // 输入参数
    required this.eightChars,
    // 步骤1: 四柱干支太玄数
    required this.yearGanTaixuanNumber,
    required this.yearZhiTaixuanNumber,
    required this.monthGanTaixuanNumber,
    required this.monthZhiTaixuanNumber,
    required this.dayGanTaixuanNumber,
    required this.dayZhiTaixuanNumber,
    required this.timeGanTaixuanNumber,
    required this.timeZhiTaixuanNumber,
    // 步骤2: 年月卦计算
    required this.yearSum,
    required this.monthSum,
    required this.nianYueUpperGuaXiantianNumber,
    required this.nianYueLowerGuaXiantianNumber,
    required this.nianYueUpperGuaName,
    required this.nianYueLowerGuaName,
    required this.nianYueZhuGuaName,
    required this.nianYueHuGuaName,
    required this.nianYueHuGuaUpperXiantianNumber,
    required this.nianYueHuGuaLowerXiantianNumber,
    // 步骤3: 年月卦条文编号 - 三种方案
    required this.nianYueZhuGuaTiaoWenNumber_Plan1,
    required this.nianYueZhuGuaTiaoWenNumber_Plan2,
    required this.nianYueZhuGuaTiaoWenNumber_Plan3,
    required this.nianYueHuGuaTiaoWenNumber_Plan1,
    required this.nianYueHuGuaTiaoWenNumber_Plan2,
    required this.nianYueHuGuaTiaoWenNumber_Plan3,
    // 步骤4: 日时卦计算
    required this.daySum,
    required this.timeSum,
    required this.riShiUpperGuaXiantianNumber,
    required this.riShiLowerGuaXiantianNumber,
    required this.riShiUpperGuaName,
    required this.riShiLowerGuaName,
    required this.riShiZhuGuaName,
    required this.riShiHuGuaName,
    required this.riShiHuGuaUpperXiantianNumber,
    required this.riShiHuGuaLowerXiantianNumber,
    // 步骤5: 日时卦条文编号 - 三种方案
    required this.riShiZhuGuaTiaoWenNumber_Plan1,
    required this.riShiZhuGuaTiaoWenNumber_Plan2,
    required this.riShiZhuGuaTiaoWenNumber_Plan3,
    required this.riShiHuGuaTiaoWenNumber_Plan1,
    required this.riShiHuGuaTiaoWenNumber_Plan2,
    required this.riShiHuGuaTiaoWenNumber_Plan3,
  });

  // ========== 便捷getter方法 ==========

  /// 获取四柱显示文本
  String get fourZhuDisplayText => eightChars.toString();

  /// 获取年柱显示文本
  String get yearZhuDisplayText => eightChars.year.name;

  /// 获取月柱显示文本
  String get monthZhuDisplayText => eightChars.month.name;

  /// 获取日柱显示文本
  String get dayZhuDisplayText => eightChars.day.name;

  /// 获取时柱显示文本
  String get timeZhuDisplayText => eightChars.time.name;

  /// 获取年月卦上卦显示文本（带先天数）
  String get nianYueUpperGuaDisplayText =>
      '$nianYueUpperGuaName($nianYueUpperGuaXiantianNumber)';

  /// 获取年月卦下卦显示文本（带先天数）
  String get nianYueLowerGuaDisplayText =>
      '$nianYueLowerGuaName($nianYueLowerGuaXiantianNumber)';

  /// 获取日时卦上卦显示文本（带先天数）
  String get riShiUpperGuaDisplayText =>
      '$riShiUpperGuaName($riShiUpperGuaXiantianNumber)';

  /// 获取日时卦下卦显示文本（带先天数）
  String get riShiLowerGuaDisplayText =>
      '$riShiLowerGuaName($riShiLowerGuaXiantianNumber)';

  /// 获取年月卦计算说明
  String get nianYueGuaDescription =>
      '年柱($yearGanTaixuanNumber+$yearZhiTaixuanNumber=$yearSum) mod 8 = $nianYueUpperGuaXiantianNumber → $nianYueUpperGuaName, '
      '月柱($monthGanTaixuanNumber+$monthZhiTaixuanNumber=$monthSum) mod 8 = $nianYueLowerGuaXiantianNumber → $nianYueLowerGuaName';

  /// 获取日时卦计算说明
  String get riShiGuaDescription {
    final dayCalc = daySum > 8
        ? '$daySum - 8 = $riShiUpperGuaXiantianNumber'
        : '$daySum';
    final timeCalc = timeSum > 8
        ? '$timeSum - 8 = $riShiLowerGuaXiantianNumber'
        : '$timeSum';
    return '日柱($dayGanTaixuanNumber+$dayZhiTaixuanNumber=$dayCalc) → $riShiUpperGuaName, '
        '时柱($timeGanTaixuanNumber+$timeZhiTaixuanNumber=$timeCalc) → $riShiLowerGuaName';
  }

  /// 根据方案编号获取年月卦主卦条文编号
  int getNianYueZhuGuaTiaoWenNumber(int planNumber) {
    switch (planNumber) {
      case 1:
        return nianYueZhuGuaTiaoWenNumber_Plan1;
      case 2:
        return nianYueZhuGuaTiaoWenNumber_Plan2;
      case 3:
        return nianYueZhuGuaTiaoWenNumber_Plan3;
      default:
        return nianYueZhuGuaTiaoWenNumber_Plan1;
    }
  }

  /// 根据方案编号获取年月卦互卦条文编号
  int getNianYueHuGuaTiaoWenNumber(int planNumber) {
    switch (planNumber) {
      case 1:
        return nianYueHuGuaTiaoWenNumber_Plan1;
      case 2:
        return nianYueHuGuaTiaoWenNumber_Plan2;
      case 3:
        return nianYueHuGuaTiaoWenNumber_Plan3;
      default:
        return nianYueHuGuaTiaoWenNumber_Plan1;
    }
  }

  /// 根据方案编号获取日时卦主卦条文编号
  int getRiShiZhuGuaTiaoWenNumber(int planNumber) {
    switch (planNumber) {
      case 1:
        return riShiZhuGuaTiaoWenNumber_Plan1;
      case 2:
        return riShiZhuGuaTiaoWenNumber_Plan2;
      case 3:
        return riShiZhuGuaTiaoWenNumber_Plan3;
      default:
        return riShiZhuGuaTiaoWenNumber_Plan1;
    }
  }

  /// 根据方案编号获取日时卦互卦条文编号
  int getRiShiHuGuaTiaoWenNumber(int planNumber) {
    switch (planNumber) {
      case 1:
        return riShiHuGuaTiaoWenNumber_Plan1;
      case 2:
        return riShiHuGuaTiaoWenNumber_Plan2;
      case 3:
        return riShiHuGuaTiaoWenNumber_Plan3;
      default:
        return riShiHuGuaTiaoWenNumber_Plan1;
    }
  }

  /// 根据方案编号获取所有条文编号（4个位置）
  ///
  /// [planNumber] 方案编号：1, 2, 或 3
  /// 返回: [年月主卦, 年月互卦, 日时主卦, 日时互卦]
  List<int> getAllTiaoWenNumbersByPlan(int planNumber) {
    return [
      getNianYueZhuGuaTiaoWenNumber(planNumber),
      getNianYueHuGuaTiaoWenNumber(planNumber),
      getRiShiZhuGuaTiaoWenNumber(planNumber),
      getRiShiHuGuaTiaoWenNumber(planNumber),
    ];
  }

  /// 获取所有条文编号（所有方案，去重）
  ///
  /// 返回: 最多12个条文编号（4个位置 × 3种方案）
  List<int> get allTiaoWenNumbers {
    return {
      // 方案1
      ...getAllTiaoWenNumbersByPlan(1),
      // 方案2
      ...getAllTiaoWenNumbersByPlan(2),
      // 方案3
      ...getAllTiaoWenNumbersByPlan(3),
    }.toList();
  }

  /// 获取带方案标签的条文编号列表
  ///
  /// 返回: List<(条文编号, 方案编号, 位置描述)>
  List<(int tiaoWenNumber, int planNumber, String position)>
  get tiaoWenNumbersWithPlanLabel {
    return [
      // 年月卦主卦 - 三种方案
      (nianYueZhuGuaTiaoWenNumber_Plan1, 1, '年月卦主卦'),
      (nianYueZhuGuaTiaoWenNumber_Plan2, 2, '年月卦主卦'),
      (nianYueZhuGuaTiaoWenNumber_Plan3, 3, '年月卦主卦'),
      // 年月卦互卦 - 三种方案
      (nianYueHuGuaTiaoWenNumber_Plan1, 1, '年月卦互卦'),
      (nianYueHuGuaTiaoWenNumber_Plan2, 2, '年月卦互卦'),
      (nianYueHuGuaTiaoWenNumber_Plan3, 3, '年月卦互卦'),
      // 日时卦主卦 - 三种方案
      (riShiZhuGuaTiaoWenNumber_Plan1, 1, '日时卦主卦'),
      (riShiZhuGuaTiaoWenNumber_Plan2, 2, '日时卦主卦'),
      (riShiZhuGuaTiaoWenNumber_Plan3, 3, '日时卦主卦'),
      // 日时卦互卦 - 三种方案
      (riShiHuGuaTiaoWenNumber_Plan1, 1, '日时卦互卦'),
      (riShiHuGuaTiaoWenNumber_Plan2, 2, '日时卦互卦'),
      (riShiHuGuaTiaoWenNumber_Plan3, 3, '日时卦互卦'),
    ];
  }

  // ========== 复制方法 ==========

  /// 复制并更新模型
  @override
  GuaZhongBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    EightChars? eightChars,
    int? yearGanTaixuanNumber,
    int? yearZhiTaixuanNumber,
    int? monthGanTaixuanNumber,
    int? monthZhiTaixuanNumber,
    int? dayGanTaixuanNumber,
    int? dayZhiTaixuanNumber,
    int? timeGanTaixuanNumber,
    int? timeZhiTaixuanNumber,
    int? yearSum,
    int? monthSum,
    int? nianYueUpperGuaXiantianNumber,
    int? nianYueLowerGuaXiantianNumber,
    Enum8Gua? nianYueUpperGuaName,
    Enum8Gua? nianYueLowerGuaName,
    Enum64Gua? nianYueZhuGuaName,
    Enum64Gua? nianYueHuGuaName,
    int? nianYueHuGuaUpperXiantianNumber,
    int? nianYueHuGuaLowerXiantianNumber,
    int? nianYueZhuGuaTiaoWenNumber_Plan1,
    int? nianYueZhuGuaTiaoWenNumber_Plan2,
    int? nianYueZhuGuaTiaoWenNumber_Plan3,
    int? nianYueHuGuaTiaoWenNumber_Plan1,
    int? nianYueHuGuaTiaoWenNumber_Plan2,
    int? nianYueHuGuaTiaoWenNumber_Plan3,
    int? daySum,
    int? timeSum,
    int? riShiUpperGuaXiantianNumber,
    int? riShiLowerGuaXiantianNumber,
    Enum8Gua? riShiUpperGuaName,
    Enum8Gua? riShiLowerGuaName,
    Enum64Gua? riShiZhuGuaName,
    Enum64Gua? riShiHuGuaName,
    int? riShiHuGuaUpperXiantianNumber,
    int? riShiHuGuaLowerXiantianNumber,
    int? riShiZhuGuaTiaoWenNumber_Plan1,
    int? riShiZhuGuaTiaoWenNumber_Plan2,
    int? riShiZhuGuaTiaoWenNumber_Plan3,
    int? riShiHuGuaTiaoWenNumber_Plan1,
    int? riShiHuGuaTiaoWenNumber_Plan2,
    int? riShiHuGuaTiaoWenNumber_Plan3,
  }) {
    return GuaZhongBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      eightChars: eightChars ?? this.eightChars,
      yearGanTaixuanNumber: yearGanTaixuanNumber ?? this.yearGanTaixuanNumber,
      yearZhiTaixuanNumber: yearZhiTaixuanNumber ?? this.yearZhiTaixuanNumber,
      monthGanTaixuanNumber:
          monthGanTaixuanNumber ?? this.monthGanTaixuanNumber,
      monthZhiTaixuanNumber:
          monthZhiTaixuanNumber ?? this.monthZhiTaixuanNumber,
      dayGanTaixuanNumber: dayGanTaixuanNumber ?? this.dayGanTaixuanNumber,
      dayZhiTaixuanNumber: dayZhiTaixuanNumber ?? this.dayZhiTaixuanNumber,
      timeGanTaixuanNumber: timeGanTaixuanNumber ?? this.timeGanTaixuanNumber,
      timeZhiTaixuanNumber: timeZhiTaixuanNumber ?? this.timeZhiTaixuanNumber,
      yearSum: yearSum ?? this.yearSum,
      monthSum: monthSum ?? this.monthSum,
      nianYueUpperGuaXiantianNumber:
          nianYueUpperGuaXiantianNumber ?? this.nianYueUpperGuaXiantianNumber,
      nianYueLowerGuaXiantianNumber:
          nianYueLowerGuaXiantianNumber ?? this.nianYueLowerGuaXiantianNumber,
      nianYueUpperGuaName: nianYueUpperGuaName ?? this.nianYueUpperGuaName,
      nianYueLowerGuaName: nianYueLowerGuaName ?? this.nianYueLowerGuaName,
      nianYueZhuGuaName: nianYueZhuGuaName ?? this.nianYueZhuGuaName,
      nianYueHuGuaName: nianYueHuGuaName ?? this.nianYueHuGuaName,
      nianYueHuGuaUpperXiantianNumber:
          nianYueHuGuaUpperXiantianNumber ??
          this.nianYueHuGuaUpperXiantianNumber,
      nianYueHuGuaLowerXiantianNumber:
          nianYueHuGuaLowerXiantianNumber ??
          this.nianYueHuGuaLowerXiantianNumber,
      nianYueZhuGuaTiaoWenNumber_Plan1:
          nianYueZhuGuaTiaoWenNumber_Plan1 ??
          this.nianYueZhuGuaTiaoWenNumber_Plan1,
      nianYueZhuGuaTiaoWenNumber_Plan2:
          nianYueZhuGuaTiaoWenNumber_Plan2 ??
          this.nianYueZhuGuaTiaoWenNumber_Plan2,
      nianYueZhuGuaTiaoWenNumber_Plan3:
          nianYueZhuGuaTiaoWenNumber_Plan3 ??
          this.nianYueZhuGuaTiaoWenNumber_Plan3,
      nianYueHuGuaTiaoWenNumber_Plan1:
          nianYueHuGuaTiaoWenNumber_Plan1 ??
          this.nianYueHuGuaTiaoWenNumber_Plan1,
      nianYueHuGuaTiaoWenNumber_Plan2:
          nianYueHuGuaTiaoWenNumber_Plan2 ??
          this.nianYueHuGuaTiaoWenNumber_Plan2,
      nianYueHuGuaTiaoWenNumber_Plan3:
          nianYueHuGuaTiaoWenNumber_Plan3 ??
          this.nianYueHuGuaTiaoWenNumber_Plan3,
      daySum: daySum ?? this.daySum,
      timeSum: timeSum ?? this.timeSum,
      riShiUpperGuaXiantianNumber:
          riShiUpperGuaXiantianNumber ?? this.riShiUpperGuaXiantianNumber,
      riShiLowerGuaXiantianNumber:
          riShiLowerGuaXiantianNumber ?? this.riShiLowerGuaXiantianNumber,
      riShiUpperGuaName: riShiUpperGuaName ?? this.riShiUpperGuaName,
      riShiLowerGuaName: riShiLowerGuaName ?? this.riShiLowerGuaName,
      riShiZhuGuaName: riShiZhuGuaName ?? this.riShiZhuGuaName,
      riShiHuGuaName: riShiHuGuaName ?? this.riShiHuGuaName,
      riShiHuGuaUpperXiantianNumber:
          riShiHuGuaUpperXiantianNumber ?? this.riShiHuGuaUpperXiantianNumber,
      riShiHuGuaLowerXiantianNumber:
          riShiHuGuaLowerXiantianNumber ?? this.riShiHuGuaLowerXiantianNumber,
      riShiZhuGuaTiaoWenNumber_Plan1:
          riShiZhuGuaTiaoWenNumber_Plan1 ?? this.riShiZhuGuaTiaoWenNumber_Plan1,
      riShiZhuGuaTiaoWenNumber_Plan2:
          riShiZhuGuaTiaoWenNumber_Plan2 ?? this.riShiZhuGuaTiaoWenNumber_Plan2,
      riShiZhuGuaTiaoWenNumber_Plan3:
          riShiZhuGuaTiaoWenNumber_Plan3 ?? this.riShiZhuGuaTiaoWenNumber_Plan3,
      riShiHuGuaTiaoWenNumber_Plan1:
          riShiHuGuaTiaoWenNumber_Plan1 ?? this.riShiHuGuaTiaoWenNumber_Plan1,
      riShiHuGuaTiaoWenNumber_Plan2:
          riShiHuGuaTiaoWenNumber_Plan2 ?? this.riShiHuGuaTiaoWenNumber_Plan2,
      riShiHuGuaTiaoWenNumber_Plan3:
          riShiHuGuaTiaoWenNumber_Plan3 ?? this.riShiHuGuaTiaoWenNumber_Plan3,
    );
  }

  // ========== 序列化方法 ==========

  /// 转换为Map用于调试和序列化
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      // 输入参数
      'eightChars': eightChars.toString(),
      // 四柱干支太玄数
      'yearGanTaixuanNumber': yearGanTaixuanNumber,
      'yearZhiTaixuanNumber': yearZhiTaixuanNumber,
      'monthGanTaixuanNumber': monthGanTaixuanNumber,
      'monthZhiTaixuanNumber': monthZhiTaixuanNumber,
      'dayGanTaixuanNumber': dayGanTaixuanNumber,
      'dayZhiTaixuanNumber': dayZhiTaixuanNumber,
      'timeGanTaixuanNumber': timeGanTaixuanNumber,
      'timeZhiTaixuanNumber': timeZhiTaixuanNumber,
      // 年月卦计算
      'yearSum': yearSum,
      'monthSum': monthSum,
      'nianYueUpperGuaXiantianNumber': nianYueUpperGuaXiantianNumber,
      'nianYueLowerGuaXiantianNumber': nianYueLowerGuaXiantianNumber,
      'nianYueUpperGuaName': nianYueUpperGuaName,
      'nianYueLowerGuaName': nianYueLowerGuaName,
      'nianYueZhuGuaName': nianYueZhuGuaName,
      'nianYueHuGuaName': nianYueHuGuaName,
      'nianYueHuGuaUpperXiantianNumber': nianYueHuGuaUpperXiantianNumber,
      'nianYueHuGuaLowerXiantianNumber': nianYueHuGuaLowerXiantianNumber,
      'nianYueGuaDescription': nianYueGuaDescription,
      // 年月卦条文编号 - 三种方案
      'nianYueZhuGuaTiaoWenNumber_Plan1': nianYueZhuGuaTiaoWenNumber_Plan1,
      'nianYueZhuGuaTiaoWenNumber_Plan2': nianYueZhuGuaTiaoWenNumber_Plan2,
      'nianYueZhuGuaTiaoWenNumber_Plan3': nianYueZhuGuaTiaoWenNumber_Plan3,
      'nianYueHuGuaTiaoWenNumber_Plan1': nianYueHuGuaTiaoWenNumber_Plan1,
      'nianYueHuGuaTiaoWenNumber_Plan2': nianYueHuGuaTiaoWenNumber_Plan2,
      'nianYueHuGuaTiaoWenNumber_Plan3': nianYueHuGuaTiaoWenNumber_Plan3,
      // 日时卦计算
      'daySum': daySum,
      'timeSum': timeSum,
      'riShiUpperGuaXiantianNumber': riShiUpperGuaXiantianNumber,
      'riShiLowerGuaXiantianNumber': riShiLowerGuaXiantianNumber,
      'riShiUpperGuaName': riShiUpperGuaName,
      'riShiLowerGuaName': riShiLowerGuaName,
      'riShiZhuGuaName': riShiZhuGuaName,
      'riShiHuGuaName': riShiHuGuaName,
      'riShiHuGuaUpperXiantianNumber': riShiHuGuaUpperXiantianNumber,
      'riShiHuGuaLowerXiantianNumber': riShiHuGuaLowerXiantianNumber,
      'riShiGuaDescription': riShiGuaDescription,
      // 日时卦条文编号 - 三种方案
      'riShiZhuGuaTiaoWenNumber_Plan1': riShiZhuGuaTiaoWenNumber_Plan1,
      'riShiZhuGuaTiaoWenNumber_Plan2': riShiZhuGuaTiaoWenNumber_Plan2,
      'riShiZhuGuaTiaoWenNumber_Plan3': riShiZhuGuaTiaoWenNumber_Plan3,
      'riShiHuGuaTiaoWenNumber_Plan1': riShiHuGuaTiaoWenNumber_Plan1,
      'riShiHuGuaTiaoWenNumber_Plan2': riShiHuGuaTiaoWenNumber_Plan2,
      'riShiHuGuaTiaoWenNumber_Plan3': riShiHuGuaTiaoWenNumber_Plan3,
      // 所有条文编号
      'allTiaoWenNumbers': allTiaoWenNumbers,
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'GuaZhongBaseNumberModel('
        'name: $name, '
        'nianYueZhuGuaName: $nianYueZhuGuaName, '
        'riShiZhuGuaName: $riShiZhuGuaName, '
        'allTiaoWenNumbers: $allTiaoWenNumbers'
        ')';
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GuaZhongBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.nianYueZhuGuaName == nianYueZhuGuaName &&
        other.riShiZhuGuaName == riShiZhuGuaName;
  }

  /// 哈希码
  @override
  int get hashCode {
    return baseNumber.hashCode ^
        name.hashCode ^
        nianYueZhuGuaName.hashCode ^
        riShiZhuGuaName.hashCode;
  }
}
