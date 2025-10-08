import 'package:common/enums.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/domain/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/utils/utils.dart';

import '../../service/strategy/base_calculation_strategy.dart';
import 'six_qin_correct_ke.dart';

class SixQinCorrectKeStrategy
    implements
        BaseCalculationStrategy<SixQinCorrectKeParams, SixQinCorrectKeResult> {
  @override
  String get name => "六亲考刻";

  @override
  String get description => "根据六亲关系进行考刻";

  @override
  List<String> get detailSteps => ["输入卦象", "计算互卦", "生成条文"];

  @override
  String get school => "铁版神数";

  @override
  StrategyCategory get category => StrategyCategory.standard;

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig =>
      GenericTiaoWenCalculationConfig.taiXuanStandard();

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs =>
      [GenericTiaoWenCalculationConfig.taiXuanStandard()];

  @override
  String get tiaoWenCalculationDescription => "基础数分别各±96四次：±96、±192、±384、±768";

  @override
  bool get isInteractive => category == StrategyCategory.interactive;

  @override
  List<int> calculateTiaoWenList(int baseNumber, SixQinCorrectKeParams params) {
    return calculateTiaoWenListWithConfig(
        baseNumber, params, defaultTiaoWenCalculationConfig);
  }

  SixQinCorrectKeResult execute(SixQinCorrectKeParams params) {
    final topGua = params.topGua;
    final bottomGua = params.bottomGua;

    final gua = PureSixYaoGua.by8Gua(topGua, bottomGua);
    final huGua = gua.hu;

    final baseNumber = calculateGuaNum(
        params.originalGuaNum, params.totalGuaNum, params.ke);

    final tiaoWenList = _generateTiaoWenList(baseNumber);

    final baseNumberModel = BaseNumberModel.create(
      baseNumber: baseNumber,
      name: gua.gua.name,
      source: BaseNumberSource.sixQinCorrectKe,
      description: "考刻六亲",
    );

    final huGuaBaseNumberModel = BaseNumberModel.create(
      baseNumber: baseNumber,
      name: huGua.name,
      source: BaseNumberSource.sixQinCorrectKe,
      description: "考刻六亲（互卦）",
    );

    return SixQinCorrectKeResult.success(
      algorithmName: '六亲考刻',
      algorithmDescription: '根据六亲关系进行考刻',
      calculationParams: params.toString(),
      baseNumbers: [baseNumberModel, huGuaBaseNumberModel],
      tiaoWen: tiaoWenList,
      sourceData: {'params': params.toString()},
    );
  }

  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    SixQinCorrectKeParams params,
    TiaoWenCalculationConfig config,
  ) {
    return config.calculateTiaoWenList(baseNumber, {'params': params});
  }

  List<TiaoWenDataModel> _generateTiaoWenList(int baseNumber) {
    final factorList = calculateTaoWenListByFactor(
      baseNumber: baseNumber,
      times: 5,
      factor: 96,
      includeSubtractions: true,
      includeBase: true,
    );

    final multiplesList = calculateTaoWenListByMultiples(
      baseNumber: baseNumber,
      multiples: [1, 2, 3, 4, 5],
      factor: 48,
      includeSubtractions: true,
      includeBase: false,
    );

    final combinedList = {...factorList, ...multiplesList}.toList();
    combinedList.sort();

    return combinedList
        .map((number) => TiaoWenDataModel(
              id: number,
              setName: DiZhi.ZI,
              content1: '',
              ageSet1: [],
            ))
        .toList();
  }
}
