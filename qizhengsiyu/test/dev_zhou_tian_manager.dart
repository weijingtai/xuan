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
import 'package:qizhengsiyu/models/panel_config.dart';
import 'package:qizhengsiyu/models/zhou_tian_model.dart';
import 'package:common/models/year_month.dart';
import 'package:qizhengsiyu/xing_xian/da_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/da_xian_palace_info.dart';

void main() {
  late PanelConfig panelConfig;

  setUpAll(() async {
    // 在所有测试之前初始化绑定
    WidgetsFlutterBinding.ensureInitialized();

    panelConfig = PanelConfig(
        panelSystemType: PanelSystemType.tropical,
        celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
        houseDivisionSystem: HouseDivisionSystem.equal,
        settleLifeType: EnumSettleLifeType.Mao,
        settleBodyType: EnumSettleBodyType.moon,
        islifeGongBySunRealTimeLocation: true,
        constellationSystemType: ConstellationSystemType.classical);
    try {
      final projectRoot = Directory.current.path;
      final projectAssetsPath = "$projectRoot/../assets/qizhengsiyu";

      await ZhouTianModelManager.instance.loadFromFiles([
        "$projectAssetsPath/ecliptic_tropical_classical_adjusted.json",
        "$projectAssetsPath/ecliptic_tropical_classical.json",
        "$projectAssetsPath/ecliptic_tropical_morden.json"
      ]);
      // ZhouTianModelManager.instance.setModelsForTesting(testMapper);
    } catch (e) {
      print(e);
    }
  });

  group("", () {
    test("获取对应的tiZhouTianModel, 黄道回归古宿", () async {
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
    test("test", skip: true, () {
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
  });

  group("calculate daxian", () {
    test("计算洞微大限 v3", skip: true, () {
      final DateTime birth = DateTime(1990, 1, 15, 10, 30);
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
        EnumTwelveGong.Zi: YearMonth(17, 2), // 15年
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
          birthTime: birth,
          daxianPalaceOrder: daxianOrder,
          daxianPalaceDurations: daxianDurations,
        );
        List<DaXianPalaceInfo> daxianResults =
            dongWeiCalculator.calculateDaXian(result, palaceMapper);
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
