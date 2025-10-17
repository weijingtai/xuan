/// 元堂派生策略的统一参数基类
///
/// 所有基于元堂卦的策略（先后天卦加则法、先后天卦取数、六爻干支和数法）
/// 都继承此基类，实现参数统一和YuanTangInfo复用
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';

import '../yuan_tang_strategy.dart';
import '../base_calculation_strategy.dart';

/// 元堂派生策略的统一参数基类
///
/// 提供两种使用模式：
/// 1. 从头计算：提供 EightChars + Gender + YuanYunOrder + TwentyFourJieQi，自动计算 YuanTangInfo
/// 2. 复用计算：直接提供已计算好的 YuanTangInfo，避免重复计算
///
/// 使用懒加载模式，仅在首次访问时计算 YuanTangInfo
abstract class YuanTangDerivedParams extends BaseCalculationParams {
  /// 四柱信息（必需）
  EightChars get eightChars;

  /// 性别（必需）
  Gender get gender;

  /// 三元（必需）
  YuanYunOrder get threeYuan;

  /// 出生节气后（必需）
  TwentyFourJieQi get birthAfterZhi;

  /// 月份类型（可选，默认为 monthYinYan）
  YuanTangMonthType get monthType => YuanTangMonthType.monthYinYan;

  /// 历法类型（可选，默认为 solar）
  CalanderType get calanderType => CalanderType.solar;

  /// 可选：预计算的 YuanTangInfo（用于复用已有计算结果）
  ///
  /// 如果为 null，则在首次调用 getOrComputeYuanTangInfo() 时自动计算
  YuanTangInfo? yuanTangInfo;

  /// 懒加载：获取或计算 YuanTangInfo
  ///
  /// 如果 yuanTangInfo 已存在，直接返回；
  /// 否则，根据 eightChars、gender、threeYuan 等参数计算并缓存
  ///
  /// 返回: 完整的元堂卦信息（包含先天卦、后天卦、大运、流年等）
  YuanTangInfo getOrComputeYuanTangInfo() {
    return yuanTangInfo ??= _computeYuanTangInfo();
  }

  /// 内部计算方法：根据参数计算 YuanTangInfo
  ///
  /// 使用 YuanTangCalculator 进行标准计算
  YuanTangInfo _computeYuanTangInfo() {
    // 从月支提取出生月份数字
    final birthMonth = YuanTangStrategyParams.getMonthNumberFromZhi(
      eightChars.month.zhi.name,
    );

    // 调用 YuanTangCalculator 进行计算
    return YuanTangCalculator().calculate(
      eightChars: eightChars,
      yearYinYang: eightChars.yearTianGan.yinYang,
      gender: gender,
      threeYuan: threeYuan,
      birthJieQi: birthAfterZhi,
      monthType: monthType,
      calanderType: calanderType,
      birthMonth: birthMonth,
    );
  }

  /// 判断是否使用了预计算的 YuanTangInfo
  ///
  /// 返回: true 表示使用了外部传入的 YuanTangInfo，false 表示需要自行计算
  bool get isUsingPrecomputedYuanTangInfo => yuanTangInfo != null;

  @override
  String get description {
    final mode = isUsingPrecomputedYuanTangInfo ? "复用模式" : "从头计算模式";
    return "元堂派生参数 [$mode]：四柱(${eightChars.year.name} ${eightChars.month.name} "
        "${eightChars.day.name} ${eightChars.time.name})，"
        "性别($gender)，三元($threeYuan)，节气($birthAfterZhi)，"
        "月份类型($monthType)，历法($calanderType)";
  }
}
