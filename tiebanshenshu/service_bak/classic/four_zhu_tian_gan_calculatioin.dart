import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../calculation_strategy.dart';

/// 四柱天干取数法计算参数
class FourZhuTianGanParams {
  final FourZhu fourZhu;

  FourZhuTianGanParams({required this.fourZhu});
}

/// 四柱天干取数法计算结果
class FourZhuTianGanResult {
  final FourZhu fourZhu;
  final int baseNumber;
  final List<int> tiaoWenNumberList;
  final Map<String, int> ganNumberMapping;

  FourZhuTianGanResult({
    required this.fourZhu,
    required this.baseNumber,
    required this.tiaoWenNumberList,
    required this.ganNumberMapping,
  });
}

/// 条文编号计算策略类 - 四柱天干取数法
class FourZhuTianGanCalculation
    extends CalculationStrategy<FourZhuTianGanParams, FourZhuTianGanResult> {
  // # 案例3： 四柱天干取数法
  // # 1. 排四柱，只取天干，进行天干配数 甲1、丙2、戊3、庚4、壬5、乙6、丁7、巳8、辛9、癸0
  // # 2. 按照 月，日，时，年，进行排列得到四位数，此数为基本数
  // # 3. 以次数为基础递加96七次，得到8个数为条文列表

  /// 天干数字映射表
  static const Map<String, int> ganNumberMapper = {
    "甲": 1,
    "乙": 6,
    "丙": 2,
    "丁": 7,
    "戊": 3,
    "己": 8,
    "庚": 4,
    "辛": 9,
    "壬": 5,
    "癸": 0,
  };

  @override
  String get name => "四柱天干取数法";

  @override
  String get description => "排四柱只取天干进行配数，按月日时年顺序排列得到基本数，递加96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的天干信息",
    "2. 天干配数：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0",
    "3. 排列组合：按照月、日、时、年的顺序排列天干配数，得到四位基本数",
    "4. 生成条文列表：以基本数为基础递加96七次，得到8个条文编号",
  ];

  @override
  String get school => "四柱天干流派";

  @override
  FourZhuTianGanResult calculate(FourZhuTianGanParams params) {
    final fourZhu = params.fourZhu;

    // 计算基本数：按照月、日、时、年的顺序排列天干配数
    final baseNumber = _calculateBaseNumber(fourZhu);

    // 生成条文列表：以基本数为基础递加96七次，得到8个数
    final tiaoWenNumberList =
        TiaowenCalculator.calculateTiaoWenListByAddFactorTimes(
          baseNumber,
          7,
          returnWithBase: true,
        );

    return FourZhuTianGanResult(
      fourZhu: fourZhu,
      baseNumber: baseNumber,
      tiaoWenNumberList: tiaoWenNumberList,
      ganNumberMapping: ganNumberMapper,
    );
  }

  /// 计算基本数
  ///
  /// 按照月、日、时、年的顺序排列天干配数
  static int _calculateBaseNumber(FourZhu fourZhu) {
    final List<String> tmpGanList = [
      fourZhu.monthGan,
      fourZhu.dayGan,
      fourZhu.timeGan,
      fourZhu.yearGan,
    ];

    final List<int> tmpGanNumberList = tmpGanList
        .map((gan) => ganNumberMapper[gan]!)
        .toList();

    return int.parse(tmpGanNumberList.join());
  }
}

/// 测试函数
void test() {
  // 创建测试用的四柱
  final fourZhu = FourZhu(
    yearGanzhi: "甲子",
    monthGanzhi: "丙寅",
    dayGanzhi: "戊辰",
    timeGanzhi: "庚午",
  );

  final strategy = FourZhuTianGanCalculation();
  final params = FourZhuTianGanParams(fourZhu: fourZhu);

  final result = strategy.calculate(params);

  print('测试通过！');
  print('四柱信息: ${result.fourZhu}');
  print('基本数: ${result.baseNumber}');
  print('条文列表: ${result.tiaoWenNumberList}');
  print('天干配数映射: ${result.ganNumberMapping}');
}
