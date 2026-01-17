import 'package:common/enums/layout_template_enums.dart';

/// CardUtils
///
/// 通用工具函数集合。
class CardUtils {
  /// 像素对齐
  static double pixelFloor(double logical, double devicePixelRatio) {
    return (logical * devicePixelRatio).floorToDouble() / devicePixelRatio;
  }

  /// 判断是否为分隔行
  static bool isSeparatorRow(RowType rowType) {
    return rowType == RowType.separator;
  }

  /// 判断是否为分隔列
  static bool isSeparatorColumn(PillarType pillarType) {
    return pillarType == PillarType.separator;
  }

  /// 获取行类型标签
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
        return '地支藏干';
      case RowType.columnHeaderRow:
        return '表头行';
      case RowType.separator:
        return '分隔线';
      default:
        return type.name;
    }
  }
}
