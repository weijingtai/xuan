/// 元堂卦取数法Strategy实现
///
/// 将元堂卦取数法算法封装为标准计算策略
library;

import '../../domain/four_zhu.dart';
import '../../constant/constants.dart' as constants;
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../utils/utils.dart' as gua_utils;
import '../../utils/tiao_wen_calculator.dart';
import '../../utils/yuan_tang_gua_helper.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 元堂卦取数法计算参数
///
/// 包含执行元堂卦取数法所需的所有参数
class YuanTangStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final FourZhu fourZhu;

  /// 性别（"男" / "女"）
  final String gender;

  /// 三元（"上" / "中" / "下"）
  final String threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final String birthAfterZhi;

  YuanTangStrategyParams({
    required this.fourZhu,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String get description =>
      "元堂卦取数法计算参数：四柱(${fourZhu.yearGanzhi} ${fourZhu.monthGanzhi} ${fourZhu.dayGanzhi} ${fourZhu.timeGanzhi})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)";
}

/// 元堂卦取数法计算策略
///
/// 实现元堂卦取数法的标准计算策略
///
/// 计算步骤：
/// 1. 生成天地卦
/// 2. 生成上下卦（先天卦）
/// 3. 元堂装卦
/// 4. 生成后天卦
/// 5. 计算各种条文编号
class YuanTangStrategy extends StandardCalculationStrategy<
    YuanTangStrategyParams, BaseNumberModelResult> {
  @override
  String get name => "元堂卦取数法";

  @override
  String get description =>
      "天干配数，地支两数相配，分阴阳配卦，以时辰阴阳判定元堂爻，爻变配卦，本互互取数";

  @override
  List<String> get detailSteps => [
        "1. 生成天地卦：四柱天干数列表、四柱地支数列表，计算奇数和、偶数和，模运算得天数、地数，配天卦、地卦",
        "2. 生成上下卦（先天卦）：根据年份阴阳和性别决定上下卦位置",
        "3. 元堂装卦：根据时辰阴阳和卦象阴阳爻数装配地支，确定元堂爻",
        "4. 生成后天卦：元堂爻爻变，上下卦互换",
        "5. 互卦：计算先天卦互卦、后天卦互卦",
        "6. 计算条文编号：加则法、纳甲太玄数法、本互法、互取数列表（8种方法）",
      ];

  @override
  String get school => "元堂卦取数流派";

  @override
  BaseNumberModelResult calculate(YuanTangStrategyParams params) {
    try {
      // 步骤1：生成天地卦（使用YuanTangGuaHelper）
      final (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
              tianGuaNum, diGuaNum, usedThreeYuanWuGong) =
          YuanTangGuaHelper.generateTianDiGua(
        fourZhu: params.fourZhu,
        gender: params.gender,
        threeYuan: params.threeYuan,
      );

      // 步骤2：生成上下卦（先天卦）（使用YuanTangGuaHelper）
      final (yearYinYang, upperGua, lowerGua, xiantianGua,
              xiantianUpperGuaNumber, xiantianLowerGuaNumber) =
          YuanTangGuaHelper.generateXiantianGua(
        fourZhu: params.fourZhu,
        gender: params.gender,
        tianGua: tianGua,
        diGua: diGua,
      );

      // 步骤3：元堂装卦（使用YuanTangGuaHelper）
      final (yuantangYaoIndex, yuantangYaoLabel, zhiList, timeGanzhi,
              timeYinYang, totalYangYao, totalYinYao) =
          YuanTangGuaHelper.yuantangZhuanggua(
        fourZhu: params.fourZhu,
        xiantianGua: xiantianGua,
        gender: params.gender,
        birthAfterZhi: params.birthAfterZhi,
      );

      // 步骤4：生成后天卦（使用YuanTangGuaHelper）
      final (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber) =
          YuanTangGuaHelper.generateHoutianGua(
        xiantianGua: xiantianGua,
        yuantangYaoIndex: yuantangYaoIndex,
      );

      // 步骤4.5：后天卦元堂装卦（使用YuanTangGuaHelper）
      final (houtianYuantangYaoIndex, houtianYuantangYaoLabel, houtianZhiList) =
          YuanTangGuaHelper.houtianYuantangZhuanggua(
        fourZhu: params.fourZhu,
        houtianGua: houtianGua,
        gender: params.gender,
        birthAfterZhi: params.birthAfterZhi,
      );

      // 步骤5：计算互卦
      final xiantianGuaHu = gua_utils.guaToHuGua(xiantianGua);
      final houtianGuaHu = gua_utils.guaToHuGua(houtianGua);

      // 步骤6：计算大运
      // 先天卦大运从1岁开始
      final xiantianDayunStartAge = 1;
      final xiantianDayunList = _calculateDayun(
        xiantianGua,
        yuantangYaoIndex,
        zhiList,
        xiantianDayunStartAge,
      );

      // 计算先天卦结束年龄
      final xiantianDayunEndAge = xiantianDayunList.last.endAge;

      // 后天卦大运接着先天卦继续
      final houtianDayunStartAge = xiantianDayunEndAge + 1;
      final houtianDayunList = _calculateDayun(
        houtianGua,
        houtianYuantangYaoIndex,
        houtianZhiList,
        houtianDayunStartAge,
      );

      // 步骤6：计算各种条文编号
      // ignore: deprecated_member_use_from_same_package
      final tiaowenNumberJiazeXiantiangua =
          TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);
      // ignore: deprecated_member_use_from_same_package
      final tiaowenNumberJiazeHoutiangua =
          TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);

      // ignore: deprecated_member_use_from_same_package
      final tiaowenNumberNajiaTaixuanXiantiangua =
          TiaowenCalculator.getTiaowenNumberByTaixuan(xiantianGua);
      // ignore: deprecated_member_use_from_same_package
      final tiaowenNumberNajiaTaixuanHoutiangua =
          TiaowenCalculator.getTiaowenNumberByTaixuan(houtianGua);

      final tiaowenNumberXiantianBenhu =
          _calculateBenhuNumber(xiantianGua, xiantianGuaHu, isXiantian: true);
      final tiaowenNumberHoutianBenhu =
          _calculateBenhuNumber(houtianGua, houtianGuaHu, isXiantian: false);

      final tiaowenNumberListXiantianGuahu = [
        // ignore: deprecated_member_use_from_same_package
        ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
          tiaowenNumberXiantianBenhu,
          [2, 4, 8, 16],
        ),
        // ignore: deprecated_member_use_from_same_package
        ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
          tiaowenNumberXiantianBenhu,
        ),
      ];

      final tiaowenNumberListHoutianGuahu = [
        // ignore: deprecated_member_use_from_same_package
        ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
          tiaowenNumberHoutianBenhu,
          [2, 4, 8, 16],
        ),
        // ignore: deprecated_member_use_from_same_package
        ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
          tiaowenNumberHoutianBenhu,
        ),
      ];

      // 创建 YuanTangBaseNumberModel
      final baseNumber = tiaowenNumberJiazeXiantiangua; // 使用先天卦加则法作为基础数

      final yuanTangModel = YuanTangBaseNumberModel.create(
        baseNumber: baseNumber,
        name: "元堂卦取数法",
        description:
            "元堂卦取数法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
        source: _getSourceFromParams(params),
        fourZhu: params.fourZhu,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        ganNumList: ganNumList,
        zhiNumList: zhiNumList,
        oddNumTotal: oddNumTotal,
        evenNumTotal: evenNumTotal,
        tianGuaNum: tianGuaNum,
        diGuaNum: diGuaNum,
        tianGua: tianGua,
        diGua: diGua,
        usedThreeYuanWuGong: usedThreeYuanWuGong,
        yearYinYang: yearYinYang,
        upperGua: upperGua,
        lowerGua: lowerGua,
        xiantianGua: xiantianGua,
        xiantianUpperGuaNumber: xiantianUpperGuaNumber,
        xiantianLowerGuaNumber: xiantianLowerGuaNumber,
        timeGanzhi: timeGanzhi,
        timeYinYang: timeYinYang,
        totalYangYao: totalYangYao,
        totalYinYao: totalYinYao,
        zhiList: zhiList,
        yuantangYaoIndex: yuantangYaoIndex,
        yuantangYaoLabel: yuantangYaoLabel,
        houtianGua: houtianGua,
        houtianUpperGuaNumber: houtianUpperGuaNumber,
        houtianLowerGuaNumber: houtianLowerGuaNumber,
        houtianZhiList: houtianZhiList,
        houtianYuantangYaoIndex: houtianYuantangYaoIndex,
        houtianYuantangYaoLabel: houtianYuantangYaoLabel,
        xiantianGuaHu: xiantianGuaHu,
        houtianGuaHu: houtianGuaHu,
        xiantianDayunStartAge: xiantianDayunStartAge,
        xiantianDayunList: xiantianDayunList,
        houtianDayunStartAge: houtianDayunStartAge,
        houtianDayunList: houtianDayunList,
        tiaowenNumberJiazeXiantiangua: tiaowenNumberJiazeXiantiangua,
        tiaowenNumberJiazeHoutiangua: tiaowenNumberJiazeHoutiangua,
        tiaowenNumberNajiaTaixuanXiantiangua:
            tiaowenNumberNajiaTaixuanXiantiangua,
        tiaowenNumberNajiaTaixuanHoutiangua: tiaowenNumberNajiaTaixuanHoutiangua,
        tiaowenNumberXiantianBenhu: tiaowenNumberXiantianBenhu,
        tiaowenNumberHoutianBenhu: tiaowenNumberHoutianBenhu,
        tiaowenNumberListXiantianGuahu: tiaowenNumberListXiantianGuahu,
        tiaowenNumberListHoutianGuahu: tiaowenNumberListHoutianGuahu,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [yuanTangModel],
        sourceData: {
          'fourZhu': params.fourZhu.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianGua': xiantianGua,
          'houtianGua': houtianGua,
          'yuantangYaoIndex': yuantangYaoIndex,
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "元堂卦计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description
        },
      );
    }
  }

  /// 获取默认的条文计算配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    // 元堂卦递加96四次配置
    return GenericTiaoWenCalculationConfig.customList(
      name: "元堂卦递加96四次",
      description: "先天卦/后天卦基础数分别递加96四次，得到5个条文编号",
      customList: [0, 96, 192, 288, 384], // 基础数 + 这些偏移量
      withSub: false,
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    YuanTangStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    if (config is GenericTiaoWenCalculationConfig) {
      // 使用calculationList进行递加
      return config.calculationList.map((offset) => baseNumber + offset).toList();
    }
    // 降级处理：直接返回基础数
    return [baseNumber];
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      defaultTiaoWenCalculationConfig,
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  // ========== 辅助方法 ==========

  /// 步骤1：生成天地卦
  ///
  /// 返回: (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
  ///        tianGuaNum, diGuaNum, usedThreeYuanWuGong)
  (
    String,
    String,
    List<int>,
    List<List<int>>,
    int,
    int,
    int,
    int,
    bool
  ) _generateTianDiGua(YuanTangStrategyParams params) {
    // 提取四柱天干数列表
    final ganNumList = [
      constants.tianGanNumberMapper[params.fourZhu.yearGan]!,
      constants.tianGanNumberMapper[params.fourZhu.monthGan]!,
      constants.tianGanNumberMapper[params.fourZhu.dayGan]!,
      constants.tianGanNumberMapper[params.fourZhu.timeGan]!,
    ];

    // 提取四柱地支数列表（每个地支两个数）
    final zhiNumList = [
      constants.diZhiNumberMapper[params.fourZhu.yearZhi]!,
      constants.diZhiNumberMapper[params.fourZhu.monthZhi]!,
      constants.diZhiNumberMapper[params.fourZhu.dayZhi]!,
      constants.diZhiNumberMapper[params.fourZhu.timeZhi]!,
    ];

    // 展开地支数列表用于计算奇偶和
    final zhiNumTotalList = [
      ...constants.diZhiNumberMapper[params.fourZhu.yearZhi]!,
      ...constants.diZhiNumberMapper[params.fourZhu.monthZhi]!,
      ...constants.diZhiNumberMapper[params.fourZhu.dayZhi]!,
      ...constants.diZhiNumberMapper[params.fourZhu.timeZhi]!,
    ];

    // 计算奇数和、偶数和
    final oddNumTotal = (ganNumList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b));

    final evenNumTotal = (ganNumList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b));

    // 计算天数（奇数和 模25）
    final tianGuaNum = gua_utils.calculateGuaNum(oddNumTotal, 25, 5);

    // 计算地数（偶数和 模30）
    final diGuaNum = gua_utils.calculateGuaNum(evenNumTotal, 30, 3);

    // 数配卦
    final yearYinYang = params.fourZhu.isYangGanYear ? "阳" : "阴";
    String tianGua;
    String diGua;
    bool usedThreeYuanWuGong = false;

    // 天卦配卦（天数为5时查询三元五宫）
    if (tianGuaNum == 5) {
      tianGua = YuanTangGuaHelper
          .threeYuan5GongMapper[params.threeYuan]![params.gender]![yearYinYang]!;
      usedThreeYuanWuGong = true;
    } else {
      tianGua = constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
    }

    // 地卦配卦（地数为5时查询三元五宫）
    if (diGuaNum == 5) {
      diGua = YuanTangGuaHelper
          .threeYuan5GongMapper[params.threeYuan]![params.gender]![yearYinYang]!;
      usedThreeYuanWuGong = true;
    } else {
      diGua = constants.yuantangHuaTianNumberGuaMapper[diGuaNum]!;
    }

    return (
      tianGua,
      diGua,
      ganNumList,
      zhiNumList,
      oddNumTotal,
      evenNumTotal,
      tianGuaNum,
      diGuaNum,
      usedThreeYuanWuGong
    );
  }

  /// 步骤2：生成上下卦（先天卦）
  ///
  /// 返回: (yearYinYang, upperGua, lowerGua, xiantianGua,
  ///        xiantianUpperGuaNumber, xiantianLowerGuaNumber)
  (String, String, String, String, int, int) _generateUpperLowerGua(
    YuanTangStrategyParams params,
    String tianGua,
    String diGua,
  ) {
    final yearYinYang = params.fourZhu.isYangGanYear ? "阳" : "阴";
    String upperGua;
    String lowerGua;

    // 根据年份阴阳和性别决定上下卦位置
    if (yearYinYang == "阳") {
      if (params.gender == "男") {
        upperGua = tianGua;
        lowerGua = diGua;
      } else {
        upperGua = diGua;
        lowerGua = tianGua;
      }
    } else {
      if (params.gender == "女") {
        upperGua = tianGua;
        lowerGua = diGua;
      } else {
        upperGua = diGua;
        lowerGua = tianGua;
      }
    }

    final xiantianGua = upperGua + lowerGua;

    // 查询后天数
    final xiantianUpperGuaNumber =
        constants.houTianGuaNumberMapper[upperGua]!;
    final xiantianLowerGuaNumber =
        constants.houTianGuaNumberMapper[lowerGua]!;

    return (
      yearYinYang,
      upperGua,
      lowerGua,
      xiantianGua,
      xiantianUpperGuaNumber,
      xiantianLowerGuaNumber
    );
  }

  /// 步骤3：元堂装卦
  ///
  /// 返回: (yuantangYaoIndex, yuantangYaoLabel, zhiList, timeGanzhi,
  ///        timeYinYang, totalYangYao, totalYinYao)
  (int, String, List<List<String>>, String, String, int, int)
      _yuantangZhuanggua(
    YuanTangStrategyParams params,
    String xiantianGua,
  ) {
    final timeGanzhi = params.fourZhu.timeGanzhi;

    // 判断时辰阴阳
    const yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    const yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];

    final timeZhi = timeGanzhi.substring(timeGanzhi.length - 1);
    final timeYinYang =
        yuantangYangTimeSet.contains(timeZhi) ? "阳" : "阴";

    // 将卦转换为二进制列表
    final upperBinary = constants.guaBinaryMapper[xiantianGua[0]]!;
    final lowerBinary = constants.guaBinaryMapper[xiantianGua[1]]!;
    final allGuaBinary = [...upperBinary, ...lowerBinary];

    // 计算阳爻和阴爻数量
    final totalYangYao = allGuaBinary.where((x) => x == 1).length;
    final totalYinYao = allGuaBinary.where((x) => x == 0).length;

    // 根据时辰阴阳和爻数分类处理
    List<List<String>> zhiList;
    if (timeYinYang == "阳") {
      // 阳时取阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
            allGuaBinary, List.from(yuantangYangTimeSet), totalYangYao, true);
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        zhiList = _zhuanggua45(
            allGuaBinary, List.from(yuantangYangTimeSet), totalYangYao, true);
      } else {
        zhiList = _zhuanggua6Yang(totalYangYao == 6,
            List.from(yuantangYangTimeSet), true, params.gender, params.birthAfterZhi);
      }
    } else {
      // 阴时取阴爻
      if (totalYinYao > 0 && totalYinYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
            allGuaBinary, List.from(yuantangYinTimeSet), totalYinYao, false);
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        zhiList = _zhuanggua45(
            allGuaBinary, List.from(yuantangYinTimeSet), totalYinYao, false);
      } else {
        zhiList = _zhuanggua6Yang(totalYinYao == 0,
            List.from(yuantangYinTimeSet), false, params.gender, params.birthAfterZhi);
      }
    }

    // 获取元堂爻索引
    final yuantangYaoIndex = _getYuantangYaoIndex(timeGanzhi, zhiList);

    // 获取元堂爻位标签
    final yuantangYaoLabel = _getYaoPositionLabel(yuantangYaoIndex);

    return (
      yuantangYaoIndex,
      yuantangYaoLabel,
      zhiList,
      timeGanzhi,
      timeYinYang,
      totalYangYao,
      totalYinYao
    );
  }

  /// 步骤4：生成后天卦
  ///
  /// 返回: (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber)
  (String, int, int) _generateHoutianGua(
    String xiantianGua,
    int yuantangYaoIndex,
  ) {
    // 将卦转换为二进制列表
    final binaryList = gua_utils.guaToBinaryList(xiantianGua);

    // 转换索引：zhiList使用从下到上的索引(0=初爻,5=上爻)
    // 而binaryList使用从上到下的索引(0=上卦第1爻,5=下卦第3爻)
    // 转换公式：binaryIndex = 5 - zhiListIndex
    final binaryIndex = 5 - yuantangYaoIndex;

    // 元堂爻爻变（阴转阳，阳转阳）
    binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

    // 拆分成两个卦
    final oldUpon = binaryList.sublist(0, 3).join();
    final oldUnder = binaryList.sublist(3).join();

    // 根据二进制找到八经卦
    final oldUponGua = constants.binaryStrGuaMapper[oldUpon]!;
    final oldUnderGua = constants.binaryStrGuaMapper[oldUnder]!;

    // 上下卦互换
    final houtianGua = oldUnderGua + oldUponGua;

    // 查询后天数
    final houtianUpperGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[0]]!;
    final houtianLowerGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[1]]!;

    return (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
  }

  /// 计算本互条文编号
  ///
  /// [ben] 本卦
  /// [hu] 互卦
  /// [isXiantian] 是否为先天卦（true使用先天数，false使用后天数）
  int _calculateBenhuNumber(String ben, String hu, {required bool isXiantian}) {
    final benUpon = ben[0];
    final benUnder = ben[1];
    final huUpon = hu[0];
    final huUnder = hu[1];

    final numberMapper = isXiantian
        ? constants.xianTianGuaNumberMapper
        : constants.houTianGuaNumberMapper;

    final benUponNum = numberMapper[benUpon]!;
    final benUnderNum = numberMapper[benUnder]!;
    final huUponNum = numberMapper[huUpon]!;
    final huUnderNum = numberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 元堂装卦 - 爻数小于3的情况（双重装配）
  List<List<String>> _zhuangguaLowerThan3(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    final yinyangZhiList = List<String>.from(timeZhiList);
    final doubleZhi4Yang = yinyangZhiList.sublist(0, 2 * totalYao);
    final totalDoubleZhi = doubleZhi4Yang.length;
    final leftZhiList = yinyangZhiList.sublist(2 * totalYao);

    final zhiList = List.generate(6, (_) => <String>[]);
    var tmpBinaryList = List<int>.from(guaBinaryList);
    tmpBinaryList = tmpBinaryList.reversed.toList();

    var doubleZhiIndex = 0;

    for (var i = 0; i < totalDoubleZhi; i++) {
      for (var j = 0; j < 6; j++) {
        if (isYang) {
          if (tmpBinaryList[j] == 1 && doubleZhiIndex < doubleZhi4Yang.length) {
            zhiList[j].add(doubleZhi4Yang[doubleZhiIndex++]);
          }
        } else {
          if (tmpBinaryList[j] == 0 && doubleZhiIndex < doubleZhi4Yang.length) {
            zhiList[j].add(doubleZhi4Yang[doubleZhiIndex++]);
          }
        }
      }
    }

    final resultList = <List<String>>[];
    var leftIndex = 0;

    for (var i = 0; i < 6; i++) {
      if (zhiList[i].isEmpty && leftIndex < leftZhiList.length) {
        resultList.add([leftZhiList[leftIndex++]]);
      } else {
        resultList.add(zhiList[i]);
      }
    }

    // 移除反转：直接返回resultList，使装卦结果符合爻位顺序
    // 修正前：return resultList.reversed.toList() 导致顺序完全颠倒
    return resultList;
  }

  /// 元堂装卦 - 4-5爻（自上而下排列）
  List<List<String>> _zhuanggua45(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    final tmpTimeList = List<String>.from(timeZhiList);
    final firstFourZhi = tmpTimeList.sublist(0, totalYao);
    final leftZhiList = tmpTimeList.sublist(totalYao);
    var tmpBinList = List<int>.from(guaBinaryList);
    tmpBinList = tmpBinList.reversed.toList();
    final resultList = <List<String>>[];

    var firstIndex = 0;
    var leftIndex = 0;

    for (var i = 0; i < tmpBinList.length; i++) {
      if (isYang) {
        if (tmpBinList[i] == 1) {
          resultList.add(
            firstIndex < firstFourZhi.length
                ? [firstFourZhi[firstIndex++]]
                : [],
          );
        } else {
          resultList.add(
            leftIndex < leftZhiList.length ? [leftZhiList[leftIndex++]] : [],
          );
        }
      } else {
        if (tmpBinList[i] == 0) {
          resultList.add(
            firstIndex < firstFourZhi.length
                ? [firstFourZhi[firstIndex++]]
                : [],
          );
        } else {
          resultList.add(
            leftIndex < leftZhiList.length ? [leftZhiList[leftIndex++]] : [],
          );
        }
      }
    }

    // 移除反转：直接返回resultList，使装卦结果符合爻位顺序
    // 修正前：return resultList.reversed.toList() 导致顺序完全颠倒
    return resultList;
  }

  /// 元堂装卦 - 6爻全阳或全阴（三爻分组）
  List<List<String>> _zhuanggua6Yang(
    bool isSixYang,
    List<String> timeZhiList,
    bool isYang,
    String gender,
    String birthAfterZhi,
  ) {
    // 三爻装配辅助函数
    List<List<String>> threeYaoZhuang(List<String> dizhiList, bool isUp2Down) {
      final tmpDizhiList = List<String>.from(dizhiList);
      final result = <List<String>>[[], [], []];
      for (var i = 0; i < dizhiList.length; i++) {
        if (tmpDizhiList.isEmpty) {
          break;
        }
        for (var j = 0; j < 3; j++) {
          if (tmpDizhiList.isNotEmpty) {
            result[j].add(tmpDizhiList.removeAt(0));
          }
        }
      }
      if (isUp2Down) {
        return result;
      } else {
        return result.reversed.toList();
      }
    }

    if (isSixYang) {
      // 六阳爻
      if (gender == "男") {
        final tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [<String>[], <String>[], <String>[], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, <String>[], <String>[], <String>[]];
        }
      } else {
        // gender == "女"
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [<String>[], <String>[], <String>[], ...threeYaoZhuang(timeZhiList, false)];
          } else {
            // 冬至后出生 上卦自上而下
            return [...threeYaoZhuang(timeZhiList, true), <String>[], <String>[], <String>[]];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 上卦自下而上
            return [...threeYaoZhuang(timeZhiList, false), <String>[], <String>[], <String>[]];
          } else {
            // 冬至后出生 下卦自上而下
            return [<String>[], <String>[], <String>[], ...threeYaoZhuang(timeZhiList, true)];
          }
        }
      }
    } else {
      // 六阴爻
      if (gender == "女") {
        final tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [<String>[], <String>[], <String>[], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, <String>[], <String>[], <String>[]];
        }
      } else {
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [<String>[], <String>[], <String>[], ...threeYaoZhuang(timeZhiList, false)];
          } else {
            // 冬至后出生 上卦自上而下
            return [...threeYaoZhuang(timeZhiList, true), <String>[], <String>[], <String>[]];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 上卦自下而上
            return [...threeYaoZhuang(timeZhiList, false), <String>[], <String>[], <String>[]];
          } else {
            // 冬至后出生 下卦自上而下
            return [<String>[], <String>[], <String>[], ...threeYaoZhuang(timeZhiList, true)];
          }
        }
      }
    }
  }

  /// 获取元堂爻索引
  int _getYuantangYaoIndex(
    String timeZhi,
    List<List<String>> yangTangYaoZhiList,
  ) {
    var resultYuantangYaoIndex = -1;
    for (var i = 0; i < yangTangYaoZhiList.length; i++) {
      if (yangTangYaoZhiList[i].contains(
        timeZhi.substring(timeZhi.length - 1),
      )) {
        resultYuantangYaoIndex = i;
        break;
      }
    }
    return resultYuantangYaoIndex;
  }

  /// 获取爻位标签
  String _getYaoPositionLabel(int index) {
    switch (index) {
      case 0:
        return '初';
      case 1:
        return '二';
      case 2:
        return '三';
      case 3:
        return '四';
      case 4:
        return '五';
      case 5:
        return '上';
      default:
        return '未知';
    }
  }

  /// 步骤4.5：后天卦元堂装卦
  ///
  /// 返回: (houtianYuantangYaoIndex, houtianYuantangYaoLabel, houtianZhiList)
  ///
  /// 规则：与先天卦相同，根据时辰阴阳和后天卦的阴阳爻数装配地支
  (int, String, List<List<String>>) _houtianYuantangZhuanggua(
    YuanTangStrategyParams params,
    String houtianGua,
  ) {
    final timeGanzhi = params.fourZhu.timeGanzhi;

    // 判断时辰阴阳（与先天卦相同）
    const yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    const yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];

    final timeZhi = timeGanzhi.substring(timeGanzhi.length - 1);
    final timeYinYang = yuantangYangTimeSet.contains(timeZhi) ? "阳" : "阴";

    // 将后天卦转换为二进制列表
    final upperBinary = constants.guaBinaryMapper[houtianGua[0]]!;
    final lowerBinary = constants.guaBinaryMapper[houtianGua[1]]!;
    final allGuaBinary = [...upperBinary, ...lowerBinary];

    // 计算阳爻和阴爻数量
    final totalYangYao = allGuaBinary.where((x) => x == 1).length;
    final totalYinYao = allGuaBinary.where((x) => x == 0).length;

    // 根据时辰阴阳和爻数分类处理（复用现有装卦方法）
    List<List<String>> zhiList;
    if (timeYinYang == "阳") {
      // 阳时取阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
            allGuaBinary, List.from(yuantangYangTimeSet), totalYangYao, true);
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        zhiList = _zhuanggua45(
            allGuaBinary, List.from(yuantangYangTimeSet), totalYangYao, true);
      } else {
        zhiList = _zhuanggua6Yang(totalYangYao == 6,
            List.from(yuantangYangTimeSet), true, params.gender, params.birthAfterZhi);
      }
    } else {
      // 阴时取阴爻
      if (totalYinYao > 0 && totalYinYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
            allGuaBinary, List.from(yuantangYinTimeSet), totalYinYao, false);
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        zhiList = _zhuanggua45(
            allGuaBinary, List.from(yuantangYinTimeSet), totalYinYao, false);
      } else {
        zhiList = _zhuanggua6Yang(totalYinYao == 0,
            List.from(yuantangYinTimeSet), false, params.gender, params.birthAfterZhi);
      }
    }

    // 获取后天卦元堂爻索引
    final houtianYuantangYaoIndex = _getYuantangYaoIndex(timeGanzhi, zhiList);

    // 获取后天卦元堂爻位标签
    final houtianYuantangYaoLabel = _getYaoPositionLabel(houtianYuantangYaoIndex);

    return (houtianYuantangYaoIndex, houtianYuantangYaoLabel, zhiList);
  }

  /// 计算大运列表
  ///
  /// [guaName] 卦名（如"震坤"）
  /// [yuantangYaoIndex] 元堂爻索引（0-5）
  /// [zhiList] 六爻地支配置
  /// [startAge] 起始年龄
  ///
  /// 返回: `List<YuanTangDayunPeriod>`
  ///
  /// 规则：
  /// 1. 从元堂爻开始，按照 元堂→下一爻→...→上爻→初爻→... 的顺序循环6个爻位
  /// 2. 阳爻9年，阴爻6年
  /// 3. 年龄连续累加
  List<YuanTangDayunPeriod> _calculateDayun(
    String guaName,
    int yuantangYaoIndex,
    List<List<String>> zhiList,
    int startAge,
  ) {
    final dayunList = <YuanTangDayunPeriod>[];
    final binaryList = gua_utils.guaToBinaryList(guaName);

    var currentAge = startAge;

    // 从元堂爻开始，循环6个爻位
    // 顺序：元堂爻 → 下一爻(+1) → ... → 上爻 → 初爻 → ...
    for (var i = 0; i < 6; i++) {
      final yaoIndex = (yuantangYaoIndex + i) % 6;

      // 注意：binaryList是从上到下的顺序，需要转换
      // binaryList[0]=上卦第1爻, binaryList[5]=下卦第3爻
      // yaoIndex: 0=初爻, 5=上爻
      // 转换：binaryIndex = 5 - yaoIndex
      final binaryIndex = 5 - yaoIndex;
      final yinYang = binaryList[binaryIndex] == 1 ? '阳' : '阴';
      final years = yinYang == '阳' ? 9 : 6;
      final endAge = currentAge + years - 1;

      dayunList.add(YuanTangDayunPeriod(
        yaoPosition: yaoIndex,
        yaoLabel: _getYaoPositionLabel(yaoIndex),
        yinYang: yinYang,
        years: years,
        startAge: currentAge,
        endAge: endAge,
        diZhiList: zhiList[yaoIndex],
      ));

      currentAge = endAge + 1;
    }

    return dayunList;
  }

  /// 获取基础数来源
  BaseNumberSource _getSourceFromParams(YuanTangStrategyParams params) {
    // 元堂卦只有一个基础数，使用yearZhu作为来源标识
    return BaseNumberSource.yearZhu;
  }
}
