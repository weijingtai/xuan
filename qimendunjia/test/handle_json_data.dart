import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/model/base_ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';

void main() {
  group('十干克应，raw json to formatted json ', () {
    test("十干克应", () {
      // 读取文件
      final file = File('test/data/ten_gan_ke_ying_final_v1.json');
      final content = file.readAsStringSync();
      Map<String, dynamic> jsonMapper = jsonDecode(content);

      // 保留jsonMapper key 为String, value TenGanKeYing
      Map<TianGan, Map<TianGan, BaseTenGanKeYing>> result = {};
      for (var key in jsonMapper.keys) {
        Map<TianGan, TenGanKeYing> res = {};
        Map<String, dynamic> value = jsonMapper[key]!;
        if (key == "甲") {
          for (var k in value.keys) {
            res[TianGan.JIA] = TenGanKeYing.fromJson(value[k]);
          }
          result[TianGan.JIA] = res;
        } else {
          for (var k in value.keys) {
            if (k == "甲") {
              res[TianGan.JIA] = TenGanKeYing.fromJson(value[k]);
            } else {
              res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
            }
          }
          result[TianGan.getFromValue(key)!] = res;
        }
      }
      // 写出文件
      // final fileOut = File('test/data/ten_gan_ke_ying.json');
      // fileOut.writeAsStringSync(jsonEncode(result.));
      // Map<HouTianGua,Map<HouTianGua,TenGanKeYing>> data = result.map((key,value)=>{})
    });
  });
  group("十干克应，2", () {
    test("ten gan ke ying", () {
      // 读取文件
      try {
        final file = File('../assets/qi_men_dun_jia/ten_gan_ke_ying_v1.json');
        final jsonString = file.readAsStringSync();
        Map<String, dynamic> jsonMapper = jsonDecode(jsonString);
        Map<TianGan, Map<TianGan, TenGanKeYing>> result = {};
        for (var key in jsonMapper.keys) {
          Map<TianGan, TenGanKeYing> res = {};
          Map<String, dynamic> value = jsonMapper[key]!;
          if (key == "甲") {
            for (var k in value.keys) {
              res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
            }
            result[TianGan.JIA] = res;
          } else {
            for (var k in value.keys) {
              if (k == "甲") {
                res[TianGan.JIA] = TenGanKeYing.fromJson(value[k]);
              } else {
                res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
              }
            }
            result[TianGan.getFromValue(key)!] = res;
          }
        }
        // print(result.entries.first);
        final file2 =
            File('../assets/qi_men_dun_jia/ten_gan_ke_ying_ji_xiong.json');
        final jsonString2 = file2.readAsStringSync();
        Map<String, dynamic> jsonMapper2 = jsonDecode(jsonString2);
        Map<String, Map<String, TenGanKeYingGeJu>> finalResult = {};
        for (var key in jsonMapper2.keys) {
          if (!finalResult.containsKey(key)) {
            finalResult[key] = {};
          }
          for (var k in jsonMapper2[key]!.keys) {
            // if (!finalResult[key]!.containsKey(k)){
            //   finalResult[key]![k] = {};
            // }
            List<dynamic> geJuNames = jsonMapper2[key][k]["geJuNames"];
            String jiXiong = jsonMapper2[key][k]["jiXiong"];
            List<dynamic> shorExplains = jsonMapper2[key][k]["shorExplains"];
            TianGan tian = TianGan.getFromValue(key)!;
            TianGan di = TianGan.getFromValue(k)!;
            var keYing = result[tian]?[di];
            Set<String> geJuNameList =
                geJuNames.map((e) => e.toString()).toSet();
            if (keYing?.juName != null) {
              geJuNameList.add(keYing?.juName ?? "");
            }
            List<String> explainList =
                shorExplains.map((e) => e.toString()).toList();
            if (keYing?.shortExplain != null) {
              explainList.add(keYing!.shortExplain);
            }
            if (keYing?.longExplain != null) {
              explainList.add(keYing!.longExplain!);
            }
            var geJu = TenGanKeYingGeJu(
                tianPan: tian,
                diPan: di,
                jiXiong: JiXiongEnum.fromName(jiXiong),
                geJuNames: geJuNameList.toList(),
                explains: explainList);
            finalResult[key]![k] = geJu;
          }
        }
        // final file3 = File('../assets/qi_men_dun_jia/ten_gan_ke_ying_final.json');
        // final jsonString3 = file3.readAsStringSync();
        // file3.writeAsStringSync(JsonEncoder.withIndent(" "*4).convert(finalResult));
      } catch (e) {
        rethrow;
      }
    });
    test("ten gan ke ying ge ju", () {
      final file2 = File('../assets/qi_men_dun_jia/ten_gan_ke_ying_final.json');
      final jsonString2 = file2.readAsStringSync();
      Map<String, dynamic> jsonMapper2 = jsonDecode(jsonString2);
      Map<TianGan, Map<TianGan, TenGanKeYingGeJu>> finalResult = {};
      for (var key in jsonMapper2.keys) {
        TianGan tian = TianGan.getFromValue(key)!;
        if (!finalResult.containsKey(tian)) {
          finalResult[tian] = {};
        }
        for (var k in jsonMapper2[key]!.keys) {
          TianGan di = TianGan.getFromValue(k)!;
          finalResult[tian]![di] =
              TenGanKeYingGeJu.fromJson(jsonMapper2[key][k]);
          // print(finalResult[tian]![di]);
        }
      }
      return finalResult;
    });
  });
}
