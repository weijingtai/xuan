/// 获取条文列表UseCase基类
///
/// 定义获取条文列表的通用业务逻辑接口
library;

import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/base_number_model.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import '../repository/tiao_wen_repository.dart';
import '../repository/datamodels/tiao_wen_datamodel.dart';

/// 获取条文列表UseCase的基础抽象类
///
/// 定义了获取条文列表的通用接口，所有具体的条文列表UseCase都应该实现此接口
/// 提供了两种处理模式的模板方法：标准批量处理和特殊逐个处理
abstract class BaseGetTiaoWenListUseCase<TParams> {
  /// UseCase名称
  String get name;

  /// UseCase描述
  String get description;

  /// 获取Repository实例（子类需要实现）
  TiaoWenRepository get repository;

  /// 获取默认计算配置（子类需要实现）
  TiaoWenListCalculationConfig get defaultCalculationConfig;

  /// 执行UseCase
  ///
  /// [params] 计算参数
  /// [calculationConfig] 可选的计算配置，如果为null则使用默认配置
  /// 返回包含条文列表的多基础数结果
  ///
  /// 抛出异常：
  /// - [InputValidationException] 输入参数验证失败
  /// - [StrategyCalculationException] Strategy计算失败
  /// - [TiaoWenListCalculationException] 条文列表计算失败
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<MultiBaseNumberResult> execute(
    TParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  });

  /// 验证参数
  ///
  /// [params] 待验证的参数
  /// 抛出 [InputValidationException] 如果参数无效
  void validateParams(TParams params) {
    if (params == null) {
      throw InputValidationException(
        "参数不能为空",
        message: '参数不能为空',
        parameterName: 'params',
      );
    }
  }

  /// 标准批量处理模式：先收集所有条文编号，然后批量查询
  ///
  /// 适用于大多数UseCase，性能较好，避免N+1查询问题
  /// [baseNumbers] Strategy计算得到的基础数字列表
  /// [config] 条文列表计算配置
  /// 返回填充了条文数据的BaseNumberTiaoWenListModel列表
  Future<List<BaseNumberTiaoWenListModel>> processWithBatchQuery(
    List<BaseNumberModel> baseNumbers,
    TiaoWenListCalculationConfig config,
  ) async {
    // 1. 创建BaseNumberTiaoWenListModel列表并收集所有条文编号
    final baseNumberTiaoWenListModels = <BaseNumberTiaoWenListModel>[];
    final allTiaoWenNumbers = <int>[];

    for (final baseNumber in baseNumbers) {
      // 为每个基础数创建BaseNumberTiaoWenListModel
      final baseNumberTiaoWenListModel =
          BaseNumberTiaoWenListModel.fromBaseModel(
            baseModel: baseNumber,
            calculationConfig: config,
          );

      baseNumberTiaoWenListModels.add(baseNumberTiaoWenListModel);
      allTiaoWenNumbers.addAll(baseNumberTiaoWenListModel.tiaoWenNumbers);
    }

    // 2. 批量查询所有条文实体
    final tiaoWenEntities = await repository.getByIdList(
      queryList: allTiaoWenNumbers,
    );

    // 3. 为每个BaseNumberTiaoWenListModel填充条文数据
    final updatedBaseNumbers = <BaseNumberTiaoWenListModel>[];
    for (final baseNumberModel in baseNumberTiaoWenListModels) {
      // 获取该基础数对应的条文数据
      final modelTiaoWenData = tiaoWenEntities
          .where((entity) => baseNumberModel.tiaoWenNumbers.contains(entity.id))
          .toList();

      // 更新模型的条文数据
      final updatedModel = baseNumberModel.copyWithTiaoWenData(
        modelTiaoWenData,
      );
      updatedBaseNumbers.add(updatedModel);
    }

    return updatedBaseNumbers;
  }

  /// 特殊逐个处理模式：为每个基础数单独查询条文数据
  ///
  /// 适用于需要特殊处理逻辑的UseCase（如四柱天干的基础数插入首位）
  /// [baseNumbers] Strategy计算得到的基础数字列表
  /// [config] 条文列表计算配置
  /// [customProcessor] 自定义处理函数，用于特殊逻辑
  /// 返回填充了条文数据的BaseNumberTiaoWenListModel列表
  Future<List<BaseNumberTiaoWenListModel>> processWithIndividualQuery(
    List<BaseNumberModel> baseNumbers,
    TiaoWenListCalculationConfig config,
    Future<BaseNumberTiaoWenListModel> Function(
      BaseNumberModel baseNumber,
      TiaoWenListCalculationConfig config,
      TiaoWenRepository repository,
    )
    customProcessor,
  ) async {
    final tiaoWenListResult = <BaseNumberTiaoWenListModel>[];

    for (final baseNumber in baseNumbers) {
      final processedModel = await customProcessor(
        baseNumber,
        config,
        repository,
      );
      tiaoWenListResult.add(processedModel);
    }

    return tiaoWenListResult;
  }
}
