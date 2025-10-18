/// 八卦加则法单次计算结果
///
/// 封装一次八卦加则法计算的完整结果,包含六爻卦、中间计算步骤和最终条文数
class BaGuaJiaZeResult {
  /// 六爻卦数据
  final dynamic pureSixYaoGua; // PureSixYaoGua 类型

  /// 上卦(后天八卦)
  final dynamic upperGua; // Enum8Gua 类型

  /// 下卦(后天八卦)
  final dynamic lowerGua; // Enum8Gua 类型

  /// 上卦后天数
  final int upperGuaNumber;

  /// 下卦后天数
  final int lowerGuaNumber;

  /// 六爻地支总和
  final int yaoSum;

  /// 计算公式字符串
  final String formula;

  /// 最终条文数(基础数)
  final int tiaoWenNumber;

  /// 计算方法名称
  final String methodName;

  /// 计算详细说明
  final String description;

  BaGuaJiaZeResult({
    required this.pureSixYaoGua,
    required this.upperGua,
    required this.lowerGua,
    required this.upperGuaNumber,
    required this.lowerGuaNumber,
    required this.yaoSum,
    required this.formula,
    required this.tiaoWenNumber,
    required this.methodName,
    required this.description,
  });

  @override
  String toString() {
    return 'BaGuaJiaZeResult('
        'method: $methodName, '
        'tiaoWenNumber: $tiaoWenNumber, '
        'formula: $formula'
        ')';
  }

  /// 获取简要信息
  String get summary =>
      '$methodName: $formula = $tiaoWenNumber';
}
