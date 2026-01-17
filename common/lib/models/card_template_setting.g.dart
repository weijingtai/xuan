// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_template_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardTemplateSettingOverride _$CardTemplateSettingOverrideFromJson(
        Map<String, dynamic> json) =>
    CardTemplateSettingOverride(
      isHiddenTitlePillar: json['isHiddenTitlePillar'] as bool?,
      isHiddenTitleRow: json['isHiddenTitleRow'] as bool?,
      showTitleColumn: json['showTitleColumn'] as bool?,
      showInCellTitleGlobal: json['showInCellTitleGlobal'] as bool?,
      showInCellTitleByRowType: _rowTypeBoolMapFromJson(
          json['showInCellTitleByRowType'] as Map<String, dynamic>?),
      activeColorMode: $enumDecodeNullable(
          _$ColorPreviewModeEnumMap, json['activeColorMode']),
    );

Map<String, dynamic> _$CardTemplateSettingOverrideToJson(
        CardTemplateSettingOverride instance) =>
    <String, dynamic>{
      'isHiddenTitlePillar': instance.isHiddenTitlePillar,
      'isHiddenTitleRow': instance.isHiddenTitleRow,
      'showTitleColumn': instance.showTitleColumn,
      'showInCellTitleGlobal': instance.showInCellTitleGlobal,
      'showInCellTitleByRowType':
          _rowTypeBoolMapToJson(instance.showInCellTitleByRowType),
      'activeColorMode': _$ColorPreviewModeEnumMap[instance.activeColorMode],
    };

const _$ColorPreviewModeEnumMap = {
  ColorPreviewMode.pure: 'pure',
  ColorPreviewMode.colorful: 'colorful',
  ColorPreviewMode.blackwhite: 'blackwhite',
};

CardTemplateSetting _$CardTemplateSettingFromJson(Map<String, dynamic> json) =>
    CardTemplateSetting(
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      templateUuid: json['templateUuid'] as String,
      isHiddenTitlePillar: json['isHiddenTitlePillar'] as bool?,
      isHiddenTitleRow: json['isHiddenTitleRow'] as bool?,
      showTitleColumn: json['showTitleColumn'] as bool?,
      showInCellTitleGlobal: json['showInCellTitleGlobal'] as bool?,
      showInCellTitleByRowType: _rowTypeBoolMapFromJson(
          json['showInCellTitleByRowType'] as Map<String, dynamic>?),
      activeColorMode: $enumDecodeNullable(
          _$ColorPreviewModeEnumMap, json['activeColorMode']),
      overridesBySkillId: _skillOverrideMapFromJson(
          json['overridesBySkillId'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$CardTemplateSettingToJson(
        CardTemplateSetting instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'templateUuid': instance.templateUuid,
      'isHiddenTitlePillar': instance.isHiddenTitlePillar,
      'isHiddenTitleRow': instance.isHiddenTitleRow,
      'showTitleColumn': instance.showTitleColumn,
      'showInCellTitleGlobal': instance.showInCellTitleGlobal,
      'showInCellTitleByRowType':
          _rowTypeBoolMapToJson(instance.showInCellTitleByRowType),
      'activeColorMode': _$ColorPreviewModeEnumMap[instance.activeColorMode],
      'overridesBySkillId':
          _skillOverrideMapToJson(instance.overridesBySkillId),
    };
