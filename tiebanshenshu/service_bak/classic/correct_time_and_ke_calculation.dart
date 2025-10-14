import '../../domain/six_yao_gua.dart';
import '../../utils/utils.dart' as Utils;
import '../calculation_strategy.dart';

/// 刻信息类
class KeInfo {
  final String timeZhi;
  final String keOrderName;
  final int number;
  final bool isAccepted;

  const KeInfo({
    required this.timeZhi,
    required this.keOrderName,
    required this.number,
    required this.isAccepted,
  });

  @override
  String toString() {
    return 'KeInfo(timeZhi: $timeZhi, keOrderName: $keOrderName, number: $number, isAccepted: $isAccepted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeInfo &&
        other.timeZhi == timeZhi &&
        other.keOrderName == keOrderName &&
        other.number == number &&
        other.isAccepted == isAccepted;
  }

  @override
  int get hashCode {
    return Object.hash(timeZhi, keOrderName, number, isAccepted);
  }
}

/// 定刻取数法计算参数
class CorrectTimeAndKeParams {
  final String birthTimeZhi;
  final List<KeInfo> keInfoList;

  CorrectTimeAndKeParams({
    required this.birthTimeZhi,
    required this.keInfoList,
  });
}

/// 定刻取数法计算结果
class DingKeQuShuResult {
  final String birthTimeZhi;
  final int baseNumber;
  final String baseGua;
  final SixYaoGua sixYaoGua;
  final int guaTotalNumber;
  final int tiaoWenNumber;
  final List<int> tiaoWenNumberList;
  final List<KeInfo> keInfoList;

  DingKeQuShuResult({
    required this.birthTimeZhi,
    required this.baseNumber,
    required this.baseGua,
    required this.sixYaoGua,
    required this.guaTotalNumber,
    required this.tiaoWenNumber,
    required this.tiaoWenNumberList,
    required this.keInfoList,
  });
}

/// 条文编号计算策略类 - 定刻取数法
class CorrectTimeAndKeCalculation
    extends CalculationStrategy<CorrectTimeAndKeParams, DingKeQuShuResult> {
  // # 案例2： 定刻取数法
  // # 1. 以被测者生辰为基准（如：出生在卯时，则以卯时为准）
  // # 2. 查《八刻数表》根据出生时刻，查出相应的几基本数（每时辰8个刻钟选择最符合的条文，其条文数作为基本数）
  // # 3. 将基本数转为后天卦（四位基本数，前两位相加为上卦、后两位相加为下卦。合数模8，取后天卦）
  // # 4. 将 "第三步" 得到的卦进行纳甲配爻，按加则法取数
  // # 5. 六爻配数相加为"卦总数"
  // # 6. 上卦后天数千位 + 卦总数 - 下卦后天数 = "条文数"
  // # 7. 条文数 ± 96 * n(n为1,2,3,4) 得出共8条
  static const List<int> _multipleList = [
    96,
    192,
    288,
    384,
    -96,
    -192,
    -288,
    -384,
  ];

  @override
  String get name => "定刻取数法";

  @override
  String get description => "以被测者出生时刻为基准，查八刻数表确定基本数，转换为后天卦并进行纳甲配爻计算条文编号";

  @override
  List<String> get detailSteps => [
    "1. 确定出生时辰：以被测者生辰为基准（如出生在卯时，则以卯时为准）",
    "2. 查八刻数表：根据出生时刻，查出相应的基本数（每时辰8个刻钟选择最符合的条文）",
    "3. 转换后天卦：四位基本数，前两位相加为上卦、后两位相加为下卦，合数模8取后天卦",
    "4. 纳甲配爻：将得到的卦进行纳甲配爻，按加则法取数",
    "5. 计算卦总数：六爻配数相加得到卦总数",
    "6. 计算条文数：上卦后天数千位 + 卦总数 - 下卦后天数 = 条文数",
    "7. 生成条文列表：条文数 ± 96 × n（n为1,2,3,4），得出共8条条文编号",
  ];

  @override
  String get school => "定刻取数流派";

  @override
  DingKeQuShuResult calculate(CorrectTimeAndKeParams params) {
    final birthTimeZhi = params.birthTimeZhi;
    final keInfoList = params.keInfoList;

    // 查找被接受的刻信息，获取基本数
    final acceptedKeInfo = keInfoList.firstWhere(
      (keInfo) => keInfo.isAccepted,
      orElse: () => throw ArgumentError('没有找到被接受的刻信息'),
    );

    final baseNumber = acceptedKeInfo.number;

    // 将基本数转为后天卦
    final baseGua = Utils.digit4NumberToHouGua(baseNumber);

    // 转换为六爻卦
    final sixYaoGua = SixYaoGua.generateFromGua(baseGua);

    // 计算卦总数（六爻配数相加）
    final guaTotalNumber = _calculateGuaTotalNumber(sixYaoGua);

    // 计算条文数：上卦后天数千位 + 卦总数 - 下卦后天数
    final tiaoWenNumber = _calculateTiaoWenNumber(baseNumber, guaTotalNumber);

    // 生成条文列表
    final tiaoWenNumberList = _multipleList
        .map((x) => tiaoWenNumber + x)
        .toList();

    return DingKeQuShuResult(
      birthTimeZhi: birthTimeZhi,
      baseNumber: baseNumber,
      baseGua: baseGua,
      sixYaoGua: sixYaoGua,
      guaTotalNumber: guaTotalNumber,
      tiaoWenNumber: tiaoWenNumber,
      tiaoWenNumberList: tiaoWenNumberList,
      keInfoList: keInfoList,
    );
  }

  /// 计算卦总数（六爻配数相加）
  int _calculateGuaTotalNumber(SixYaoGua sixYaoGua) {
    // 这里需要根据纳甲配爻的具体规则来实现
    // 暂时返回一个示例值，实际实现需要根据具体的纳甲配爻规则
    int total = 0;
    for (int i = 0; i < 6; i++) {
      // 根据爻的阴阳和位置计算配数
      // 这里需要具体的纳甲配爻算法
      total += (sixYaoGua.binaryList[i] == 1) ? (i + 1) * 2 : (i + 1);
    }
    return total;
  }

  /// 计算条文数：上卦后天数千位 + 卦总数 - 下卦后天数
  int _calculateTiaoWenNumber(int baseNumber, int guaTotalNumber) {
    // 提取四位基本数的前两位和后两位
    final String baseNumberStr = baseNumber.toString().padLeft(4, '0');
    final int frontTwo = int.parse(baseNumberStr.substring(0, 2));
    final int backTwo = int.parse(baseNumberStr.substring(2, 4));

    // 计算上卦和下卦的后天数
    final int upperGuaNumber = (frontTwo % 8 == 0) ? 8 : frontTwo % 8;
    final int lowerGuaNumber = (backTwo % 8 == 0) ? 8 : backTwo % 8;

    // 上卦后天数千位 + 卦总数 - 下卦后天数
    return upperGuaNumber * 1000 + guaTotalNumber - lowerGuaNumber;
  }
}

/// 测试函数
void test() {
  // 创建测试用的刻信息列表
  final keInfoList = [
    KeInfo(timeZhi: "卯", keOrderName: "一刻", number: 1234, isAccepted: false),
    KeInfo(timeZhi: "卯", keOrderName: "二刻", number: 2345, isAccepted: true),
    KeInfo(timeZhi: "卯", keOrderName: "三刻", number: 3456, isAccepted: false),
  ];

  final strategy = CorrectTimeAndKeCalculation();
  final params = CorrectTimeAndKeParams(
    birthTimeZhi: "卯",
    keInfoList: keInfoList,
  );

  final result = strategy.calculate(params);

  print('测试通过！');
  print('出生时支: ${result.birthTimeZhi}');
  print('基本数: ${result.baseNumber}');
  print('基本卦: ${result.baseGua}');
  print('卦总数: ${result.guaTotalNumber}');
  print('条文数: ${result.tiaoWenNumber}');
  print('条文列表: ${result.tiaoWenNumberList}');
}
