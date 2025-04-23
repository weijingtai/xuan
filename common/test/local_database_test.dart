import 'package:common/database/app_database.dart';
import 'package:common/database/converters/coordinates_converter.dart';
import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:common/models/query_datetime.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

void main() {
  late AppDatabase database;

  // 初始化内存数据库
  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  // 测试用例组
  group('QueryDatetimeModel映射测试', () {
    var createdDatetime = DateTime.now();
    var lastUpdatedDatetime =createdDatetime;
    var testDatetime = DateTime(2025, 2, 3, 4, 5, 6);
    const queryUuid = UuidV4();
    const testUuid = UuidV4();
    const trueSolarUuid = UuidV4();
    final testBazi = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time:JiaZi.DING_MAO,
    );
    test('标准时间类型完整映射', () async {

      // 插入测试数据
      await database.into(database.queryDatetime).insert(
          QueryDatetimeCompanion.insert(
            uuid: testUuid.toString(),
            createdAt: createdDatetime,
            type: EnumDatetimeType.standard,
            datetime: testDatetime,
            timezoneStr: 'Asia/Shanghai',
            yearJiaZi: testBazi.year,
            monthJiaZi:  testBazi.month,
            dayJiaZi: testBazi.day,
            timeJiaZi: testBazi.time,
            lunarMonth: '正月',
            lunarDay: '初一',
            jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.LI_CHUN, startAt: DateTime.now() , endAt: DateTime.now()),

            isDst: false,
            isManual: false,
            queryUuid: queryUuid.toString(),
          )
      );

      // 验证查询结果
      final result = await database.select(database.queryDatetime).getSingle();
      expect(result.uuid, testUuid.toString());
      expect(result.type, EnumDatetimeType.standard);
      expect(result.timezoneStr, 'Asia/Shanghai');
      expect(result.yearJiaZi, testBazi.year);
      expect(result.monthJiaZi, testBazi.month);
      expect(result.dayJiaZi, testBazi.day);
      expect(result.timeJiaZi, testBazi.time);
    });

    test('真太阳时类型带坐标映射', () async {
      final testCoords = Coordinates(latitude: 31.2304, longitude: 121.4737);

      await database.into(database.queryDatetime).insert(
          QueryDatetimeCompanion.insert(
            uuid:trueSolarUuid.toString(),
            createdAt: createdDatetime,
            type: EnumDatetimeType.trueSolar,
            coordinates: Value(testCoords),
            datetime: testDatetime,
            timezoneStr: 'UTC+8',
            lunarMonth: '二月',
            lunarDay: '十五',
            yearJiaZi: testBazi.year,
            monthJiaZi:  testBazi.month,
            dayJiaZi: testBazi.day,
            timeJiaZi: testBazi.time,
            jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.LI_CHUN, startAt: DateTime.now() , endAt: DateTime.now()),
            isDst: false,
            isManual: false,
            queryUuid: queryUuid.toString(),
          )
      );

      final result = await database.select(database.queryDatetime).getSingle();
      expect(result.coordinates!.toString(), testCoords.toString());
      expect(result.type, EnumDatetimeType.trueSolar);
      expect(result.yearJiaZi, testBazi.year);
      expect(result.monthJiaZi, testBazi.month);
      expect(result.dayJiaZi, testBazi.day);
      expect(result.timeJiaZi, testBazi.time);
    });
  });

  group('类型转换测试', () {


    test('枚举类型存储验证', () {
      const converter = EnumNameConverter(EnumDatetimeType.values);
      expect(converter.toSql(EnumDatetimeType.meanSolar), 'meanSolar');
      expect(converter.fromSql('removeDST'), EnumDatetimeType.removeDST);
    });
  });
}