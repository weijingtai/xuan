import 'package:common/models/eight_chars.dart';

import '../application/usecases/base_get_tiao_wen_list_use_case.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 太玄四柱条文列表UseCase实现
///
/// 负责处理基于太玄四柱计算条文列表的业务逻辑
/// 完整流程：Strategy计算基础数字 -> 根据配置扩展条文列表 -> Repository获取条文实体
class TaiXuanFourZhuTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<TaiXuanFourZhuUseCaseParams> {
  final TaiXuanFourZhuStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  TaiXuanFourZhuTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  String get name => '太玄四柱UseCase';

  @override
  String get description => '基于太玄四柱计算条文列表的UseCase';

  @override
  Future<TiaoWenListResult> execute(
    TaiXuanFourZhuUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础数字列表
      final strategyParams = TaiXuanFourZhuStrategyParams(
        eightChars: params.eightChars,
      );
      final strategyResult = _strategy.calculate(strategyParams);
      final baseTiaoWenList = strategyResult.baseTiaoWenList;

      // 3. 根据配置扩展条文列表（对每个基础数字进行扩展）
      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;
      final allTiaoWenNumbers = <int>[];
      for (final baseNumber in baseTiaoWenList) {
        final calculator = TiaoWenListCalculator(effectiveConfig);
        final calculationResult = calculator.calculate(baseNumber);
        allTiaoWenNumbers.addAll(calculationResult.tiaoWenNumbers);
      }

      // 4. 调用Repository获取条文实体
      final tiaoWenEntities = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 5. 转换为UseCase结果
      return TiaoWenListResult.success(
        tiaoWenNumbers: allTiaoWenNumbers,
        tiaoWenEntities: tiaoWenEntities,
        calculationMethod: '太玄四柱',
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'baseTiaoWenList': baseTiaoWenList,
          'allTiaoWenNumbers': allTiaoWenNumbers,
          'calculationConfig': effectiveConfig.desc ?? 'N/A',
          'tiaoWenCount': allTiaoWenNumbers.length,
          'tiaoWenEntities': tiaoWenEntities.map((e) => e.toJson()).toList(),
        },
      );
    } catch (e) {
      return TiaoWenListResult.error(
        calculationMethod: '太玄四柱',
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
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
