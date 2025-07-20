import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:common/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/managers/zhou_tian_calculator.dart';
import 'package:qizhengsiyu/models/base_panel_model.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/panel_config.dart';
import 'package:qizhengsiyu/models/zhou_tian_model.dart';
import 'package:common/models/year_month.dart';
import 'package:qizhengsiyu/xing_xian/da_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/da_xian_palace_info.dart';
import 'package:qizhengsiyu/xing_xian/fei_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/fei_xian_detail_palace.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  late BasePanelConfig panelConfig = BasePanelConfig(
      panelSystemType: PanelSystemType.tropical,
      celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
      constellationSystemType: ConstellationSystemType.classical);
  late ZhouTianModel zhouTianModel;

  late BasePanelModel basePanel;

  late ObserverPosition observer = ObserverPosition(
      latitude: 38.8026097,
      longitude: -116.419389,
      altitude: 0,
      timezone: "America/Los_Angeles",
      dateTime: DateTime.parse("2025-05-28T22:33:37.000"),
      yearGanZhi: JiaZi.YI_SI,
      monthGanZhi: JiaZi.XIN_SI,
      dayGanZhi: JiaZi.DING_YOU,
      timeGanZhi: JiaZi.XIN_HAI,
      isDayBirth: false);

  final List<EnumTwelveGong> daxianOrder = [
    EnumTwelveGong.Zi,
    EnumTwelveGong.Chou,
    EnumTwelveGong.Yin,
    EnumTwelveGong.Mao,
    EnumTwelveGong.Chen,
    EnumTwelveGong.Si,
    EnumTwelveGong.Wu,
    EnumTwelveGong.Wei,
    EnumTwelveGong.Shen,
    EnumTwelveGong.You,
    EnumTwelveGong.Xu,
    EnumTwelveGong.Hai
  ];
  // 将double类型的宫位时长改为YearMonth类型
  final Map<EnumTwelveGong, YearMonth> daxianDurations = {
    EnumTwelveGong.Zi: YearMonth(15, 0), // 15年
    EnumTwelveGong.Chou: YearMonth(10, 0), // 10年
    EnumTwelveGong.Yin: YearMonth(12, 0), // 11年
    EnumTwelveGong.Mao: YearMonth(9, 0), // 15年
    EnumTwelveGong.Chen: YearMonth(12, 0), // 8年
    EnumTwelveGong.Si: YearMonth(7, 0), // 7年
    EnumTwelveGong.Wu: YearMonth(11, 0), // 11年
    EnumTwelveGong.Wei: YearMonth(4, 6), // 4.5年
    EnumTwelveGong.Shen: YearMonth(4, 6), // 4.5年
    EnumTwelveGong.You: YearMonth(4, 6), // 4.5年
    EnumTwelveGong.Xu: YearMonth(5, 0), // 5年
    EnumTwelveGong.Hai: YearMonth(5, 0), // 5年
  };

  setUpAll(() async {
    // 在所有测试之前初始化绑定
    tz.initializeTimeZones();
    WidgetsFlutterBinding.ensureInitialized();
    // final DateTime birth = DateTime(1990, 1, 15, 10, 30);

    try {
      final projectRoot = Directory.current.path;
      final projectAssetsPath = "$projectRoot/../assets/qizhengsiyu";

      await ZhouTianModelManager.instance.loadFromFiles([
        "$projectAssetsPath/ecliptic_tropical_classical_adjusted.json",
        "$projectAssetsPath/ecliptic_tropical_classical.json",
        "$projectAssetsPath/ecliptic_tropical_morden.json"
      ]);
      // ZhouTianModelManager.instance.setModelsForTesting(testMapper);

      zhouTianModel =
          ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig);
    } catch (e) {
      print("load panel config encounter error :$e");
    }
    try {
      final projectRoot = Directory.current.path;
      final testJsonFile = "$projectRoot/test/resources/base_panel_model.json";
      final basePanelJsonStr = await File(testJsonFile).readAsString();
      basePanel = BasePanelModel.fromJson(jsonDecode(basePanelJsonStr));
      // ZhouTianModelManager.instance.setModelsForTesting(testMapper);
    } catch (e) {
      print("load base_panel_model.json encounter error :$e");
    }
  });

  group("获取对应的tiZhouTianModel", () {
    test("黄道回归古宿", () async {
      ZhouTianModel? zhouTianModel =
          ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig);
      expect(zhouTianModel, isNotNull);
      expect(zhouTianModel!.panelSystemType, PanelSystemType.tropical);
      expect(zhouTianModel.constellationSystemType,
          ConstellationSystemType.classical);
      expect(zhouTianModel.systemType, CelestialCoordinateSystem.ecliptic);
      expect(zhouTianModel.epochCorrection, "开禧历");
    });
  });
  group("calculator", () {
    test("test 宿度的宫位的映射", skip: true, () {
      final calculator = ZhouTianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
      );
      print(calculator.zhouTianModel.starInnDegreeSeq.firstWhere(
          (t) => t.constellation == Enum28Constellations.Kui_Mu_Lang));
      final result = calculator.mapConstellationsToPalaces();
      expect(result, isNotEmpty);
      expect(result.length, 28);
      for (var element in result) {
        print(element);
      }
    });

    test("test calculate 宫包含宿度", skip: true, () {
      final calculator = ZhouTianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
      );
      // print(calculator.zhouTianModel.starInnDegreeSeq.firstWhere(
      // (t) => t.constellation == Enum28Constellations.Kui_Mu_Lang));
      final result = calculator.mapPalacesToConstellations(
        calculator.mapConstellationsToPalaces(),
        calculator.calculatePalaceAngles(),
      );
      expect(result, isNotEmpty);
      expect(result.length, 12);
      for (var element in result) {
        print(element);
      }
    });
  });

  group("calculate 大限", () {
    test("计算洞微大限 v3", skip: true, () {
      try {
        final zhouTianCalculator = ZhouTianCalculator(
          zhouTianModel:
              ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        );
        final result = zhouTianCalculator.mapConstellationsToPalaces();
        final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

        final dongWeiCalculator = DongWeiDaXianCalculator(
          zhouTianModel: ZhouTianModelManager.instance
              .getZhouTianModelBy(panelConfig), // 你的静态周天模型
          basePanel: basePanel,
          daxianPalaceOrder: daxianOrder,
          daxianPalaceDurations: daxianDurations,
          observerPosition: observer,
        );
        List<DaXianPalaceInfo> daxianResults =
            dongWeiCalculator.calculateDaXianV1(
                result, palaceMapper, basePanel.enteredGongMapper);
        for (var daxian in daxianResults) {
          print(daxian);
          print("\n---------------------------------------\n");
        }
      } catch (e, s) {
        print("计算大限出错: $e");
        print("堆栈: $s");
      }
    });
  });

  group("calculate 大限 v2", () {
    test("计算洞微大限 v3", skip: true, () {
      try {
        final zhouTianCalculator = ZhouTianCalculator(
          zhouTianModel:
              ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        );
        final palaceMapper = zhouTianCalculator.calculatePalaceAngles();
        final result = zhouTianCalculator.mapPalacesToConstellations(
          zhouTianCalculator.mapConstellationsToPalaces(),
          palaceMapper,
        );

        final dongWeiCalculator = DongWeiDaXianCalculator(
          zhouTianModel: ZhouTianModelManager.instance
              .getZhouTianModelBy(panelConfig), // 你的静态周天模型
          basePanel: basePanel,
          daxianPalaceOrder: daxianOrder,
          daxianPalaceDurations: daxianDurations,
          observerPosition: observer,
        );
        List<DaXianPalaceInfo> daxianResults =
            dongWeiCalculator.calculateDaXian(
          result, palaceMapper,
          // basePanel.enteredGongMapper
        );
        for (var daxian in daxianResults) {
          print(daxian);
          print("\n---------------------------------------\n");
        }
      } catch (e, s) {
        print("计算大限出错: $e");
        print("堆栈: $s");
      }
    });
  });

  group("compare 大限 results", () {
    test("比较两种大限计算方法的结果", skip: false, () {
      try {
        final zhouTianCalculator = ZhouTianCalculator(
          zhouTianModel:
              ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        );

        // 准备数据
        final constellationToPalaceResult =
            zhouTianCalculator.mapConstellationsToPalaces();
        final palaceMapper = zhouTianCalculator.calculatePalaceAngles();
        final palaceToConstellationResult =
            zhouTianCalculator.mapPalacesToConstellations(
          constellationToPalaceResult,
          palaceMapper,
        );

        final dongWeiCalculator = DongWeiDaXianCalculator(
          zhouTianModel:
              ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
          basePanel: basePanel,
          daxianPalaceOrder: daxianOrder,
          daxianPalaceDurations: daxianDurations,
          observerPosition: observer,
        );

        // 方法1：使用 calculateDaXianV1 (ConstellationMappingResult)
        List<DaXianPalaceInfo> daxianResultsV1 =
            dongWeiCalculator.calculateDaXianV1(constellationToPalaceResult,
                palaceMapper, basePanel.enteredGongMapper);

        // 方法2：使用 calculateDaXian (PalaceMappingResult)
        List<DaXianPalaceInfo> daxianResultsV2 =
            dongWeiCalculator.calculateDaXian(
          palaceToConstellationResult,
          palaceMapper,
          // basePanel.enteredGongMapper
        );

        // 比较结果
        // print("=== 比较两种大限计算方法的结果 ===");
        // print(
        // "V1 (ConstellationMappingResult) 结果数量: ${daxianResultsV1.length}");
        // print("V2 (PalaceMappingResult) 结果数量: ${daxianResultsV2.length}");

        expect(daxianResultsV1.length, equals(daxianResultsV2.length),
            reason: "两种方法应该返回相同数量的大限结果");

        // 逐个比较每个大限宫位的结果
        for (int i = 0; i < daxianResultsV1.length; i++) {
          final v1Result = daxianResultsV1[i];
          final v2Result = daxianResultsV2[i];

          // print("\n--- 比较第${i + 1}个大限宫位 (${v1Result.palace.name}) ---");

          // 比较基本信息
          expect(v1Result.palace, equals(v2Result.palace), reason: "宫位应该相同");
          expect(v1Result.order, equals(v2Result.order), reason: "序号应该相同");
          expect(v1Result.durationYears, equals(v2Result.durationYears),
              reason: "持续时间应该相同");
          expect(v1Result.startTime, equals(v2Result.startTime),
              reason: "开始时间应该相同");
          expect(v1Result.endTime, equals(v2Result.endTime),
              reason: "结束时间应该相同");
          expect(v1Result.startAge, equals(v2Result.startAge),
              reason: "开始年龄应该相同");
          expect(v1Result.endAge, equals(v2Result.endAge), reason: "结束年龄应该相同");

          // 比较宫位度数
          expect(v1Result.totalGongDegreee,
              closeTo(v2Result.totalGongDegreee, 0.001),
              reason: "宫位总度数应该相近");

          // 比较星宿过宫信息
          expect(v1Result.constellationPassages.length,
              equals(v2Result.constellationPassages.length),
              reason: "星宿过宫数量应该相同");

          // print("  V1 星宿过宫数量: ${v1Result.constellationPassages.length}");
          // print("  V2 星宿过宫数量: ${v2Result.constellationPassages.length}");

          // 比较每个星宿过宫的详细信息
          for (int j = 0; j < v1Result.constellationPassages.length; j++) {
            final v1Passage = v1Result.constellationPassages[j];
            final v2Passage = v2Result.constellationPassages[j];

            // print(
            // "    星宿${j + 1}: V1=${v1Passage.constellation.name}, V2=${v2Passage.constellation.name}");

            expect(v1Passage.constellation, equals(v2Passage.constellation),
                reason: "星宿名称应该相同");
            expect(v1Passage.segmentAngularSpanDegrees,
                closeTo(v2Passage.segmentAngularSpanDegrees, 0.001),
                reason: "星宿段度数应该相近");
            expect(v1Passage.passageDurationYears,
                equals(v2Passage.passageDurationYears),
                reason: "过宫持续时间应该相同");
            expect(v1Passage.entryTime, equals(v2Passage.entryTime),
                reason: "入宫时间应该相同");
            expect(v1Passage.exitTime, equals(v2Passage.exitTime),
                reason: "出宫时间应该相同");

            // 检查度数差异
            final degreeDiff = (v1Passage.segmentAngularSpanDegrees -
                    v2Passage.segmentAngularSpanDegrees)
                .abs();
            if (degreeDiff > 0.001) {
              print("    ⚠️  度数差异: ${degreeDiff.toStringAsFixed(6)}°");
            }
          }

          // print("  ✅ 第${i + 1}个大限宫位比较完成");
        }

        // print("\n=== 比较完成 ===");
        // print("✅ 两种方法的计算结果一致性验证通过");
      } catch (e, s) {
        print("比较大限计算结果出错: $e");
        print("堆栈: $s");
        rethrow;
      }
    });
  });

  group("calculate 飞限", () {
    test("计算飞限 15年", skip: true, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);
      for (var element in finalResult) {
        print(jsonEncode(element));
      }
    });
    test("计算飞限 10年", skip: true, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults[1]);
      for (var element in finalResult) {
        print(jsonEncode(element));
      }
    });
    test("第一宫 计算飞限 4.5年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults[7]);
      expect(finalResult.length, 3);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.triangleIndex, 0);
    });
    test("第一宫 计算飞限 5.5 年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      var ming5_5Mapper = Map.fromEntries(
          daxianDurations.map((k, v) => MapEntry(k, v)).entries);
      ming5_5Mapper[EnumTwelveGong.Zi] = YearMonth(5, 6);

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: ming5_5Mapper,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);

      expect(finalResult.length, 4);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.triangleIndex, 1);
    });
    test("第一宫 计算飞限 6.5 年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      var ming5_5Mapper = Map.fromEntries(
          daxianDurations.map((k, v) => MapEntry(k, v)).entries);
      ming5_5Mapper[EnumTwelveGong.Zi] = YearMonth(6, 6);

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: ming5_5Mapper,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);

      expect(finalResult.length, 5);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.feiXianGongType, FeiXianGongType.current);
    });
    test("第一宫 计算飞限 7.5 年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      var ming5_5Mapper = Map.fromEntries(
          daxianDurations.map((k, v) => MapEntry(k, v)).entries);
      ming5_5Mapper[EnumTwelveGong.Zi] = YearMonth(7, 6);

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: ming5_5Mapper,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);

      expect(finalResult.length, 5);
      expect(finalResult.last.durationYears, YearMonth(1, 6));
      expect(finalResult.last.feiXianGongType, FeiXianGongType.current);
    });
    test("第一宫 计算飞限 8.5 年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      var ming5_5Mapper = Map.fromEntries(
          daxianDurations.map((k, v) => MapEntry(k, v)).entries);
      ming5_5Mapper[EnumTwelveGong.Zi] = YearMonth(8, 6);

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: ming5_5Mapper,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);

      expect(finalResult.length, 6);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.feiXianGongType, FeiXianGongType.opposite);
    });
    test("第一宫 计算飞限 9.5 年", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      var ming5_5Mapper = Map.fromEntries(
          daxianDurations.map((k, v) => MapEntry(k, v)).entries);
      ming5_5Mapper[EnumTwelveGong.Zi] = YearMonth(9, 6);

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: ming5_5Mapper,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults.first);
      // for (var element in finalResult) {
      //   print(jsonEncode(element));
      // }
      expect(finalResult.length, 6);
      expect(finalResult.last.durationYears, YearMonth(1, 6));
      expect(finalResult.last.feiXianGongType, FeiXianGongType.opposite);
    });
    test("未宫 计算飞限", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults[7]);
      // for (var element in finalResult) {
      //   print(jsonEncode(element));
      // }
      expect(finalResult.length, 3);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.triangleIndex, 0);
      expect(finalResult.last.endAge, daxianResults[7].endAge,
          reason: "${finalResult.last.endAge} - ${daxianResults[7].endAge}");
    });

    test("申宫 计算飞限", skip: false, () {
      final zhouTianCalculator = ZhouTianCalculator(
        zhouTianModel: zhouTianModel,
      );
      final result = zhouTianCalculator.mapConstellationsToPalaces();
      final palaceMapper = zhouTianCalculator.calculatePalaceAngles();

      final dongWeiCalculator = DongWeiDaXianCalculator(
        zhouTianModel: zhouTianModel, // 你的静态周天模型
        basePanel: basePanel,
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        observerPosition: observer,
      );
      List<DaXianPalaceInfo> daxianResults = dongWeiCalculator
          .calculateDaXianV1(result, palaceMapper, basePanel.enteredGongMapper);

      final feiXianCalculator = FeiXianCalculator(
        zhouTianModel:
            ZhouTianModelManager.instance.getZhouTianModelBy(panelConfig),
        daxianPalaceOrder: daxianOrder,
        daxianPalaceDurations: daxianDurations,
        basePanel: basePanel,
        observerPosition: observer,
      );
      List<FeiXianDetailPalace> finalResult =
          feiXianCalculator.calculateEach(daxianResults[8]);
      // for (var element in finalResult) {
      //   print(jsonEncode(element));
      // }
      // print(daxianResults[8].startAge);
      expect(finalResult.length, 3);
      expect(finalResult.last.durationYears, YearMonth(0, 6));
      expect(finalResult.last.triangleIndex, 0);
      expect(finalResult.last.endAge, daxianResults[8].endAge,
          reason: "${finalResult.last.endAge} - ${daxianResults[8].endAge}");
    });
  });
}

Future<Map<String, ZhouTianModel>> loadFromFiles(List<String> filePaths) async {
  Map<String, ZhouTianModel> _mapper = {};
  for (String filePath in filePaths) {
    File file = File(filePath);
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    ZhouTianModel model = ZhouTianModel.fromJson(jsonMap);
    _mapper[model.epochCorrection] = model;
  }
  return _mapper; // Return the mapper as the resul
}
