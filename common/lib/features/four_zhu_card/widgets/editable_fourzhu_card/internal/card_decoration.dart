import 'package:flutter/material.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';

/// CardDecoration
///
/// 负责装饰样式计算(边距、内边距、边框等)。
class CardDecoration {
  /// 获取单元格装饰
  static BoxDecoration getCellDecoration({
    required RowType rowType,
    required EditableFourZhuCardTheme theme,
    required Brightness brightness,
  }) {
    final cellStyle = theme.cell.getBy(rowType);
    final border = cellStyle.border;
    final backgroundColor = cellStyle.resolveBackgroundColor(brightness);

    Color? borderColor;
    double borderWidth = 0.0;

    if (border != null && border.enabled) {
      borderWidth = border.width;
      borderColor = border.resolveColor(brightness);
    }

    // 如果没有边框配置，使用默认的透明边框以保持布局一致性
    // 或者根据设计需求，某些行可能有特定边框逻辑

    if ((borderWidth > 0 && borderColor != null) || backgroundColor != null) {
      return BoxDecoration(
        color: backgroundColor,
        border: (borderWidth > 0 && borderColor != null)
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(border?.radius ?? 0),
      );
    }

    return const BoxDecoration();
  }
}
