import '../enums/layout_template_enums.dart';

class ConstantValuesUtils {
  /// Maps a `RowType` to its default display label.
  ///
  /// Parameters:
  /// - [type]: The `RowType` enum.
  ///
  /// Returns: The localized default label for the given row type.
  static String labelForRowType(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.tenGod:
        return '十神';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.xunShou:
        return '旬首';
      case RowType.hiddenStems:
        return '地支藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      case RowType.hiddenStemsPrimary:
        return '藏干主气';
      case RowType.hiddenStemsSecondary:
        return '藏干中气';
      case RowType.hiddenStemsTertiary:
        return '藏干余气';
      case RowType.hiddenStemsPrimaryGods:
        return '藏干主神';
      case RowType.hiddenStemsSecondaryGods:
        return '藏干中神';
      case RowType.hiddenStemsTertiaryGods:
        return '藏干余神';
      case RowType.starYun:
        return '星运';
      case RowType.selfSiting:
        return '自坐';
      case RowType.columnHeaderRow:
        return '表头行';
      case RowType.separator:
        return '分割线';
    }
  }
}
