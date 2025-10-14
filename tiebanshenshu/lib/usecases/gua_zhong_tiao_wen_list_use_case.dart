import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/gua_zhong_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/gua_zhong_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 卦中取数法条文列表UseCase实现
///
/// 负责处理基于卦中取数法计算条文列表的业务逻辑
///
/// **三种千位计算方案**:
/// - 年月卦和日时卦各产生2个条文编号（主卦+互卦）
/// - 每个条文有3种方案，总计12个条文编号（4个位置 × 3种方案）
/// - 默认使用全部三种方案，UI层可通过ViewModel过滤显示
class GuaZhongTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<GuaZhongUseCaseParams> {
  final GuaZhongStrategy _strategy;
  final TiaoWenRepository _repository;

  GuaZhongTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '卦中取数法UseCase';

  @override
  String get description => '基于卦中取数法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    GuaZhongUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = GuaZhongStrategyParams(eightChars: params.eightChars);
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("卦中取数法计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取GuaZhongBaseNumberModel
      final guaZhongModel =
          strategyResult.baseNumbers.first as GuaZhongBaseNumberModel;

      // 4. 获取所有条文编号（12个：4个位置 × 3种方案，去重）
      final allTiaoWenNumbers = guaZhongModel.allTiaoWenNumbers
          .where((n) => n > 0 && n <= 12000) // 方案3可能产生五位数（如10484）
          .toList();

      // 6. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 7. 构建两个BaseNumberTiaoWenListModel（年月卦和日时卦分开）
      // 获取所有三种方案的条文编号
      final nianYueTiaoWenNumbers = <int>[];
      final riShiTiaoWenNumbers = <int>[];

      for (int plan = 1; plan <= 3; plan++) {
        nianYueTiaoWenNumbers.add(
          guaZhongModel.getNianYueZhuGuaTiaoWenNumber(plan),
        );
        nianYueTiaoWenNumbers.add(
          guaZhongModel.getNianYueHuGuaTiaoWenNumber(plan),
        );
        riShiTiaoWenNumbers.add(
          guaZhongModel.getRiShiZhuGuaTiaoWenNumber(plan),
        );
        riShiTiaoWenNumbers.add(guaZhongModel.getRiShiHuGuaTiaoWenNumber(plan));
      }

      // 过滤有效范围并去重
      nianYueTiaoWenNumbers.retainWhere((n) => n > 0 && n <= 12000);
      riShiTiaoWenNumbers.retainWhere((n) => n > 0 && n <= 12000);

      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: guaZhongModel.getNianYueZhuGuaTiaoWenNumber(
            1,
          ), // 使用方案1作为主基础数
          tiaoWenDataList: tiaoWenDataList.toList(),
          name: "${guaZhongModel.name} - 年月卦",
          description:
              "年月卦${guaZhongModel.nianYueZhuGuaName}条文（主卦+互卦，三种方案共${nianYueTiaoWenNumbers.toSet().length}个条文）",
          source: guaZhongModel.source,
          tiaoWenNumbers: nianYueTiaoWenNumbers.toSet().toList(),
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: guaZhongModel.getRiShiZhuGuaTiaoWenNumber(
            1,
          ), // 使用方案1作为主基础数
          tiaoWenDataList: tiaoWenDataList.toList(),
          name: "${guaZhongModel.name} - 日时卦",
          description:
              "日时卦${guaZhongModel.riShiZhuGuaName}条文（主卦+互卦，三种方案共${riShiTiaoWenNumbers.toSet().length}个条文）",
          source: guaZhongModel.source,
          tiaoWenNumbers: riShiTiaoWenNumbers.toSet().toList(),
        ),
      ];

      // 8. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '卦中取数法（三种方案）',
        algorithmDescription: '卦中取数法（八字:${params.eightChars}，支持三种千位计算方案）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'nianYueTiaoWenCount': nianYueTiaoWenNumbers.toSet().length,
          'riShiTiaoWenCount': riShiTiaoWenNumbers.toSet().length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          'supportedPlans': [1, 2, 3],
          'plan1Description': '取1代替0（推荐）',
          'plan2Description': '取卦先天数',
          'plan3Description': '保留10（五位数）',
          // 保存GuaZhongBaseNumberModel以便UI层访问完整的中间结果
          'guaZhongBaseNumberModel': guaZhongModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '卦中取数法',
        algorithmDescription: '卦中取数法',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(GuaZhongUseCaseParams params) {
    // 卦中取数法只需要八字，无需额外验证
    // EightChars 的基本校验通过类型系统保证
  }
}

/// 卦中取数法UseCase参数
///
/// 包含卦中取数法计算所需的所有参数
class GuaZhongUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const GuaZhongUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'GuaZhongUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuaZhongUseCaseParams && other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
