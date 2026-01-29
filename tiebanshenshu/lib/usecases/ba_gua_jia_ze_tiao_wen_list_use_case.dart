import 'package:common/models/eight_chars.dart';

import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/ba_gua_jia_ze_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 八卦加则条文列表UseCase实现
///
/// 负责处理基于八卦加则计算条文列表的业务逻辑
/// 八卦加则不扩展条文列表，直接使用基础数作为条文编号
class BaGuaJiaZeTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<BaGuaJiaZeUseCaseParams> {
  final BaGuaJiaZeStrategy _strategy;
  final TiaoWenRepository _repository;

  BaGuaJiaZeTiaoWenListUseCase(
    this._strategy,
    this._repository,
  );

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig
          as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '八卦加则UseCase';

  @override
  String get description => '基于八卦加则计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    BaGuaJiaZeUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础数
      final strategyParams = BaGuaJiaZeStrategyParams(
        eightChars: params.eightChars,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("八卦加则计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 不扩展条文列表，直接使用基础数作为条文编号
      final baseNumberTiaoWenList = <BaseNumberTiaoWenListModel>[];

      for (final baseModel in strategyResult.baseNumbers) {
        final tiaoWenNumber = baseModel.baseNumber;

        // 查询单个条文
        try {
          final tiaoWenData = await _repository.getById(tiaoWenNumber);

          // 创建BaseNumberTiaoWenListModel（条文列表只包含自己）
          baseNumberTiaoWenList.add(
            BaseNumberTiaoWenListModel(
              baseNumber: baseModel.baseNumber,
              tiaoWenDataList: tiaoWenData != null ? [tiaoWenData] : [],
              name: baseModel.name,
              description: baseModel.description,
              source: baseModel.source,
              tiaoWenNumbers: [tiaoWenNumber],
            ),
          );
        } catch (e) {
          // 记录错误但继续处理其他条文
          print('获取条文数据失败 (number: $tiaoWenNumber): $e');

          // 即使查询失败，也添加到列表（但tiaoWenDataList为空）
          baseNumberTiaoWenList.add(
            BaseNumberTiaoWenListModel(
              baseNumber: baseModel.baseNumber,
              tiaoWenDataList: [],
              name: baseModel.name,
              description: baseModel.description,
              source: baseModel.source,
              tiaoWenNumbers: [tiaoWenNumber],
            ),
          );
        }
      }

      // 4. 提取所有条文实体
      final allTiaoWenEntities = baseNumberTiaoWenList
          .expand((model) => model.tiaoWenDataList)
          .toList();

      // 5. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: strategyResult.algorithmDescription,
        calculationParams: strategyResult.calculationParams,
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: allTiaoWenEntities,
        sourceData: {
          ...strategyResult.sourceData,
          'tiaoWenCount': allTiaoWenEntities.length,
          'totalBaseNumbers': strategyResult.baseNumbers.length,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '八卦加则',
        algorithmDescription: '八卦装配地支加则取数法',
        calculationParams: params.eightChars.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(BaGuaJiaZeUseCaseParams params) {
    // 八字对象不会为null，因为是required参数
    // 这里可以添加其他验证逻辑
  }
}

/// 八卦加则UseCase参数
///
/// 使用EightChars对象，与Strategy参数保持一致
class BaGuaJiaZeUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const BaGuaJiaZeUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'BaGuaJiaZeUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaGuaJiaZeUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
