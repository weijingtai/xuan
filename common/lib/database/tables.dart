import 'package:common/database/converters/coordinates_converter.dart';
import 'package:common/database/converters/jie_qi_info_converter.dart';
import 'package:common/database/converters/location_converter.dart';
import 'package:common/enums.dart';
import 'package:drift/drift.dart';

import '../models/query_datetime.dart';

class Queries extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  // [命理、运程、占测、择吉、风水、化解、运筹]
  TextColumn get queryTypeUuid => text().named('query_type_uuid')();


  TextColumn get yearGanZhi => text().nullable().named("year_gan_zhi")();
  // 当前起卦使用的地理位置（起卦时间）是否为卦师自己的位置
  BoolColumn get isSeersLocation => boolean().named('is_seers_location')();


  TextColumn get queryQuestion => text().named('query_question')();
  TextColumn get queryDescription => text().named('query_description')();


  // 可以为空，表示为卦师自己的客源
  TextColumn get seekerUuid => text().nullable().named('seeker_uuid')();
  // 吉凶、中平/ 夭寿、穷通、贤愚
  TextColumn get tinySummary => text().named('tiny_summary')();
  TextColumn get directlyPredict => text().named('directly_predict')();
  TextColumn get panelUuid => text().nullable().named('panel_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}
class QueryPanelMapper extends Table {
  // 一对多 一个query 对应多个 panel
  IntColumn get id => integer().autoIncrement()();
  TextColumn get queryUuid => text().named('query_uuid')();
  TextColumn get panelUuid => text().named('panel_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  @override
  Set<Column> get primaryKey => {id};
}

class Panel extends Table {

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  // [合盘、合婚、同参、校验、单盘]
  TextColumn get panelType => text().named('panel_type')();
  // 一对一关系
  IntColumn get skillId => integer().named('skill_id')();

  // 技法使用的阴阳 如：时家奇门分阴盘、阳盘，六壬分阴盘阳盘；梅花易数分先天卦，后天卦，
  BoolColumn get yinYang => boolean().nullable().named('yin_yang')();

  TextColumn get panelName => text().named('panel_name')();
  // 随机起盘（如，三式从阴阳遁局中随机选取），自定义（用户手动选择盘面），时间起盘
  TextColumn get divinationType => text().nullable().named('divination_type')();

  // 卜问的时间（当为算命时是命主的生成）
  TextColumn get queryDatetimeUuid => text().named('query_datetime_uuid')();



  @override
  Set<Column> get primaryKey => {uuid};
}
class PanelSkillClassMapper extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get panelUuid => text().named('panel_uuid')();
  TextColumn get skillClassUuid => text().named('skill_class_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}

class Skills extends Table {
  // TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  IntColumn get id=>integer().autoIncrement().named('id')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  BoolColumn get isAvailable => boolean().named('is_available')();
  TextColumn get name => text().named('name')();
  TextColumn get descriptions => text().named('descriptions')();

}
class SkillClass extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  IntColumn get skillId => integer().named('skill_id')();
  TextColumn get name => text().named('name')();
  TextColumn get specification => text().named('specification')();
  TextColumn get feature => text().named('feature')();


  BoolColumn get isCustomized => boolean().named('is_customized')();

  @override
  Set<Column> get primaryKey => {uuid};

}

class CombinedQueries extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  IntColumn get order => integer().named('order')();
  TextColumn get queryUuid => text().named('query_uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get combinedType => text().named('combined_type')();

  @override
  Set<Column> get primaryKey => {uuid};
}


@UseRowClass(QueryDatetimeModel)
class QueryDatetime extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();


  TextColumn get type => text().map(const EnumNameConverter(EnumDatetimeType.values)).named('datetime_type')();
  BoolColumn get isDst => boolean().named('is_dst')();
  BoolColumn get isManual => boolean().named('is_manual')();
  DateTimeColumn get datetime => dateTime().named('datetime')();
  TextColumn get timezoneStr => text().named('timezone_str')();

  TextColumn get location => text().map(const LocationConverter()).nullable().named('location_json')();
  TextColumn get coordinates => text().map(const CoordinatesConverter()).nullable().named('coordinates')();
  IntColumn get hourAdjusted => integer().nullable().named('hour_adjusted')();
  TextColumn get yearJiaZi => text().map(const EnumNameConverter(JiaZi.values)).named('year_gan_zhi')();
  TextColumn get monthJiaZi => text().map(const EnumNameConverter(JiaZi.values)).named('month_gan_zhi')();
  TextColumn get dayJiaZi => text().map(const EnumNameConverter(JiaZi.values)).named('day_gan_zhi')();
  TextColumn get timeJiaZi => text().map(const EnumNameConverter(JiaZi.values)).named('hour_gan_zhi')();

  TextColumn get lunarMonth => text().named('lunar_month')();
  TextColumn get lunarDay => text().named('lunar_day')();

  TextColumn get jieQiInfo => text().map(const JieQiInfoConverter()).named('jie_qi_json')();


  TextColumn get queryUuid => text().named('t_query_uuid')();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Seekers extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get username => text().named('username')();
  TextColumn get nickname => text().named('nickname')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  DateTimeColumn get birthDatetime => dateTime().named('birth_datetime')();
  TextColumn get eightChars => text().named('eight_chars')();
  TextColumn get birthLocation => text().named('birth_location')();
  RealColumn get birthLng => real().named('birth_lng')();
  RealColumn get birthLat => real().named('birth_lat')();
  TextColumn get currentLocation => text().named('current_location')();
  RealColumn get currentLng => real().named('current_lng')();
  RealColumn get currentLat => real().named('current_lat')();

  @override
  Set<Column> get primaryKey => {uuid};
}



class QueryTypes extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description')();
  // 使用的次数
  IntColumn get times => integer().named('times')();


  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();
  // TextColumn get subTypes => text().named('sub_types')();

  @override
  Set<Column> get primaryKey => {uuid};
}
class SubQueryTypes extends Table {
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  DateTimeColumn get hiddenAt => dateTime().nullable().named('hidden_at')();
  TextColumn get name => text().named('name')();

  // 使用的次数，每次被使用后次数+1
  IntColumn get times => integer().named('times')();

  BoolColumn get isCustomized => boolean().named('is_customized')();
  BoolColumn get isAvailable => boolean().named('is_available')();

  @override
  Set<Column> get primaryKey => {uuid};
}
class QuerySubQueryTypeMapper extends Table {
  // 一对多 一个query 对应多个 subQueryType
  IntColumn get id => integer().autoIncrement()();
  TextColumn get queryUuid => text().named('query_type_uuid')();
  TextColumn get subTypeUuid => text().named('sub_type_uuid')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
}


