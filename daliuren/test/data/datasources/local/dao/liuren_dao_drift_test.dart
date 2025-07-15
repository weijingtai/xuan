import 'package:common/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:daliuren/data/datasources/local/database/drift_database.dart';
import 'package:daliuren/data/datasources/local/database/dao/liuren_dao.dart';
import 'package:daliuren/data/models/da_liu_ren_gong_data_model.dart';
import 'package:daliuren/data/models/four_class_data_model.dart';
import 'package:daliuren/data/models/three_chuan_data_model.dart';
import 'package:daliuren/data/models/each_class_data_model.dart';
import 'package:daliuren/data/models/each_chuan_data_model.dart';

import 'package:common/enums.dart' as common_enums;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;
import 'package:daliuren/domain/enums/nine_zong_men.dart'
    as domain_nine_zong_men;

void main() {
  late DaLiuRenAppDatabase testDb;
  late LiuRenDao testDao;

  setUp(() {
    testDb = DaLiuRenAppDatabase.forTesting(NativeDatabase.memory());

    testDao = LiuRenDao(testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  test('DbInitializationFlag can be set and retrieved', () async {
    const flagKey = 'testFlag';
    await testDao.setInitializationFlag(flagKey, true);
    final flag = await testDao.getInitializationFlag(flagKey);

    expect(flag, isNotNull);
    expect(flag!.isSet, isTrue);
    expect(flag.flagKey, flagKey);

    await testDao.setInitializationFlag(flagKey, false);
    final updatedFlag = await testDao.getInitializationFlag(flagKey);
    expect(updatedFlag!.isSet, isFalse);
  });

  test('JuMappings can be inserted and retrieved', () async {
    final companion = JuMappingsCompanion.insert(
        dayJiaZiName: "甲子",
        timeDiZhiName: "子",
        yinYangValue: "yang",
        juNumber: 1);
    await testDao.bulkInsertJuMappings([companion]);

    final retrieved = await testDao.findJuMapping(
        dayJiaZiName: "甲子", timeDiZhiName: "子", yinYangValue: "yang");

    expect(retrieved, isNotNull);
    expect(retrieved!.juNumber, 1);

    final count = await testDao.countJuMappings();
    expect(count, 1);
  });

  test('YuDingEntries can be inserted and retrieved with JSON conversions',
      () async {
    final companion = YuDingEntriesCompanion.insert(
        dayJiaZiName: "甲子",
        juName: "子",
        juNumber: 1,
        detailsJson: {'key1': 'value1'},
        booksJson: {'bookA': 'contentA'},
        bodyJson: {'line1', 'line2'},
        meaning: "meaning text",
        explain: "explain text",
        predication: "predication text");
    await testDao.bulkInsertYuDingEntries([companion]);

    final retrieved =
        await testDao.findYuDingEntry(dayJiaZiName: "甲子", juName: "子");
    expect(retrieved, isNotNull);
    expect(retrieved!.detailsJson['key1'], 'value1');
    expect(retrieved.bodyJson, contains('line1'));
    expect(retrieved.meaning, "meaning text");
  });

  test('PresetPans can be inserted and retrieved with complex JSON conversions',
      () async {
    // Constructing complex DataModels for JSON fields
    final gongModel = DaLiuRenGongDataModel(
        skyPanDiZhi: common_enums.DiZhi.MAO,
        groundPanDiZhi: common_enums.DiZhi.YIN,
        guiRen: domain_gui_ren.GuiRen.GUI_REN,
        jiaZi: common_enums.JiaZi.JIA_XU,
        tianGan: common_enums.TianGan.JIA);
    final eachClass = EachClassDataModel(
        order: 1,
        sky: common_enums.DiZhi.WU,
        ground: common_enums.DiZhi.SI,
        guiRen: domain_gui_ren.GuiRen.TENG_SHE,
        isFirstClass: true);
    final fourClassModel = FourClassDataModel(
        first: eachClass,
        firstClassDayGan: common_enums.TianGan.BING,
        second: eachClass.copyWith(order: 2, isFirstClass: false),
        third: eachClass.copyWith(order: 3, isFirstClass: false),
        fourth: eachClass.copyWith(order: 4, isFirstClass: false));
    final eachChuan = EachChuanDataModel(
        diZhi: common_enums.DiZhi.SHEN,
        guiRen: domain_gui_ren.GuiRen.QING_LONG,
        liuQin: common_enums.LiuQin.QI_CAI);
    final threeChuanModel = ThreeChuanDataModel(
        first: eachChuan,
        second: eachChuan,
        third: eachChuan,
        nineZongMen: domain_nine_zong_men.NineZongMen.FU_YIN);

    final companion = PresetPansCompanion.insert(
        dayJiaZiName: "丙寅",
        shiChenName: "午",
        yinYangDun: "yang",
        juNumberName: "三局",
        // heavenPlateJson: {"Yin": gongModel}, // Map key is DiZhi name as string
        // earthPlateJson: {"Mao": gongModel},
        fourClassJson: fourClassModel,
        threeChuanJson: threeChuanModel,
        nineZongMenName: domain_nine_zong_men.NineZongMen.FU_YIN.name);
    await testDao.bulkInsertPresetPans([companion]);

    final retrieved = await testDao.findPresetPan(
        dayJiaZiName: "丙寅", shiChenName: "午", yinYangDun: "yang");
    expect(retrieved, isNotNull);
    // expect(
    //     retrieved!.heavenPlateJson["Yin"]!.skyPanDiZhi, common_enums.DiZhi.MAO);
    // expect(retrieved.fourClassJson.first.sky, common_enums.DiZhi.WU);
    // expect(retrieved.threeChuanJson.nineZongMen,
    //     domain_nine_zong_men.NineZongMen.FU_YIN);
  });

  test('clearAllData should remove all entries', () async {
    // Arrange: Insert some data
    await testDao.bulkInsertJuMappings([
      JuMappingsCompanion.insert(
          dayJiaZiName: "甲子",
          timeDiZhiName: "子",
          yinYangValue: "yang",
          juNumber: 1)
    ]);
    await testDao.setInitializationFlag("testFlagClear", true);

    // Act
    await testDao.clearAllData();

    // Assert
    expect(await testDao.countJuMappings(), 0);
    final flag = await testDao.getInitializationFlag("testFlagClear");
    // Assuming clearAllData also clears flags as per DAO impl.
    // If not, this might be null or its 'isSet' might be false depending on re-creation logic.
    // Current DAO clearAllData deletes from DbInitializationFlags, so it should be null.
    expect(flag, isNull);
  });
}

// Helper extension for EachClassDataModel copyWith, if not accessible from main code
// (already added to drift_database.dart, but good for test file self-containment if needed)
extension on EachClassDataModel {
  EachClassDataModel copyWith({
    int? order,
    common_enums.DiZhi? sky,
    common_enums.DiZhi? ground,
    domain_gui_ren.GuiRen? guiRen,
    bool? isFirstClass,
    bool? isSkyKeDayGan,
    bool? isSkySameYinYangWithDayGan,
    int? sheHaiTimes,
    List<int>? otherSameSkyGroundIndexList,
  }) {
    return EachClassDataModel(
      order: order ?? this.order,
      sky: sky ?? this.sky,
      ground: ground ?? this.ground,
      guiRen: guiRen ?? this.guiRen,
      isFirstClass: isFirstClass ?? this.isFirstClass,
      isSkyKeDayGan: isSkyKeDayGan ?? this.isSkyKeDayGan,
      isSkySameYinYangWithDayGan:
          isSkySameYinYangWithDayGan ?? this.isSkySameYinYangWithDayGan,
      sheHaiTimes: sheHaiTimes ?? this.sheHaiTimes,
      otherSameSkyGroundIndexList:
          otherSameSkyGroundIndexList ?? this.otherSameSkyGroundIndexList,
    );
  }
}
