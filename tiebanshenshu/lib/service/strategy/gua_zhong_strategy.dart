/// 卦中取数法 Strategy
///
/// 负责实现卦中取数法的核心算法逻辑
library;

import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';

import '../../constant/constants.dart' as constants;
import 'package:common/models/eight_chars.dart';
import 'package:common/enums.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/gua_zhong_base_number_model.dart';
import '../../utils/utils.dart' as gua_utils;
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 卦中取数法 Strategy参数类
class GuaZhongStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  GuaZhongStrategyParams({required this.eightChars});

  @override
  String get description =>
      "卦中取数法计算参数：四柱(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})";

  @override
  String toString() {
    return 'GuaZhongStrategyParams(eightChars: ${eightChars.toString()})';
  }
}

/// 卦中取数法 Strategy实现
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
/// 算法步骤：
/// 1. 排四柱，获取干支太玄数
/// 2. 年月卦计算：
///    - 年柱干支太玄数相加 mod 8 得上卦先天数
///    - 月柱干支太玄数相加 mod 8 得下卦先天数
///    - 主卦条文：千位=(上卦先天数+6)按三种方案计算，百位=上卦先天数，十位=年干太玄数，个位=年支太玄数
///    - 互卦条文：千位和百位同主卦，十位=互卦上卦先天数，个位=互卦下卦先天数
/// 3. 日时卦计算：
///    - 日柱干支太玄数相加 > 8 则减8 得上卦先天数
///    - 时柱干支太玄数相加 > 8 则减8 得下卦先天数
///    - 主卦条文：千位=(上卦先天数+6)按三种方案计算，百位=上卦先天数，十位=日干太玄数，个位=日支太玄数
///    - 互卦条文：千位和百位同主卦，十位=互卦上卦先天数，个位=互卦下卦先天数
///
/// **总计产生12个条文编号**（4个位置 × 3种方案）
class GuaZhongStrategy
    extends
        StandardCalculationStrategy<
          GuaZhongStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "卦中取数法（三种千位计算方案）";

  @override
  String get description =>
      "基于四柱干支太玄数，分别生成年月卦和日时卦，每卦产生主卦和互卦两个条文编号。"
      "由于千位计算存在歧义（当上卦先天数=4时，4+6=10，%10=0导致三位数），"
      "同时提供三种千位计算方案：方案1取1代替0（推荐），方案2取先天数代替，方案3保留10（五位数）";

  @override
  List<String> get detailSteps => [
    "1. 排四柱，四柱干支配太玄数",
    "2. 年月卦计算：年柱+月柱组卦 → 主卦条文(3种方案) + 互卦条文(3种方案)",
    "3. 日时卦计算：日柱+时柱组卦 → 主卦条文(3种方案) + 互卦条文(3种方案)",
    "4. 总计产生12个条文编号（4个位置 × 3种方案，无扩展）",
  ];

  @override
  String get school => "卦中取数流派";

  @override
  BaseNumberModelResult calculate(GuaZhongStrategyParams params) {
    try {
      // 步骤1：获取四柱干支太玄数
      final (
        yearGanTaixuanNumber,
        yearZhiTaixuanNumber,
        monthGanTaixuanNumber,
        monthZhiTaixuanNumber,
        dayGanTaixuanNumber,
        dayZhiTaixuanNumber,
        timeGanTaixuanNumber,
        timeZhiTaixuanNumber,
      ) = _getEightCharsTaixuanNumbers(
        params.eightChars,
      );

      // 步骤2：年月卦计算（返回16个值）
      final (
        yearSum,
        monthSum,
        nianYueUpperGuaXiantianNumber,
        nianYueLowerGuaXiantianNumber,
        nianYueUpperGuaName,
        nianYueLowerGuaName,
        nianYueZhuGuaName,
        nianYueHuGuaName,
        nianYueHuGuaUpperXiantianNumber,
        nianYueHuGuaLowerXiantianNumber,
        nianYueZhuGuaTiaoWenNumber_Plan1,
        nianYueZhuGuaTiaoWenNumber_Plan2,
        nianYueZhuGuaTiaoWenNumber_Plan3,
        nianYueHuGuaTiaoWenNumber_Plan1,
        nianYueHuGuaTiaoWenNumber_Plan2,
        nianYueHuGuaTiaoWenNumber_Plan3,
      ) = _calculateNianYueGua(
        yearGanTaixuanNumber,
        yearZhiTaixuanNumber,
        monthGanTaixuanNumber,
        monthZhiTaixuanNumber,
      );

      // 步骤3：日时卦计算（返回16个值）
      final (
        daySum,
        timeSum,
        riShiUpperGuaXiantianNumber,
        riShiLowerGuaXiantianNumber,
        riShiUpperGuaName,
        riShiLowerGuaName,
        riShiZhuGuaName,
        riShiHuGuaName,
        riShiHuGuaUpperXiantianNumber,
        riShiHuGuaLowerXiantianNumber,
        riShiZhuGuaTiaoWenNumber_Plan1,
        riShiZhuGuaTiaoWenNumber_Plan2,
        riShiZhuGuaTiaoWenNumber_Plan3,
        riShiHuGuaTiaoWenNumber_Plan1,
        riShiHuGuaTiaoWenNumber_Plan2,
        riShiHuGuaTiaoWenNumber_Plan3,
      ) = _calculateRiShiGua(
        dayGanTaixuanNumber,
        dayZhiTaixuanNumber,
        timeGanTaixuanNumber,
        timeZhiTaixuanNumber,
      );

      // 组合基础数（使用第一个条文编号作为基础数）
      final baseNumber = nianYueZhuGuaTiaoWenNumber_Plan1;

      // 创建 GuaZhongBaseNumberModel（包含12个条文编号）
      final model = GuaZhongBaseNumberModel(
        baseNumber: baseNumber,
        name: name,
        description: description,
        source: BaseNumberSource.combined,
        // 输入参数
        eightChars: params.eightChars,
        // 四柱干支太玄数
        yearGanTaixuanNumber: yearGanTaixuanNumber,
        yearZhiTaixuanNumber: yearZhiTaixuanNumber,
        monthGanTaixuanNumber: monthGanTaixuanNumber,
        monthZhiTaixuanNumber: monthZhiTaixuanNumber,
        dayGanTaixuanNumber: dayGanTaixuanNumber,
        dayZhiTaixuanNumber: dayZhiTaixuanNumber,
        timeGanTaixuanNumber: timeGanTaixuanNumber,
        timeZhiTaixuanNumber: timeZhiTaixuanNumber,
        // 年月卦计算
        yearSum: yearSum,
        monthSum: monthSum,
        nianYueUpperGuaXiantianNumber: nianYueUpperGuaXiantianNumber,
        nianYueLowerGuaXiantianNumber: nianYueLowerGuaXiantianNumber,
        nianYueUpperGuaName: nianYueUpperGuaName,
        nianYueLowerGuaName: nianYueLowerGuaName,
        nianYueZhuGuaName: nianYueZhuGuaName,
        nianYueHuGuaName: nianYueHuGuaName,
        nianYueHuGuaUpperXiantianNumber: nianYueHuGuaUpperXiantianNumber,
        nianYueHuGuaLowerXiantianNumber: nianYueHuGuaLowerXiantianNumber,
        // 年月卦条文编号 - 三种方案
        nianYueZhuGuaTiaoWenNumber_Plan1: nianYueZhuGuaTiaoWenNumber_Plan1,
        nianYueZhuGuaTiaoWenNumber_Plan2: nianYueZhuGuaTiaoWenNumber_Plan2,
        nianYueZhuGuaTiaoWenNumber_Plan3: nianYueZhuGuaTiaoWenNumber_Plan3,
        nianYueHuGuaTiaoWenNumber_Plan1: nianYueHuGuaTiaoWenNumber_Plan1,
        nianYueHuGuaTiaoWenNumber_Plan2: nianYueHuGuaTiaoWenNumber_Plan2,
        nianYueHuGuaTiaoWenNumber_Plan3: nianYueHuGuaTiaoWenNumber_Plan3,
        // 日时卦计算
        daySum: daySum,
        timeSum: timeSum,
        riShiUpperGuaXiantianNumber: riShiUpperGuaXiantianNumber,
        riShiLowerGuaXiantianNumber: riShiLowerGuaXiantianNumber,
        riShiUpperGuaName: riShiUpperGuaName,
        riShiLowerGuaName: riShiLowerGuaName,
        riShiZhuGuaName: riShiZhuGuaName,
        riShiHuGuaName: riShiHuGuaName,
        riShiHuGuaUpperXiantianNumber: riShiHuGuaUpperXiantianNumber,
        riShiHuGuaLowerXiantianNumber: riShiHuGuaLowerXiantianNumber,
        // 日时卦条文编号 - 三种方案
        riShiZhuGuaTiaoWenNumber_Plan1: riShiZhuGuaTiaoWenNumber_Plan1,
        riShiZhuGuaTiaoWenNumber_Plan2: riShiZhuGuaTiaoWenNumber_Plan2,
        riShiZhuGuaTiaoWenNumber_Plan3: riShiZhuGuaTiaoWenNumber_Plan3,
        riShiHuGuaTiaoWenNumber_Plan1: riShiHuGuaTiaoWenNumber_Plan1,
        riShiHuGuaTiaoWenNumber_Plan2: riShiHuGuaTiaoWenNumber_Plan2,
        riShiHuGuaTiaoWenNumber_Plan3: riShiHuGuaTiaoWenNumber_Plan3,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [model],
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'nianYueZhuGuaName': nianYueZhuGuaName,
          'riShiZhuGuaName': riShiZhuGuaName,
          'allTiaoWenNumbers': model.allTiaoWenNumbers,
          'totalTiaoWenCount': model.allTiaoWenNumbers.length,
          'supportedPlans': [1, 2, 3],
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "$name 计算失败: $e",
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// 获取八字干支太玄数
  ///
  /// 返回: (年干, 年支, 月干, 月支, 日干, 日支, 时干, 时支)
  (int, int, int, int, int, int, int, int) _getEightCharsTaixuanNumbers(
    EightChars eightChars,
  ) {
    final yearGan = eightChars.yearTianGan;
    final yearZhi = eightChars.yearDiZhi;

    final monthGan = eightChars.monthTianGan;
    final monthZhi = eightChars.monthDiZhi;

    final dayGan = eightChars.dayTianGan;
    final dayZhi = eightChars.dayDiZhi;

    final timeGan = eightChars.hourTianGan;
    final timeZhi = eightChars.hourDiZhi;

    return (
      _getTaixuanNumberFromEnums(yearGan),
      _getTaixuanNumberFromEnums(yearZhi),
      _getTaixuanNumberFromEnums(monthGan),
      _getTaixuanNumberFromEnums(monthZhi),
      _getTaixuanNumberFromEnums(dayGan),
      _getTaixuanNumberFromEnums(dayZhi),
      _getTaixuanNumberFromEnums(timeGan),
      _getTaixuanNumberFromEnums(timeZhi),
    );
  }

  /// 获取天干或地支的太玄数（枚举版）
  int _getTaixuanNumberFromEnums(dynamic ganOrZhiEnum) {
    if (ganOrZhiEnum is TianGan) {
      final mapper = constants.taiXuanGanNumberMapper;
      if (mapper.containsKey(ganOrZhiEnum)) {
        return mapper[ganOrZhiEnum]!;
      }
    }
    if (ganOrZhiEnum is DiZhi) {
      final mapper = constants.taiXuanZhiNumberMapper;
      if (mapper.containsKey(ganOrZhiEnum)) {
        return mapper[ganOrZhiEnum]!;
      }
    }
    throw ArgumentError('无法找到 $ganOrZhiEnum 对应的太玄数');
  }

  /// 根据先天数获取卦名
  ///
  /// 先天数范围: 1-8
  Enum8Gua _getGuaNameByXiantianNumber(int number) {
    return constants.numberXianGuaMapper[number]!;
  }

  /// 千位计算 - 方案1（推荐）：取1代替0
  ///
  /// 当 `(上卦先天数 + 6) == 10` 时，使用 `1` 代替 `0`，保持四位数格式
  ///
  /// 逻辑: `qianWei = (xiantianNumber + 6) == 10 ? 1 : (xiantianNumber + 6) % 10`
  ///
  /// **触发场景**: 当上卦为震卦(xiantian=4)时触发
  /// - 震卦(4) → (4+6)=10 → 千位=1
  ///
  /// **优点**: 保持四位数格式，符合铁板神数规范
  ///
  /// [xiantianNumber] 上卦先天数 (1-8)
  /// 返回: 千位数字 (1-9)
  int _calculateQianWei_Plan1(int xiantianNumber) {
    final sum = xiantianNumber + 6;
    return sum == 10 ? 1 : sum % 10;
  }

  /// 千位计算 - 方案2：取先天数代替
  ///
  /// 当 `(上卦先天数 + 6) == 10` 时，使用上卦先天数本身代替 `0`
  ///
  /// 逻辑: `qianWei = (xiantianNumber + 6) == 10 ? xiantianNumber : (xiantianNumber + 6) % 10`
  ///
  /// **触发场景**: 当上卦为震卦(xiantian=4)时触发
  /// - 震卦(4) → (4+6)=10 → 千位=4
  ///
  /// **优点**: 保留卦象数字特征
  ///
  /// [xiantianNumber] 上卦先天数 (1-8)
  /// 返回: 千位数字 (1-9)
  int _calculateQianWei_Plan2(int xiantianNumber) {
    final sum = xiantianNumber + 6;
    return sum == 10 ? xiantianNumber : sum % 10;
  }

  /// 千位计算 - 方案3：保留10（五位数）
  ///
  /// 直接使用 `(上卦先天数 + 6)` 的结果，不取模，可能产生五位数条文编号
  ///
  /// 逻辑: `qianWei = xiantianNumber + 6` (不取模)
  ///
  /// **触发场景**: 当上卦为震卦(xiantian=4)时触发
  /// - 震卦(4) → (4+6)=10 → 千位=10 → 条文=10484 (五位数)
  ///
  /// **优点**: 完全按照原始算法，无修改
  /// **缺点**: 打破四位数规范，可能导致数据库查询失败
  ///
  /// [xiantianNumber] 上卦先天数 (1-8)
  /// 返回: 千位数字 (7-14，通常为7-13，震卦时为10)
  int _calculateQianWei_Plan3(int xiantianNumber) {
    return xiantianNumber + 6;
  }

  /// 计算年月卦
  ///
  /// 年柱干支相加 mod 8 得上卦先天数
  /// 月柱干支相加 mod 8 得下卦先天数
  ///
  /// 返回: (yearSum, monthSum, 上卦先天数, 下卦先天数, 上卦名, 下卦名, 主卦名, 互卦名,
  ///        互卦上卦先天数, 互卦下卦先天数,
  ///        主卦条文号_方案1, 主卦条文号_方案2, 主卦条文号_方案3,
  ///        互卦条文号_方案1, 互卦条文号_方案2, 互卦条文号_方案3)
  ///
  /// **共返回16个值**：基础信息10个 + 6个条文编号（3种方案 × 2个卦）
  (
    int, // yearSum
    int, // monthSum
    int, // upperGuaXiantianNumber
    int, // lowerGuaXiantianNumber
    Enum8Gua, // upperGuaName
    Enum8Gua, // lowerGuaName
    Enum64Gua, // zhuGuaName
    Enum64Gua, // huGuaName
    int, // huGuaUpperXiantianNumber
    int, // huGuaLowerXiantianNumber
    int, // zhuGuaTiaoWenNumber_Plan1
    int, // zhuGuaTiaoWenNumber_Plan2
    int, // zhuGuaTiaoWenNumber_Plan3
    int, // huGuaTiaoWenNumber_Plan1
    int, // huGuaTiaoWenNumber_Plan2
    int, // huGuaTiaoWenNumber_Plan3
  )
  _calculateNianYueGua(
    int yearGanTaixuan,
    int yearZhiTaixuan,
    int monthGanTaixuan,
    int monthZhiTaixuan,
  ) {
    // 计算年柱和月柱干支太玄数之和
    final yearSum = yearGanTaixuan + yearZhiTaixuan;
    final monthSum = monthGanTaixuan + monthZhiTaixuan;

    // 取模8得到先天数（范围1-8）
    // 注意：如果和正好是8的倍数，则为8
    final upperGuaXiantianNumber = yearSum % 8 == 0 ? 8 : yearSum % 8;
    final lowerGuaXiantianNumber = monthSum % 8 == 0 ? 8 : monthSum % 8;

    // 根据先天数获取卦名
    final upperGuaName = _getGuaNameByXiantianNumber(upperGuaXiantianNumber);
    final lowerGuaName = _getGuaNameByXiantianNumber(lowerGuaXiantianNumber);

    // 组合主卦名
    final zhuGuaName = Enum64Gua.getBy8Gua(upperGuaName, lowerGuaName);

    // 计算互卦
    final huGuaName = gua_utils.guaToHuGua(zhuGuaName);

    // 获取互卦的上下卦先天数
    final huGuaUpperName = huGuaName.top.name;
    final huGuaLowerName = huGuaName.bottom.name;
    final huGuaUpperXiantianNumber =
        constants.xianTianGuaNumberMapper[huGuaUpperName]!;
    final huGuaLowerXiantianNumber =
        constants.xianTianGuaNumberMapper[huGuaLowerName]!;

    // 计算主卦条文编号 - 三种方案
    // 百位=上卦先天数，十位=年干太玄数，个位=年支太玄数（三种方案相同）
    final baiWei = upperGuaXiantianNumber;
    final shiWei = yearGanTaixuan;
    final geWei = yearZhiTaixuan;

    // 方案1：千位取1代替0
    final qianWei_Plan1 = _calculateQianWei_Plan1(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan1 =
        qianWei_Plan1 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 方案2：千位取先天数代替
    final qianWei_Plan2 = _calculateQianWei_Plan2(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan2 =
        qianWei_Plan2 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 方案3：千位保留10
    final qianWei_Plan3 = _calculateQianWei_Plan3(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan3 =
        qianWei_Plan3 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 计算互卦条文编号 - 三种方案
    // 千位和百位同主卦，十位=互卦上卦先天数，个位=互卦下卦先天数
    final huGuaTiaoWenNumber_Plan1 =
        qianWei_Plan1 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    final huGuaTiaoWenNumber_Plan2 =
        qianWei_Plan2 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    final huGuaTiaoWenNumber_Plan3 =
        qianWei_Plan3 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    return (
      yearSum,
      monthSum,
      upperGuaXiantianNumber,
      lowerGuaXiantianNumber,
      upperGuaName,
      lowerGuaName,
      zhuGuaName,
      huGuaName,
      huGuaUpperXiantianNumber,
      huGuaLowerXiantianNumber,
      zhuGuaTiaoWenNumber_Plan1,
      zhuGuaTiaoWenNumber_Plan2,
      zhuGuaTiaoWenNumber_Plan3,
      huGuaTiaoWenNumber_Plan1,
      huGuaTiaoWenNumber_Plan2,
      huGuaTiaoWenNumber_Plan3,
    );
  }

  /// 计算日时卦
  ///
  /// 日柱干支相加 > 8 则减8 得上卦先天数
  /// 时柱干支相加 > 8 则减8 得下卦先天数
  ///
  /// 返回: (daySum, timeSum, 上卦先天数, 下卦先天数, 上卦名, 下卦名, 主卦名, 互卦名,
  ///        互卦上卦先天数, 互卦下卦先天数,
  ///        主卦条文号_方案1, 主卦条文号_方案2, 主卦条文号_方案3,
  ///        互卦条文号_方案1, 互卦条文号_方案2, 互卦条文号_方案3)
  ///
  /// **共返回16个值**：基础信息10个 + 6个条文编号（3种方案 × 2个卦）
  (
    int, // daySum
    int, // timeSum
    int, // upperGuaXiantianNumber
    int, // lowerGuaXiantianNumber
    Enum8Gua, // upperGuaName
    Enum8Gua, // lowerGuaName
    Enum64Gua, // zhuGuaName
    Enum64Gua, // huGuaName
    int, // huGuaUpperXiantianNumber
    int, // huGuaLowerXiantianNumber
    int, // zhuGuaTiaoWenNumber_Plan1
    int, // zhuGuaTiaoWenNumber_Plan2
    int, // zhuGuaTiaoWenNumber_Plan3
    int, // huGuaTiaoWenNumber_Plan1
    int, // huGuaTiaoWenNumber_Plan2
    int, // huGuaTiaoWenNumber_Plan3
  )
  _calculateRiShiGua(
    int dayGanTaixuan,
    int dayZhiTaixuan,
    int timeGanTaixuan,
    int timeZhiTaixuan,
  ) {
    // 计算日柱和时柱干支太玄数之和
    final daySum = dayGanTaixuan + dayZhiTaixuan;
    final timeSum = timeGanTaixuan + timeZhiTaixuan;

    // 如果大于8则减8得到先天数（范围1-8）
    final upperGuaXiantianNumber = daySum > 8 ? daySum - 8 : daySum;
    final lowerGuaXiantianNumber = timeSum > 8 ? timeSum - 8 : timeSum;

    // 根据先天数获取卦名
    final upperGuaName = _getGuaNameByXiantianNumber(upperGuaXiantianNumber);
    final lowerGuaName = _getGuaNameByXiantianNumber(lowerGuaXiantianNumber);

    // 组合主卦名
    final zhuGuaName = Enum64Gua.getBy8Gua(upperGuaName, lowerGuaName);

    // 计算互卦
    final huGuaName = gua_utils.guaToHuGua(zhuGuaName);

    // 获取互卦的上下卦先天数
    final huGuaUpperName = huGuaName.top;
    final huGuaLowerName = huGuaName.bottom;
    final huGuaUpperXiantianNumber =
        constants.xianGuaNumberMapper[huGuaUpperName]!;
    final huGuaLowerXiantianNumber =
        constants.xianGuaNumberMapper[huGuaLowerName]!;

    // 计算主卦条文编号 - 三种方案
    // 百位=上卦先天数，十位=日干太玄数，个位=日支太玄数（三种方案相同）
    final baiWei = upperGuaXiantianNumber;
    final shiWei = dayGanTaixuan;
    final geWei = dayZhiTaixuan;

    // 方案1：千位取1代替0
    final qianWei_Plan1 = _calculateQianWei_Plan1(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan1 =
        qianWei_Plan1 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 方案2：千位取先天数代替
    final qianWei_Plan2 = _calculateQianWei_Plan2(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan2 =
        qianWei_Plan2 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 方案3：千位保留10
    final qianWei_Plan3 = _calculateQianWei_Plan3(upperGuaXiantianNumber);
    final zhuGuaTiaoWenNumber_Plan3 =
        qianWei_Plan3 * 1000 + baiWei * 100 + shiWei * 10 + geWei;

    // 计算互卦条文编号 - 三种方案
    // 千位和百位同主卦，十位=互卦上卦先天数，个位=互卦下卦先天数
    final huGuaTiaoWenNumber_Plan1 =
        qianWei_Plan1 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    final huGuaTiaoWenNumber_Plan2 =
        qianWei_Plan2 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    final huGuaTiaoWenNumber_Plan3 =
        qianWei_Plan3 * 1000 +
        baiWei * 100 +
        huGuaUpperXiantianNumber * 10 +
        huGuaLowerXiantianNumber;

    return (
      daySum,
      timeSum,
      upperGuaXiantianNumber,
      lowerGuaXiantianNumber,
      upperGuaName,
      lowerGuaName,
      zhuGuaName,
      huGuaName,
      huGuaUpperXiantianNumber,
      huGuaLowerXiantianNumber,
      zhuGuaTiaoWenNumber_Plan1,
      zhuGuaTiaoWenNumber_Plan2,
      zhuGuaTiaoWenNumber_Plan3,
      huGuaTiaoWenNumber_Plan1,
      huGuaTiaoWenNumber_Plan2,
      huGuaTiaoWenNumber_Plan3,
    );
  }

  /// 默认条文计算配置
  ///
  /// 卦中取数法不进行条文扩展，直接返回12个条文编号（4个位置 × 3种方案）
  @override
  GenericTiaoWenCalculationConfig get defaultTiaoWenCalculationConfig =>
      GenericTiaoWenCalculationConfig.customList(
        name: "卦中取数法无扩展（三种方案）",
        description: "卦中取数法产生12个固定条文编号（4个位置 × 3种千位计算方案），无扩展计算",
        customList: [0],
        withSub: false,
      );
}
