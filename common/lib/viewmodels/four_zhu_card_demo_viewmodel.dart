import 'package:common/features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_gender.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/layout_template_enums.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/enum_di_zhi.dart';
import '../models/eight_chars.dart';
import '../models/drag_payloads.dart';
import '../models/pillar_content.dart';
import '../models/row_strategy.dart';
import '../enums/layout_template_enums.dart';
import '../models/text_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/card_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/cell_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/pillar_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/text_groups.dart';
import '../themes/editable_four_zhu_card_theme.dart';
import '../viewmodels/editable_four_zhu_theme_controller.dart';
import '../themes/char_color_strategy.dart';

/// FourZhuCardDemoViewModel
/// 管理 EditableFourZhuCardDemoPage 的全部可配置状态与默认值，集中化更新接口，降低硬编码与重复。
///
/// 职责：
/// - 维护样式主题与主题控制器
/// - 维护 V3 卡片渲染的开关与文本样式覆盖
/// - 提供柱/行/内边距的 ValueNotifier 以供卡片订阅
class FourZhuCardDemoViewModel extends ChangeNotifier {
  /// 构造函数：初始化默认演示数据、主题与各项开关。
  FourZhuCardDemoViewModel() {
    _initDefaults();
  }

  late final Map<RowType, RowComputationStrategy> rowStrategyMapper;

  // late CardStyleConfig currentCardStyleConfig;

  /// 是否处于可编辑模式（预留，当前页面主要用于开关演示）。
  bool _isEditable = false;

  /// 是否启用“独立映射渲染”（禁用全局字体，按分组/行配置渲染）。
  bool _useIndependentMapping = true;

  /// V3 彩色模式开关（按字调色盘，支持深/浅色）。
  bool _v3ColorfulMode = false;

  /// Debug：滞回可视化开关（显示列/行中点及滞回边界）。
  bool _debugHysteresisOverlay = false;

  /// 抓手显示开关（同时控制抓手行与抓手列）。
  bool _showGrips = true;

  /// 分组字体样式覆盖。
  Map<TextGroup, TextStyle> _groupTextStyles = {};

  /// 按字符上色映射（在非彩色模式下应用）。
  Map<String, Color> _perCharColors = {};

  /// 类型安全的天干颜色覆写（非彩色模式时外部策略生成）。
  Map<TianGan, Color> _perGanColors = {};

  /// 类型安全的地支颜色覆写（非彩色模式时外部策略生成）。
  Map<DiZhi, Color> _perZhiColors = {};

  /// 每字颜色策略（外置），随主题明暗生成稳定映射。
  late CharColorStrategy _charColorStrategy;

  /// 当前主题配置与解析控制器。
  // late EditableFourZhuCardTheme _theme;
  // EditableFourZhuCardTheme get theme => _theme;

  late final ValueNotifier<EditableFourZhuCardTheme> themeNotifier;
  late final ValueNotifier<Brightness> cardBrightnessNotifier;
  late final ValueNotifier<ColorPreviewMode> colorPreviewModeNotifier;

  EditableFourZhuThemeController? _themeController;

  /// V3 载荷型 Notifier：柱/行/内边距。
  // late final ValueNotifier<List<PillarPayload>> pillarsNotifier;
  // late final ValueNotifier<List<TextRowPayload>> rowListNotifier;
  late final ValueNotifier<EdgeInsets> paddingNotifier;
  late final ValueNotifier<CardPayload> cardPayloadNotifier;

  void _initDefaults() {
    _initThemeStyleDefaults();
    _initStrategyDefaults();
  }

  void _initStrategyDefaults() {
    rowStrategyMapper = {
      RowType.tenGod: TenGodRowStrategy(),
      RowType.hiddenStemsTenGod: HiddenStemsTenGodsRowStrategy(),
      RowType.hiddenStems: HiddenStemsRowStrategy(),
      RowType.kongWang: KongWangRowStrategy(),
      RowType.gu: GuRowStrategy(),
      RowType.xu: XuRowStrategy(),
      RowType.naYin: NaYinRowStrategy(),
      RowType.xunShou: XunShouRowStrategy(),
      RowType.yiMa: YiMaRowStrategy(),
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

  /// 初始化默认数据与主题。
  void _initThemeStyleDefaults() {
    // 默认颜色策略初始化。
    _charColorStrategy = const DefaultCharColorStrategy();
    // 默认八字样例，仅用于构建柱内容展示；真实业务由上层提供。
    final sample = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time: JiaZi.DING_MAO,
    );

    themeNotifier = ValueNotifier(EditableFourZhuCardTheme(
      displayHeaderRow: true,
      displayRowTitleColumn: true,
      displayCellTitle: false,
      card: CardStyleConfig.defaultCardStyleConfig,
      cell: CellSection(
        pillarTitleCellConfig: CellStyleConfig.defaultCellStyleConfig,
        rowTitleCellConfig: CellStyleConfig.defaultCellStyleConfig.copyWith(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            border: BoxBorderStyle.defaultBorder.copyWith(enabled: false)),
        globalCellConfig: CellStyleConfig.defaultCellStyleConfig,
        rowTypeCellConfigMapper: {
          RowType.columnHeaderRow: CellStyleConfig.defaultCellStyleConfig,
          RowType.earthlyBranch: CellStyleConfig.defaultCellStyleConfig,
          RowType.heavenlyStem: CellStyleConfig.defaultCellStyleConfig,
          RowType.hiddenStems: CellStyleConfig.defaultCellStyleConfig,
          RowType.hiddenStemsTenGod: CellStyleConfig.defaultCellStyleConfig,
        },
      ),
      pillar: PillarSection(
        global: PillarStyleConfig.defaultPillarStyleConfig,
        mapper: {
          PillarType.year: PillarStyleConfig.defaultPillarStyleConfig,
          PillarType.month: PillarStyleConfig.defaultPillarStyleConfig,
          PillarType.day: PillarStyleConfig.defaultPillarStyleConfig,
          PillarType.hour: PillarStyleConfig.defaultPillarStyleConfig,
        },
        // Separator 专用配置
        defaultSeparatorConfig: PillarStyleConfig(
          border: BoxBorderStyle.defaultBorder
              .copyWith(enabled: false, radius: 0.0),
          lightBackgroundColor: Colors.transparent,
          darkBackgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          shadow: BoxShadowStyle.defaultShadow.copyWith(
              withShadow: false,
              lightThemeColor: Colors.transparent,
              darkThemeColor: Colors.transparent),
          separatorWidth: 16.0, // 使用用户设置的宽度
        ),
        // defaultMargin: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
        // borderWidth: 0,
      ),
      typography: TypographySection.defaultTypographySection,
    ));

    cardBrightnessNotifier = ValueNotifier<Brightness>(Brightness.light);
    colorPreviewModeNotifier =
        ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);

    // 默认主题：卡片边角与排版参数。
    _themeController = EditableFourZhuThemeController(themeNotifier.value);

    final titleUuid = Uuid().v4();
    final yearUuid = Uuid().v4();
    final monthUuid = Uuid().v4();
    final dayUuid = Uuid().v4();
    final hourUuid = Uuid().v4();
    // 初始化 V3 载荷 Notifier。
    // 第一列：行标题列（特殊柱）。
    final titleRowUuid = Uuid().v4();
    final heavenlyStemUuid = Uuid().v4();
    final earthlyBranchUuid = Uuid().v4();
    final naYinUuid = Uuid().v4();
    final kongWangUuid = Uuid().v4();
    final tenGodUuid = Uuid().v4();
    // 在 v3 卡片中默认显示“表头行”（列标题），位于索引 0。
    // 后续数据行（天干、地支、纳音）依次排列在其后。
    // rowListNotifier = ValueNotifier<List<TextRowPayload>>([

    // ]);

    CardPayload cardPayload = CardPayload(
      gender: Gender.male,
      pillarMap: {
        // 第一列：行标题列（特殊柱）
        titleUuid: RowTitleColumnPayload(uuid: titleUuid),
        // 数据柱：年月日时。
        yearUuid: ContentPillarPayload(
          uuid: yearUuid,
          pillarLabel: '年',
          pillarType: PillarType.year,
          pillarContent: PillarContent(
            id: 'pillar-year',
            pillarType: PillarType.year,
            label: '年',
            jiaZi: sample.year,
            description: '示例年柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        monthUuid: ContentPillarPayload(
          uuid: monthUuid,
          pillarLabel: '月',
          pillarType: PillarType.month,
          pillarContent: PillarContent(
            id: 'pillar-month',
            pillarType: PillarType.month,
            label: '月',
            jiaZi: sample.month,
            description: '示例月柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        dayUuid: ContentPillarPayload(
          uuid: dayUuid,
          pillarLabel: '日',
          pillarType: PillarType.day,
          pillarContent: PillarContent(
            id: 'pillar-day',
            pillarType: PillarType.day,
            label: '日',
            jiaZi: sample.day,
            description: '示例日柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        hourUuid: ContentPillarPayload(
          uuid: hourUuid,
          pillarLabel: '时',
          pillarType: PillarType.hour,
          pillarContent: PillarContent(
            id: 'pillar-hour',
            pillarType: PillarType.hour,
            label: '时',
            jiaZi: sample.time,
            description: '示例时柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        )
      },
      pillarOrderUuid: [yearUuid, monthUuid, dayUuid, hourUuid, titleUuid],
      rowMap: {
        titleRowUuid: TitleRowPayload(uuid: titleRowUuid),
        tenGodUuid: TextRowPayload(
          rowType: RowType.tenGod,
          rowLabel: '十神',
          uuid: tenGodUuid,
          titleInCell: false,
        ),
        heavenlyStemUuid: TextRowPayload(
          rowType: RowType.heavenlyStem,
          rowLabel: '天干',
          uuid: heavenlyStemUuid,
          titleInCell: false,
        ),
        earthlyBranchUuid: TextRowPayload(
          rowType: RowType.earthlyBranch,
          rowLabel: '地支',
          uuid: earthlyBranchUuid,
          titleInCell: false,
        ),
        naYinUuid: TextRowPayload(
          rowType: RowType.naYin,
          rowLabel: '纳音',
          uuid: naYinUuid,
          titleInCell: false,
        ),
        // 新增：空亡信息行，使用策略驱动按需计算每柱值
        kongWangUuid: TextRowPayload(
          rowType: RowType.kongWang,
          rowLabel: '空亡',
          uuid: kongWangUuid,
          titleInCell: false,
        ),
      },
      rowOrderUuid: [
        titleRowUuid,
        tenGodUuid,
        heavenlyStemUuid,
        earthlyBranchUuid,
        naYinUuid,
        kongWangUuid,
      ],
    );

    cardPayloadNotifier = ValueNotifier<CardPayload>(cardPayload);
    paddingNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);

    // 执行一次批量迁移：将旧数据中的 titleInCell 映射到样式层
    _migrateTitleInCellToCellStyle();
  }

  /// 返回当前主题。
  // EditableFourZhuCardTheme get theme => _theme;

  /// 返回当前主题控制器（可能为 null）。
  EditableFourZhuThemeController? get themeController => _themeController;

  /// 返回是否使用独立映射渲染。
  bool get useIndependentMapping => _useIndependentMapping;

  /// 返回彩色模式开关。
  bool get v3ColorfulMode => _v3ColorfulMode;

  /// 返回抓手显示开关。
  bool get showGrips => _showGrips;

  /// 返回分组文本样式覆盖。
  Map<TextGroup, TextStyle> get groupTextStyles => _groupTextStyles;

  /// 返回按字符上色映射。
  // Map<String, Color> get perCharColors => _perCharColors;

  /// 返回按天干类型安全映射（TianGan → Color）。
  // Map<TianGan, Color> get perGanColors => _perGanColors;

  /// 返回按地支类型安全映射（DiZhi → Color）。
  // Map<DiZhi, Color> get perZhiColors => _perZhiColors;

  /// 返回是否开启调试滞回可视化。
  bool get debugHysteresisOverlay => _debugHysteresisOverlay;

  /// 批量迁移：将载荷中的 titleInCell 映射为样式层的 showsTitleInCell
  /// 仅迁移非 header/separator 的行类型；行类型覆盖始终优先
  void _migrateTitleInCellToCellStyle() {
    final payload = cardPayloadNotifier.value;
    final theme = themeNotifier.value;
    final cell = theme.cell;
    final mapper =
        Map<RowType, CellStyleConfig>.of(cell.rowTypeCellConfigMapper);
    payload.rowMap.values.whereType<TextRowPayload>().forEach((row) {
      final rt = row.rowType;
      if (rt == RowType.columnHeaderRow || rt == RowType.separator) return;
      if (row.titleInCell) {
        final base = mapper[rt] ?? cell.globalCellConfig;
        mapper[rt] = base.copyWith(showsTitleInCell: true);
      }
    });
    updateEditableFourZhuCardTheme(
      theme.copyWith(
        cell: cell.copyWith(rowTypeCellConfigMapper: mapper),
      ),
    );
  }

  void updateEditableFourZhuCardTheme(EditableFourZhuCardTheme newTheme) {
    // _theme = newTheme;
    themeNotifier.value = newTheme;
    _themeController = EditableFourZhuThemeController(themeNotifier.value);
    // 主动同步内边距以触发 V3 的重算链，避免等值短路导致监听未触发
    paddingNotifier.value = newTheme.card.padding;
    final list =
        List<PillarPayload>.of(cardPayloadNotifier.value.pillarMap.values);
    for (var i = 0; i < list.length; i++) {
      final payload = list[i];
      final t = payload.pillarType;
      final style = _themeController?.resolvePillarStyleFor(t);
      if (style == null) continue;
      list[i] = payload.copyWith(
          // columnMargin: style.margin,
          // columnPadding: style.padding,
          // columnBorderWidth: style.border?.width,
          );
    }
    // pillarsNotifier.value = list;
    notifyListeners();
  }

  void updatePillarOrderFromTypes(List<PillarType> types) {
    final currentPayload = cardPayloadNotifier.value;
    final pillarMap = currentPayload.pillarMap;
    final usedUuids = <String>{};
    final newOrderUuid = <String>[];

    for (var type in types) {
      String? foundUuid;
      for (var entry in pillarMap.entries) {
        if (entry.value.pillarType == type && !usedUuids.contains(entry.key)) {
          foundUuid = entry.key;
          break;
        }
      }

      if (foundUuid != null) {
        newOrderUuid.add(foundUuid);
        usedUuids.add(foundUuid);
      }
    }

    // Append any remaining pillars that were not in the types list
    // (This ensures we don't accidentally lose pillars if the input list was partial)
    for (var uuid in currentPayload.pillarOrderUuid) {
      if (!usedUuids.contains(uuid)) {
        newOrderUuid.add(uuid);
      }
    }

    cardPayloadNotifier.value =
        currentPayload.copyWith(pillarOrderUuid: newOrderUuid);
    notifyListeners();
  }

  void updateRowOrderFromTypes(List<RowType> orderedTypes) {
    final currentPayload = cardPayloadNotifier.value;
    final rowMap = currentPayload.rowMap;
    final oldOrderUuid = currentPayload.rowOrderUuid;

    final newOrderUuid = <String>[];
    final typesSet = orderedTypes.toSet();

    // 1. Collect available UUIDs for the types in orderedTypes
    final availableUuidsByType = <RowType, List<String>>{};
    for (final uuid in oldOrderUuid) {
      final payload = rowMap[uuid];
      if (payload is TextRowPayload && typesSet.contains(payload.rowType)) {
        availableUuidsByType.putIfAbsent(payload.rowType, () => []).add(uuid);
      }
    }

    // 2. Slot Filling
    int orderedIndex = 0;

    for (final uuid in oldOrderUuid) {
      final payload = rowMap[uuid];
      if (payload is TextRowPayload && typesSet.contains(payload.rowType)) {
        // This is a slot. Fill with UUID of the next type in orderedTypes.
        if (orderedIndex < orderedTypes.length) {
          final nextType = orderedTypes[orderedIndex++];
          final candidates = availableUuidsByType[nextType];
          if (candidates != null && candidates.isNotEmpty) {
            newOrderUuid.add(candidates.removeAt(0));
          } else {
            // Fallback
            newOrderUuid.add(uuid);
          }
        } else {
          newOrderUuid.add(uuid);
        }
      } else {
        // Keep (e.g. separator or header if not in orderedTypes)
        newOrderUuid.add(uuid);
      }
    }

    cardPayloadNotifier.value =
        currentPayload.copyWith(rowOrderUuid: newOrderUuid);
    notifyListeners();
  }

  /// 设置是否启用独立映射渲染。
  /// 参数：v 表示开关值。
  /// 返回：无。
  void setUseIndependentMapping(bool v) {
    _useIndependentMapping = v;
    notifyListeners();
  }

  /// 设置彩色模式开关。
  /// 参数：v 表示开关值。
  /// 返回：无。
  void setV3ColorfulMode(bool v) {
    _v3ColorfulMode = v;
    notifyListeners();
  }

  /// 设置彩色模式并根据传入亮度立即应用映射（可选）。
  /// 参数：
  /// - v：彩色模式开关值；
  /// - brightness：可选的主题明暗，用于立即重建每字颜色映射。
  /// 返回：无。
  void setV3ColorfulModeWithBrightness(bool v, Brightness brightness) {
    _v3ColorfulMode = v;
    applyBrightness(brightness);
  }

  /// 设置抓手显示开关。
  /// 参数：v 表示开关值。
  /// 返回：无。
  void setShowGrips(bool v) {
    _showGrips = v;
    notifyListeners();
  }

  /// 更新分组文本样式覆盖。
  /// 参数：styles 分组到 TextStyle 的映射。
  /// 返回：无。
  void setGroupTextStyles(Map<TextGroup, TextStyle> styles) {
    _groupTextStyles = Map<TextGroup, TextStyle>.of(styles);
    notifyListeners();
  }

  /// 更新按字符上色映射。
  /// 参数：colors 字符到颜色的映射。
  /// 返回：无。
  void setPerCharColors(Map<String, Color> colors) {
    _perCharColors = Map<String, Color>.of(colors);
    notifyListeners();
  }

  /// 应用主题亮度到每字颜色映射：
  /// - 非彩色模式：按策略生成映射；
  /// - 彩色模式：清空外置映射，交由卡片内部调色。
  /// 参数：brightness 当前主题明暗。
  /// 返回：无。
  void applyBrightness(Brightness brightness) {
    if (!_v3ColorfulMode) {
      // 构建字符串键映射（向后兼容），并同步生成类型安全的天干/地支映射。
      final perChar =
          _charColorStrategy.buildPerCharColors(brightness: brightness);
      _perCharColors = perChar;
      _perGanColors = {
        for (final g in TianGan.values)
          if (perChar.containsKey(g.name)) g: perChar[g.name]!
      };
      _perZhiColors = {
        for (final z in DiZhi.values)
          if (perChar.containsKey(z.name)) z: perChar[z.name]!
      };
    } else {
      // 彩色模式交由卡片内部的 ElementColorResolver/Palette 处理；清空外置覆写。
      _perCharColors = {};
      _perGanColors = {};
      _perZhiColors = {};
    }
    notifyListeners();
  }

  /// 设置颜色策略（可替换为自定义策略）。
  /// 参数：strategy 新的颜色策略实现。
  /// 返回：无。
  void setColorStrategy(CharColorStrategy strategy) {
    // 替换策略引用；不立即触发映射重建，需外部调用 applyBrightness。
    _charColorStrategy = strategy;
  }

  /// 设置并重建主题控制器。
  /// 参数：t 新主题。
  /// 返回：无。
  void setTheme(EditableFourZhuCardTheme t) {
    themeNotifier.value = t;
    _themeController = EditableFourZhuThemeController(t);
    final list =
        List<PillarPayload>.of(cardPayloadNotifier.value.pillarMap.values);
    for (var i = 0; i < list.length; i++) {
      final payload = list[i];
      final t = payload.pillarType;
      final style = _themeController?.resolvePillarStyleFor(t);
      if (style == null) continue;
      // list[i] = payload.copyWith(
      //   columnMargin: style.margin,
      //   columnPadding: style.padding,
      //   columnBorderWidth: style.border?.width,
      // );
    }
    // pillarsNotifier.value = list;
    notifyListeners();
  }

  /// 设置调试滞回可视化开关。
  /// 参数：enable 是否开启。
  /// 返回：无。
  void setDebugHysteresisOverlay(bool enable) {
    _debugHysteresisOverlay = enable;
    notifyListeners();
  }

  /// 切换是否处于编辑模式（预留）。
  /// 参数：editable 新编辑状态。
  /// 返回：无。
  void setEditable(bool editable) {
    _isEditable = editable;
    notifyListeners();
  }

  /// 返回是否处于编辑模式（预留）。
  bool get isEditable => _isEditable;

  @override
  void dispose() {
    themeNotifier.dispose();
    cardBrightnessNotifier.dispose();
    colorPreviewModeNotifier.dispose();
    paddingNotifier.dispose();
    cardPayloadNotifier.dispose();
    super.dispose();
  }
}
