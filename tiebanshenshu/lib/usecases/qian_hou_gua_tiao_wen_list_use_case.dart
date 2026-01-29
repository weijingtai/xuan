import 'package:common/enums.dart';

import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/qian_hou_gua_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/qian_hou_gua_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 前后卦取数法条文列表UseCase实现
///
/// 负责处理基于前后卦取数法计算条文列表的业务逻辑
/// 前卦和后卦各产生5个条文编号（前卦递增96四次，后卦递减96四次）
class QianHouGuaTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<QianHouGuaUseCaseParams> {
  final QianHouGuaStrategy _strategy;
  final TiaoWenRepository _repository;

  QianHouGuaTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '前后卦取数法UseCase';

  @override
  String get description => '基于前后卦取数法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    QianHouGuaUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = QianHouGuaStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("前后卦取数法计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取QianHouGuaBaseNumberModel
      final qianHouModel =
          strategyResult.baseNumbers.first as QianHouGuaBaseNumberModel;

      // 4. 获取前卦条文编号（已在Strategy中递增96四次），并过滤掉无效的编号
      final qianGuaBaseNumber = qianHouModel.qianGuaBaseNumber;
      final qianGuaTiaoWenList = qianHouModel.qianGuaTiaoWenNumbers.toList();

      // 5. 获取后卦条文编号（已在Strategy中递减96四次），并过滤掉无效的编号（负数或超出范围）
      final houGuaBaseNumber = qianHouModel.houGuaBaseNumber;
      final houGuaTiaoWenList = qianHouModel.houGuaTiaoWenNumbers.toList();

      // 6. 合并所有条文编号
      final allTiaoWenNumbers = {
        ...qianGuaTiaoWenList,
        ...houGuaTiaoWenList,
      }.toList(); // 去重

      // 7. 转换为数据库ID（tiao_wen_number + 1000）
      // final dbIds = allTiaoWenNumbers.map((n) => n + 1000).toList();

      // 8. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 9. 构建两个BaseNumberTiaoWenListModel（前卦和后卦分开）
      // 注意：这里需要将数据库ID转换回条文编号来进行匹配
      // final qianGuaDbIds = qianGuaTiaoWenList.map((n) => n + 1000).toSet();
      // final houGuaDbIds = houGuaTiaoWenList.map((n) => n + 1000).toSet();
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: qianGuaBaseNumber,
          tiaoWenDataList: tiaoWenDataList.toList(),
          name: "${qianHouModel.name} - 前卦",
          description:
              "前卦${qianHouModel.qianGuaName}条文（基础数$qianGuaBaseNumber + [0, 96, 192, 288, 384]）",
          source: qianHouModel.source,
          tiaoWenNumbers: qianGuaTiaoWenList,
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: houGuaBaseNumber,
          tiaoWenDataList: tiaoWenDataList.toList(),
          name: "${qianHouModel.name} - 后卦",
          description:
              "后卦${qianHouModel.houGuaName}条文（基础数$houGuaBaseNumber + [0, -96, -192, -288, -384]）",
          source: qianHouModel.source,
          tiaoWenNumbers: houGuaTiaoWenList,
        ),
      ];

      // 9. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '前后卦取数法',
        algorithmDescription:
            '前后卦取数法（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          'eightChars': strategyParams.eightChars.toString(),
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'qianGuaTiaoWenCount': qianGuaTiaoWenList.length,
          'houGuaTiaoWenCount': houGuaTiaoWenList.length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          // 保存QianHouGuaBaseNumberModel以便UI层访问完整的中间结果
          'qianHouGuaBaseNumberModel': qianHouModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '前后卦取数法',
        algorithmDescription: '前后卦取数法',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(QianHouGuaUseCaseParams params) {
    // 验证性别
    if (params.gender != Gender.male && params.gender != Gender.female) {
      throw InputValidationException(
        '性别验证',
        parameterName: 'gender',
        parameterValue: params.gender,
        message: '性别必须为"男"或"女"',
      );
    }

    // 验证三元
    if (params.threeYuan != YuanYunOrder.upper &&
        params.threeYuan != YuanYunOrder.middle &&
        params.threeYuan != YuanYunOrder.lower) {
      throw InputValidationException(
        '三元验证',
        parameterName: 'threeYuan',
        parameterValue: params.threeYuan,
        message: '三元必须为"上"、"中"或"下"',
      );
    }

    // 验证节气
    if (params.birthAfterZhi != TwentyFourJieQi.XIA_ZHI &&
        params.birthAfterZhi != TwentyFourJieQi.DONG_ZHI) {
      throw InputValidationException(
        '节气验证',
        parameterName: 'birthAfterZhi',
        parameterValue: params.birthAfterZhi,
        message: '出生节气后必须为"夏至"或"冬至"',
      );
    }
  }
}

/// 前后卦取数法UseCase参数
///
/// 包含前后卦取数法计算所需的所有参数
class QianHouGuaUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  const QianHouGuaUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String toString() {
    return 'QianHouGuaUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan, birthAfterZhi: $birthAfterZhi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QianHouGuaUseCaseParams &&
        other.eightChars == eightChars &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.birthAfterZhi == birthAfterZhi;
  }

  @override
  int get hashCode =>
      eightChars.hashCode ^
      gender.hashCode ^
      threeYuan.hashCode ^
      birthAfterZhi.hashCode;
}
