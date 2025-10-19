/// 四门法Strategy实现
///
/// 实现四门法V2的完整计算流程
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/si_men_fa_base_number_model.dart';
import '../../domain/models/tiao_wen_source_info.dart';
import '../../utils/tiao_wen_number_calculator.dart';
import 'base/multi_gua_calculator_base.dart';
import 'base_calculation_strategy.dart';

/// 四门法计算参数
class SiMenFaStrategyParams extends BaseCalculationParams {
  final EightChars eightChars;
  final Gender gender;
  final YuanYunOrder threeYuan;

  SiMenFaStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
  });

  @override
  String get description => "四门法计算（性别:$gender，三元:$threeYuan）";

  Map<String, dynamic> toMap() {
    return {
      'eightChars': eightChars.toString(),
      'gender': gender,
      'threeYuan': threeYuan,
    };
  }
}

/// 四门法计算器实现
class SiMenFaCalculator extends MultiGuaCalculatorBase {
  SiMenFaCalculator()
    : super(
        // 偶数配置：除以8取余，转后天卦
        evenNumberConfig: const NumberConfig(
          numberOperationStrategy: NumberOperationStrategy.mode,
          factorNumber: 8,
          guaConversionStrategy: NumberConversionGuaStrategy.toHouTian,
          withLength: false,
        ),
        // 奇数配置：除以8取余，转后天卦
        oddNumberConfig: const NumberConfig(
          numberOperationStrategy: NumberOperationStrategy.mode,
          factorNumber: 8,
          guaConversionStrategy: NumberConversionGuaStrategy.toHouTian,
          withLength: false,
        ),
        // 天干使用干支数配置
        ganToNumberStrategy: GanZhiToNumberStrategy.ganZhiNumber,
        // 地支使用干支数配置
        zhiToNumberStrategy: GanZhiToNumberStrategy.ganZhiNumber,
        // 奇数为上卦
        isOddAsTopGua: true,
      );

  @override
  GuaGenerationConfig getGuaGenerationConfig() {
    return const GuaGenerationConfig(
      // 第一卦：基本卦的互卦
      firstGuaType: "互",
      // 第二卦：第一卦变爻后的错卦
      secondGuaStrategy: GuaStrategy.forSecondGua(
        needExchange: false,
        needCuoGua: true,
        guaType: "本",
      ),
      // 第三卦：第一卦的互卦
      thirdGuaStrategy: GuaStrategy.forThirdGua(
        needExchange: false,
        needCuoGua: false,
        guaType: "互",
        baseGuaSource: "first",
      ),
      // 第四卦：第二卦的互卦
      fourthGuaStrategy: GuaStrategy.forFourthGua(
        needExchange: false,
        needCuoGua: false,
        guaType: "互",
        baseGuaSource: "second",
      ),
    );
  }
}

/// 四门法计算策略
class SiMenFaStrategy
    extends
        BaseCalculationStrategy<SiMenFaStrategyParams, BaseNumberModelResult> {
  final _calculator = SiMenFaCalculator();
  final _tiaoWenCalculator = const TiaoWenNumberCalculator();

  @override
  String get name => "四门法V2";

  @override
  String get description => "四门法V2完整计算流程，包含基本卦、互卦、变爻、秘数和条文计算";

  @override
  List<String> get detailSteps => [
    "1. 计算基本卦和基本数",
    "2. 计算变爻基数",
    "3. 生成前四卦（互卦→变爻错卦→第一卦互卦→第二卦互卦）",
    "4. 计算秘数列表",
    "5. 计算先天数列表",
    "6. 计算最终条文列表",
  ];

  @override
  String get school => "四门法流派";

  @override
  StrategyCategory get category => StrategyCategory.standard;

  BaseNumberModelResult calculate(SiMenFaStrategyParams params) {
    try {
      // 步骤1：生成前四卦
      final result = _calculator.generateFirstFourGua(
        params.eightChars,
        params.threeYuan,
        params.gender,
      );

      // 步骤2：计算秘数列表
      final isYangYear = params.eightChars.year.gan.yinYang == YinYang.YANG;
      final secretNumbers = _tiaoWenCalculator.calculateSecretNumbers(
        isYangYear,
        result.fourGuaList,
      );

      // 步骤3：计算先天数列表
      final xiantianNumbers = _tiaoWenCalculator.calculateXiantianNumbers(
        result.fourGuaList,
      );

      // 步骤4：计算最终条文列表
      final finalTiaowenList = _tiaoWenCalculator.calculateFinalTiaowen(
        xiantianNumbers,
        secretNumbers,
      );

      // 步骤5：生成条文来源信息列表（覆盖全部组合，不仅是前四项）
      final constantsList = [19, 37, 53, 79, 103, 237];
      final tiaoWenSourceList = <TiaoWenSourceInfo>[];
      for (int xiIndex = 0; xiIndex < xiantianNumbers.length; xiIndex++) {
        final xiNum = xiantianNumbers[xiIndex];
        final xiGua = result.fourGuaList[xiIndex];
        for (int seIndex = 0; seIndex < secretNumbers.length; seIndex++) {
          final seNum = secretNumbers[seIndex];
          final seGua = result.fourGuaList[seIndex];
          for (final k in constantsList) {
            final secretT = seNum * k - 7;
            int eachNum = xiNum * 47 + secretT;
            int finalNum;
            if (eachNum < 1000) {
              finalNum = eachNum + 12000;
            } else if (eachNum > 13000) {
              final tmpRes = eachNum - 12000;
              if (tmpRes > 13000) {
                finalNum = tmpRes - 12000;
              } else {
                finalNum = tmpRes;
              }
            } else {
              finalNum = eachNum;
            }

            tiaoWenSourceList.add(
              TiaoWenSourceInfo.fromSiMenFa(
                tiaoWenNumber: finalNum,
                secretGua: seGua,
                secretGuaIndex: seIndex + 1,
                secretNumber: seNum,
                xiantianNumber: xiNum,
                xiantianGua: xiGua,
                xiantianGuaIndex: xiIndex + 1,
                secretConst: k,
              ),
            );
          }
        }
      }

      // 步骤6：创建 SiMenFaBaseNumberModel
      final model = SiMenFaBaseNumberModel(
        baseNumber: result.basicNumber,
        name: name,
        description: "四门法V2计算（性别:${params.gender}，三元:${params.threeYuan}）",
        source: BaseNumberSource.yearZhu,
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        basicGua: result.basicGua,
        basicNumber: result.basicNumber,
        variationBase: result.variationBase,
        fourGuaList: result.fourGuaList,
        secretNumbers: secretNumbers,
        xiantianNumbers: xiantianNumbers,
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
          'basicGua': result.basicGua,
          'basicNumber': result.basicNumber,
          'variationBase': result.variationBase,
          'fourGuaList': result.fourGuaList.map((g) => g.toString()).toList(),
          'secretNumbers': secretNumbers,
          'xiantianNumbers': xiantianNumbers,
          'tiaowenCount': finalTiaowenList.length,
        },
      );
    } catch (e, stackTrace) {
      return handleError(params, e, stackTrace);
    }
  }

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    // 四门法使用复杂的秘数+先天数计算，不使用简单配置
    return GenericTiaoWenCalculationConfig.customList(
      name: "四门法条文计算",
      description: "使用秘数和先天数的组合计算",
      customList: [0],
      withSub: false,
    );
  }

  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    SiMenFaStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 四门法需要完整计算流程，不支持单独的条文扩展
    throw UnsupportedError('四门法需要使用 calculate 方法进行完整计算');
  }

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription => "使用秘数和先天数组合计算，生成完整的条文列表";

  BaseNumberModelResult handleError(
    SiMenFaStrategyParams params,
    Object error,
    StackTrace stackTrace,
  ) {
    return BaseNumberModelResult.error(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      errorMessage: "四门法V2计算失败: $error",
      sourceData: {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'params': params.description,
      },
    );
  }
}
