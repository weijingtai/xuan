/// 八卦滚法Strategy实现
///
/// 实现八卦滚法的完整计算流程
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../domain/models/ba_gua_gun_base_number_model.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../utils/tiao_wen_number_calculator.dart';
import '../../utils/utils.dart';
import 'base/multi_gua_calculator_base.dart';
import 'base_calculation_strategy.dart';
import '../../domain/models/tiao_wen_source_info.dart';

/// 八卦滚法计算参数
class BaGuaGunStrategyParams extends BaseCalculationParams {
  final EightChars eightChars;
  final Gender gender;
  final YuanYunOrder threeYuan;

  BaGuaGunStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
  });

  @override
  String get description =>
      "八卦滚法计算（性别:$gender，三元:$threeYuan）";

  Map<String, dynamic> toMap() {
    return {
      'eightChars': eightChars.toString(),
      'gender': gender,
      'threeYuan': threeYuan,
    };
  }
}

/// 八卦滚法计算器实现
class BaGuaGunCalculator extends MultiGuaCalculatorBase {
  BaGuaGunCalculator()
      : super(
          // 偶数配置：只保留个位，转先天卦
          evenNumberConfig: const NumberConfig(
            numberOperationStrategy: NumberOperationStrategy.onlyDigit,
            factorNumber: 8,
            guaConversionStrategy: NumberConversionGuaStrategy.toXianTian,
            withLength: false,
          ),
          // 奇数配置：只保留个位，转先天卦
          oddNumberConfig: const NumberConfig(
            numberOperationStrategy: NumberOperationStrategy.onlyDigit,
            factorNumber: 8,
            guaConversionStrategy: NumberConversionGuaStrategy.toXianTian,
            withLength: false,
          ),
          // 天干使用太玄数
          ganToNumberStrategy: GanZhiToNumberStrategy.taiXuanNumber,
          // 地支使用太玄数
          zhiToNumberStrategy: GanZhiToNumberStrategy.taiXuanNumber,
          // 奇数为上卦
          isOddAsTopGua: true,
        );

  @override
  GuaGenerationConfig getGuaGenerationConfig() {
    return const GuaGenerationConfig(
      // 第一卦：基本卦本身
      firstGuaType: "本",
      // 第二卦：第一卦变爻后上下交换
      secondGuaStrategy: GuaStrategy.forSecondGua(
        needExchange: true,
        needCuoGua: false,
        guaType: "本",
      ),
      // 第三卦：第二卦的互卦
      thirdGuaStrategy: GuaStrategy.forThirdGua(
        needExchange: false,
        needCuoGua: false,
        guaType: "互",
        baseGuaSource: "second",
      ),
      // 第四卦：第三卦的错卦
      fourthGuaStrategy: GuaStrategy.forFourthGua(
        needExchange: false,
        needCuoGua: true,
        guaType: "本",
        baseGuaSource: "third",
      ),
    );
  }

  /// 生成后四卦
  ///
  /// 后四卦的生成规则：
  /// - 第五卦：第四卦变爻后上下交换
  /// - 第六卦：第五卦的互卦
  /// - 第七卦：第六卦的错卦
  /// - 第八卦：第七卦变爻后上下交换
  List<Enum64Gua> generateLastFourGua(
    Enum64Gua fourthGua,
    int variationBase,
  ) {
    final result = <Enum64Gua>[];
    final guaMap = <String, Enum64Gua>{"fourth": fourthGua};

    // 第五卦：第四卦变爻后上下交换
    final fifthGuaStrategy = const GuaStrategy(
      needExchange: true,
      needCuoGua: false,
      guaType: "本",
      baseGuaSource: "fourth",
      needVariation: true,
    );
    final fifthGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      fifthGuaStrategy,
    );
    result.add(fifthGua);
    guaMap["fifth"] = fifthGua;

    // 第六卦：第五卦的互卦
    final sixthGuaStrategy = const GuaStrategy(
      needExchange: false,
      needCuoGua: false,
      guaType: "互",
      baseGuaSource: "fifth",
      needVariation: false,
    );
    final sixthGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      sixthGuaStrategy,
    );
    result.add(sixthGua);
    guaMap["sixth"] = sixthGua;

    // 第七卦：第六卦的错卦
    final seventhGuaStrategy = const GuaStrategy(
      needExchange: false,
      needCuoGua: true,
      guaType: "本",
      baseGuaSource: "sixth",
      needVariation: false,
    );
    final seventhGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      seventhGuaStrategy,
    );
    result.add(seventhGua);
    guaMap["seventh"] = seventhGua;

    // 第八卦：第七卦变爻后上下交换
    final eighthGuaStrategy = const GuaStrategy(
      needExchange: true,
      needCuoGua: false,
      guaType: "本",
      baseGuaSource: "seventh",
      needVariation: true,
    );
    final eighthGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      eighthGuaStrategy,
    );
    result.add(eighthGua);

    return result;
  }

  /// 根据统一策略生成卦象（复用基类方法）
  Enum64Gua _generateGuaWithStrategy(
    Map<String, Enum64Gua> guaMap,
    int variationBase,
    GuaStrategy strategy,
  ) {
    // 获取基础卦
    final baseGua = guaMap[strategy.baseGuaSource];
    if (baseGua == null) {
      throw ArgumentError('无效的基础卦来源：${strategy.baseGuaSource}');
    }

    Enum64Gua resultGua = baseGua;

    // 如果需要变爻
    if (strategy.needVariation) {
      final bianYaoNum = variationBase % 9;
      final bianYaoPositions = getChangePositions(bianYaoNum);

      final guaBinary = guaToBinaryList(resultGua);
      final changedBinary = yaoBianGua(guaBinary, bianYaoPositions);

      // 将二进制列表转换为二进制字符串
      final binaryStr = changedBinary.join('');

      // 转换回Enum64Gua
      resultGua = Enum64Gua.fromBinaryStr(binaryStr);
    }

    // 根据策略处理
    if (strategy.needExchange) {
      // 上下交换
      resultGua = Enum64Gua.getBy8Gua(resultGua.bottom, resultGua.top);
    }

    if (strategy.needCuoGua) {
      resultGua = guaToCuoGua(resultGua);
    }

    // 根据卦象类型处理
    switch (strategy.guaType) {
      case "互":
        resultGua = guaToHuGua(resultGua);
        break;
      case "错":
        resultGua = guaToCuoGua(resultGua);
        break;
      case "本":
        // 保持不变
        break;
      default:
        throw ArgumentError('不支持的卦象类型：${strategy.guaType}');
    }

    return resultGua;
  }
}

/// 八卦滚法计算策略
class BaGuaGunStrategy
    extends BaseCalculationStrategy<BaGuaGunStrategyParams, BaseNumberModelResult> {
  final _calculator = BaGuaGunCalculator();
  final _tiaoWenCalculator = const TiaoWenNumberCalculator();

  @override
  String get name => "八卦滚法";

  @override
  String get description => "八卦滚法完整计算流程，生成八个卦象并计算每卦的三基数和条文";

  @override
  List<String> get detailSteps => [
        "1. 计算基本卦和基本数",
        "2. 计算变爻基数",
        "3. 生成前四卦（本→变爻交换→互→错）",
        "4. 生成后四卦（变爻交换→互→错→变爻交换）",
        "5. 计算每卦的三基数（先天顺序数、先天洛书数、后天洛书数）",
        "6. 计算每卦的六个条文数（a*100+b, a*100+c, b*100+a, b*100+c, c*100+a, c*100+b）",
      ];

  @override
  String get school => "八卦滚法流派";

  @override
  StrategyCategory get category => StrategyCategory.standard;

  BaseNumberModelResult calculate(BaGuaGunStrategyParams params) {
    try {
      // 步骤1：生成前四卦
      final firstFourResult = _calculator.generateFirstFourGua(
        params.eightChars,
        params.threeYuan,
        params.gender,
      );

      // 步骤2：生成后四卦
      final lastFourGuaList = _calculator.generateLastFourGua(
        firstFourResult.fourGuaList[3], // 第四卦
        firstFourResult.variationBase,
      );

      // 步骤3：计算每卦的三基数
      final allGuaList = [
        ...firstFourResult.fourGuaList,
        ...lastFourGuaList,
      ];
      final guaThreeNumbersList = <GuaThreeNumbers>[];
      for (final gua in allGuaList) {
        final (a, b, c) = _tiaoWenCalculator.getGuaThreeNumbers(gua);
        guaThreeNumbersList.add(GuaThreeNumbers(
          gua: gua,
          xiantianShunxu: a,
          xiantianLuoshu: b,
          houtianLuoshu: c,
        ));
      }

      // 步骤4：计算最终条文列表
      final finalTiaowenList =
          _tiaoWenCalculator.calculateEightGuaTiaowenNumbers(allGuaList);

      // 新增：生成条文来源信息列表（48条）
      final tiaoWenSourceList = <TiaoWenSourceInfo>[];
      for (int i = 0; i < allGuaList.length; i++) {
        final gua = allGuaList[i];
        final three = guaThreeNumbersList[i];
        final perGuaTiaoWen = _tiaoWenCalculator.calculateGuaTiaowenList(
          three.xiantianShunxu,
          three.xiantianLuoshu,
          three.houtianLuoshu,
        );
        const formulaTypes = [
          'a*100+b',
          'a*100+c',
          'b*100+a',
          'b*100+c',
          'c*100+a',
          'c*100+b',
        ];
        for (int j = 0; j < perGuaTiaoWen.length; j++) {
          final tn = perGuaTiaoWen[j];
          tiaoWenSourceList.add(TiaoWenSourceInfo.fromThreeNumbers(
            tiaoWenNumber: tn,
            sourceGua: gua,
            guaIndex: i + 1,
            a: three.xiantianShunxu,
            b: three.xiantianLuoshu,
            c: three.houtianLuoshu,
            formulaType: formulaTypes[j],
          ));
        }
      }

      // 步骤5：创建 BaGuaGunBaseNumberModel
      final model = BaGuaGunBaseNumberModel(
        baseNumber: firstFourResult.basicNumber,
        name: name,
        description:
            "八卦滚法计算（性别:${params.gender}，三元:${params.threeYuan}）",
        source: BaseNumberSource.yearZhu,
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        basicGua: firstFourResult.basicGua,
        basicNumber: firstFourResult.basicNumber,
        variationBase: firstFourResult.variationBase,
        firstFourGuaList: firstFourResult.fourGuaList,
        lastFourGuaList: lastFourGuaList,
        guaThreeNumbersList: guaThreeNumbersList,
        finalTiaowenList: finalTiaowenList,
        tiaoWenSourceList: tiaoWenSourceList,
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
          'basicGua': firstFourResult.basicGua,
          'basicNumber': firstFourResult.basicNumber,
          'variationBase': firstFourResult.variationBase,
          'eightGuaList': allGuaList.map((g) => g.toString()).toList(),
          'guaThreeNumbersList':
              guaThreeNumbersList.map((g) => g.toMap()).toList(),
          'tiaowenCount': finalTiaowenList.length,
        },
      );
    } catch (e, stackTrace) {
      return handleError(params, e, stackTrace);
    }
  }

  BaseNumberModelResult handleError(
    BaGuaGunStrategyParams params,
    Object error,
    StackTrace stackTrace,
  ) {
    return BaseNumberModelResult.error(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      errorMessage: "八卦滚法计算失败: $error",
      sourceData: {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'params': params.description,
      },
    );
  }

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    // 八卦滚法使用三基数组合计算，不使用简单配置
    return GenericTiaoWenCalculationConfig.customList(
      name: "八卦滚法条文计算",
      description: "使用三基数（a,b,c）组合计算",
      customList: [0],
      withSub: false,
    );
  }

  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    BaGuaGunStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 八卦滚法需要完整计算流程，不支持单独的条文扩展
    throw UnsupportedError('八卦滚法需要使用 calculate 方法进行完整计算');
  }

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      "使用三基数（先天顺序数、先天洛书数、后天洛书数）组合计算，每卦生成6个条文，共48个条文";
}
