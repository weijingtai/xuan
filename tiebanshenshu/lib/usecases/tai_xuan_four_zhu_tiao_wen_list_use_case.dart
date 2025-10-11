import 'package:common/models/eight_chars.dart';

import '../repository/datamodels/tiao_wen_datamodel.dart';
import 'base_get_tiao_wen_list_use_case.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/tai_xuan_base_number_model.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../service/strategy/base_calculation_strategy.dart';

/// 太玄四柱条文列表UseCase实现
///
/// 负责处理基于太玄四柱计算条文列表的业务逻辑
/// 支持两种纳甲方案：年干阴阳纳甲和传统内外卦纳甲
/// 完整流程：Strategy计算基础数字并处理条文计算 -> Repository获取条文实体
class TaiXuanFourZhuTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<TaiXuanFourZhuUseCaseParams> {
  final TaiXuanFourZhuStrategy _strategy;
  final TiaoWenRepository _repository;

  TaiXuanFourZhuTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      (_strategy.defaultTiaoWenCalculationConfig
              as GenericTiaoWenCalculationConfig)
          .toTiaoWenListCalculationConfig();

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '太玄四柱UseCase';

  @override
  String get description => '基于太玄四柱计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    TaiXuanFourZhuUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
    TaiXuanNaJiaMethod? naJiaMethod,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 使用指定的纳甲方法，如未指定则使用默认（年干阴阳）
      final method = naJiaMethod ?? TaiXuanNaJiaMethod.yearGanYinYang;

      // 2. 调用Strategy计算基础数模型
      final strategyParams = TaiXuanFourZhuStrategyParams(
        eightChars: params.eightChars,
        naJiaMethod: method,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("太玄四柱计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 使用条文列表计算配置（默认或用户指定）
      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;

      // 4. 为每个基础数计算条文列表并获取条文数据
      final baseNumberTiaoWenList = <BaseNumberTiaoWenListModel>[];

      for (final baseNumber in strategyResult.baseNumbers) {
        // 使用TiaoWenListCalculator计算条文列表
        final calculator = TiaoWenListCalculator(effectiveConfig);
        final calculationResult = calculator.calculate(baseNumber.baseNumber);
        final tiaoWenNumbers = calculationResult.tiaoWenNumbers;

        // 从Repository获取条文数据
        final tiaoWenDataList = <TiaoWenDataModel>[];
        for (final number in tiaoWenNumbers) {
          try {
            final tiaoWenData = await _repository.getById(number);
            if (tiaoWenData != null) {
              tiaoWenDataList.add(tiaoWenData);
            }
          } catch (e) {
            // 记录错误但继续处理其他条文
            print('获取条文数据失败 (number: $number): $e');
          }
        }

        // 创建BaseNumberTiaoWenListModel
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

      // 5. 提取所有条文实体
      final allTiaoWenEntities = baseNumberTiaoWenList
          .expand((model) => model.tiaoWenDataList)
          .toList();

      // 6. 创建并返回MultiBaseNumberResult
      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: '${strategyResult.algorithmDescription}（${method.displayName}）',
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
        algorithmName: '太玄四柱',
        algorithmDescription: '太玄四柱取数法',
        calculationParams: params.eightChars.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// 计算两种纳甲方案并返回
  ///
  /// 同时计算年干阴阳纳甲和传统内外卦纳甲两种方案的结果
  ///
  /// [params] UseCase参数
  /// [calculationConfig] 条文计算配置（可选）
  ///
  /// 返回包含两种方案结果的Map
  Future<Map<TaiXuanNaJiaMethod, MultiBaseNumberResult>> calculateBothMethods(
    TaiXuanFourZhuUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    final results = <TaiXuanNaJiaMethod, MultiBaseNumberResult>{};

    // 计算年干阴阳纳甲
    results[TaiXuanNaJiaMethod.yearGanYinYang] = await execute(
      params,
      calculationConfig: calculationConfig,
      naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
    );

    // 计算传统内外卦纳甲
    results[TaiXuanNaJiaMethod.innerOuterGua] = await execute(
      params,
      calculationConfig: calculationConfig,
      naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
    );

    return results;
  }

  /// 获取支持的条文计算配置选项
  ///
  /// 返回用户可以选择的预设配置列表
  List<TiaoWenCalculationConfig> getSupportedTiaoWenCalculationConfigs() {
    return _strategy.supportedTiaoWenCalculationConfigs;
  }

  /// 获取默认的条文计算配置
  ///
  /// 返回Strategy的默认配置
  TiaoWenCalculationConfig getDefaultTiaoWenCalculationConfig() {
    return _strategy.defaultTiaoWenCalculationConfig;
  }

  @override
  void validateParams(TaiXuanFourZhuUseCaseParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        "八字不能为空",
        message: '八字不能为空',
        parameterName: '四柱太玄',
      );
    }
  }
}

/// 太玄四柱UseCase参数
///
/// 使用EightChars对象而不是字符串列表，与Strategy参数保持一致
class TaiXuanFourZhuUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const TaiXuanFourZhuUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'TaiXuanFourZhuUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaiXuanFourZhuUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
