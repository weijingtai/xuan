import 'package:collection/collection.dart';

import '../enums/layout_template_enums.dart';

class LayoutTemplate {
  LayoutTemplate({
    required this.id,
    required this.name,
    required this.collectionId,
    required this.cardStyle,
    required List<ChartGroup> chartGroups,
    required List<RowConfig> rowConfigs,
    this.version = 1,
    required this.updatedAt,
  })  : chartGroups = List.unmodifiable(chartGroups),
        rowConfigs = List.unmodifiable(rowConfigs);

  final String id;
  final String name;
  final String collectionId;
  final CardStyle cardStyle;
  final List<ChartGroup> chartGroups;
  final List<RowConfig> rowConfigs;
  final int version;
  final DateTime updatedAt;

  LayoutTemplate copyWith({
    String? id,
    String? name,
    String? collectionId,
    CardStyle? cardStyle,
    List<ChartGroup>? chartGroups,
    List<RowConfig>? rowConfigs,
    int? version,
    DateTime? updatedAt,
  }) {
    return LayoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      collectionId: collectionId ?? this.collectionId,
      cardStyle: cardStyle ?? this.cardStyle,
      chartGroups: chartGroups ?? this.chartGroups,
      rowConfigs: rowConfigs ?? this.rowConfigs,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'collectionId': collectionId,
      'cardStyle': cardStyle.toJson(),
      'chartGroups': chartGroups.map((group) => group.toJson()).toList(),
      'rowConfigs': rowConfigs.map((config) => config.toJson()).toList(),
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LayoutTemplate.fromJson(Map<String, dynamic> json) {
    return LayoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      collectionId: json['collectionId'] as String,
      cardStyle: CardStyle.fromJson(json['cardStyle'] as Map<String, dynamic>),
      chartGroups: (json['chartGroups'] as List<dynamic>)
          .map((item) => ChartGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
      rowConfigs: (json['rowConfigs'] as List<dynamic>)
          .map((item) => RowConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
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
        other.collectionId == collectionId &&
        other.cardStyle == cardStyle &&
        const ListEquality<ChartGroup>()
            .equals(other.chartGroups, chartGroups) &&
        const ListEquality<RowConfig>().equals(other.rowConfigs, rowConfigs) &&
        other.version == version &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        collectionId,
        cardStyle,
        const ListEquality<ChartGroup>().hash(chartGroups),
        const ListEquality<RowConfig>().hash(rowConfigs),
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
        const ListEquality<PillarType>().equals(other.pillarOrder, pillarOrder) &&
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
  });

  final BorderType dividerType;
  final String dividerColorHex;
  final double dividerThickness;
  final String globalFontFamily;
  final double globalFontSize;
  final String globalFontColorHex;

  CardStyle copyWith({
    BorderType? dividerType,
    String? dividerColorHex,
    double? dividerThickness,
    String? globalFontFamily,
    double? globalFontSize,
    String? globalFontColorHex,
  }) {
    return CardStyle(
      dividerType: dividerType ?? this.dividerType,
      dividerColorHex: dividerColorHex ?? this.dividerColorHex,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      globalFontFamily: globalFontFamily ?? this.globalFontFamily,
      globalFontSize: globalFontSize ?? this.globalFontSize,
      globalFontColorHex: globalFontColorHex ?? this.globalFontColorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dividerType': dividerType.name,
      'dividerColorHex': dividerColorHex,
      'dividerThickness': dividerThickness,
      'globalFontFamily': globalFontFamily,
      'globalFontSize': globalFontSize,
      'globalFontColorHex': globalFontColorHex,
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
      globalFontFamily: json['globalFontFamily'] as String? ?? 'NotoSans',
      globalFontSize: (json['globalFontSize'] as num?)?.toDouble() ?? 14,
      globalFontColorHex: json['globalFontColorHex'] as String? ?? '#FF000000',
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
        other.globalFontFamily == globalFontFamily &&
        other.globalFontSize == globalFontSize &&
        other.globalFontColorHex == globalFontColorHex;
  }

  @override
  int get hashCode => Object.hash(
        dividerType,
        dividerColorHex,
        dividerThickness,
        globalFontFamily,
        globalFontSize,
        globalFontColorHex,
      );
}

class RowConfig {
  const RowConfig({
    required this.type,
    required this.isVisible,
    required this.isTitleVisible,
    this.fontFamily,
    this.fontSize,
    this.textColorHex,
    this.textAlign,
    this.padding,
    this.borderType,
    this.borderColorHex,
  });

  final RowType type;
  final bool isVisible;
  final bool isTitleVisible;
  final String? fontFamily;
  final double? fontSize;
  final String? textColorHex;
  final RowTextAlign? textAlign;
  final double? padding;
  final BorderType? borderType;
  final String? borderColorHex;

  RowConfig copyWith({
    RowType? type,
    bool? isVisible,
    bool? isTitleVisible,
    String? fontFamily,
    double? fontSize,
    String? textColorHex,
    RowTextAlign? textAlign,
    double? padding,
    BorderType? borderType,
    String? borderColorHex,
  }) {
    return RowConfig(
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      isTitleVisible: isTitleVisible ?? this.isTitleVisible,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColorHex: textColorHex ?? this.textColorHex,
      textAlign: textAlign ?? this.textAlign,
      padding: padding ?? this.padding,
      borderType: borderType ?? this.borderType,
      borderColorHex: borderColorHex ?? this.borderColorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isVisible': isVisible,
      'isTitleVisible': isTitleVisible,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textColorHex': textColorHex,
      'textAlign': textAlign?.name,
      'padding': padding,
      'borderType': borderType?.name,
      'borderColorHex': borderColorHex,
    };
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

    return RowConfig(
      type: rowType,
      isVisible: json['isVisible'] as bool? ?? true,
      isTitleVisible: json['isTitleVisible'] as bool? ?? true,
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      textColorHex: json['textColorHex'] as String?,
      textAlign: textAlign,
      padding: (json['padding'] as num?)?.toDouble(),
      borderType: borderType,
      borderColorHex: json['borderColorHex'] as String?,
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
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.textColorHex == textColorHex &&
        other.textAlign == textAlign &&
        other.padding == padding &&
        other.borderType == borderType &&
        other.borderColorHex == borderColorHex;
  }

  @override
  int get hashCode => Object.hash(
        type,
        isVisible,
        isTitleVisible,
        fontFamily,
        fontSize,
        textColorHex,
        textAlign,
        padding,
        borderType,
        borderColorHex,
      );
}
