import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/row_strategy.dart';

Map<RowType, RowComputationStrategy> defaultRowStrategyMapper() {
  return <RowType, RowComputationStrategy>{
    RowType.tenGod: TenGodRowStrategy(),
    RowType.hiddenStemsTenGod: HiddenStemsTenGodsRowStrategy(),
    RowType.hiddenStems: HiddenStemsRowStrategy(),
    RowType.kongWang: KongWangRowStrategy(),
    RowType.naYin: NaYinRowStrategy(),
    RowType.xunShou: XunShouRowStrategy(),
    RowType.hiddenStemsPrimary: HiddenStemsPrimaryRowStrategy(),
    RowType.hiddenStemsSecondary: HiddenStemsSecondaryRowStrategy(),
    RowType.hiddenStemsTertiary: HiddenStemsTertiaryRowStrategy(),
    RowType.hiddenStemsPrimaryGods: HiddenStemsPrimaryGodsRowStrategy(),
    RowType.hiddenStemsSecondaryGods: HiddenStemsSecondaryGodsRowStrategy(),
    RowType.hiddenStemsTertiaryGods: HiddenStemsTertiaryGodsRowStrategy(),
    RowType.starYun: StarYunRowStrategy(),
    RowType.selfSiting: SelfSitingRowStrategy(),
  };
}
