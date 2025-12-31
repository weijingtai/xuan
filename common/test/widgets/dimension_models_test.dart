import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/widgets/editable_fourzhu_card/dimension_models.dart';

void main() {
  group('MeasurementContext', () {
    test('工厂方法正确创建上下文', () {
      final ctx = MeasurementContext.fromStateConfig(
        pillarWidth: 64.0,
        otherCellHeight: 32.0,
        ganZhiHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
        rowTitleWidth: 52.0,
      );

      expect(ctx.defaultPillarWidth, 64.0);
      expect(ctx.ganZhiCellHeight, 48.0);
      expect(ctx.minPillarWidth, 40.0);
      expect(ctx.maxPillarWidth, 160.0);
    });
  });

  group('ColumnDimension', () {
    late MeasurementContext ctx;
    late PillarPayload normalPillar;
    late PillarPayload separatorPillar;
    late PillarPayload rowTitlePillar;

    setUp(() {
      ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
        rowTitleWidth: 52.0,
      );

      normalPillar =
          const PillarPayload(uuid: 'pillar-normal', pillarType: PillarType.year);

      separatorPillar = const PillarPayload(
        uuid: 'pillar-separator',
        pillarType: PillarType.separator,
      );

      rowTitlePillar = const PillarPayload(
        uuid: 'pillar-row-title',
        pillarType: PillarType.rowTitleColumn,
      );
    });

    test('普通柱使用默认宽度', () {
      final col = ColumnDimension(index: 0, payload: normalPillar);
      expect(col.measure(ctx), 64.0);
    });

    test('分隔列使用固定窄宽度', () {
      final col = ColumnDimension(index: 0, payload: separatorPillar);
      expect(col.measure(ctx), 9.6);
    });

    test('行标题列使用配置宽度', () {
      final col = ColumnDimension(index: 0, payload: rowTitlePillar);
      expect(col.measure(ctx), 52.0);
    });

    test('覆盖值优先于默认宽度', () {
      final col = ColumnDimension(
        index: 0,
        payload: normalPillar,
        widthOverride: 80.0,
      );
      expect(col.measure(ctx), 80.0);
    });

    test('覆盖值受最小最大值约束', () {
      final colMin = ColumnDimension(
        index: 0,
        payload: normalPillar,
        widthOverride: 20.0, // 低于最小值 40
      );
      expect(colMin.measure(ctx), 40.0);

      final colMax = ColumnDimension(
        index: 0,
        payload: normalPillar,
        widthOverride: 200.0, // 高于最大值 160
      );
      expect(colMax.measure(ctx), 160.0);
    });

    test('withWidthOverride 创建正确副本', () {
      final col = ColumnDimension(index: 0, payload: normalPillar);
      final updated = col.withWidthOverride(100.0);

      expect(updated.index, 0);
      expect(updated.payload, normalPillar);
      expect(updated.widthOverride, 100.0);
      expect(col.widthOverride, null); // 原对象不变
    });

    test('withIndex 创建正确副本', () {
      final col = ColumnDimension(
        index: 0,
        payload: normalPillar,
        widthOverride: 80.0,
      );
      final updated = col.withIndex(5);

      expect(updated.index, 5);
      expect(updated.widthOverride, 80.0); // 覆盖值保留
    });
  });

  group('RowDimension', () {
    late MeasurementContext ctx;
    late TextRowPayload normalRow;
    late TextRowPayload headerRow;
    late RowSeparatorPayload separatorRow;

    setUp(() {
      ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
      );

      normalRow = TextRowPayload(
        uuid: 'row-normal',
        rowType: RowType.tenGod,
        titleInCell: false,
      );

      headerRow = TextRowPayload(
        rowType: RowType.columnHeaderRow,
        uuid: 'row-header',
        titleInCell: false,
      );

      separatorRow = RowSeparatorPayload(uuid: 'row-separator');
    });

    test('普通行使用默认高度', () {
      final row = RowDimension(index: 0, payload: normalRow);
      // OtherCellDefaultStrategy 返回 otherHeight
      expect(row.measure(ctx), 32.0);
    });

    test('表头行使用固定高度', () {
      final row = RowDimension(index: 0, payload: headerRow);
      expect(row.measure(ctx), 24.0);
    });

    test('分隔行使用固定高度', () {
      final row = RowDimension(index: 0, payload: separatorRow);
      expect(row.measure(ctx), 8.8);
    });
  });

  group('CardLayoutModel - 基本功能', () {
    late PillarPayload pillar0, pillar1, pillar2;
    late TextRowPayload row0, row1, row2;
    late MeasurementContext ctx;

    setUp(() {
      ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
      );

      pillar0 = const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year);
      pillar1 =
          const PillarPayload(uuid: 'pillar-1', pillarType: PillarType.month);
      pillar2 = const PillarPayload(uuid: 'pillar-2', pillarType: PillarType.day);

      row0 = TextRowPayload(
        uuid: 'row-0',
        rowType: RowType.columnHeaderRow,
        titleInCell: false,
      );
      row1 = TextRowPayload(
        uuid: 'row-1',
        rowType: RowType.heavenlyStem,
        titleInCell: false,
      );
      row2 = TextRowPayload(
        uuid: 'row-2',
        rowType: RowType.tenGod,
        titleInCell: false,
      );
    });

    test('computeSize 正确计算总尺寸', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(index: 0, payload: pillar0),
          ColumnDimension(index: 1, payload: pillar1),
        ],
        rows: [
          RowDimension(index: 0, payload: row0), // 24
          RowDimension(index: 1, payload: row1), // 48
          RowDimension(index: 2, payload: row2), // 32
        ],
        padding: const EdgeInsets.all(10.0),
        dragHandleRowHeight: 20.0,
      );

      final size = model.computeSize(ctx);

      // 宽度: 64*2 + 10*2 + 20*2 = 188
      expect(size.width, 188.0);

      // 高度: 24+48+32 + 10*2 + 20*2 = 164
      expect(size.height, 164.0);
    });

    test('columnWidth 返回正确宽度', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(index: 0, payload: pillar0, widthOverride: 80.0),
          ColumnDimension(index: 1, payload: pillar1),
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );

      expect(model.columnWidth(0, ctx), 80.0);
      expect(model.columnWidth(1, ctx), 64.0);
      expect(model.columnWidth(10, ctx), 0.0); // 越界
    });

    test('sumColumnWidthsUpTo 正确累计宽度', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(index: 0, payload: pillar0), // 64
          ColumnDimension(index: 1, payload: pillar1), // 64
          ColumnDimension(index: 2, payload: pillar2), // 64
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );

      expect(model.sumColumnWidthsUpTo(0, ctx), 0.0);
      expect(model.sumColumnWidthsUpTo(1, ctx), 64.0);
      expect(model.sumColumnWidthsUpTo(2, ctx), 128.0);
      expect(model.sumColumnWidthsUpTo(3, ctx), 192.0);
    });
  });

  group('CardLayoutModel - 列操作', () {
    late CardLayoutModel model;
    late PillarPayload pillar0, pillar1, pillar2;
    late MeasurementContext ctx;

    setUp(() {
      ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
      );

      pillar0 = const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year);
      pillar1 =
          const PillarPayload(uuid: 'pillar-1', pillarType: PillarType.month);
      pillar2 = const PillarPayload(uuid: 'pillar-2', pillarType: PillarType.day);

      model = CardLayoutModel(
        columns: [
          ColumnDimension(index: 0, payload: pillar0),
          ColumnDimension(index: 1, payload: pillar1),
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );
    });

    test('insertColumn 正确插入并重建索引', () {
      final newCol = ColumnDimension(index: -1, payload: pillar2);
      final updated = model.insertColumn(1, newCol);

      expect(updated.columns.length, 3);
      expect(updated.columns[0].index, 0);
      expect(updated.columns[1].index, 1); // 新插入的
      expect(updated.columns[2].index, 2); // 原索引1变为2
      expect(updated.columns[1].payload, pillar2);
    });

    test('removeColumn 正确删除并重建索引', () {
      final updated = model.removeColumn(0);

      expect(updated.columns.length, 1);
      expect(updated.columns[0].index, 0); // 原索引1变为0
      expect(updated.columns[0].payload, pillar1);
    });

    test('reorderColumn 正确重排并重建索引', () {
      final modelWith3 = model.insertColumn(
        2,
        ColumnDimension(index: 2, payload: pillar2),
      );

      // 从索引0移动到索引2（末尾）
      final updated = modelWith3.reorderColumn(0, 3);

      expect(updated.columns.length, 3);
      expect(updated.columns[0].payload, pillar1); // 原索引1
      expect(updated.columns[1].payload, pillar2); // 原索引2
      expect(updated.columns[2].payload, pillar0); // 原索引0移到末尾

      // 验证索引正确
      expect(updated.columns[0].index, 0);
      expect(updated.columns[1].index, 1);
      expect(updated.columns[2].index, 2);
    });

    test('updateColumnWidth 正确更新宽度覆盖', () {
      final updated = model.updateColumnWidth(0, 100.0);

      expect(updated.columns[0].widthOverride, 100.0);
      expect(updated.columns[1].widthOverride, null);
      expect(model.columns[0].widthOverride, null); // 原模型不变
    });

    test('宽度覆盖在重排后自动跟随', () {
      final modelWithOverride = model.updateColumnWidth(0, 100.0);

      // 将索引0（有覆盖值）移动到索引2
      final updated = modelWithOverride.reorderColumn(0, 2);

      // 覆盖值应该跟随移动
      expect(updated.columns[1].widthOverride, 100.0);
      expect(updated.columns[1].payload, pillar0); // 确认是同一列
    });
  });

  group('CardLayoutModel - 行操作', () {
    late CardLayoutModel model;
    late TextRowPayload row0, row1, row2;
    late MeasurementContext ctx;

    setUp(() {
      ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
      );

      row0 = TextRowPayload(
        rowType: RowType.columnHeaderRow,
        uuid: 'row-0',
        titleInCell: false,
      );
      row1 = TextRowPayload(
        rowType: RowType.heavenlyStem,
        uuid: 'row-1',
        titleInCell: false,
      );
      row2 = TextRowPayload(
        rowType: RowType.tenGod,
        uuid: 'row-2',
        titleInCell: false,
      );

      model = CardLayoutModel(
        columns: [],
        rows: [
          RowDimension(index: 0, payload: row0),
          RowDimension(index: 1, payload: row1),
        ],
        padding: EdgeInsets.zero,
      );
    });

    test('insertRow 正确插入并重建索引', () {
      final newRow = RowDimension(index: -1, payload: row2);
      final updated = model.insertRow(1, newRow);

      expect(updated.rows.length, 3);
      expect(updated.rows[0].index, 0);
      expect(updated.rows[1].index, 1); // 新插入的
      expect(updated.rows[2].index, 2); // 原索引1变为2
    });

    test('removeRow 正确删除并重建索引', () {
      final updated = model.removeRow(0);

      expect(updated.rows.length, 1);
      expect(updated.rows[0].index, 0); // 原索引1变为0
      expect(updated.rows[0].payload, row1);
    });

    test('reorderRow 正确重排并重建索引', () {
      final modelWith3 = model.insertRow(
        2,
        RowDimension(index: 2, payload: row2),
      );

      final updated = modelWith3.reorderRow(0, 3);

      expect(updated.rows[0].payload, row1);
      expect(updated.rows[1].payload, row2);
      expect(updated.rows[2].payload, row0);

      expect(updated.rows[0].index, 0);
      expect(updated.rows[1].index, 1);
      expect(updated.rows[2].index, 2);
    });
  });

  group('CardLayoutModel - 工厂方法', () {
    test('fromNotifiers 正确构建模型', () {
      final pillars = [
        const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year),
        const PillarPayload(uuid: 'pillar-1', pillarType: PillarType.month),
      ];

      final rows = [
        TextRowPayload(
          rowType: RowType.columnHeaderRow,
          uuid: 'row-0',
          titleInCell: false,
        ),
      ];

      final model = CardLayoutModel.fromNotifiers(
        pillars: pillars,
        rows: rows,
        padding: const EdgeInsets.all(10.0),
        columnWidthOverrides: {0: 80.0},
      );

      expect(model.columns.length, 2);
      expect(model.rows.length, 1);
      expect(model.columns[0].widthOverride, 80.0);
      expect(model.padding, const EdgeInsets.all(10.0));
    });

    test('extractColumnWidthOverrides 正确提取覆盖值', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(
            index: 0,
            payload:
                const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year),
            widthOverride: 100.0,
          ),
          ColumnDimension(
            index: 1,
            payload:
                const PillarPayload(
                    uuid: 'pillar-1', pillarType: PillarType.month),
          ),
          ColumnDimension(
            index: 2,
            payload:
                const PillarPayload(uuid: 'pillar-2', pillarType: PillarType.day),
            widthOverride: 120.0,
          ),
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );

      final overrides = model.extractColumnWidthOverrides();

      expect(overrides.length, 2);
      expect(overrides[0], 100.0);
      expect(overrides[2], 120.0);
      expect(overrides.containsKey(1), false);
    });
  });

  group('CardLayoutModel - 边界情况', () {
    test('空模型计算尺寸', () {
      final model = CardLayoutModel(
        columns: [],
        rows: [],
        padding: EdgeInsets.zero,
        dragHandleRowHeight: 20.0,
      );

      final ctx = MeasurementContext(
        defaultPillarWidth: 64.0,
        defaultOtherCellHeight: 32.0,
        ganZhiCellHeight: 48.0,
        columnTitleHeight: 24.0,
        rowDividerHeightEffective: 8.8,
        colDividerWidthEffective: 9.6,
      );

      final size = model.computeSize(ctx);

      expect(size.width, 40.0); // 只有 dragHandleColWidth * 2
      expect(size.height, 40.0); // 只有 dragHandleRowHeight * 2
    });

    test('删除不存在的索引不影响模型', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(
            index: 0,
            payload:
                const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year),
          ),
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );

      final updated = model.removeColumn(10);

      expect(updated, model); // 返回原对象
      expect(updated.columns.length, 1);
    });

    test('插入索引自动钳位到有效范围', () {
      final model = CardLayoutModel(
        columns: [
          ColumnDimension(
            index: 0,
            payload:
                const PillarPayload(uuid: 'pillar-0', pillarType: PillarType.year),
          ),
        ],
        rows: [],
        padding: EdgeInsets.zero,
      );

      final newCol = ColumnDimension(
        index: -1,
        payload:
            const PillarPayload(uuid: 'pillar-new', pillarType: PillarType.month),
      );

      // 插入到负数索引，应该钳位到0
      final updated = model.insertColumn(-5, newCol);

      expect(updated.columns.length, 2);
      expect(updated.columns[0].payload.pillarType, PillarType.month);
    });
  });
}
