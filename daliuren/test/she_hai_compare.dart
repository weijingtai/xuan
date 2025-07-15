import 'dart:convert';
import 'dart:io';

import 'package:daliuren/domain/enums/nine_zong_men.dart';
import 'package:daliuren/model/raw_pan_datamodel.dart';

import '../lib/domain/services/nine_zong_men_calculator_v1_2.dart';

void main() async {
  print('=== 大六壬涉害法三种策略比较 ===');

  try {
    // 1. 读取涉害课式数据文件
    final file = File('test/she_hai.json');
    if (!await file.exists()) {
      print('错误：test/she_hai.json 文件不存在，请先运行 she_hai_checkout.dart 生成数据');
      return;
    }

    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    print('成功加载涉害课式数据，共 ${jsonData.length} 条记录');

    // 2. 对每个RawPan使用三种策略计算三传
    List<Map<String, dynamic>> differenceResults = [];
    int totalCases = jsonData.length;
    int differentCount = 0;

    for (int i = 0; i < jsonData.length; i++) {
      final data = jsonData[i];

      try {
        // 解析为 RawPan 对象
        final rawPan = RawPan.fromJson(data);

        // 使用三种策略分别计算
        final strategies = [
          SheHaiStrategy.COMPREHENSIVE, // 深浅法
          SheHaiStrategy.MENG_PRIORITY, // 孟仲法
          SheHaiStrategy.COMBINED_APPROACH // 两法参合
        ];

        List<ThreeChuanOutput> results = [];
        List<String> strategyNames = ['深浅法', '孟仲法', '两法参合'];

        // 分别使用三种策略计算
        for (int j = 0; j < strategies.length; j++) {
          final calculator = DaLiuRenModelCalculator(
            rawPanData: rawPan,
            sheHaiStrategy: strategies[j],
          );

          final result = calculator.resolveThreeChuan();
          results.add(result);
        }

        // 3. 比较三种策略的三传结果
        bool hasThreeChuanDifference = false;

        // 检查是否所有三传结果都相同
        String firstThreeChuan =
            '${results[0].first.diZhi.name}-${results[0].second.diZhi.name}-${results[0].third.diZhi.name}';

        for (int k = 1; k < results.length; k++) {
          String currentThreeChuan =
              '${results[k].first.diZhi.name}-${results[k].second.diZhi.name}-${results[k].third.diZhi.name}';
          if (firstThreeChuan != currentThreeChuan) {
            hasThreeChuanDifference = true;
            break;
          }
        }

        // 4. 如果结果不同，记录差异详情
        if (hasThreeChuanDifference) {
          differentCount++;

          Map<String, dynamic> differenceDetail = {
            'index': i + 1,
            'dayInfo': '${rawPan.day.name}日${rawPan.upon.name}时',
            'juInfo': '${rawPan.juStr}(${rawPan.ju})',
            'rawPanData': rawPan.toJson(),
            'strategies': []
          };

          // 记录每种策略的结果
          for (int j = 0; j < results.length; j++) {
            differenceDetail['strategies'].add({
              'strategyName': strategyNames[j],
              'className': results[j].patternName,
              'content': results[j].content,
              'threeChuan': [
                results[j].first.diZhi.name,
                results[j].second.diZhi.name,
                results[j].third.diZhi.name,
              ],
              'threeChuanString':
                  '${results[j].first.diZhi.name} → ${results[j].second.diZhi.name} → ${results[j].third.diZhi.name}'
            });
          }

          differenceResults.add(differenceDetail);

          // 打印差异到控制台
          print('\n🔍 发现三传差异 #$differentCount:');
          print(
              '   课式: ${rawPan.day.name}日${rawPan.upon.name}时 ${rawPan.juStr}(${rawPan.ju})');

          for (int j = 0; j < results.length; j++) {
            print('   ${strategyNames[j]}: ${results[j].patternName}');
            print(
                '     三传: ${results[j].first.diZhi.name} → ${results[j].second.diZhi.name} → ${results[j].third.diZhi.name}');
            print('     说明: ${results[j].content}');
          }
        }

        // 显示进度
        if ((i + 1) % 10 == 0 || i == jsonData.length - 1) {
          print('已比较 ${i + 1}/$totalCases 个涉害课式，发现 $differentCount 个差异');
        }
      } catch (e) {
        print('处理第 ${i + 1} 条数据时出错: $e');
        continue;
      }
    }

    // 5. 输出统计结果
    print('\n=== 三种涉害策略比较结果统计 ===');
    print('总涉害课式数量: $totalCases');
    print('三传结果相同: ${totalCases - differentCount}');
    print('三传结果不同: $differentCount');
    print('差异比例: ${(differentCount / totalCases * 100).toStringAsFixed(2)}%');

    // 6. 保存差异结果到文件
    if (differenceResults.isNotEmpty) {
      final diffFile = File('test/she_hai_diff.json');
      final diffJson = json.encode(differenceResults);
      await diffFile.writeAsString(diffJson);
      print('\n差异详情已保存到: test/she_hai_diff.json');
      print('差异详情包含:');
      print('  - RawPan 原始数据');
      print('  - 三种策略的计算结果');
      print('  - 三传对比信息');
    } else {
      print('\n所有涉害课式的三种策略结果完全一致，无差异文件生成');
    }

    print('\n=== 涉害法三种策略比较完成 ===');
  } catch (e) {
    print('程序执行出错: $e');
  }
}
