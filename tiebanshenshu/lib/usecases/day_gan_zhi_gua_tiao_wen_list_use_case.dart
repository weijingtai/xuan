import 'package:common/shared/enums/enum_jia_zi.dart';

import '../application/usecases/base_get_tiao_wen_list_use_case.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/day_gan_zhi_gua_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 日干支卦条文列表UseCase实现
///
/// 负责处理基于日干支卦计算条文列表的业务逻辑
/// 包含参数验证、Strategy调用、条文列表计算和Repository查询
class DayGanZhiGuaTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<DayGanZhiGuaUseCaseParams> {
  final DayGanZhiGuaStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  DayGanZhiGuaTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  String get name => '日干支卦UseCase';

  @override
  String get description => '基于日干支卦计算条文列表的UseCase';

  @override
  Future<TiaoWenListResult> execute(
    DayGanZhiGuaUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础条文
      final strategyParams = DayGanZhiGuaStrategyParams(
        dayGanZhi: params.dayGanZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);
      final baseTiaoWenNumber = strategyResult.tiaoWenNumber;

      // 3. 根据基础条文和TiaoWenListCalculationConfig计算所有条文列表
      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;
      final calculator = TiaoWenListCalculator(effectiveConfig);
      final calculationResult = calculator.calculate(baseTiaoWenNumber);
      final allTiaoWenNumbers = calculationResult.tiaoWenNumbers;

      // 4. 调用Repository获取条文Entity结果集
      final tiaoWenEntities = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 5. 转换为UseCase结果
      return TiaoWenListResult.success(
        tiaoWenNumbers: allTiaoWenNumbers,
        tiaoWenEntities: tiaoWenEntities,
        calculationMethod: '日干支卦',
        sourceData: {
          'dayGanZhi': params.dayGanZhi.name,
          'baseTiaoWenNumber': baseTiaoWenNumber,
          'calculationConfig': effectiveConfig.desc ?? 'Unknown',
          'tiaoWenCount': allTiaoWenNumbers.length,
          'tiaoWenEntities': tiaoWenEntities.map((e) => e.toJson()).toList(),
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return TiaoWenListResult.error(
        calculationMethod: '日干支卦',
        errorMessage: e.toString(),
        sourceData: {'dayGanZhi': params.dayGanZhi.name, 'error': e.toString()},
      );
    }
  }

  @override
  void validateParams(DayGanZhiGuaUseCaseParams params) {
    if (params.dayGanZhi == null) {
      throw InputValidationException(
        "日干支参数",
        parameterName: '日干支参数',
        message: '日干支参数',
      );
    }
  }
}

/// 日干支卦UseCase参数
///
/// 使用JiaZi对象而不是字符串，与Strategy参数保持一致
class DayGanZhiGuaUseCaseParams {
  /// 日干支
  final JiaZi dayGanZhi;

  const DayGanZhiGuaUseCaseParams({required this.dayGanZhi});

  @override
  String toString() {
    return 'DayGanZhiGuaUseCaseParams(dayGanZhi: ${dayGanZhi.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayGanZhiGuaUseCaseParams && other.dayGanZhi == dayGanZhi;
  }

  @override
  int get hashCode => dayGanZhi.hashCode;
}
