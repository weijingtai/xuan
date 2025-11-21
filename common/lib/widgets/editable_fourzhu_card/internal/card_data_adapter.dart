import 'package:flutter/material.dart';
import '../../../enums/layout_template_enums.dart';
import '../../../models/drag_payloads.dart';
import '../../../models/text_style_config.dart';
import '../../../models/row_strategy.dart';
import '../size_calculator/metrics.dart';
import '../../../themes/editable_four_zhu_card_theme.dart';

/// CardDataAdapter
///
/// 负责数据转换与适配,将 CardPayload 转换为 UI 所需的格式。
class CardDataAdapter {
  /// 构建 CellTextSpec 映射
  static Map<String, CellTextSpec> buildCellTextSpecMap({
    required CardPayload payload,
    required Map<RowType, RowComputationStrategy> rowStrategyMapper,
    required TypographySection typography,
  }) {
    final specMap = <String, CellTextSpec>{};

    for (final rowUuid in payload.rowOrderUuid) {
      final row = payload.rowMap[rowUuid];
      if (row == null) continue;

      for (final pillarUuid in payload.pillarOrderUuid) {
        final pillar = payload.pillarMap[pillarUuid];
        if (pillar == null) continue;

        final charCount = _calculateCharCount(
          rowType: row.rowType,
          pillarType: pillar.pillarType,
          rowStrategyMapper: rowStrategyMapper,
        );

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
  }) {
    // 1. 优先使用 Strategy
    final strategy = rowStrategyMapper[rowType];
    if (strategy != null) {
      // 构造 Input
      final pillars = payload.pillarOrderUuid
          .map((uuid) => payload.pillarMap[uuid])
          .whereType<ContentPillarPayload>() // 只处理内容柱
          .map((p) => p.pillarContent)
          .toList();

      // 查找日柱
      final dayPillar =
          payload.pillarMap.values.whereType<ContentPillarPayload>().firstWhere(
                (p) => p.pillarType == PillarType.day,
                orElse: () => payload.pillarMap.values
                    .whereType<ContentPillarPayload>()
                    .first,
              );

      final input = RowComputationInput(
        pillars: pillars,
        dayJiaZi: dayPillar.pillarContent.jiaZi,
        gender: payload.gender,
      );

      return strategy.compute(input).perPillarValues;
    }

    // 2. 处理非 Strategy 的基础行
    final values = <String, String>{};
    for (final pillarUuid in payload.pillarOrderUuid) {
      final pillar = payload.pillarMap[pillarUuid];
      if (pillar is! ContentPillarPayload) continue;

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
        case RowType.xunShou:
          text = content.jiaZi.xunHeader.name;
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

  /// 计算单元格字符数
  static int _calculateCharCount({
    required RowType rowType,
    required PillarType pillarType,
    required Map<RowType, RowComputationStrategy> rowStrategyMapper,
  }) {
    // 简化实现:根据行类型返回典型字符数
    switch (rowType) {
      case RowType.heavenlyStem:
      case RowType.earthlyBranch:
        return 1; // 单个天干/地支字符
      case RowType.tenGod:
        return 2; // 十神通常2个字
      case RowType.naYin:
        return 3; // 纳音通常3个字
      case RowType.kongWang:
        return 2; // 空亡2个字
      case RowType.hiddenStems:
      case RowType.hiddenStemsPrimary:
      case RowType.hiddenStemsSecondary:
      case RowType.hiddenStemsTertiary:
        return 3; // 藏干通常3个字
      case RowType.columnHeaderRow:
        return 4; // 列标题
      case RowType.separator:
        return 0; // 分隔线无文字
      default:
        return 2; // 默认2个字
    }
  }
}
