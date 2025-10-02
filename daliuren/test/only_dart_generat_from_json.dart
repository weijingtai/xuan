import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/da_liu_ren_pan_model.dart';
import 'package:daliuren/model/each_class.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:daliuren/model/yu_ding_da_liu_ren.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // read_from_file();
  group("create", () {
    test("json ser", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "酉戌亥子丑寅卯辰巳午未申".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<GuiRen> godsNameList = GuiRen.clockwiseList;
      JiaZi dayJiaZi = JiaZi.WU_CHEN;
      DiZhi timeZhi = DiZhi.SHEN;
      List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, dipanlistDev);
      Map<DiZhi, GuiRen> currentDiGodsMapper =
          Map<DiZhi, GuiRen>.fromIterables(diSeq, godsNameList);

      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
      for (var di in dipanlistDev) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // currentPanWithGods.forEach((k,v)=>print("${k.value} ${v.groundPanDiZhi.value}=${v.skyPanDiZhi.value}"));
      // 两个贼 2  --- 涉害 1
      String first = "辰丁";
      String second = "丑辰"; // 妻财
      String third = "戌丑"; // 官鬼
      String fourth = "未戌"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      FourClass fourClass2 = FourClass.fastGenerate(
          dayGanZhi: dayJiaZi, eachGongMapper: currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      // print(jsonEncode(fourClass2));
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, null);
      expect(fourClass.third.isSkyKeDayGan, null);
      expect(fourClass.fourth.isSkyKeDayGan, null);
      ThreeChuan? maoXing =
          DaLiuRenKePan.checkByMaoXing(dayJiaZi, fourClass, currentPanWithGods);
      expect(maoXing, isNotNull);
      expect(maoXing!.first.diZhi, DiZhi.getFromValue("子"));
      expect(maoXing.second.diZhi, DiZhi.getFromValue("辰"));
      expect(maoXing.third.diZhi, DiZhi.getFromValue("戌"));
    });
    // test("", () {
    //   read_from_file();
    // });
    test("handle 御定大六壬", () {
      read_yu_ding();
    });
  });
}

FourClass createFourClass(JiaZi dayJiaZi, String first, String second,
    String third, String fourth, Map<DiZhi, DaLiuRenGong> eachGongMapper) {
  // List<String> each = fourClassString.split(" ").toList();
  //
  // String first = each[3];
  // String second = each[2];
  // String third = each[1];
  // String fourth = each[0];

  return FourClass.generate(
      firstGround: TianGan.getFromValue(first.split("").last)!,
      firstSky: DiZhi.getFromValue(first.split("").first)!,
      secondSky: DiZhi.getFromValue(second.split("").first)!,
      secondGround: DiZhi.getFromValue(second.split("").last)!,
      thirdSky: DiZhi.getFromValue(third.split("").first)!,
      thirdGround: DiZhi.getFromValue(third.split("").last)!,
      fourthSky: DiZhi.getFromValue(fourth.split("").first)!,
      fourthGround: DiZhi.getFromValue(fourth.split("").last)!,
      // dayGanZhi:JiaZi.getFromGanZhiValue("${first.split("").last}${DiZhi.getFromValue(third.split("").last)!}")!,
      dayGanZhi: dayJiaZi,
      eachGongMapper: eachGongMapper);
}

void read_yu_ding() {
  String content =
      File('${Directory.current.path}\\test\\御定.json').readAsStringSync();
  Map<String, dynamic> rawJsonMapper = jsonDecode(content);
  List<YuDingDaLiuRen> allList = [];
  for (MapEntry<String, dynamic> rawMapper in rawJsonMapper.entries) {
    // print(rawMapper.value);
    for (MapEntry<String, dynamic> eachClass in rawMapper.value.entries) {
      Map<String, String> detailMapper = {};
      for (var d in eachClass.value['details'].entries) {
        detailMapper[d.key] = d.value as String;
      }
      Map<String, String> bookMapper = {};
      for (var d in eachClass.value['books'].entries) {
        bookMapper[d.key] = d.value as String;
      }
      var yuDing = YuDingDaLiuRen(
        details: detailMapper,
        books: bookMapper,
        dayJiaZi: JiaZi.getFromGanZhiValue(eachClass.value["dayJiaZi"])!,
        juNumber: eachClass.value['juNumber'],
        juName: DiZhi.getFromValue(eachClass.value['juName'])!,
        body: Set.from(eachClass.value['body']),
        meaning: eachClass.value['meaning'],
        explain: eachClass.value['explain'],
        predication: eachClass.value['predication'],
      );
      allList.add(yuDing);
    }
    // print(rawMapper.key);
  }
  File('${Directory.current.path}\\test\\御定大六壬.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(allList));
}

// 从‘1.json’ 中读取数据
void read_from_file() {
  // 打开文件并读取其中内容
  String content =
      File('${Directory.current.path}\\test\\2.json').readAsStringSync();
  List<DaLiuRenPanModel> allPanModel = [];
  // 解析文件
  try {
    Map<String, dynamic> json = jsonDecode(content);

    for (var eachJiaZi in json.values) {
      // print(eachJiaZi.keys.length);
      // print(eachJiaZi.values.first);
      // print(eachJiaZi.values.first);

      // print("$jiaZiName $shiChenName $orderInThatDay");
      // print( eachJiaZi.keys.length);
      for (var key in eachJiaZi.keys) {
        String name = key;
        String jiaZiName = name.split(" ")[1].substring(0, 2);
        String shiChenName =
            name.split(" ")[0].replaceFirst("【", "").replaceFirst("】", "");
        String orderInThatDay = name.split(" ")[1].substring(2);
        JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(jiaZiName)!;
        Map<String, dynamic> res = eachJiaZi[key];

        Map<DiZhi, DaLiuRenGong> eachGongMapper = {};
        for (Map<String, dynamic> eachGongJsonDict in res["gongList"]) {
          DaLiuRenGong eachGong = DaLiuRenGong(
            skyPanDiZhi: DiZhi.getFromValue(eachGongJsonDict['tian']!)!,
            groundPanDiZhi: DiZhi.getFromValue(eachGongJsonDict['di']!)!,
            guiRen: GuiRen.getBySingleName(eachGongJsonDict['guiRen']!),
          );
          eachGongMapper[eachGong.groundPanDiZhi] = eachGong;
        }
        FourClass fourClass = FourClass.fastGenerate(
            dayGanZhi: dayJiaZi, eachGongMapper: eachGongMapper);
        // if ([JiaZi.WU_XU,JiaZi.WU_CHEN].contains(dayJiaZi)&&["七局"].contains(orderInThatDay)){
        //   if ([JiaZi.WU_XU].contains(dayJiaZi)&&["七局"].contains(orderInThatDay)){
        //   continue;
        // }

        // print("${dayJiaZi.ganZhiStr} $orderInThatDay - 伏吟:${fourClass.isFuYin},反吟:${fourClass.isFanYin},四课备${fourClass.isFullClass},四课不备${fourClass.isThreeClassOnly}");
        test_four_class(dayJiaZi, name, fourClass, res["fourClass"]);

        ThreeChuan threeChuan = DaLiuRenKePan.calculateThreeChuan(
            dayJiaZi, fourClass, eachGongMapper);
        // if (threeChuan.nineZongMen == NineZongMen.SHE_HAI){
        //  // 如何是涉害法 需要表现出 涉害的步骤
        //   print("${fourClass.first.sky.name}${fourClass.first.tianGan.name}${fourClass.first.sheHaiTimes},"
        //       "${fourClass.second.sky.name}${fourClass.second.sky.name}${fourClass.second.sheHaiTimes},"
        //       "${fourClass.third.sky.name}${fourClass.third.sky.name}${fourClass.third.sheHaiTimes},"
        //       "${fourClass.fourth.sky.name}${fourClass.fourth.sky.name}${fourClass.fourth.sheHaiTimes}");
        // }
        test_three_chuan(dayJiaZi, name, threeChuan, res["threeChuan"]);
        allPanModel.add(DaLiuRenPanModel(
          dayJiaZi: dayJiaZi,
          shiChen: DiZhi.getFromValue(shiChenName)!,
          juNumberName: orderInThatDay,
          fourClass: fourClass,
          threeChuan: threeChuan,
          gongMapper: eachGongMapper,
        ));
        // print('------------==========================');
      }

      // break;
      // print("${dayJiaZi} 通过");
    }
    // 将 JSON 对象转换为 Dart 对象
    // var data = Data.fromJson(json);
    // 打印 Dart 对象
    // print(data);
  } catch (e) {
    print(e);
  }
  // print(allPanModel.length);
  // 写出json格式到文
  // File('${Directory.current.path\test\\甲午庚牛羊_阴.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(allPanModel));

  // juNumber
  File('${Directory.current.path}\\test\\甲午庚牛羊_阴.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(allPanModel));

  // 将读取的内容转换为 JSON 对象
}

void test_four_class(JiaZi dayJiaZi, String juName, FourClass fourClass,
    Map<String, dynamic> rawFourClass) {
  List<EachClass> yaoKeSkyKeDayGanList = fourClass.listAllClass
      .where((each) => each.isSkyKeDayGan != null && each.isSkyKeDayGan!)
      .toList();
  List<EachClass> yaoKeDayGanKeSkyList = fourClass.listAllClass
      .where((each) => each.isSkyKeDayGan != null && !each.isSkyKeDayGan!)
      .toList();
  expect(fourClass.first.sky, DiZhi.getFromValue(rawFourClass["first"]['sky']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.first.ground,
      DiZhi.getFromValue(rawFourClass["first"]['ground']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.first.guiRen,
      GuiRen.getBySingleName(rawFourClass["first"]['god']),
      reason: "${dayJiaZi.name} $juName 四课");

  expect(
      fourClass.second.sky, DiZhi.getFromValue(rawFourClass["second"]['sky']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.second.ground,
      DiZhi.getFromValue(rawFourClass["second"]['ground']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.second.guiRen,
      GuiRen.getBySingleName(rawFourClass["second"]['god']),
      reason: "${dayJiaZi.name} $juName 四课");

  expect(fourClass.third.sky, DiZhi.getFromValue(rawFourClass["third"]['sky']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.third.ground,
      DiZhi.getFromValue(rawFourClass["third"]['ground']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.third.guiRen,
      GuiRen.getBySingleName(rawFourClass["third"]['god']),
      reason: "${dayJiaZi.name} $juName 四课");

  expect(
      fourClass.fourth.sky, DiZhi.getFromValue(rawFourClass["fourth"]['sky']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.fourth.ground,
      DiZhi.getFromValue(rawFourClass["fourth"]['ground']),
      reason: "${dayJiaZi.name} $juName 四课");
  expect(fourClass.fourth.guiRen,
      GuiRen.getBySingleName(rawFourClass["fourth"]['god']),
      reason: "${dayJiaZi.name} $juName 四课");
}

void test_three_chuan(JiaZi dayJiaZi, String juName, ThreeChuan threeChuan,
    Map<String, dynamic> rawThreeChuan) {
  expect(
      threeChuan.first.diZhi, DiZhi.getFromValue(rawThreeChuan["first"]['zhi']),
      reason: "${dayJiaZi.name} $juName 初传 地支");
  var strGan = rawThreeChuan["first"]['gan"'];
  expect(threeChuan.first.tianGan,
      strGan == null ? strGan : TianGan.getFromValue(strGan),
      reason: "${dayJiaZi.name} $juName 初传 天干");
  expect(threeChuan.first.guiRen,
      GuiRen.getBySingleName(rawThreeChuan["first"]['guiRen']),
      reason: "${dayJiaZi.name} $juName 初传 贵人");
  expect(threeChuan.first.liuQin,
      LiuQin.getLiuQinBySingleName(rawThreeChuan["first"]['LiuQin']),
      reason: "${dayJiaZi.name} $juName 初传 六亲");

  expect(threeChuan.second.diZhi,
      DiZhi.getFromValue(rawThreeChuan["second"]['zhi']),
      reason: "${dayJiaZi.name} $juName 中传 地支");
  strGan = rawThreeChuan["second"]['gan"'];
  expect(threeChuan.second.tianGan,
      strGan == null ? strGan : TianGan.getFromValue(strGan),
      reason: "${dayJiaZi.name} $juName 中传 天干");
  expect(threeChuan.second.guiRen,
      GuiRen.getBySingleName(rawThreeChuan["second"]['guiRen']),
      reason: "${dayJiaZi.name} $juName 中传 贵人");
  expect(threeChuan.second.liuQin,
      LiuQin.getLiuQinBySingleName(rawThreeChuan["second"]['LiuQin']),
      reason: "${dayJiaZi.name} $juName 中传 六亲");

  expect(
      threeChuan.third.diZhi, DiZhi.getFromValue(rawThreeChuan["third"]['zhi']),
      reason: "${dayJiaZi.name} $juName 末传 地支");
  strGan = rawThreeChuan["third"]['gan"'];
  expect(threeChuan.third.tianGan,
      strGan == null ? strGan : TianGan.getFromValue(strGan),
      reason: "${dayJiaZi.name} $juName 末传 天干");
  expect(threeChuan.third.guiRen,
      GuiRen.getBySingleName(rawThreeChuan["third"]['guiRen']),
      reason: "${dayJiaZi.name} $juName 末传 贵人");
  expect(threeChuan.third.liuQin,
      LiuQin.getLiuQinBySingleName(rawThreeChuan["third"]['LiuQin']),
      reason: "${dayJiaZi.name} $juName 末传 六亲");
}
