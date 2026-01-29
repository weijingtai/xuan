/// 先后天卦六爻干支和数法Strategy实现(重构版)
///
/// 继承自 YuanTangBasedStrategy，复用元堂卦计算逻辑
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info_ext.dart';

import '../../constant/constants.dart' as constants;
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/liu_yao_gan_zhi_he_base_number_model.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'base/yuan_tang_based_strategy.dart';
import 'base/yuan_tang_derived_params.dart';
import 'base_calculation_strategy.dart';

/// 先后天卦六爻干支和数法计算参数
///
/// 继承自 YuanTangDerivedParams，支持两种计算模式：
/// 1. 从头计算：提供 EightChars + Gender + YuanYunOrder + TwentyFourJieQi
/// 2. 复用计算：提供已计算好的 YuanTangInfo
class LiuYaoGanZhiHeStrategyParams extends YuanTangDerivedParams {
  @override
  final EightChars eightChars;

  @override
  final Gender gender;

  @override
  final YuanYunOrder threeYuan;

  @override
  final TwentyFourJieQi birthAfterZhi;

  @override
  final YuanTangMonthType monthType;

  @override
  final CalanderType calanderType;

  @override
  YuanTangInfo? yuanTangInfo;

  LiuYaoGanZhiHeStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    this.monthType = YuanTangMonthType.monthYinYan,
    this.calanderType = CalanderType.solar,
    this.yuanTangInfo,
  });

  /// 从 YuanTangInfo 直接创建参数（复用模式）
  factory LiuYaoGanZhiHeStrategyParams.fromYuanTangInfo(
    YuanTangInfo yuanTangInfo, {
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    return LiuYaoGanZhiHeStrategyParams(
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      yuanTangInfo: yuanTangInfo,
    );
  }
}

/// 先后天卦六爻干支和数法计算策略(重构版)
///
/// 继承自 YuanTangBasedStrategy，消除了重复的元堂卦计算代码
///
/// 算法原理：
/// 1. 获取 YuanTangInfo（懒加载或复用）
/// 2. 从 YuanTangInfo 提取先天卦和后天卦
/// 3. 对先天卦进行六爻纳甲（天干+地支）
/// 4. 纳甲的天干、地支配上太玄数，每爻的干支太玄数相加（如果和==10则不计）
/// 5. 上三爻干支相加的数总和，下三爻干支相加的数总和。前者作为千百位，后者作为十位个位，组成一个四位条文数
/// 6. 这个数递增减96四次，得到8个数
/// 7. 后天卦重复步骤3-6
///
/// 算法特点：
/// - 复用 YuanTangInfo 计算结果，避免重复计算
/// - 先天卦和后天卦分别计算六爻干支和数
/// - 使用六爻纳甲规则配置天干地支
class LiuYaoGanZhiHeStrategy extends YuanTangBasedStrategy<
    LiuYaoGanZhiHeStrategyParams, BaseNumberModelResult> {
  @override
  String get name => "先后天卦六爻干支和数法";

  @override
  String get description =>
      "根据元堂卦法取先天卦和后天卦，对两卦分别进行六爻纳甲装配（天干+地支），计算六爻干支太玄数之和（和为10则不计），上三爻为千百位，下三爻为十位个位，组成四位条文数";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 根据元堂卦法取先天卦和后天卦",
    "3. 先天卦六爻纳甲配置：为六爻配置天干和地支",
    "4. 先天卦干支和数计算：每爻的干支太玄数相加（和为10不计），上三爻为千百位，下三爻为十位个位",
    "5. 后天卦六爻纳甲配置：为六爻配置天干和地支",
    "6. 后天卦干支和数计算：每爻的干支太玄数相加（和为10不计），上三爻为千百位，下三爻为十位个位",
    "7. 条文扩展：先天卦和后天卦基础数分别递增减96四次，各得到8个条文编号",
  ];

  @override
  String get school => "先后天卦六爻干支和数流派";

  @override
  BaseNumberModelResult calculateWithYuanTangInfo(
    LiuYaoGanZhiHeStrategyParams params,
    YuanTangInfo yuanTangInfo,
  ) {
    // 步骤1：从 YuanTangInfo 中提取天地卦数据
    if (yuanTangInfo.tianDiGuaData == null) {
      throw StateError(
        '天地卦数据不存在，请确保 YuanTangCalculator.calculate() 正确返回了 tianDiGuaData',
      );
    }

    final tianDiGuaDataSource = yuanTangInfo.tianDiGuaData!;

    // 步骤2：从 YuanTangInfo 提取先天卦和后天卦
    final xiantianGua = getXiantianGua(yuanTangInfo);
    final houtianGua = getHoutianGua(yuanTangInfo);

    // 步骤3-4：先天卦六爻纳甲和干支和数计算
    final (
      xiantianBaseNumber,
      xiantianYaoTianGanList,
      xiantianYaoDiZhiList,
      xiantianYaoSumList,
      xiantianUpperSum,
      xiantianLowerSum,
    ) = _calculateLiuYaoSum(
      xiantianGua,
    );

    // 步骤5-6：后天卦六爻纳甲和干支和数计算
    final (
      houtianBaseNumber,
      houtianYaoTianGanList,
      houtianYaoDiZhiList,
      houtianYaoSumList,
      houtianUpperSum,
      houtianLowerSum,
    ) = _calculateLiuYaoSum(
      houtianGua,
    );

    // 步骤7：提取后天数
    final (houtianUpperGuaNumber, houtianLowerGuaNumber) = getHoutianNumbers(yuanTangInfo);

    // 步骤8：提取先天数
    final xiantianUpperGuaNumber = constants.xianTianGuaNumberMapper[yuanTangInfo.xianTanGua.gua.top.name]!;
    final xiantianLowerGuaNumber = constants.xianTianGuaNumberMapper[yuanTangInfo.xianTanGua.gua.bottom.name]!;

    // 创建数据模型
    final model = LiuYaoGanZhiHeBaseNumberModel.create(
      baseNumber: xiantianBaseNumber, // 使用先天卦基础数作为主基础数（也可以选择后天卦）
      name: "先后天卦六爻干支和数法",
      description:
          "先后天卦六爻干支和数法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
      source: BaseNumberSource.yearZhu, // 使用yearZhu作为来源标识
      eightChars: params.eightChars,
      gender: params.gender,
      threeYuan: params.threeYuan,
      birthAfterZhi: params.birthAfterZhi,
      // 天地卦字段（从 tianDiGuaDataSource 提取）
      ganNumList: tianDiGuaDataSource.ganNumList,
      zhiNumList: tianDiGuaDataSource.zhiNumList,
      oddNumTotal: tianDiGuaDataSource.oddNumTotal,
      evenNumTotal: tianDiGuaDataSource.evenNumTotal,
      tianGuaNum: tianDiGuaDataSource.tianGuaNum,
      diGuaNum: tianDiGuaDataSource.diGuaNum,
      tianGua: tianDiGuaDataSource.tianGua,
      diGua: tianDiGuaDataSource.diGua,
      usedThreeYuanWuGong: tianDiGuaDataSource.usedThreeYuanWuGong,
      // 先后天卦字段
      yearYinYang: yuanTangInfo.yearYinYang,
      upperGua: yuanTangInfo.xianTanGua.gua.top,
      lowerGua: yuanTangInfo.xianTanGua.gua.bottom,
      xiantianGua: xiantianGua,
      houtianGua: houtianGua,
      xiantianUpperGuaNumber: xiantianUpperGuaNumber,
      xiantianLowerGuaNumber: xiantianLowerGuaNumber,
      houtianUpperGuaNumber: houtianUpperGuaNumber,
      houtianLowerGuaNumber: houtianLowerGuaNumber,
      // 先天卦六爻纳甲字段
      xiantianYaoTianGanList: xiantianYaoTianGanList,
      xiantianYaoDiZhiList: xiantianYaoDiZhiList,
      xiantianYaoSumList: xiantianYaoSumList,
      xiantianUpperSum: xiantianUpperSum,
      xiantianLowerSum: xiantianLowerSum,
      xiantianBaseNumber: xiantianBaseNumber,
      // 后天卦六爻纳甲字段
      houtianYaoTianGanList: houtianYaoTianGanList,
      houtianYaoDiZhiList: houtianYaoDiZhiList,
      houtianYaoSumList: houtianYaoSumList,
      houtianUpperSum: houtianUpperSum,
      houtianLowerSum: houtianLowerSum,
      houtianBaseNumber: houtianBaseNumber,
    );

    return BaseNumberModelResult.success(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      baseNumbers: [model],
      sourceData: {
        'eightChars': params.eightChars.toString(),
        'gender': params.gender,
        'threeYuan': params.threeYuan,
        'birthAfterZhi': params.birthAfterZhi,
        'xiantianGua': xiantianGua,
        'houtianGua': houtianGua,
        'xiantianBaseNumber': xiantianBaseNumber,
        'houtianBaseNumber': houtianBaseNumber,
        'calculationMode': getCalculationModeDescription(params),
      },
    );
  }

  @override
  BaseNumberModelResult handleError(
    LiuYaoGanZhiHeStrategyParams params,
    Object error,
    StackTrace stackTrace,
  ) {
    return BaseNumberModelResult.error(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      errorMessage: "先后天卦六爻干支和数法计算失败: $error",
      sourceData: {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'params': params.description,
      },
    );
  }

  /// 为六爻配置天干（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoTianGan
  /// - 外卦（上卦）使用 outerGuaYaoTianGan
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个天干，从初爻到上爻)
  List<String> _najiaTianGan(Enum64Gua guaName) {
    // 拆分成上下卦
    // 转换为Enum8Gua
    final Enum8Gua upperGua = guaName.top;
    final Enum8Gua lowerGua = guaName.bottom;

    // 获取纳甲天干配置
    final List<TianGan> lowerTianGanList =
        constants.innerGuaYaoTianGan[lowerGua]!; // 内卦（下卦）
    final List<TianGan> upperTianGanList =
        constants.outerGuaYaoTianGan[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var tianGan in lowerTianGanList) {
      result.add(tianGan.name);
    }
    for (var tianGan in upperTianGanList) {
      result.add(tianGan.name);
    }

    return result;
  }

  /// 为六爻配置地支（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoDiZhi
  /// - 外卦（上卦）使用 outerGuaYaoDiZhi
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个地支，从初爻到上爻)
  List<String> _najiaDiZhi(Enum64Gua guaName) {
    // 拆分成上下卦
    // 转换为Enum8Gua
    final Enum8Gua upperGua = guaName.top;
    final Enum8Gua lowerGua = guaName.bottom;

    // 获取纳甲地支配置
    final List<DiZhi> lowerDiZhiList =
        constants.innerGuaYaoDiZhi[lowerGua]!; // 内卦（下卦）
    final List<DiZhi> upperDiZhiList =
        constants.outerGuaYaoDiZhi[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var diZhi in lowerDiZhiList) {
      result.add(diZhi.name);
    }
    for (var diZhi in upperDiZhiList) {
      result.add(diZhi.name);
    }

    return result;
  }

  /// 获取天干或地支的太玄数
  ///
  /// [ganOrZhi] 天干或地支字符串
  /// 返回: int (太玄数 1-10，但实际映射范围是4-9)
  int _getTaixuanNumber(String ganOrZhi) {
    // 优先尝试天干映射
    if (constants.taixuanGanNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanGanNumberMapper[ganOrZhi]!;
    }

    // 尝试地支映射
    if (constants.taixuanZhiNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanZhiNumberMapper[ganOrZhi]!;
    }

    // 如果都不存在，抛出异常
    throw ArgumentError('无法找到 $ganOrZhi 对应的太玄数');
  }

  /// 计算单爻干支太玄数之和
  ///
  /// 规则：天干太玄数 + 地支太玄数，如果和==10则返回0（不计）
  ///
  /// [tianGan] 天干字符串
  /// [diZhi] 地支字符串
  /// 返回: int (如果和==10则返回0，否则返回和)
  int _calculateYaoGanZhiSum(String tianGan, String diZhi) {
    final ganNum = _getTaixuanNumber(tianGan);
    final zhiNum = _getTaixuanNumber(diZhi);
    final sum = ganNum + zhiNum;

    // 和为10不计
    if (sum == 10) {
      return 0;
    }

    return sum;
  }

  /// 计算六爻干支和数，组成四位数
  ///
  /// 步骤：
  /// 1. 调用 _najiaTianGan() 获取六个天干
  /// 2. 调用 _najiaDiZhi() 获取六个地支
  /// 3. 对每一爻调用 _calculateYaoGanZhiSum()
  /// 4. 上三爻（4-6爻，即索引3-5）和数作为千百位
  /// 5. 下三爻（1-3爻，即索引0-2）和数作为十位个位
  /// 6. 组合成四位基础数
  ///
  /// [guaName] 卦名（如"震坤"）
  /// 返回: (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum)
  (int, List<String>, List<String>, List<int>, int, int) _calculateLiuYaoSum(
    Enum64Gua guaName,
  ) {
    // 步骤1-2：获取六爻纳甲配置
    final tianGanList = _najiaTianGan(guaName);
    final diZhiList = _najiaDiZhi(guaName);

    // 步骤3：计算每一爻的干支和数
    final yaoSumList = <int>[];
    for (var i = 0; i < 6; i++) {
      final sum = _calculateYaoGanZhiSum(tianGanList[i], diZhiList[i]);
      yaoSumList.add(sum);
    }

    // 步骤4：下三爻（初、二、三爻，索引0-2）和数作为十位个位
    final lowerSum = yaoSumList[0] + yaoSumList[1] + yaoSumList[2];

    // 步骤5：上三爻（四、五、上爻，索引3-5）和数作为千百位
    final upperSum = yaoSumList[3] + yaoSumList[4] + yaoSumList[5];

    // 步骤6：组合成四位基础数
    // 千百位（上三爻） + 十位个位（下三爻）
    final baseNumber = upperSum * 100 + lowerSum;

    return (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum);
  }

  /// 获取默认的条文计算配置
  ///
  /// 先天卦和后天卦都使用递增减96四次：[0, 96, 192, 288, 384, -96, -192, -288]
  /// 每个卦生成8个条文编号
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "递增减96四次",
      description: "先天卦/后天卦基础数分别递增减96四次，各得到8个条文编号",
      customList: [0, 96, 192, 288, 384, -96, -192, -288],
      withSub: false, // 已经包含了负数，不需要额外的减法
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    LiuYaoGanZhiHeStrategyParams params,
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
}
