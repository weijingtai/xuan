import 'package:json_annotation/json_annotation.dart';

enum TaiYuanCalculateStrategy {
  /// 直接以受孕时间确定胎元
  @JsonValue("受孕时间法")
  directConceptionDate(
    name: '受孕时间法',
    description:
        '若命主已知自己的受孕时间（即受精怀胎的具体日期），直接以受孕当天的日柱干支作为胎元。若受孕时间在当日子时（23:00-1:00）之前，取上一天的日柱；若在子时之后，取当天的日柱。',
    warning: '需要准确的受孕时间，试管婴儿以植入胚胎时间为准。受孕时间可通过末次月经、B超孕囊大小或排卵期反推，但医学推算存在±1周误差。',
  ),

  /// 月柱推算法（主流方法）
  @JsonValue("月柱推算法")
  monthPillarMethod(
    name: '月柱推算法',
    description:
        '基于"十月怀胎"的假设进行推算。胎元天干：出生月柱的天干向前顺推一位；胎元地支：出生月柱的地支向前顺推三位。例如：若命主生于乙亥月，胎元为丙寅（乙→丙，亥→子→丑→寅）。',
    warning:
        '此方法为主流推算方式，但基于标准十月怀胎假设，实际妊娠周期存在个体差异。早产（＜10个月）需在地支基础上减一位，晚产（＞10个月）需加一位。',
  ),

  /// 生日倒推法（古法参考）
  /// 从出生日向前推算300天（约十个月），该日的干支即为胎元。例如：甲子日出生者，300天前同为甲子日，胎元即甲子。
  @JsonValue("生日倒推法")
  birthdayCountbackMethod(
    name: '生日倒推法',
    description: '从出生日向前推算300天（约十个月），该日的干支即为胎元。例如：甲子日出生者，300天前同为甲子日，胎元即甲子。',
    warning: '此为古法参考方法，实际妊娠周期存在个体差异（早产/晚产），准确性受到质疑。建议结合其他方法综合判断。',
  ),

  /// 日主阴阳属性法（少数流派应用）
  /// 日主的阴阳属性决定胎元天干。阳干日主（甲、丙等）：胎元天干取出生月地支的藏干；阴干日主（乙、丁等）：胎元天干取出生时地支的藏干。例如：日主乙木（阴干），出生时支为卯，藏干乙木，胎元为乙木。
  @JsonValue("日主阴阳属性法")
  dayMasterYinYangMethod(
    name: '日主阴阳属性法',
    description:
        '根据日主的阴阳属性确定胎元。阳干日主（甲、丙等）：胎元天干取出生月地支的藏干；阴干日主（乙、丁等）：胎元天干取出生时地支的藏干。例如：日主乙木（阴干），出生时支为卯，藏干乙木，胎元为乙木。',
    warning: '此方法仅在少数流派中应用，理论基础相对薄弱。需要准确掌握地支藏干理论，且计算结果可能与主流方法存在较大差异。',
  );

  const TaiYuanCalculateStrategy({
    required this.name,
    required this.description,
    required this.warning,
  });

  /// 策略名称
  final String name;

  /// 策略描述
  final String description;

  /// 注意事项和警告
  final String warning;
}
