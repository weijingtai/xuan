import 'package:common/models/eight_chars.dart';

import 'base_get_tiao_wen_list_use_case.dart';
import '../domain/models/base_number_model.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/four_zhu_tian_gan_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 四柱天干条文列表UseCase实现
///
/// 负责处理基于四柱天干计算条文列表的业务逻辑
/// 完整流程：Strategy计算基础数字 -> 根据配置扩展条文列表 -> Repository获取条文实体
class FourZhuTianGanTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<FourZhuTianGanUseCaseParams> {
  final FourZhuTianGanStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  FourZhuTianGanTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  TiaoWenRepository get repository => _repository;

  String get name => '四柱天干UseCase';

  @override
  String get description => '基于四柱天干计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    FourZhuTianGanUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      TiaoWenListCalculationConfig effectiveConfig =
          calculationConfig ?? defaultCalculationConfig;
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础数字
      final strategyParams = FourZhuTianGanStrategyParams(
        eightChars: params.eightChars,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("四柱天干计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 使用基类模板方法处理条文列表（特殊逐个处理模式）
      final tiaoWenListResult = await super.processWithIndividualQuery(
        strategyResult.baseNumbers,
        effectiveConfig,
        _customFourZhuProcessor,
      );

      // 4. 提取所有条文实体
      final allTiaoWenEntities = tiaoWenListResult
          .expand((model) => model.tiaoWenDataList)
          .toList();

      // 5. 创建并返回MultiBaseNumberResult
      return MultiBaseNumberResult.success(
        algorithmName: '四柱天干',
        algorithmDescription: '四柱天干取数法',
        calculationParams: params.eightChars.toString(),
        baseNumberTiaoWenList: tiaoWenListResult,
        tiaoWenEntities: allTiaoWenEntities,
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'calculationConfig': effectiveConfig.desc ?? 'N/A',
          'tiaoWenCount': tiaoWenListResult.fold<int>(
            0,
            (sum, model) => sum + model.tiaoWenCount,
          ),
        },
      );
    } catch (e) {
      return MultiBaseNumberResult.error(
        algorithmName: '四柱天干',
        algorithmDescription: '四柱天干取数法',
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
  void validateParams(FourZhuTianGanUseCaseParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        "四柱太玄",
        message: '八字不能为空',
        parameterName: '四柱太玄',
      );
    }
  }

  /// 四柱天干特有的自定义处理函数
  ///
  /// 实现基础数插入条文列表首位的特殊逻辑
  /// [baseNumber] 基础数模型
  /// [config] 计算配置
  /// [repository] 条文数据仓库
  /// 返回填充了条文数据的BaseNumberTiaoWenListModel
  static Future<BaseNumberTiaoWenListModel> _customFourZhuProcessor(
    BaseNumberModel baseNumber,
    TiaoWenListCalculationConfig config,
    TiaoWenRepository repository,
  ) async {
    // 使用配置计算条文编号
    final tiaoWenNumbers = TiaoWenListCalculator(
      config,
    ).calculate(baseNumber.baseNumber);

    // 修正数据：如果基础数已在条文编号列表中，则移除它
    if (tiaoWenNumbers.tiaoWenNumbers.contains(baseNumber.baseNumber)) {
      tiaoWenNumbers.tiaoWenNumbers.remove(baseNumber.baseNumber);
    }

    // 将基础数插入到条文列表首位
    tiaoWenNumbers.tiaoWenNumbers.insert(0, baseNumber.baseNumber);

    // 获取包括基础数在内的所有条文
    final tiaoWenEntities = await repository.getByIdList(
      queryList: tiaoWenNumbers.tiaoWenNumbers,
    );

    // 创建BaseNumberTiaoWenListModel
    return BaseNumberTiaoWenListModel.fromBaseModelWithData(
      baseTiaoWen: tiaoWenEntities[0],
      baseModel: baseNumber,
      calculationConfig: config,
      tiaoWenDataList: tiaoWenEntities.skip(1).toList(),
    );
  }
}

/// 四柱天干UseCase参数
///
/// 使用EightChars对象而不是字符串列表，与Strategy参数保持一致
class FourZhuTianGanUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const FourZhuTianGanUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'FourZhuTianGanUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FourZhuTianGanUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
