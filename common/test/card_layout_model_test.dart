import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/widgets/four_zhu/card_layout_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

/// CardLayoutModel 单元测试
///
/// 覆盖高度解析与抓手可见性/有效宽度的核心行为。
void main() {
  group('CardLayoutModel.resolveRowHeight', () {
    test('分隔行返回 dividerHeight', () {
      final model = CardLayoutModel(dividerHeight: 6);
      final h =
          model.resolveRowHeight(RowType.separator, defaultCellHeight: 28);
      expect(h, 6);
    });

    test('payload 驱动高度解析（忽略入参 rowType）', () {
      final payload = TextRowPayload(
        rowType: RowType.separator,
        uuid: 'sep-row',
        titleInCell: false,
        rowLabel: '分隔符',
      );
      final model = CardLayoutModel(dividerHeight: 8);
      final h = model.resolveRowHeight(
        RowType.naYin,
        payload: payload,
        defaultCellHeight: 28,
      );
      expect(h, 8);
    });

    test('表头行返回默认 header（由 defaultCellHeight 传入）', () {
      final payload = TextRowPayload(
        rowType: RowType.columnHeaderRow,
        uuid: 'header-row',
        titleInCell: false,
        rowLabel: '表头',
      );
      final model = CardLayoutModel();
      final h = model.resolveRowHeight(RowType.columnHeaderRow,
          payload: payload, defaultCellHeight: 24);
      expect(h, 24);
    });

    test('干支行与一般行在缺省时回退到 defaultCellHeight', () {
      final model = CardLayoutModel();
      expect(
          model.resolveRowHeight(RowType.heavenlyStem, defaultCellHeight: 48),
          48);
      expect(model.resolveRowHeight(RowType.naYin, defaultCellHeight: 32), 32);
    });
  });

  group('CardLayoutModel grip visibility and width', () {
    test('分隔行强制隐藏抓手', () {
      final model = CardLayoutModel(gripVisibleWidth: 12, gripHiddenWidth: 0);
      final visible =
          model.isGripVisibleForRow(RowType.separator, showGripsConfig: true);
      expect(visible, isFalse);
      expect(model.effectiveGripWidth(isVisible: visible), 0);
    });

    test('普通行按配置显示抓手并返回可见宽度', () {
      final model = CardLayoutModel(gripVisibleWidth: 14, gripHiddenWidth: 0);
      final visible =
          model.isGripVisibleForRow(RowType.naYin, showGripsConfig: true);
      expect(visible, isTrue);
      expect(model.effectiveGripWidth(isVisible: visible), 14);
    });
  });

  group('CardLayoutModel grip effective height', () {
    test('抓手隐藏时有效高度为 0', () {
      final model = CardLayoutModel(
        gripVisibleWidth: 20.0,
        gripHiddenWidth: 0.0,
      );
      expect(model.effectiveGripHeight(isVisible: false), 0.0);
    });

    test('抓手显示时有效高度为可见值', () {
      final model = CardLayoutModel(
        gripVisibleWidth: 20.0,
        gripHiddenWidth: 0.0,
      );
      expect(model.effectiveGripHeight(isVisible: true), 20.0);
    });
  });

  group('CardLayoutModel divider effective sizes', () {
    test('行分割线有效高度 = paddingTop + paddingBottom + thickness', () {
      final model = CardLayoutModel(
        rowDividerPaddingTop: 4,
        rowDividerPaddingBottom: 6,
        rowDividerThickness: 0.8,
      );
      expect(model.rowDividerHeightEffective, closeTo(10.8, 0.001));
    });

    test('列分割线有效宽度 = paddingLeft + paddingRight + thickness', () {
      final model = CardLayoutModel(
        colDividerPaddingLeft: 3,
        colDividerPaddingRight: 5,
        colDividerThickness: 1.2,
      );
      expect(model.colDividerWidthEffective, closeTo(9.2, 0.001));
    });
  });
}
