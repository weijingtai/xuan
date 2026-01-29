import 'package:common/models/eight_chars.dart';

import '../repository/datamodels/tiao_wen_datamodel.dart';
import 'base_get_tiao_wen_list_use_case.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/gua_yao_gan_zhi_he_strategy.dart';
import '../service/strategy/base_calculation_strategy.dart';


class GuaYaoGanZhiHeTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<GuaYaoGanZhiHeUseCaseParams> {
  final GuaYaoGanZhiHeStrategy _strategy;
  final TiaoWenRepository _repository;

  GuaYaoGanZhiHeTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      (_strategy.defaultTiaoWenCalculationConfig
              as GenericTiaoWenCalculationConfig)
          .toTiaoWenListCalculationConfig();

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '卦爻干支和条文列表UseCase';

  @override
  String get description => '基于爻干支计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    GuaYaoGanZhiHeUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
    GuaYaoGanZhiHeNaJiaMethod? naJiaMethod,
  }) async {
    try {
      validateParams(params);

      final method = naJiaMethod ?? GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang;

      final strategyParams = GuaYaoGanZhiHeStrategyParams(
        eightChars: params.eightChars,
        naJiaMethod: method,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      if (strategyResult.hasError) {
        throw Exception("策略计算出错: ${strategyResult.errorMessage}");
      }

      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;

      final baseNumberTiaoWenList = <BaseNumberTiaoWenListModel>[];

      for (final baseNumber in strategyResult.baseNumbers) {
        final calculator = TiaoWenListCalculator(effectiveConfig);
        final calculationResult = calculator.calculate(baseNumber.baseNumber);
        final tiaoWenNumbers = calculationResult.tiaoWenNumbers;

        final tiaoWenDataList = <TiaoWenDataModel>[];
        for (final number in tiaoWenNumbers) {
          try {
            final tiaoWenData = await _repository.getById(number);
            if (tiaoWenData != null) {
              tiaoWenDataList.add(tiaoWenData);
            }
          } catch (e) {
            print("获取爻文字符失败 (number: $number): $e");
          }
        }

        // 保留原始的GuaYaoGanZhiHeBaseNumberModel类型，只添加条文数据
        if (baseNumber is GuaYaoGanZhiHeBaseNumberModel) {
          baseNumberTiaoWenList.add(
            baseNumber.copyWith(
              tiaoWenDataList: tiaoWenDataList,
              tiaoWenNumbers: tiaoWenNumbers,
            ),
          );
        } else {
          // 如果不是GuaYaoGanZhiHeBaseNumberModel，回退到创建BaseNumberTiaoWenListModel
          baseNumberTiaoWenList.add(
            BaseNumberTiaoWenListModel(
              baseNumber: baseNumber.baseNumber,
              tiaoWenDataList: tiaoWenDataList,
              name: baseNumber.name,
              description: baseNumber.description,
              source: baseNumber.source,
              tiaoWenNumbers: tiaoWenNumbers,
            ),
          );
        }
      }

      final allTiaoWenEntities = baseNumberTiaoWenList
          .expand((model) => model.tiaoWenDataList)
          .toList();

      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: '${strategyResult.algorithmDescription}${method.displayName}	',
        calculationParams: strategyResult.calculationParams,
        sourceData: {
          ...strategyResult.sourceData,
          'naJiaMethod': method.name,
          'tiaoWenCalculationMethod': effectiveConfig.desc ?? 'N/A',
          'tiaoWenCount': baseNumberTiaoWenList.fold<int>(
            0,
            (sum, model) => sum + model.tiaoWenCount,
          ),
        },
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: allTiaoWenEntities,
      );
    } catch (e) {
      return MultiBaseNumberResult.error(
        algorithmName: '卦爻干支',
        algorithmDescription: '卦爻干支',
        calculationParams: params.eightChars.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  Future<Map<GuaYaoGanZhiHeNaJiaMethod, MultiBaseNumberResult>>
      calculateBothMethods(
    GuaYaoGanZhiHeUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    final results = <GuaYaoGanZhiHeNaJiaMethod, MultiBaseNumberResult>{};

    results[GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang] = await execute(
      params,
      calculationConfig: calculationConfig,
      naJiaMethod: GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
    );

    results[GuaYaoGanZhiHeNaJiaMethod.innerOuterGua] = await execute(
      params,
      calculationConfig: calculationConfig,
      naJiaMethod: GuaYaoGanZhiHeNaJiaMethod.innerOuterGua,
    );

    return results;
  }

  List<TiaoWenCalculationConfig> getSupportedTiaoWenCalculationConfigs() {
    return _strategy.supportedTiaoWenCalculationConfigs;
  }

  TiaoWenCalculationConfig getDefaultTiaoWenCalculationConfig() {
    return _strategy.defaultTiaoWenCalculationConfig;
  }

  @override
  void validateParams(GuaYaoGanZhiHeUseCaseParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        "参数错误",
        message: '未提供必须的八字',
        parameterName: 'eightChars',
      );
    }
  }
}

class GuaYaoGanZhiHeUseCaseParams {
  final EightChars eightChars;

  const GuaYaoGanZhiHeUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'GuaYaoGanZhiHeUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuaYaoGanZhiHeUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
