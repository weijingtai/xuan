import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/models/row_strategy.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/utils/constant_values_utils.dart';
import '../size_calculator/metrics.dart';
import 'card_utils.dart';

/// CardDataAdapter
///
/// 负责数据转换与适配,将 CardPayload 转换为 UI 所需的格式。
class CardDataAdapter {
  /// 构建 CellTextSpec 映射
  static Map<String, CellTextSpec> buildCellTextSpecMap({
    required CardPayload payload,
    required Map<RowType, RowComputationStrategy> rowStrategyMapper,
    Map<PillarType, PillarComputationStrategy>? pillarStrategyMapper,
    required TypographySection typography,
  }) {
    final specMap = <String, CellTextSpec>{};

    for (final rowUuid in payload.rowOrderUuid) {
      final row = payload.rowMap[rowUuid];
      if (row == null) continue;

      final rowValues = getRowValues(
        rowType: row.rowType,
        payload: payload,
        rowStrategyMapper: rowStrategyMapper,
        pillarStrategyMapper: pillarStrategyMapper,
      );

      for (final pillarUuid in payload.pillarOrderUuid) {
        final pillar = payload.pillarMap[pillarUuid];
        if (pillar == null) continue;

        final content = rowValues[pillarUuid] ?? '';
        final charCount = content.length;

        final fontSize = typography
            .getCellContentBy(row.rowType)
            .fontStyleDataModel
            .fontSize;

        specMap['\$rowUuid|\$pillarUuid'] = CellTextSpec(
          rowUuid: rowUuid,
          pillarUuid: pillarUuid,
          charCount: charCount,
          fontSize: fontSize,
        );
      }
    }

    return specMap;
  }

  /// 获取整行数据
  static Map<String, String> getRowValues({
    required RowType rowType,
    required CardPayload payload,
    required Map<RowType, RowComputationStrategy> rowStrategyMapper,
    Map<PillarType, PillarComputationStrategy>? pillarStrategyMapper,
  }) {
    final values = <String, String>{};

    final contentPillars = payload.pillarOrderUuid
        .map((uuid) => payload.pillarMap[uuid])
        .whereType<ContentPillarPayload>()
        .toList(growable: false);

    final pillars =
        contentPillars.map((p) => p.pillarContent).toList(growable: false);

    final ContentPillarPayload? dayPillar = contentPillars.isNotEmpty
        ? contentPillars.firstWhere(
            (p) => p.pillarType == PillarType.day,
            orElse: () => contentPillars.first,
          )
        : null;

    final dayJiaZi = dayPillar?.pillarContent.jiaZi;

    final textRowPayloads = payload.rowMap.values
        .whereType<TextRowPayload>()
        .where((r) => r.rowType == rowType);

    final tenGodLabelType = textRowPayloads.isNotEmpty
        ? textRowPayloads.first.tenGodLabelType
        : 'name';

    final isShortName = tenGodLabelType == 'singleName';

    // 1. 优先使用 Strategy（仅对内容柱计算）
    final strategy = rowStrategyMapper[rowType];
    if (strategy != null && contentPillars.isNotEmpty && dayPillar != null) {
      final input = RowComputationInput(
        pillars: pillars,
        dayJiaZi: dayPillar.pillarContent.jiaZi,
        gender: payload.gender,
        isShortName: isShortName,
      );

      final result = strategy.compute(input);

      for (final p in contentPillars) {
        values[p.uuid] = result.perPillarValues[p.pillarContent.id] ?? '';
      }
    }

    // 2. 补齐非内容柱（行标题列/分隔列），并为未被 strategy 覆盖的内容柱走基础逻辑
    for (final pillarUuid in payload.pillarOrderUuid) {
      final pillar = payload.pillarMap[pillarUuid];
      if (pillar == null) continue;

      if (pillar.pillarType == PillarType.separator) {
        values[pillar.uuid] = '';
        continue;
      }

      if (pillar.pillarType == PillarType.rowTitleColumn) {
        final title = (rowType == RowType.columnHeaderRow)
            ? FourZhuText.zaoLabelForGender(payload.gender)
            : CardUtils.labelForRowType(rowType);
        values[pillar.uuid] = title;
        continue;
      }

      if (pillar is! ContentPillarPayload) continue;

      if (pillarStrategyMapper != null && dayJiaZi != null) {
        final override =
            pillarStrategyMapper[pillar.pillarType]?.computeSingleValue(
          rowType,
          pillar.pillarContent.jiaZi,
          dayJiaZi,
          payload.gender,
        );
        if (override != null) {
          values[pillar.uuid] = override;
          continue;
        }
      }

      if (values.containsKey(pillar.uuid)) continue;

      final content = pillar.pillarContent;
      String text = '';

      switch (rowType) {
        case RowType.heavenlyStem:
          text = content.jiaZi.gan.name;
          break;
        case RowType.earthlyBranch:
          text = content.jiaZi.zhi.name;
          break;
        case RowType.naYin:
          text = content.jiaZi.naYinStr;
          break;
        case RowType.kongWang:
          final kw = content.jiaZi.getKongWang();
          text = '${kw.item1.name}${kw.item2.name}';
          break;
        case RowType.gu:
          final kw = content.jiaZi.getKongWang();
          text = '${kw.item1.name}${kw.item2.name}';
          break;
        case RowType.xu:
          final kw = content.jiaZi.getKongWang();
          text = '${kw.item1.sixChongZhi.name}${kw.item2.sixChongZhi.name}';
          break;
        case RowType.xunShou:
          text = content.jiaZi.xunHeader.name;
          break;
        case RowType.yiMa:
          final zhi = content.jiaZi.zhi;
          if (zhi == DiZhi.SHEN || zhi == DiZhi.ZI || zhi == DiZhi.CHEN) {
            text = DiZhi.YIN.value;
          } else if (zhi == DiZhi.YIN || zhi == DiZhi.WU || zhi == DiZhi.XU) {
            text = DiZhi.SHEN.value;
          } else if (zhi == DiZhi.SI || zhi == DiZhi.YOU || zhi == DiZhi.CHOU) {
            text = DiZhi.HAI.value;
          } else {
            text = DiZhi.SI.value;
          }
          break;
        case RowType.hiddenStems:
          text = content.jiaZi.zhi.cangGan.map((e) => e.name).join('');
          break;
        case RowType.columnHeaderRow:
          text = content.label;
          break;
        default:
          text = '';
      }
      values[pillar.uuid] = text;
    }

    return values;
  }

  /// 获取单元格样式
  static TextStyle getCellStyle({
    required RowType rowType,
    required String content,
    required EditableFourZhuCardTheme theme,
    required Brightness brightness,
    required ColorPreviewMode colorPreviewMode,
  }) {
    final ts = theme.typography.getCellContentBy(rowType);

    return ts.toTextStyle(
      char: content,
      colorPreviewMode: colorPreviewMode,
      brightness: brightness,
    );
  }
}
