import 'dart:convert';
import 'dart:io';

import 'package:daliuren/domain/enums/nine_zong_men.dart';
import 'package:daliuren/domain/enums/three_chuan_staff.dart';
import 'package:daliuren/model/raw_pan_datamodel.dart';

import '../lib/domain/services/nine_zong_men_calculator_v1_2.dart';

void main() async {
  print('=== 大六壬涉害法测试与比较 ===');

  try {
    // 1. 读取原始数据文件
    final file = File('test/甲戊庚牛羊.json');
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    print('成功加载数据，共 ${jsonData.length} 条记录');

    // 2. 筛选涉害课式
    // List<Map<String, dynamic>> sheHaiCases = [];
    int processedCount = 0;
    int sheHaiCount = 0;

    List<RawPan> sheHaiList = []; // 添加缺失的分号
    for (int i = 0; i < jsonData.length; i++) {
      final data = jsonData[i];
      processedCount++;

      try {
        // 解析为 RawPan 对象
        final rawPan = RawPan.fromJson(data);

        // 使用默认策略计算九宗门
        final calculator = DaLiuRenModelCalculator(
          rawPanData: rawPan,
          sheHaiStrategy: SheHaiStrategy.COMPREHENSIVE,
        );

        final result = calculator.resolveThreeChuan();

        // 检查是否为涉害课
        if (result.nineZongmen == NineZongMen.SHE_HAI) {
          sheHaiList.add(rawPan);
          // sheHaiCount++; // 增加计数

          // 同时添加到 sheHaiCases 用于后续比较
          // sheHaiCases.add({
          //   'index': i + 1,
          //   'rawData': data,
          //   'nineZongmen': result.nineZongmen.name,
          //   'className': result.className,
          //   'content': result.content,
          // });
        }
      } catch (e) {
        print('处理第 ${i + 1} 条数据时出错: $e');
        continue;
      }
    }

    print('\n=== 筛选完成 ===');
    print('总计处理: $processedCount 条数据');
    print('发现涉害课式: ${sheHaiList.length} 个');
    print(
        '涉害课式占比: ${(sheHaiList.length / processedCount * 100).toStringAsFixed(2)}%');

    // 3. 保存涉害课式到文件
    if (sheHaiList.isNotEmpty) {
      final sheHaiFile = File('test/she_hai.json');

      // 将 sheHaiList 转换为可序列化的格式
      final sheHaiListJson =
          sheHaiList.map((rawPan) => rawPan.toJson()).toList();
      final sheHaiJson = json.encode(sheHaiListJson);
      await sheHaiFile.writeAsString(sheHaiJson);
      print('\n涉害课式已保存到: test/she_hai.json');

      // 4. 使用三种策略重新计算并比较结果
      print('\n=== 开始三种涉害策略比较 ===');
      // await compareThreeStrategies(sheHaiCases);
    } else {
      print('\n未发现涉害课式，无需进行策略比较');
    }
  } catch (e) {
    print('程序执行出错: $e');
  }
}

/// 比较三种涉害策略的计算结果
Future<void> compareThreeStrategies(
    List<Map<String, dynamic>> sheHaiCases) async {
  int totalCases = sheHaiCases.length;
  int differentResults = 0;
  List<Map<String, dynamic>> differenceDetails = [];

  print('开始比较 $totalCases 个涉害课式的三种策略结果...');

  for (int i = 0; i < sheHaiCases.length; i++) {
    final caseData = sheHaiCases[i];
    final rawData = caseData['rawData'];

    try {
      // 解析原始数据
      final rawPan = RawPan.fromJson(rawData);

      // 使用三种策略分别计算
      final strategies = [
        SheHaiStrategy.COMPREHENSIVE,
        SheHaiStrategy.MENG_PRIORITY,
        SheHaiStrategy.COMBINED_APPROACH,
      ];

      List<ThreeChuanOutput> results = [];

      for (final strategy in strategies) {
        final calculator = DaLiuRenModelCalculator(
          rawPanData: rawPan,
          sheHaiStrategy: strategy,
        );

        final result = calculator.resolveThreeChuan();
        results.add(result);
      }

      // 比较三传结果是否相同
      bool hasThreeChuanDifference = false;

      // 比较深浅法和孟仲法的三传
      if (results.length >= 2) {
        final comprehensive = results[0];
        final mengPriority = results[1];

        bool threeChuanSame =
            comprehensive.first.diZhi == mengPriority.first.diZhi &&
                comprehensive.second.diZhi == mengPriority.second.diZhi &&
                comprehensive.third.diZhi == mengPriority.third.diZhi;

        if (!threeChuanSame) {
          hasThreeChuanDifference = true;
          differentResults++;

          // 记录差异详情
          final differenceDetail = {
            'caseIndex': caseData['index'],
            'dayInfo': '${rawPan.day.name}日${rawPan.upon.name}时',
            'juInfo': '${rawPan.juStr}(${rawPan.ju})',
            'comprehensive': {
              'strategy': '深浅法',
              'className': comprehensive.patternName,
              'content': comprehensive.content,
              'threeChuan': [
                comprehensive.first.diZhi.name,
                comprehensive.second.diZhi.name,
                comprehensive.third.diZhi.name,
              ]
            },
            'mengPriority': {
              'strategy': '孟仲法',
              'className': mengPriority.patternName,
              'content': mengPriority.content,
              'threeChuan': [
                mengPriority.first.diZhi.name,
                mengPriority.second.diZhi.name,
                mengPriority.third.diZhi.name,
              ]
            }
          };

          differenceDetails.add(differenceDetail);

          // 打印到控制台
          print('\n🔍 发现三传差异 #$differentResults:');
          print(
              '   课式: ${rawPan.day.name}日${rawPan.upon.name}时 ${rawPan.juStr}(${rawPan.ju})');
          print('   深浅法: ${comprehensive.patternName}');
          print(
              '     三传: ${comprehensive.first.diZhi.name} → ${comprehensive.second.diZhi.name} → ${comprehensive.third.diZhi.name}');
          print('     说明: ${comprehensive.content}');
          print('   孟仲法: ${mengPriority.patternName}');
          print(
              '     三传: ${mengPriority.first.diZhi.name} → ${mengPriority.second.diZhi.name} → ${mengPriority.third.diZhi.name}');
          print('     说明: ${mengPriority.content}');
        }
      }

      // 显示进度
      if ((i + 1) % 50 == 0 || i == sheHaiCases.length - 1) {
        print('已比较 ${i + 1}/$totalCases 个涉害课式，发现 $differentResults 个差异');
      }
    } catch (e) {
      print('比较第 ${caseData['index']} 个涉害课式时出错: $e');
      continue;
    }
  }

  // 输出统计结果
  print('\n=== 三种策略比较结果统计 ===');
  print('总涉害课式数量: $totalCases');
  print('三传结果相同: ${totalCases - differentResults}');
  print('三传结果不同: $differentResults');
  print('差异比例: ${(differentResults / totalCases * 100).toStringAsFixed(2)}%');

  // 保存差异详情到文件
  if (differenceDetails.isNotEmpty) {
    final differenceFile = File('test/she_hai_differences.json');
    final differenceJson = json.encode(differenceDetails);
    await differenceFile.writeAsString(differenceJson);
    print('\n差异详情已保存到: test/she_hai_differences.json');
  }

  print('\n=== 涉害法策略比较测试完成 ===');
}
