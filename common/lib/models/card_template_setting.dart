import 'package:common/enums/layout_template_enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'text_style_config.dart';

part 'card_template_setting.g.dart';

@JsonSerializable(explicitToJson: true)
class CardTemplateSettingOverride {
  const CardTemplateSettingOverride({
    this.isHiddenTitlePillar,
    this.isHiddenTitleRow,
    this.showTitleColumn,
    this.showInCellTitleGlobal,
    this.showInCellTitleByRowType,
    this.activeColorMode,
  });

  final bool? isHiddenTitlePillar;
  final bool? isHiddenTitleRow;

  final bool? showTitleColumn;
  final bool? showInCellTitleGlobal;

  @JsonKey(fromJson: _rowTypeBoolMapFromJson, toJson: _rowTypeBoolMapToJson)
  final Map<RowType, bool>? showInCellTitleByRowType;

  final ColorPreviewMode? activeColorMode;

  factory CardTemplateSettingOverride.fromJson(Map<String, dynamic> json) =>
      _$CardTemplateSettingOverrideFromJson(json);

  Map<String, dynamic> toJson() => _$CardTemplateSettingOverrideToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CardTemplateSetting {
  const CardTemplateSetting({
    required this.createdAt,
    required this.modifiedAt,
    required this.deletedAt,
    required this.templateUuid,
    this.isHiddenTitlePillar,
    this.isHiddenTitleRow,
    this.showTitleColumn,
    this.showInCellTitleGlobal,
    this.showInCellTitleByRowType,
    this.activeColorMode,
    this.overridesBySkillId,
  });

  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;

  final String templateUuid;

  final bool? isHiddenTitlePillar;
  final bool? isHiddenTitleRow;

  final bool? showTitleColumn;
  final bool? showInCellTitleGlobal;

  @JsonKey(fromJson: _rowTypeBoolMapFromJson, toJson: _rowTypeBoolMapToJson)
  final Map<RowType, bool>? showInCellTitleByRowType;

  final ColorPreviewMode? activeColorMode;

  @JsonKey(
    fromJson: _skillOverrideMapFromJson,
    toJson: _skillOverrideMapToJson,
  )
  final Map<int, CardTemplateSettingOverride>? overridesBySkillId;

  factory CardTemplateSetting.fromJson(Map<String, dynamic> json) =>
      _$CardTemplateSettingFromJson(json);

  Map<String, dynamic> toJson() => _$CardTemplateSettingToJson(this);
}

Map<RowType, bool>? _rowTypeBoolMapFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  final result = <RowType, bool>{};
  json.forEach((key, value) {
    final type = RowType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => RowType.separator,
    );
    if (type == RowType.separator) return;
    if (value is bool) {
      result[type] = value;
    }
  });
  return result;
}

Map<String, dynamic>? _rowTypeBoolMapToJson(Map<RowType, bool>? map) {
  if (map == null) return null;
  return map.map((k, v) => MapEntry(k.name, v));
}

Map<int, CardTemplateSettingOverride>? _skillOverrideMapFromJson(
  Map<String, dynamic>? json,
) {
  if (json == null) return null;
  final result = <int, CardTemplateSettingOverride>{};
  json.forEach((key, value) {
    final skillId = int.tryParse(key);
    if (skillId == null) return;
    if (value is Map<String, dynamic>) {
      result[skillId] = CardTemplateSettingOverride.fromJson(value);
    }
  });
  return result;
}

Map<String, dynamic>? _skillOverrideMapToJson(
  Map<int, CardTemplateSettingOverride>? map,
) {
  if (map == null) return null;
  return map.map((k, v) => MapEntry(k.toString(), v.toJson()));
}

