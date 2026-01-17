import '../enums/layout_template_enums.dart';
import '../enums/enum_gender.dart';

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
      case RowType.gu:
        return '孤';
      case RowType.xu:
        return '虚';
      case RowType.xunShou:
        return '旬首';
      case RowType.yiMa:
        return '驿马';
      case RowType.hiddenStems:
        return '藏干';
      case RowType.hiddenStemsTenGod:
        return '藏神';
      case RowType.hiddenStemsPrimary:
        return '主气';
      case RowType.hiddenStemsSecondary:
        return '中气';
      case RowType.hiddenStemsTertiary:
        return '余气';
      case RowType.hiddenStemsPrimaryGods:
        return '主神';
      case RowType.hiddenStemsSecondaryGods:
        return '中神';
      case RowType.hiddenStemsTertiaryGods:
        return '余神';
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

class FourZhuText {
  static const String qianZao = '乾造';
  static const String kunZao = '坤造';
  static const String riYuan = '日元';

  static String zaoLabelForGender(Gender gender) {
    switch (gender) {
      case Gender.male:
        return qianZao;
      case Gender.female:
        return kunZao;
      case Gender.unknown:
        return riYuan;
    }
  }

  static String zaoLabelOrEmptyForGender(Gender gender) {
    switch (gender) {
      case Gender.male:
        return qianZao;
      case Gender.female:
        return kunZao;
      case Gender.unknown:
        return '';
    }
  }
}
