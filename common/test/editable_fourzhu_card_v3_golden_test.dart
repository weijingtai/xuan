import 'package:common/widgets/editable_fourzhu_card/card_grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:common/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import 'package:common/widgets/editable_fourzhu_card/card_grid_painter.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/pillar_content.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/pillar_content.dart' as model;
import 'package:common/models/row_strategy.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/models/text_style_config.dart';
import 'test_editable_fourzhu_card_defaults.dart';

/// Builds a minimal `PillarContent` instance for a four pillars chart.
///
/// Parameters:
/// - [id]: Unique pillar id such as `year#1`.
/// - [pillarType]: Type of pillar (e.g., `PillarType.year`).
/// - [label]: Optional title label to display.
///
/// Returns: A `PillarContent` with the specified identity and basic fields.
/// 创建符合当前 `PillarContent` 构造签名的示例数据。
model.PillarContent _pillarContent({
  required String id,
  required PillarType pillarType,
  String? label,
}) {
  // 使用任意合法的甲子作为示例干支。
  final JiaZi jiaZi = JiaZi.JIA_ZI;
  return model.PillarContent(
    id: id,
    pillarType: pillarType,
    label: label ?? '',
    jiaZi: jiaZi,
    description: null,
    version: '1',
    sourceKind: PillarSourceKind.userInput,
    operationType: null,
  );
}

/// Creates a basic pillars list including the row-title column and 年/月/日/时列。
///
/// Returns: List of `PillarPayload` used to render the grid.
List<PillarPayload> _buildPillars() {
  return [
    const RowTitleColumnPayload(uuid: 'row-title'),
    ContentPillarPayload(
      uuid: 'year-col',
      pillarType: PillarType.year,
      pillarLabel: '年',
      pillarContent:
          _pillarContent(id: 'year#1', pillarType: PillarType.year, label: '年'),
    ),
    ContentPillarPayload(
      uuid: 'month-col',
      pillarType: PillarType.month,
      pillarLabel: '月',
      pillarContent: _pillarContent(
          id: 'month#1', pillarType: PillarType.month, label: '月'),
    ),
    ContentPillarPayload(
      uuid: 'day-col',
      pillarType: PillarType.day,
      pillarLabel: '日',
      pillarContent:
          _pillarContent(id: 'day#1', pillarType: PillarType.day, label: '日'),
    ),
    ContentPillarPayload(
      uuid: 'hour-col',
      pillarType: PillarType.hour,
      pillarLabel: '时',
      pillarContent:
          _pillarContent(id: 'hour#1', pillarType: PillarType.hour, label: '时'),
    ),
  ];
}

/// Creates a basic rows list including 表头/天干/地支/分隔/纳音/空亡。
///
/// 参数：
/// - [pillars]：用于构建每行值的柱列表（包含 `pillarContent`）。
///
/// 返回：用于渲染网格的 `RowInfoPayload` 列表。
List<TextRowPayload> _buildRows(List<PillarPayload> pillars) {
  return [
    ColumnHeaderRowPayload(uuid: 'header', gender: Gender.male),
    TextRowPayload(
        uuid: 'stem-row',
        rowType: RowType.heavenlyStem,
        rowLabel: '天干',
        titleInCell: false),
    TextRowPayload(
        uuid: 'branch-row',
        rowType: RowType.earthlyBranch,
        rowLabel: '地支',
        titleInCell: false),
    TextRowPayload(
        uuid: 'sep-row',
        rowType: RowType.separator,
        rowLabel: '分隔符',
        titleInCell: false),
    TextRowPayload(
        uuid: 'nayin-row',
        rowType: RowType.naYin,
        rowLabel: '纳音',
        titleInCell: false),
    TextRowPayload(
        uuid: 'kw-row',
        rowType: RowType.kongWang,
        rowLabel: '空亡',
        titleInCell: false),
  ];
}

/// Pumps an `EditableFourZhuCardV3` inside a sized material app for golden testing.
///
/// Parameters:
/// - [tester]: The widget tester instance.
/// - [pillars]: Pillars to render in the card。
/// - [rows]: Rows to render in the card。
/// - [size]: Fixed size for reproducible snapshots。
///
/// Returns: Nothing. Awaits the frame pump completion.
/// 渲染并等待一个带固定尺寸与唯一边界键的 V3 卡片。
///
/// 参数：
/// - [tester]：测试器实例。
/// - [pillars]：列数据。
/// - [rows]：行数据。
/// - [size]：固定画布尺寸，保证快照可重复。
///
/// 返回：无（等待渲染完成）。
Future<void> _pumpCard(
  WidgetTester tester, {
  required List<PillarPayload> pillars,
  required List<TextRowPayload> rows,
  Size size = const Size(420, 280),
}) async {
  // 设定固定画布尺寸，避免设备不同导致快照不一致。
  await tester.binding.setSurfaceSize(size);

  final themeNotifier = ValueNotifier<EditableFourZhuCardTheme>(
      EditableCardThemeBuilder.createDefaultTheme());
  final brightnessNotifier = ValueNotifier<Brightness>(Brightness.light);
  final colorPreviewModeNotifier =
      ValueNotifier<ColorPreviewMode>(ColorPreviewMode.pure);
  final paddingNotifier = ValueNotifier<EdgeInsets>(const EdgeInsets.all(8));
  final rowStrategyMapper = defaultRowStrategyMapper();

  final cardPayload = CardPayload(
    gender: Gender.male,
    pillarMap: {for (final p in pillars) p.uuid: p},
    pillarOrderUuid: pillars.map((e) => e.uuid).toList(),
    rowMap: {for (final r in rows) r.uuid: r},
    rowOrderUuid: rows.map((e) => e.uuid).toList(),
  );
  final cardPayloadNotifier = ValueNotifier<CardPayload>(cardPayload);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: RepaintBoundary(
              key: const Key('v3-card-boundary'),
              child: EditableFourZhuCardV3(
                dayGanZhi: JiaZi.JIA_ZI,
                brightnessNotifier: brightnessNotifier,
                colorPreviewModeNotifier: colorPreviewModeNotifier,
                themeNotifier: themeNotifier,
                cardPayloadNotifier: cardPayloadNotifier,
                paddingNotifier: paddingNotifier,
                rowStrategyMapper: rowStrategyMapper,
                gender: Gender.male,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// Golden 基线：默认参数下的 EditableFourZhuCardV3 网格与分隔线绘制。
///
/// 验收：生成 `goldens/editable_fourzhu_card_v3_default.png`，用于后续回归对比。
void main() {
  // 仅网格画笔 Golden：确保分隔线绘制基线稳定
  testWidgets('CardGridPainter golden: default grid/separators baseline',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 280));
    // 构造示例坐标：左侧标题列 52 宽，数据列统一 64 宽
    const double leftInset = 8;
    const double topInset = 8;
    const double rowTitleWidth = 52;
    const double colWidth = 64;
    final verticalXs = <double>[
      leftInset + rowTitleWidth,
      leftInset + rowTitleWidth + colWidth,
      leftInset + rowTitleWidth + colWidth * 2,
      leftInset + rowTitleWidth + colWidth * 3,
      leftInset + rowTitleWidth + colWidth * 4,
    ];
    final horizontalYs = <double>[
      topInset + 24, // 表头行
      topInset + 24 + 48, // 天干
      topInset + 24 + 48 * 2, // 地支
      topInset + 24 + 48 * 2 + 8, // 分隔行
      topInset + 24 + 48 * 2 + 8 + 32, // 纳音
      topInset + 24 + 48 * 2 + 8 + 32 * 2, // 空亡
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              height: 280,
              child: RepaintBoundary(
                key: const Key('grid-boundary'),
                child: CustomPaint(
                  painter: CardGridPainter(
                    verticalXs: verticalXs,
                    horizontalYs: horizontalYs,
                    topInset: topInset,
                    leftInset: leftInset,
                    rightInset: 8,
                    bottomInset: 8,
                    columnColor: const Color(0x22000000),
                    columnThickness: 1.0,
                    rowColor: const Color(0x22000000),
                    rowThickness: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('grid-boundary')),
      matchesGoldenFile('goldens/card_grid_painter_default.png'),
    );
  });

  testWidgets('EditableFourZhuCardV3 golden: default grid and separators',
      (tester) async {
    final pillars = _buildPillars();
    await _pumpCard(
      tester,
      pillars: pillars,
      rows: _buildRows(pillars),
      size: const Size(920, 360),
    );

    await expectLater(
      find.byKey(const Key('v3-card-boundary')),
      matchesGoldenFile('goldens/editable_fourzhu_card_v3_default.png'),
    );
  });
}
