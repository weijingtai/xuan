import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';
import 'package:tuple/tuple.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import '../../domain/models/huang_ji_formula.dart';
import '../../domain/models/huang_ji_number.dart';
import 'base_calculation_strategy.dart';

class HuangJiStrategy
    extends
        BaseCalculationStrategy<
          HuangJiCalculationParams,
          HuangJiCalculationResult
        > {
  /// 1. 第一步需要的计算操作
  /// 1.1. 根据四柱配太玄数
  /// 1.2. 求出元、会、运、世 四个数
  /// 1.3. 求出 元会(互合)、运世(互合逆右旋取数) 基本数
  YuanHuiYunShi calcuateYuanHuiYinShi(EightChars eightChars) {
    return YuanHuiYunShi.fromEightChars(eightChars);
  }

  /// 2.1. 有些算法会进行处理
  ///   将元会基本数 与 运世基本数，分别加上 年干(千位) 后获取条文，让用户确定是否符合，如不符合则增减30循环知道确认
  HuangJiBaseNumber calcuateBaseNumber(
    HuangJiBaseNumber huangJiBaseNumber,
    HuangJiPlacedNumber placeNumber,
  ) {
    return HuangJiBaseNumber(
      name:
          "${huangJiBaseNumber.numberSource.name}_${huangJiBaseNumber.baseNumberType.next.name}",
      description:
          '${huangJiBaseNumber.description} + ${placeNumber.description}',
      orinialNumber: huangJiBaseNumber.orinialNumber + placeNumber.number,
      baseNumberType: huangJiBaseNumber.baseNumberType.next,
      numberSource: huangJiBaseNumber.numberSource,
    );
  }

  int tiaoWenFormulaExecutor(
    HuangJiTiaoWenCalculationFormula formula,
    YuanHuiYunShi yuanHuiYunShi,
  ) {
    int baseNumber = 0;
    if (formula.basePart.numberSource == NumberSource.yuanHui) {
      baseNumber = yuanHuiYunShi.yuanHuiMergeNumber.number;
    } else if (formula.basePart.numberSource == NumberSource.yunShi) {
      baseNumber = yuanHuiYunShi.yunShiMergeNumber.number;
    }
    for (var p in formula.otherPartsList) {
      if (p.forBaseOperator == EnumHuangJiOperator.add) {
        if (p is HuangJiFormulaOtherSingleNumberPart) {
          int _taiXuanNumber = yuanHuiYunShi.getTaiXuanNumberBy(
            ganZhiType: p.fourZhuGanZhiType,
            fourZhu: p.fourZhuName,
          );
          var placeNumber = HuangJiPlacedNumber.generateWithGanZhi(
            _taiXuanNumber,
            p.numberPlace,
            p.fourZhuName,
            p.fourZhuGanZhiType,
          );
          baseNumber += placeNumber.number;
          if (baseNumber > 13000) {
            baseNumber -= 12000;
          }
        }
      }
    }

    return baseNumber;
  }

  // HuangJiTiaoWenNumber calculateHuangJiTiaoWenNumber(HuangJiTiaoWenNumber baseNumber)
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    HuangJiCalculationParams params,
    TiaoWenCalculationConfig config,
  ) {
    // TODO: implement calculateTiaoWenListWithConfig
    throw UnimplementedError();
  }

  @override
  // TODO: implement category
  StrategyCategory get category => throw UnimplementedError();

  @override
  // TODO: implement defaultTiaoWenCalculationConfig
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig =>
      throw UnimplementedError();

  @override
  // TODO: implement description
  String get description => throw UnimplementedError();

  @override
  // TODO: implement detailSteps
  List<String> get detailSteps => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement school
  String get school => throw UnimplementedError();

  @override
  // TODO: implement supportedTiaoWenCalculationConfigs
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs =>
      throw UnimplementedError();

  @override
  // TODO: implement tiaoWenCalculationDescription
  String get tiaoWenCalculationDescription => throw UnimplementedError();
}
