import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:daliuren/domain/enums/three_chuan_staff.dart';
import 'package:daliuren/domain/services/calculate_month_general_service.dart';
import 'package:daliuren/model/raw_pan_datamodel.dart';

import '../lib/domain/services/nine_zong_men_calculator_v1_2.dart';

void main() async {
  print('=== 大六壬九宗门计算器测试 ===');

  try {
    // 读取 JSON 数据文件
    final file = File('test/甲戊庚牛羊.json');
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    print('成功加载数据，共 ${jsonData.length} 条记录');

    // 测试前几条数据
    // final testCount = jsonData.length; // 测试前5条数据
    final testCount = 720; // 测试前5条数据
    for (int i = 0; i < testCount && i < jsonData.length; i++) {
      final data = jsonData[i];
      // print('\n--- 测试第 ${i + 1} 条数据 ---');
      // print(data);

      try {
        // 解析 JSON 数据为 RawPan 对象
        final rawPan = RawPan.fromJson(data);
        final SheHaiStrategy strategy = SheHaiStrategy.MENG_PRIORITY;

        // 创建计算器实例
        final calculator = DaLiuRenModelCalculator(
          rawPanData: rawPan,
          sheHaiStrategy: strategy,
          monthJiaZi: JiaZi.WU_ZI,
          timeJiaZi: JiaZi.WU_ZI,
          dayJiaZi: rawPan.day,
          dayNight: EnumDayNight.day,
          guiRenType: GuiRenType.Jia_Wu_Geng_Niu_Yang,
          guiRenPosition: DiZhi.ZI,
          dayNightBoundaryType: DayNightBoundaryType.maoYou,
        );

        // 执行三传计算
        final result = calculator.resolveThreeChuan();

        // 比较 result 和原始数据 中的三传数据
        final rawThreeChuan = rawPan.three;
        final resultThreeChuan = [result.first, result.second, result.third];
        if (resultThreeChuan[0] != result.first ||
            resultThreeChuan[1] != result.second ||
            resultThreeChuan[2] != result.third) {
          // 输出结果
          printDebugInfo(
            rawPan,
            result,
            resultThreeChuan,
            strategy,
          );
        }
      } catch (e) {
        print('处理第 ${i + 1} 条数据时出错: $e');
        print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌");
        print(data);
        print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌");
        throw e;
      }
    }
  } catch (e) {
    print('读取或解析 JSON 文件时出错: $e');
  }
}

void printDebugInfo(RawPan rawPan, ThreeChuanOutput result,
    List<ThreeClassItem> resultThreeChuan, SheHaiStrategy strategy) {
  print('输入数据:');
  print(
      '  ${rawPan.day.name} 干上${rawPan.upon.name} 第${rawPan.juStr} (${rawPan.ju})');
  print(" ${rawPan.four.map((f) => "${f.sky.name}").join(" ")}");
  print(" ${rawPan.four.map((f) => "${f.ground.name}").join(" ")}");
  print(
      " 九宗门：${result.nineZongmen.name}(${result.patternName}) --- ${strategy.name}");
  print(
      '  原三传: ${rawPan.three.map((t) => "${t.diZhi.name}(${t.liuQin.name})").join("  ")}');
  print(
      '  新三传: ${resultThreeChuan.map((t) => "${t.diZhi.name}(${t.liuQin.name})").join("  ")}');
}
