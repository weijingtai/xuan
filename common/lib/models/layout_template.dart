import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'text_style_config.dart';

import '../const_resources_mapper.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/enum_di_zhi.dart';
import '../enums/layout_template_enums.dart';

class _Unset {
  const _Unset();
}

class LayoutTemplate {
  static const _Unset _unset = _Unset();

  LayoutTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.collectionId,
    required this.cardStyle,
    required List<ChartGroup> chartGroups,
    required List<RowConfig> rowConfigs,
    Map<String, dynamic>? editableTheme,
    this.version = 1,
    required this.updatedAt,
  })  : chartGroups = List.unmodifiable(chartGroups),
        rowConfigs = List.unmodifiable(rowConfigs),
        editableTheme = editableTheme == null
            ? null
            : Map<String, dynamic>.unmodifiable(editableTheme);

  final String id;
  final String name;
  final String? description;
  final String collectionId;
  final CardStyle cardStyle;
  final List<ChartGroup> chartGroups;
  final List<RowConfig> rowConfigs;
  final Map<String, dynamic>? editableTheme;
  final int version;
  final DateTime updatedAt;

  LayoutTemplate copyWith({
    String? id,
    String? name,
    Object? description = _unset,
    String? collectionId,
    CardStyle? cardStyle,
    List<ChartGroup>? chartGroups,
    List<RowConfig>? rowConfigs,
    Object? editableTheme = _unset,
    int? version,
    DateTime? updatedAt,
  }) {
    return LayoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      collectionId: collectionId ?? this.collectionId,
      cardStyle: cardStyle ?? this.cardStyle,
      chartGroups: chartGroups ?? this.chartGroups,
      rowConfigs: rowConfigs ?? this.rowConfigs,
      editableTheme: identical(editableTheme, _unset)
          ? this.editableTheme
          : editableTheme as Map<String, dynamic>?,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'collectionId': collectionId,
      'cardStyle': cardStyle.toJson(),
      'chartGroups': chartGroups.map((group) => group.toJson()).toList(),
      'rowConfigs': rowConfigs.map((config) => config.toJson()).toList(),
      'editableTheme': editableTheme,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LayoutTemplate.fromJson(Map<String, dynamic> json) {
    return LayoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      collectionId: json['collectionId'] as String,
      cardStyle: CardStyle.fromJson(json['cardStyle'] as Map<String, dynamic>),
      chartGroups: (json['chartGroups'] as List<dynamic>)
          .map((item) => ChartGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
      rowConfigs: (json['rowConfigs'] as List<dynamic>)
          .map((item) => RowConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
      editableTheme: (json['editableTheme'] as Map?)?.cast<String, dynamic>(),
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutTemplate &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.collectionId == collectionId &&
        other.cardStyle == cardStyle &&
        const ListEquality<ChartGroup>()
            .equals(other.chartGroups, chartGroups) &&
        const ListEquality<RowConfig>().equals(other.rowConfigs, rowConfigs) &&
        const DeepCollectionEquality()
            .equals(other.editableTheme, editableTheme) &&
        other.version == version &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        collectionId,
        cardStyle,
        const ListEquality<ChartGroup>().hash(chartGroups),
        const ListEquality<RowConfig>().hash(rowConfigs),
        const DeepCollectionEquality().hash(editableTheme),
        version,
        updatedAt,
      );
}

class ChartGroup {
  ChartGroup({
    required this.id,
    required this.title,
    required List<PillarType> pillarOrder,
    this.locked = false,
    this.colorHex,
    this.expanded = true,
  }) : pillarOrder = List.unmodifiable(pillarOrder);

  final String id;
  final String title;
  final List<PillarType> pillarOrder;
  final bool locked;
  final String? colorHex;
  final bool expanded;

  ChartGroup copyWith({
    String? id,
    String? title,
    List<PillarType>? pillarOrder,
    bool? locked,
    String? colorHex,
    bool? expanded,
  }) {
    return ChartGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      pillarOrder: pillarOrder ?? this.pillarOrder,
      locked: locked ?? this.locked,
      colorHex: colorHex ?? this.colorHex,
      expanded: expanded ?? this.expanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pillarOrder': pillarOrder.map((pillar) => pillar.name).toList(),
      'locked': locked,
      'colorHex': colorHex,
      'expanded': expanded,
    };
  }

  factory ChartGroup.fromJson(Map<String, dynamic> json) {
    return ChartGroup(
      id: json['id'] as String,
      title: json['title'] as String,
      pillarOrder: (json['pillarOrder'] as List<dynamic>)
          .map((name) => PillarType.values.firstWhere(
              (element) => element.name == name as String,
              orElse: () => PillarType.year))
          .toList(),
      locked: json['locked'] as bool? ?? false,
      colorHex: json['colorHex'] as String?,
      expanded: json['expanded'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ChartGroup &&
        other.id == id &&
        other.title == title &&
        const ListEquality<PillarType>()
            .equals(other.pillarOrder, pillarOrder) &&
        other.locked == locked &&
        other.colorHex == colorHex &&
        other.expanded == expanded;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        const ListEquality<PillarType>().hash(pillarOrder),
        locked,
        colorHex,
        expanded,
      );
}

class CardStyle {
  const CardStyle({
    required this.dividerType,
    required this.dividerColorHex,
    required this.dividerThickness,
    required this.globalFontFamily,
    required this.globalFontSize,
    required this.globalFontColorHex,
    this.contentPadding = const EdgeInsets.all(16.0),
  });

  static String _normalizeFontFamily(String value) {
    if (value == 'NotoSansSC' || value == 'NotoSans')
      return 'NotoSansSC-Regular';
    return value;
  }

  final BorderType dividerType;
  final String dividerColorHex;
  final double dividerThickness;
  final String globalFontFamily;
  final double globalFontSize;
  final String globalFontColorHex;
  final EdgeInsets contentPadding;

  CardStyle copyWith({
    BorderType? dividerType,
    String? dividerColorHex,
    double? dividerThickness,
    String? globalFontFamily,
    double? globalFontSize,
    String? globalFontColorHex,
    EdgeInsets? contentPadding,
  }) {
    return CardStyle(
      dividerType: dividerType ?? this.dividerType,
      dividerColorHex: dividerColorHex ?? this.dividerColorHex,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      globalFontFamily: globalFontFamily ?? this.globalFontFamily,
      globalFontSize: globalFontSize ?? this.globalFontSize,
      globalFontColorHex: globalFontColorHex ?? this.globalFontColorHex,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dividerType': dividerType.name,
      'dividerColorHex': dividerColorHex,
      'dividerThickness': dividerThickness,
      'globalFontFamily': _normalizeFontFamily(globalFontFamily),
      'globalFontSize': globalFontSize,
      'globalFontColorHex': globalFontColorHex,
      'contentPadding': {
        'left': contentPadding.left,
        'top': contentPadding.top,
        'right': contentPadding.right,
        'bottom': contentPadding.bottom,
      },
    };
  }

  factory CardStyle.fromJson(Map<String, dynamic> json) {
    final dividerTypeName = json['dividerType'] as String?;
    final dividerType = dividerTypeName != null
        ? BorderType.values.firstWhere(
            (element) => element.name == dividerTypeName,
            orElse: () => BorderType.solid,
          )
        : BorderType.solid;

    return CardStyle(
      dividerType: dividerType,
      dividerColorHex: json['dividerColorHex'] as String? ?? '#FFFFFFFF',
      dividerThickness: (json['dividerThickness'] as num?)?.toDouble() ?? 1,
      globalFontFamily: () {
        final f = json['globalFontFamily'] as String? ?? 'NotoSansSC-Regular';
        return (f == 'NotoSansSC' || f == 'NotoSans')
            ? 'NotoSansSC-Regular'
            : f;
      }(),
      globalFontSize: (json['globalFontSize'] as num?)?.toDouble() ?? 14.0,
      globalFontColorHex: json['globalFontColorHex'] as String? ?? '#FF000000',
      contentPadding: () {
        final m = json['contentPadding'] as Map<String, dynamic>?;
        if (m == null) return const EdgeInsets.all(16.0);
        double pick(String k) => (m[k] as num?)?.toDouble() ?? 0.0;
        return EdgeInsets.fromLTRB(
          pick('left'),
          pick('top'),
          pick('right'),
          pick('bottom'),
        );
      }(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CardStyle &&
        other.dividerType == dividerType &&
        other.dividerColorHex == dividerColorHex &&
        other.dividerThickness == dividerThickness &&
        _normalizeFontFamily(other.globalFontFamily) ==
            _normalizeFontFamily(globalFontFamily) &&
        other.globalFontSize == globalFontSize &&
        other.globalFontColorHex == globalFontColorHex &&
        other.contentPadding == contentPadding;
  }

  @override
  int get hashCode => Object.hash(
        dividerType,
        dividerColorHex,
        dividerThickness,
        _normalizeFontFamily(globalFontFamily),
        globalFontSize,
        globalFontColorHex,
        contentPadding,
      );
}

class RowConfig {
  const RowConfig({
    required this.type,
    required this.isVisible,
    required this.isTitleVisible,
    required this.textStyleConfig,
    this.textAlign,
    this.paddingVertical,
    this.paddingHorizontal,
    this.marginVertical,
    this.marginHorizontal,
    this.borderType,
    this.borderColorHex,
    this.tenGodLabelType = 'name',
  });

  final RowType type;
  final bool isVisible;
  final bool isTitleVisible;

  /// 新版文本样式配置（优先于旧的离散字段）。
  final TextStyleConfig textStyleConfig;
  final RowTextAlign? textAlign;
  final double? paddingVertical;
  // New: per-row spacing controls
  // marginVertical: extra top/bottom outside space per row (px)
  // marginHorizontal: extra left/right outside space per row (px)
  // paddingHorizontal: extra left/right inside padding per row (px)
  final double? marginVertical;
  final double? marginHorizontal;
  final double? paddingHorizontal;
  final BorderType? borderType;
  final String? borderColorHex;

  /// 'name' (2 chars) or 'shortName' (1 char)
  final String tenGodLabelType;

  RowConfig copyWith({
    RowType? type,
    bool? isVisible,
    bool? isTitleVisible,
    TextStyleConfig? textStyleConfig,
    RowTextAlign? textAlign,
    double? padding,
    double? marginVertical,
    double? marginHorizontal,
    double? paddingHorizontal,
    BorderType? borderType,
    String? borderColorHex,
    String? tenGodLabelType,
  }) {
    return RowConfig(
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      isTitleVisible: isTitleVisible ?? this.isTitleVisible,
      textStyleConfig: textStyleConfig ?? this.textStyleConfig,
      textAlign: textAlign ?? this.textAlign,
      paddingVertical: padding ?? this.paddingVertical,
      marginVertical: marginVertical ?? this.marginVertical,
      marginHorizontal: marginHorizontal ?? this.marginHorizontal,
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      borderType: borderType ?? this.borderType,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      tenGodLabelType: tenGodLabelType ?? this.tenGodLabelType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isVisible': isVisible,
      'isTitleVisible': isTitleVisible,
      // 新版样式字段（优先写入）
      'textStyleConfig': textStyleConfig.toJson(),
      'textAlign': textAlign?.name,
      'padding': paddingVertical,
      'marginVertical': marginVertical,
      'marginHorizontal': marginHorizontal,
      'paddingHorizontal': paddingHorizontal,
      'borderType': borderType?.name,
      'borderColorHex': borderColorHex,
      'tenGodLabelType': tenGodLabelType,
    };
  }

  /// 根据 RowType 生成带有完整颜色映射的默认 TextStyleConfig
  static TextStyleConfig _generateDefaultTextStyleConfig(RowType rowType) {
    Map<String, Color> pureLightMapper;
    Map<String, Color> colorfulLightMapper;
    Map<String, Color> pureDarkMapper;
    Map<String, Color> colorfulDarkMapper;

    switch (rowType) {
      case RowType.heavenlyStem:
      case RowType.hiddenStemsPrimary:
      case RowType.hiddenStemsSecondary:
      case RowType.hiddenStemsTertiary:
        // 天干：10 个颜色映射
        pureLightMapper = Map.fromEntries(
          TianGan.values.take(10).map((g) => MapEntry(g.name, Colors.black87)),
        );
        colorfulLightMapper = ConstResourcesMapper.zodiacGanColors.map(
          (key, value) => MapEntry(key.name, value),
        );
        pureDarkMapper = Map.fromEntries(
          TianGan.values.take(10).map((g) => MapEntry(g.name, Colors.white70)),
        );
        colorfulDarkMapper = colorfulLightMapper;
        break;

      case RowType.earthlyBranch:
        // 地支：12 个颜色映射
        pureLightMapper = Map.fromEntries(
          DiZhi.values.take(12).map((z) => MapEntry(z.name, Colors.black87)),
        );
        colorfulLightMapper = ConstResourcesMapper.zodiacZhiColors.map(
          (key, value) => MapEntry(key.name, value),
        );
        pureDarkMapper = Map.fromEntries(
          DiZhi.values.take(12).map((z) => MapEntry(z.name, Colors.white70)),
        );
        colorfulDarkMapper = colorfulLightMapper;
        break;

      case RowType.tenGod:
      case RowType.hiddenStemsTenGod:
      case RowType.hiddenStemsPrimaryGods:
      case RowType.hiddenStemsSecondaryGods:
      case RowType.hiddenStemsTertiaryGods:
        // 十神 & 藏干(神)：使用十神颜色
        return TextStyleConfig.defaultTenGodsConfig;

      default:
        // 其他行类型使用现有的默认配置
        return TextStyleConfig.defaultConfig;
    }

    return TextStyleConfig(
      colorMapperDataModel: ColorMapperDataModel(
        pureLightMapper: pureLightMapper,
        colorfulLightMapper: colorfulLightMapper,
        pureDarkMapper: pureDarkMapper,
        colorfulDarkMapper: colorfulDarkMapper,
      ),
      textShadowDataModel: TextShadowDataModel(),
      fontStyleDataModel: FontStyleDataModel(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontFamily: 'NotoSansSC-Regular',
        height: 1.2,
      ),
    );
  }

  factory RowConfig.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final rowType = typeName != null
        ? RowType.values.firstWhere(
            (element) => element.name == typeName,
            orElse: () => RowType.heavenlyStem,
          )
        : RowType.heavenlyStem;
    final textAlignName = json['textAlign'] as String?;
    final textAlign = textAlignName != null
        ? RowTextAlign.values.firstWhere(
            (e) => e.name == textAlignName,
            orElse: () => RowTextAlign.left,
          )
        : null;
    final borderTypeName = json['borderType'] as String?;
    final borderType = borderTypeName != null
        ? BorderType.values.firstWhere(
            (e) => e.name == borderTypeName,
            orElse: () => BorderType.solid,
          )
        : null;

    // 读取新版 TextStyleConfig；若不存在则使用默认配置以保证向后兼容。
    final Map<String, dynamic>? styleJson =
        json['textStyleConfig'] as Map<String, dynamic>?;

    final textStyleConfig = styleJson != null
        ? TextStyleConfig.fromJson(styleJson)
        : _generateDefaultTextStyleConfig(rowType);

    return RowConfig(
      type: rowType,
      isVisible: json['isVisible'] as bool? ?? true,
      isTitleVisible: json['isTitleVisible'] as bool? ?? true,
      textStyleConfig: textStyleConfig,
      textAlign: textAlign,
      paddingVertical: (json['padding'] as num?)?.toDouble(),
      marginVertical: (json['marginVertical'] as num?)?.toDouble(),
      marginHorizontal: (json['marginHorizontal'] as num?)?.toDouble(),
      paddingHorizontal: (json['paddingHorizontal'] as num?)?.toDouble(),
      borderType: borderType,
      borderColorHex: json['borderColorHex'] as String?,
      tenGodLabelType: json['tenGodLabelType'] as String? ?? 'name',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RowConfig &&
        other.type == type &&
        other.isVisible == isVisible &&
        other.isTitleVisible == isTitleVisible &&
        other.textStyleConfig == textStyleConfig &&
        other.textAlign == textAlign &&
        other.paddingVertical == paddingVertical &&
        other.marginVertical == marginVertical &&
        other.marginHorizontal == marginHorizontal &&
        other.paddingHorizontal == paddingHorizontal &&
        other.borderType == borderType &&
        other.borderColorHex == borderColorHex &&
        other.tenGodLabelType == tenGodLabelType;
  }

  @override
  int get hashCode => Object.hash(
        type,
        isVisible,
        isTitleVisible,
        textStyleConfig,
        textAlign,
        paddingVertical,
        marginVertical,
        marginHorizontal,
        paddingHorizontal,
        borderType,
        borderColorHex,
        tenGodLabelType,
        // 阴影字段
      );
}
