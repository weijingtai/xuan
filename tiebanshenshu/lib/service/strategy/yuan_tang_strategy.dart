/// 元堂卦取数法Strategy实现
///
/// 将元堂卦取数法算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info_ext.dart';

import '../../constant/constants.dart' as constants;
import '../../domain/models/base_number_model.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../domain/models/yuan_tang_model_result.dart';
import '../../utils/utils.dart' as gua_utils;
import '../../utils/tiao_wen_calculator.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 元堂卦取数法计算参数
///
/// 包含执行元堂卦取数法所需的所有参数
class YuanTangStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（TwentyFourJieQi.XIA_ZHI / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  /// 出生月份(1-12,从monthZhi提取)
  final int birthMonth;

  /// 月份类型（阴阳月判断规则）
  final YuanTangMonthType monthType;

  /// 历法类型（阳历/农历）
  final CalanderType calanderType;

  YuanTangStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    required this.birthMonth,
    this.monthType = YuanTangMonthType.monthYinYan,
    this.calanderType = CalanderType.solar,
  });

  /// 从地支提取月份数字
  ///
  /// 地支到月份的映射关系：
  /// 寅=1, 卯=2, 辰=3, 巳=4, 午=5, 未=6,
  /// 申=7, 酉=8, 戌=9, 亥=10, 子=11, 丑=12
  static int getMonthNumberFromZhi(String zhi) {
    const zhiToMonth = {
      '子': 11,
      '丑': 12,
      '寅': 1,
      '卯': 2,
      '辰': 3,
      '巳': 4,
      '午': 5,
      '未': 6,
      '申': 7,
      '酉': 8,
      '戌': 9,
      '亥': 10,
    };
    return zhiToMonth[zhi] ?? 1; // 默认返回1(寅月)
  }

  @override
  String get description =>
      "元堂卦取数法计算参数：四柱(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)，出生月($birthMonth月)，月份类型($monthType)，历法($calanderType)";
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
class YuanTangStrategy
    extends
        StandardCalculationStrategy<
          YuanTangStrategyParams,
          YuanTangModelResult
        > {
  @override
  String get name => "元堂卦取数法";

  @override
  String get description => "天干配数，地支两数相配，分阴阳配卦，以时辰阴阳判定元堂爻，爻变配卦，本互互取数";

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
  YuanTangModelResult calculate(YuanTangStrategyParams params) {
    try {
      // 步骤1：使用 YuanTangCalculator 计算元堂卦（使用params中的新参数）
      final yuanTangInfo = YuanTangCalculator().calculate(
        eightChars: params.eightChars,
        yearYinYang: params.eightChars.yearTianGan.yinYang,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthJieQi: params.birthAfterZhi,
        monthType: params.monthType,
        calanderType: params.calanderType,
        birthMonth: params.birthMonth,
      );

      // 步骤2：提取天地卦数据（保留计算过程展示）
      final tianDiGuaData = _extractTianDiGuaData(params);

      // 步骤3：计算条文编号
      final tiaowenNumbers = _calculateTiaowenNumbers(yuanTangInfo);

      // 步骤4：转换为 YuanTangBaseNumberModel
      final baseNumber = tiaowenNumbers.jiazeXiantian;
      final yuanTangModel = yuanTangInfo.toBaseNumberModel(
        tianDiGuaData: tianDiGuaData,
        tiaowenNumbers: tiaowenNumbers,
        baseNumber: baseNumber,
        name: "元堂卦取数法",
        description:
            "元堂卦取数法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}，月份类型:${params.monthType}，历法:${params.calanderType}）",
        source: _getSourceFromParams(params),
      );

      return YuanTangModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [yuanTangModel],
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'monthType': params.monthType,
          'calanderType': params.calanderType,
          'xiantianGua': yuanTangInfo.xianTanGua.gua,
          'houtianGua': yuanTangInfo.houTianGua.gua,
          'yuantangYaoIndex':
              yuanTangInfo.xianTanGua.yuanTangYao.indexAtYaoList,
        },
        yuanTangInfo: yuanTangInfo,
      );
    } catch (e, stackTrace) {
      // 错误情况下也需要创建一个空的YuanTangInfo
      final emptyYuanTangInfo = YuanTangCalculator().calculate(
        eightChars: params.eightChars,
        yearYinYang: params.eightChars.yearTianGan.yinYang,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthJieQi: params.birthAfterZhi,
        monthType: params.monthType,
        calanderType: params.calanderType,
        birthMonth: params.birthMonth,
      );

      return YuanTangModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "元堂卦计算失败: $e",
        yuanTangInfo: emptyYuanTangInfo,
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description,
        },
      );
    }
  }

  /// 提取天地卦数据（保留计算过程）
  ///
  /// 此方法保留原有的天地卦计算逻辑，用于在UI中展示计算过程
  TianDiGuaData _extractTianDiGuaData(YuanTangStrategyParams params) {
    // 重用YuanTangGuaHelper的天地卦计算（保持UI展示一致性）
    final (
      tianGua,
      diGua,
      ganNumList,
      zhiNumList,
      oddNumTotal,
      evenNumTotal,
      tianGuaNum,
      diGuaNum,
      usedThreeYuanWuGong,
    ) = YuanTangCalculator.generateTianDiGua(
      eightChars: params.eightChars,
      gender: params.gender,
      threeYuan: params.threeYuan,
    );

    return TianDiGuaData(
      ganNumList: ganNumList,
      zhiNumList: zhiNumList,
      oddNumTotal: oddNumTotal,
      evenNumTotal: evenNumTotal,
      tianGuaNum: tianGuaNum,
      diGuaNum: diGuaNum,
      tianGua: tianGua,
      diGua: diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong,
    );
  }

  /// 计算条文编号
  ///
  /// 根据先天卦和后天卦计算各种条文编号
  TiaowenNumbers _calculateTiaowenNumbers(YuanTangInfo yuanTangInfo) {
    final xiantianGua = yuanTangInfo.xianTanGua.gua;
    final houtianGua = yuanTangInfo.houTianGua.gua;
    final xiantianGuaHu = yuanTangInfo.xianTanGua.hu;
    final houtianGuaHu = yuanTangInfo.houTianGua.hu;

    // ignore: deprecated_member_use_from_same_package
    final jiazeXiantian = TiaowenCalculator.getTiaowenNumberByJiaZe(
      xiantianGua,
    );
    // ignore: deprecated_member_use_from_same_package
    final jiazeHoutian = TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);

    // ignore: deprecated_member_use_from_same_package
    final najiaTaixuanXiantian = TiaowenCalculator.getTiaowenNumberByTaixuan(
      xiantianGua,
    );
    // ignore: deprecated_member_use_from_same_package
    final najiaTaixuanHoutian = TiaowenCalculator.getTiaowenNumberByTaixuan(
      houtianGua,
    );

    final benhuXiantian = _calculateBenhuNumber(
      xiantianGua,
      xiantianGuaHu,
      isXiantian: true,
    );
    final benhuHoutian = _calculateBenhuNumber(
      houtianGua,
      houtianGuaHu,
      isXiantian: false,
    );

    final guahuListXiantian = [
      // ignore: deprecated_member_use_from_same_package
      ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
        benhuXiantian,
        [2, 4, 8, 16],
      ),
      // ignore: deprecated_member_use_from_same_package
      ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
        benhuXiantian,
      ),
    ];

    final guahuListHoutian = [
      // ignore: deprecated_member_use_from_same_package
      ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
        benhuHoutian,
        [2, 4, 8, 16],
      ),
      // ignore: deprecated_member_use_from_same_package
      ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
        benhuHoutian,
      ),
    ];

    return TiaowenNumbers(
      jiazeXiantian: jiazeXiantian,
      jiazeHoutian: jiazeHoutian,
      najiaTaixuanXiantian: najiaTaixuanXiantian,
      najiaTaixuanHoutian: najiaTaixuanHoutian,
      benhuXiantian: benhuXiantian,
      benhuHoutian: benhuHoutian,
      guahuListXiantian: guahuListXiantian,
      guahuListHoutian: guahuListHoutian,
    );
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
      return config.calculationList
          .map((offset) => baseNumber + offset)
          .toList();
    }
    // 降级处理：直接返回基础数
    return [baseNumber];
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  // ========== 流运系统公开API ==========

  /// 计算所有流年卦（先天卦6个大运 + 后天卦6个大运）
  ///
  /// 参数：
  /// - [model]: 元堂卦基础数模型（包含所有大运信息）
  /// - [birthYear]: 出生年份（公元纪年，如1990）
  ///
  /// 返回: 完整的流年卦列表（最多108个：12个大运 × 9年）
  ///
  /// 性能优化策略：
  /// - 一次性计算所有流年卦，避免重复计算
  /// - 计算时间 < 100ms
  List<YuanTangLiunianGua> calculateAllLiunianGua(
    YuanTangBaseNumberModel model,
    int birthYear,
  ) {
    final allLiunianList = <YuanTangLiunianGua>[];

    // 先天卦的6个大运
    for (final dayun in model.xiantianDayunList) {
      final liunianList = _calculateLiunianForDayun(
        dayun,
        model.xiantianGua,
        '先天卦',
        birthYear,
      );
      allLiunianList.addAll(liunianList);
    }

    // 后天卦的6个大运
    for (final dayun in model.houtianDayunList) {
      final liunianList = _calculateLiunianForDayun(
        dayun,
        model.houtianGua,
        '后天卦',
        birthYear,
      );
      allLiunianList.addAll(liunianList);
    }

    return allLiunianList;
  }

  /// 计算指定年龄的12个流月卦（按需计算）
  ///
  /// 参数：
  /// - [targetAge]: 目标年龄（虚岁）
  /// - [liunianGua]: 该年龄对应的流年卦象
  /// - [yuantangYaoIndex]: 元堂爻位置（0-5）
  ///
  /// 返回: 12个流月卦列表（1-12月，已排序）
  ///
  /// 性能优化策略：
  /// - 按需计算，仅当用户点击某个流年卦时才调用
  /// - 计算时间 < 50ms
  List<YuanTangLiuyueGua> calculateLiuyueForAge(
    int targetAge,
    Enum64Gua liunianGua,
    int yuantangYaoIndex,
  ) {
    return _calculateLiuyueForAge(targetAge, liunianGua, yuantangYaoIndex);
  }

  /// 计算本互条文编号
  ///
  /// [ben] 本卦
  /// [hu] 互卦
  /// [isXiantian] 是否为先天卦（true使用先天数，false使用后天数）
  int _calculateBenhuNumber(
    Enum64Gua ben,
    Enum64Gua hu, {
    required bool isXiantian,
  }) {
    final benUpon = ben.top;
    final benUnder = ben.bottom;
    final huUpon = hu.top;
    final huUnder = hu.bottom;

    final numberMapper = isXiantian
        ? constants.xianGuaNumberMapper
        : constants.houGuaNumberMapper;

    final benUponNum = numberMapper[benUpon]!;
    final benUnderNum = numberMapper[benUnder]!;
    final huUponNum = numberMapper[huUpon]!;
    final huUnderNum = numberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 爻变方法（用于流年卦和流月卦计算）
  ///
  /// 对指定爻位进行爻变（阴转阳，阳转阴）
  ///
  /// 参数：
  /// - [gua]: 卦象（如"震坤"）
  /// - [yaoIndex]: 爻位索引（0-5，0=初爻，5=上爻）
  ///
  /// 返回: 变换后的新卦象
  Enum64Gua _changeYao(Enum64Gua gua, int yaoIndex) {
    // 将卦转换为二进制列表
    final binaryList = gua_utils.guaToBinaryList(gua);

    // 转换索引：yaoIndex使用从下到上的索引(0=初爻,5=上爻)
    // 而binaryList使用从上到下的索引(0=上卦第1爻,5=下卦第3爻)
    // 转换公式：binaryIndex = 5 - yaoIndex
    final binaryIndex = 5 - yaoIndex;

    // 爻变：阴变阳(0→1)，阳变阴(1→0)
    binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

    // 重组卦象
    final upper = binaryList.sublist(0, 3).join();
    final lower = binaryList.sublist(3).join();
    final upperGua = constants.binaryStrGuaMapper[upper]!;
    final lowerGua = constants.binaryStrGuaMapper[lower]!;
    return Enum64Gua.getBy8Gua(
      Enum8Gua.fromValue(upperGua),
      Enum8Gua.fromValue(lowerGua),
    );
  }

  /// 判断年份是否为阳年（用于流年卦计算）
  ///
  /// 根据天干判断年份阴阳性：
  /// - 阳年：甲丙戊庚壬（天干索引：0, 2, 4, 6, 8）
  /// - 阴年：乙丁己辛癸（天干索引：1, 3, 5, 7, 9）
  ///
  /// 算法：
  /// - 公元4年为甲子年（天干索引0）
  /// - ganIndex = (year - 4) % 10
  /// - 索引为偶数(0,2,4,6,8)的是阳年
  ///
  /// 参数：
  /// - [year]: 公元纪年（如2024）
  ///
  /// 返回: true表示阳年，false表示阴年
  bool _isYangGanYear(int year) {
    // 公元4年为甲子年(天干索引0)
    final ganIndex = (year - 4) % 10;

    // 甲(0)、丙(2)、戊(4)、庚(6)、壬(8)为阳年
    return [0, 2, 4, 6, 8].contains(ganIndex);
  }

  /// 计算单个大运期的流年卦列表
  ///
  /// 根据大运爻的阴阳性分派到不同的计算方法
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象（先天卦或后天卦）
  /// - [guaSource]: 卦象来源标识（"先天卦" / "后天卦"）
  /// - [birthYear]: 出生年份（公元纪年）
  ///
  /// 返回: 该大运期的所有流年卦列表（阳爻9个，阴爻6个）
  List<YuanTangLiunianGua> _calculateLiunianForDayun(
    YuanTangDayunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    int birthYear,
  ) {
    if (dayun.yinYang == '阳') {
      return _calculateLiunianForYangYaoDayun(
        dayun,
        baseGua,
        guaSource,
        birthYear,
      );
    } else {
      return _calculateLiunianForYinYaoDayun(
        dayun,
        baseGua,
        guaSource,
        birthYear,
      );
    }
  }

  /// 计算阳爻大运的流年卦（9年）
  ///
  /// 阳爻大运规则：
  /// 1. 判断大运初年的阴阳（出生年 + 大运起始年龄 - 1）
  /// 2. 如果初年为阳年：第1年直接使用基础卦，不变换
  /// 3. 如果初年为阴年：第1年先变换大运爻
  /// 4. 第2-9年：按照 (大运爻-2) → 大运爻 → (大运爻+1) → (大运爻+2) 循环变换
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象
  /// - [guaSource]: 卦象来源标识
  /// - [birthYear]: 出生年份
  ///
  /// 返回: 9个流年卦
  List<YuanTangLiunianGua> _calculateLiunianForYangYaoDayun(
    YuanTangDayunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    int birthYear,
  ) {
    final liunianList = <YuanTangLiunianGua>[];

    // 判断大运初年的阴阳
    final dayunStartYear = birthYear + dayun.startAge - 1;
    final isYangStartYear = _isYangGanYear(dayunStartYear);

    Enum64Gua currentGua = baseGua;
    int? firstChangedYaoIndex;

    // 第1年
    if (!isYangStartYear) {
      // 初年为阴年: 先变换大运爻
      currentGua = _changeYao(baseGua, dayun.yaoPosition);
      firstChangedYaoIndex = dayun.yaoPosition;
    }

    liunianList.add(
      YuanTangLiunianGua(
        age: dayun.startAge,
        yearIndex: 0,
        gua: currentGua,
        guaSource: guaSource,
        dayunPeriod: dayun,
        changedYaoIndex: firstChangedYaoIndex ?? -1,
        previousGua: null,
      ),
    );

    // 第2-9年: 按顺序变换爻位
    final changeSequence = [
      (dayun.yaoPosition - 2 + 6) % 6, // 大运爻-2
      dayun.yaoPosition, // 大运爻
      (dayun.yaoPosition + 1) % 6, // 大运爻+1
      (dayun.yaoPosition + 2) % 6, // 大运爻+2
    ];

    for (int i = 1; i < 9; i++) {
      final previousGua = currentGua;
      final yaoToChange = changeSequence[(i - 1) % 4];
      currentGua = _changeYao(currentGua, yaoToChange);

      liunianList.add(
        YuanTangLiunianGua(
          age: dayun.startAge + i,
          yearIndex: i,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYaoIndex: yaoToChange,
          previousGua: previousGua,
        ),
      );
    }

    return liunianList;
  }

  /// 计算阴爻大运的流年卦（6年）
  ///
  /// 阴爻大运规则：
  /// 1. 不论大运初年是阴年还是阳年
  /// 2. 第1年：先变换大运爻
  /// 3. 第2-6年：依次变换大运爻的下一爻、下两爻...
  /// 4. 变换顺序：大运爻 → (大运爻+1) → (大运爻+2) → (大运爻+3) → (大运爻+4) → (大运爻+5)
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象
  /// - [guaSource]: 卦象来源标识
  /// - [birthYear]: 出生年份
  ///
  /// 返回: 6个流年卦
  List<YuanTangLiunianGua> _calculateLiunianForYinYaoDayun(
    YuanTangDayunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    int birthYear,
  ) {
    final liunianList = <YuanTangLiunianGua>[];

    // 第1年: 先变换大运爻(不论初年阴阳)
    Enum64Gua currentGua = _changeYao(baseGua, dayun.yaoPosition);

    liunianList.add(
      YuanTangLiunianGua(
        age: dayun.startAge,
        yearIndex: 0,
        gua: currentGua,
        guaSource: guaSource,
        dayunPeriod: dayun,
        changedYaoIndex: dayun.yaoPosition,
        previousGua: null,
      ),
    );

    // 第2-6年: 逐爻变换
    for (int i = 1; i < 6; i++) {
      final previousGua = currentGua;
      final yaoToChange = (dayun.yaoPosition + i) % 6;
      currentGua = _changeYao(currentGua, yaoToChange);

      liunianList.add(
        YuanTangLiunianGua(
          age: dayun.startAge + i,
          yearIndex: i,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYaoIndex: yaoToChange,
          previousGua: previousGua,
        ),
      );
    }

    return liunianList;
  }

  /// 获取应爻位置（用于流月卦计算）
  ///
  /// 传统六爻术数中的应爻对应关系：
  /// - 初爻(0) ←→ 四爻(3)
  /// - 二爻(1) ←→ 五爻(4)
  /// - 三爻(2) ←→ 上爻(5)
  ///
  /// 参数：
  /// - [yaoIndex]: 爻位索引（0-5）
  ///
  /// 返回: 对应的应爻索引（0-5）
  int _getYingYaoIndex(int yaoIndex) {
    return (yaoIndex + 3) % 6;
  }

  /// 计算指定年龄的12个流月卦
  ///
  /// 流月卦计算规则：
  /// 1. 阳月卦(1,3,5,7,9,11月): 从正月卦开始, 逐月变换下一爻
  /// 2. 阴月卦(2,4,6,8,10,12月): 取对应阳月卦, 变换其"应爻"
  /// 3. 正月卦起法: 变换(元堂爻 - 1)的爻位
  ///
  /// 参数：
  /// - [targetAge]: 目标年龄（虚岁）
  /// - [liunianGua]: 该年的流年卦
  /// - [yuantangYaoIndex]: 元堂爻位置（0-5）
  ///
  /// 返回: 12个流月卦列表（已按月份排序）
  List<YuanTangLiuyueGua> _calculateLiuyueForAge(
    int targetAge,
    Enum64Gua liunianGua,
    int yuantangYaoIndex,
  ) {
    final liuyueList = <YuanTangLiuyueGua>[];

    // 步骤1: 计算正月卦(变换元堂爻前一爻)
    final zhengYueYaoIndex = (yuantangYaoIndex - 1 + 6) % 6;
    Enum64Gua zhengYueGua = _changeYao(liunianGua, zhengYueYaoIndex);

    liuyueList.add(
      YuanTangLiuyueGua(
        month: 1,
        isYangMonth: true,
        gua: zhengYueGua,
        age: targetAge,
        changedYaoIndex: zhengYueYaoIndex,
        sourceGua: liunianGua,
        yingYaoIndex: null,
      ),
    );

    // 步骤2: 计算其他阳月卦(3,5,7,9,11月)
    Enum64Gua currentYangGua = zhengYueGua;
    int lastChangedYaoIndex = zhengYueYaoIndex;

    for (int month in [3, 5, 7, 9, 11]) {
      final previousGua = currentYangGua;
      // 逐月向前变换(变换上一次变换爻的下一爻)
      final nextYaoIndex = (lastChangedYaoIndex + 1) % 6;
      currentYangGua = _changeYao(currentYangGua, nextYaoIndex);

      liuyueList.add(
        YuanTangLiuyueGua(
          month: month,
          isYangMonth: true,
          gua: currentYangGua,
          age: targetAge,
          changedYaoIndex: nextYaoIndex,
          sourceGua: previousGua,
          yingYaoIndex: null,
        ),
      );

      lastChangedYaoIndex = nextYaoIndex;
    }

    // 步骤3: 计算阴月卦(2,4,6,8,10,12月)
    final yangMonths = [1, 3, 5, 7, 9, 11];
    final yinMonths = [2, 4, 6, 8, 10, 12];

    for (int i = 0; i < 6; i++) {
      final yangMonth = yangMonths[i];
      final yinMonth = yinMonths[i];

      // 找到对应阳月卦
      final yangGua = liuyueList.firstWhere((g) => g.month == yangMonth).gua;

      // 计算该阳月的变爻位置
      final yangYaoIndex = i == 0
          ? zhengYueYaoIndex
          : (zhengYueYaoIndex + i) % 6;

      // 变换应爻
      final yingYaoIndex = _getYingYaoIndex(yangYaoIndex);
      final yinGua = _changeYao(yangGua, yingYaoIndex);

      liuyueList.add(
        YuanTangLiuyueGua(
          month: yinMonth,
          isYangMonth: false,
          gua: yinGua,
          age: targetAge,
          changedYaoIndex: yingYaoIndex,
          sourceGua: yangGua,
          yingYaoIndex: yingYaoIndex,
        ),
      );
    }

    // 按月份排序
    liuyueList.sort((a, b) => a.month.compareTo(b.month));

    return liuyueList;
  }

  /// 获取基础数来源
  BaseNumberSource _getSourceFromParams(YuanTangStrategyParams params) {
    // 元堂卦只有一个基础数，使用yearZhu作为来源标识
    return BaseNumberSource.yearZhu;
  }
}
