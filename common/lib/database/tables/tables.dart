import 'package:common/database/app_database.dart';
import 'package:common/database/converters/coordinates_converter.dart';
import 'package:common/database/converters/jie_qi_info_converter.dart';
import 'package:common/database/converters/location_converter.dart';
import 'package:common/database/converters/divination_datetime_model_converter.dart';
import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:common/datamodel/divination_type_data_model.dart';
import 'package:common/enums.dart';
import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../datamodel/seeker_model.dart';
import '../../datamodel/sub_divination_type_data_model.dart';
import '../../datamodel/timing_divination_model.dart';
import '../../models/divination_datetime.dart';
import 'package:common/enums.dart';
import '../converters/nullable_location_converter.dart';

@DataClassName('CombinedDivination')
class CombinedDivinations extends Table {
  @override
  String get tableName => "t_combined_divinations";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  IntColumn get order => integer().named("order")();
  // 一个 CombinedDivination 拥有一个或多个 Divination
  // 如：看完八字命理之后，可以针对命运中的突发情况进行“化解”或通过“堪舆”调整。
  TextColumn get divinationUuid =>
      text().named("divination_uuid").references(Divinations, #uuid)();

  @override
  Set<Column> get primaryKey => {uuid};
}

@UseRowClass(DivinationRequestInfoDataModel)
class Divinations extends Table {
  @override
  String get tableName => "t_divinations";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  // [命理、运程、占测、择吉、化解、运筹、堪舆]
  TextColumn get divinationTypeUuid =>
      text().named('divination_type_uuid').references(DivinationTypes, #uuid)();

  TextColumn get fateYear => text().nullable().named("fate_year")();

  TextColumn get question => text().nullable().named('question')();
  TextColumn get detail => text().nullable().named('detail')();

  // 卜问求测人的uuid, 当本字段为空时说明求测人以前未进行过卜问 （可以为空，表示为卦师自己的客源）
  TextColumn get ownerSeekerUuid =>
      text().nullable().named('seeker_uuid').references(Seekers, #uuid)();
  // 部分卜问需要求测人性别，如果求测人不提供如八字等详细生辰信息时用此字段
  // 当求测人提供自己全部的生辰信息时应尽量避免使用本字段。
  TextColumn get gender => textEnum<Gender>().nullable()();
  TextColumn get seekerName => text().nullable().named('seeker_name')();
  // 吉凶、中平/ 夭寿、穷通、贤愚
  TextColumn get tinyPredict => text().nullable().named('tiny_predict')();
  // 直断，12~24字内
  TextColumn get directlyPredict =>
      text().nullable().named('directly_predict')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('SeekerDivinationMapper')
class SeekerDivinationMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_seeker_divination_mapper";
  // 多对多
  //  一个seeker 可以有多个Divination, 一个求测人求测多个问题
  // 一个query可以有多个seeker, 合盘、合婚等
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get divinationUuid =>
      text().named('divination_uuid').references(Divinations, #uuid)();
  TextColumn get seekerUuid =>
      text().named('seeker_uuid').references(Seekers, #uuid)();
}

@DataClassName('DivinationPanelMapper')
class DivinationPanelMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_divination_panel_mappers";
  // 多对多:
  // 每个Divination可以对应多个Panel， 如在“合婚”时，一个query需要同时起男女双方两个盘
  // 每个Panel可以对应多个Divination，如在“运筹”时，需要同时获取求测人“命盘”。
  TextColumn get divinationUuid =>
      text().named('divination_uuid').references(Divinations, #uuid)();
  TextColumn get panelUuid =>
      text().named('panel_uuid').references(Panels, #uuid)();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}

@DataClassName('Panel')
class Panels extends Table {
  @override
  String get tableName => "t_panels";
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  // [单盘、合盘、合婚(合盘的一种，但)、同参(俗称‘穿’)、校验]
  IntColumn get panelType => intEnum<EnumPanelType>().named('panel_type')();
  // 一对一关系
  IntColumn get skillId =>
      integer().named('skill_id').references(Skills, #id)();

  // 随机起盘（如，三式从阴阳遁局中随机选取），手动指定，时间起盘，数字起盘、测字等。
  TextColumn get divinateType => text().named('divinate_type')();
  // 当为时间起卦是，这个uuid指向的是 TimingDivinations 中的uuid
  TextColumn get divinateUuid => text().named('divinate_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('PanelSkillClassMapper')
class PanelSkillClassMappers extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_panel_skill_class_mapper";
  TextColumn get panelUuid =>
      text().named('panel_uuid').references(Panels, #uuid)();
  TextColumn get skillClassUuid =>
      text().named('skill_class_uuid').references(SkillClasses, #uuid)();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('Skill')
class Skills extends Table {
  @override
  String get tableName => "t_skills";
  IntColumn get id => integer().autoIncrement().named('id')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  BoolColumn get isAvailable => boolean().named('is_available')();
  TextColumn get name => text().named('name')();
  TextColumn get descriptions => text().named('descriptions')();
}

@DataClassName('SkillClass')
class SkillClasses extends Table {
  @override
  String get tableName => "t_skill_classes";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  IntColumn get skillId =>
      integer().named('skill_id').references(Skills, #id)();
  TextColumn get name => text().named('name')();
  TextColumn get specification => text().named('specification')();
  TextColumn get feature => text().named('feature')();

  BoolColumn get isCustomized => boolean().named('is_customized')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LayoutTemplateRow')
class LayoutTemplates extends Table {
  @override
  String get tableName => 't_layout_templates';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get collectionId =>
      text().withLength(min: 1).named('collection_id')();
  TextColumn get name => text().withLength(min: 1).named('name')();
  TextColumn get description => text().nullable().named('description')();

  TextColumn get templateJson => text().named('template_json')();
  IntColumn get version => integer().named('version')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('CardTemplateMeta')
class CardTemplateMetas extends Table {
  @override
  String get tableName => 't_card_template_meta';

  TextColumn get templateUuid => text().named('template_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get authorUuid => text().nullable().named('author_uuid')();
  TextColumn get createFromCardUuid =>
      text().nullable().named('create_from_card_uuid')();
  BoolColumn get isCustomized => boolean().nullable().named('is_customized')();

  @override
  Set<Column> get primaryKey => {templateUuid};
}

@DataClassName('CardTemplateSettingRecord')
class CardTemplateSettings extends Table {
  @override
  String get tableName => 't_card_template_setting';

  TextColumn get templateUuid => text().named('template_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get settingJson => text().named('setting_json')();

  @override
  Set<Column> get primaryKey => {templateUuid};
}

@DataClassName('CardTemplateSkillUsage')
class CardTemplateSkillUsages extends Table with AutoIncrementingPrimaryKey {
  @override
  String get tableName => 't_card_template_skill_usage';

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  TextColumn get queryUuid => text().named('query_uuid')();
  TextColumn get templateUuid => text().named('template_uuid')();
  IntColumn get skillId => integer().named('skill_id')();

  TextColumn get usedAt => text().named('used_at')();

  @override
  List<Index> get indexes => [
        Index(
          'idx_card_template_skill_usage_query_uuid',
          'CREATE INDEX idx_card_template_skill_usage_query_uuid ON t_card_template_skill_usage (query_uuid);',
        ),
        Index(
          'idx_card_template_skill_usage_template_uuid',
          'CREATE INDEX idx_card_template_skill_usage_template_uuid ON t_card_template_skill_usage (template_uuid);',
        ),
        Index(
          'idx_card_template_skill_usage_skill_id',
          'CREATE INDEX idx_card_template_skill_usage_skill_id ON t_card_template_skill_usage (skill_id);',
        ),
      ];
}

@DataClassName('MarketTemplateInstall')
class MarketTemplateInstalls extends Table {
  @override
  String get tableName => 't_market_template_installs';

  TextColumn get localTemplateUuid => text().named('local_template_uuid')();

  TextColumn get marketTemplateId => text().named('market_template_id')();
  TextColumn get marketVersionId => text().named('market_version_id')();

  DateTimeColumn get installedAt => dateTime().named('installed_at')();
  DateTimeColumn get pinnedAt => dateTime().nullable().named('pinned_at')();
  DateTimeColumn get lastCheckedAt =>
      dateTime().nullable().named('last_checked_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {localTemplateUuid};

  @override
  List<Index> get indexes => [
        Index(
          'idx_market_template_installs_market_template_id',
          'CREATE INDEX idx_market_template_installs_market_template_id ON t_market_template_installs (market_template_id);',
        ),
        Index(
          'idx_market_template_installs_market_version_id',
          'CREATE INDEX idx_market_template_installs_market_version_id ON t_market_template_installs (market_version_id);',
        ),
      ];
}

@UseRowClass(DivinationTypeDataModel)
class DivinationTypes extends Table {
  @override
  String get tableName => "t_divination_types";
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description')();

  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@UseRowClass(SubDivinationTypeDataModel)
class SubDivinationTypes extends Table {
  @override
  String get tableName => "t_sub_divination_types";

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  DateTimeColumn get hiddenAt => dateTime().nullable().named('hidden_at')();
  TextColumn get name => text().named('name')();

  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('DivinationSubDivinationTypeMapper')
class DivinationSubDivinationTypeMappers extends Table
    with AutoIncrementingPrimaryKey {
  @override
  String get tableName => "t_divination_sub_divination_type_mappers";
  // 一对多 一个query 对应多个 subDivinationType
  TextColumn get typeUuid =>
      text().named('divination_type_uuid').references(DivinationTypes, #uuid)();
  TextColumn get subTypeUuid => text()
      .named('sub_divination_type_uuid')
      .references(SubDivinationTypes, #uuid)();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}

@UseRowClass(TimingDivinationModel)
class TimingDivinations extends Table {
  @override
  String get tableName => "t_timing_divinations";
  // 主键设计
  TextColumn get uuid => text().named('uuid')();

  // 时间追踪
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now()).named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime()
      .nullable()
      .withDefault(currentDateAndTime)
      .named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 关联字段
  TextColumn get divinationUuid => text().named('divination_uuid')();

  // 历法核心数据
  IntColumn get timingType =>
      intEnum<DateTimeType>()(); // 使用MappedEnumConverter
  DateTimeColumn get datetime => dateTime().named('datetime')();
  BoolColumn get isManual =>
      boolean().withDefault(const Constant(false)).named('is_manual')();

  // 干支体系， 注意甲子的index=0 而非枚举类型number=1
  IntColumn get yearGanZhi => intEnum<JiaZi>().named('year_gan_zhi')();
  IntColumn get monthGanZhi => intEnum<JiaZi>().named('month_gan_zhi')();
  IntColumn get dayGanZhi => intEnum<JiaZi>().named('day_gan_zhi')();
  IntColumn get timeGanZhi => intEnum<JiaZi>().named('time_gan_zhi')();

  // 阴历数据
  IntColumn get lunarMonth => integer().named('lunar_month')();
  // 是否为闰月
  BoolColumn get isLeapMonth =>
      boolean().withDefault(const Constant(false)).named('is_leap_month')();
  IntColumn get lunarDay => integer().named('lunar_day')();

  TextColumn get timingInfoUuid => text().named('timing_info_uuid')();
  TextColumn get location => text()
      .nullable()
      .map(const NullableLocationConverter())
      .named("location_json")();
  // JSON扩展字段
  TextColumn get timingInfoListJson => text()
      .map(const DivinationDatetimeModelConverter())
      .nullable()
      .named('info_list_json')();

  @override
  Set<Column> get primaryKey => {uuid};
}

@UseRowClass(SeekerModel)
class Seekers extends Table {
  @override
  String get tableName => "t_seekers";

  /// 标识为求测人
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get username => text().named('username').nullable()();
  TextColumn get nickname => text().named('nickname').nullable()();
  TextColumn get gender => textEnum<Gender>()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt =>
      dateTime().nullable().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 历法核心数据
  IntColumn get timingType =>
      intEnum<DateTimeType>()(); // 使用MappedEnumConverter

  DateTimeColumn get datetime => dateTime().named('datetime')();

  // 干支体系， 注意甲子的index=0 而非枚举类型number=1
  IntColumn get yearGanZhi => intEnum<JiaZi>().named('year_gan_zhi')();
  IntColumn get monthGanZhi => intEnum<JiaZi>().named('month_gan_zhi')();
  IntColumn get dayGanZhi => intEnum<JiaZi>().named('day_gan_zhi')();
  IntColumn get timeGanZhi => intEnum<JiaZi>().named('time_gan_zhi')();

  // 阴历数据
  IntColumn get lunarMonth => integer().named('lunar_month')();
  // 是否为闰月
  BoolColumn get isLeapMonth =>
      boolean().withDefault(const Constant(false)).named('is_leap_month')();
  IntColumn get lunarDay => integer().named('lunar_day')();
  // 关联字段
  TextColumn get divinationUuid => text().named('divination_uuid')();

  TextColumn get timingInfoUuid =>
      text().named('timing_info_uuid').nullable()();
  // JSON扩展字段
  TextColumn get timingInfoListJson => text()
      .map(const DivinationDatetimeModelConverter())
      .nullable()
      .named('info_list_json')();

  TextColumn get location => text()
      .nullable()
      .map(const NullableLocationConverter())
      .named("location_json")();

  @override
  Set<Column> get primaryKey => {uuid};
}
