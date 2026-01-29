import 'package:common/enums.dart';

import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/xian_houtian_qu_shu_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/xian_houtian_qu_shu_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 先后天卦取数条文列表UseCase实现
///
/// 负责处理基于先后天卦取数法计算条文列表的业务逻辑
/// 先天卦和后天卦各产生8个条文编号（±48×倍数[2,4,8,16]）
class XianHoutianQuShuTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<XianHoutianQuShuUseCaseParams> {
  final XianHoutianQuShuStrategy _strategy;
  final TiaoWenRepository _repository;

  XianHoutianQuShuTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '先后天卦取数UseCase';

  @override
  String get description => '基于先后天卦取数法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    XianHoutianQuShuUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = XianHoutianQuShuStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("先后天卦取数计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取XianHoutianQuShuBaseNumberModel
      final model =
          strategyResult.baseNumbers.first as XianHoutianQuShuBaseNumberModel;

      // 4. 生成先天卦条文编号列表（±48×倍数[2,4,8,16]：8个数）
      final xiantianBaseNumber = model.xiantianBaseNumber;
      final config = _strategy.defaultTiaoWenCalculationConfig;
      final xiantianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        strategyParams,
        config,
      );

      // 5. 生成后天卦条文编号列表（±48×倍数[2,4,8,16]：8个数）
      final houtianBaseNumber = model.houtianBaseNumber;
      final houtianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        houtianBaseNumber,
        strategyParams,
        config,
      );

      // 6. 合并所有条文编号并去重
      final allTiaoWenNumbers = {
        ...xiantianTiaoWenList,
        ...houtianTiaoWenList,
      }.toList();

      // 7. 批量查询条文数据
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 8. 构建两个BaseNumberTiaoWenListModel（先天和后天分开）
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: xiantianBaseNumber,
          tiaoWenDataList: tiaoWenDataList
              .where((t) => xiantianTiaoWenList.contains(t.id))
              .toList(),
          name: "${model.name} - 先天卦",
          description:
              "先天卦${model.xiantianGua}六爻干支和数条文（基础数$xiantianBaseNumber，±48×倍数[2,4,8,16]）",
          source: model.source,
          tiaoWenNumbers: xiantianTiaoWenList,
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: houtianBaseNumber,
          tiaoWenDataList: tiaoWenDataList
              .where((t) => houtianTiaoWenList.contains(t.id))
              .toList(),
          name: "${model.name} - 后天卦",
          description:
              "后天卦${model.houtianGua}六爻干支和数条文（基础数$houtianBaseNumber，±48×倍数[2,4,8,16]）",
          source: model.source,
          tiaoWenNumbers: houtianTiaoWenList,
        ),
      ];

      // 9. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '先后天卦取数',
        algorithmDescription:
            '先后天卦取数（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianBaseNumber': xiantianBaseNumber,
          'houtianBaseNumber': houtianBaseNumber,
          'xiantianTiaoWenCount': xiantianTiaoWenList.length,
          'houtianTiaoWenCount': houtianTiaoWenList.length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          // 保存XianHoutianQuShuBaseNumberModel以便UI层访问完整的中间结果
          'xianHoutianQuShuBaseNumberModel': model,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '先后天卦取数',
        algorithmDescription: '先后天卦取数',
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
  void validateParams(XianHoutianQuShuUseCaseParams params) {
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

/// 先后天卦取数UseCase参数
///
/// 包含先后天卦取数计算所需的所有参数
class XianHoutianQuShuUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  const XianHoutianQuShuUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String toString() {
    return 'XianHoutianQuShuUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan, birthAfterZhi: $birthAfterZhi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XianHoutianQuShuUseCaseParams &&
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
