import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("create daliuren with shehai(涉害)", () {
    List<DiZhi> diZhiList = DiZhi.listAll;
    DiZhi timeZhi = DiZhi.SHEN;
    DiZhi monthGeneral = DiZhi.WEI;
    // List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi,diZhiList);
    // List<DiZhi> monthGeneralSeq = DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    // Map<DiZhi,DiZhi> currentPan = Map<DiZhi,DiZhi>.fromIterables(diSeq, monthGeneralSeq);

    List<DiZhi> dipanlistDev =
        "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
    List<DiZhi> tianpanlistDev =
        "戌亥子丑寅卯辰巳午未申酉".split("").map((e) => DiZhi.getFromValue(e)!).toList();
    // Map<DiZhi,DiZhi> currentPan = Map.fromIterables(diPanList_dev, tianPanList_dev);
    JiaZi dayJiaZi = JiaZi.WU_CHEN;

    List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, dipanlistDev);
    // List<DiZhi> monthGeneralSeq = DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    List<DiZhi> monthGeneralSeq = tianpanlistDev;

    // List<String> godsNameList = ["贵人","腾蛇","朱雀","六合","勾陈","青龙","天空","白虎","太常","玄武","太阴","天后"];
    List<GuiRen> godsNameList = GuiRen.clockwiseList;

    // Map<DiZhi,DiZhi> currentTianDiMapper = Map<DiZhi,DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    Map<DiZhi, DiZhi> currentTianDiMapper =
        Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, monthGeneralSeq);
    Map<DiZhi, GuiRen> currentDiGodsMapper =
        Map<DiZhi, GuiRen>.fromIterables(diSeq, godsNameList);
    Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
    for (var di in diSeq) {
      currentPanWithGods[di] = DaLiuRenGong(
          guiRen: currentDiGodsMapper[di]!,
          skyPanDiZhi: currentTianDiMapper[di]!,
          groundPanDiZhi: di);
    }

    test("两个贼 2  --- 涉害 1", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "戌亥子丑寅卯辰巳未申酉午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      // Map<DiZhi,DiZhi> currentTianDiMapper = Map<DiZhi,DiZhi>.fromIterables(diPanList_dev, tianPanList_dev);
      // Map<DiZhi,String> currentDiGodsMapper = Map<DiZhi,String>.fromIterables(diSeq, godsNameList);
      Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个贼 2  --- 涉害 1
      String first = "巳丁";
      String second = "卯巳";
      String third = "丑卯"; // 贼
      String fourth = "亥丑"; // 贼
      // String fourClassString = "$first $second $third $fourth";
      dayJiaZi = JiaZi.DING_SI;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(fourClass.third.isSkySameYinYangWithDayGan, true);
      expect(fourClass.fourth.isSkySameYinYangWithDayGan, true);
      expect(fourClass.third.sheHaiTimes, 2);
      expect(fourClass.fourth.sheHaiTimes, 6);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("亥"));
    });
    test("两个克 2 第一个为 第一课 --- 涉害 2", () {
      // print("old天：${tianPanList.map((e)=>e.value)}");
      // print("old地：${diPanList.map((e)=>e.value)}");
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个克 2  --- 涉害 2
      String first = "午庚"; // 克
      String second = "辰午";
      String third = "戌子"; // 克
      String fourth = "申戌";
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(fourClass.third.isSkySameYinYangWithDayGan, true);
      expect(fourClass.third.sheHaiTimes, 2);
      expect(fourClass.first.sheHaiTimes, 4);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("午"));
    });
    test("两个贼 --- 涉害 3 --- 缀", () {
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个克 2  --- 涉害 2
      String fourth = "午亥"; // 贼
      String third = "卯辰"; // 克
      String second = "未子"; // 克
      String first = "子戊"; // 贼
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("子"));
    });
    test("三个贼 一个克 --- 涉害 3 --- 缀", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "未申酉戌亥子丑寅卯辰巳午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }

      // 两个克 2  --- 涉害 2
      String fourth = "午亥"; // 贼
      String third = "亥辰"; // 贼
      String second = "未子"; // 克
      String first = "子戊"; // 贼
      dayJiaZi = JiaZi.WU_CHEN;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(fourClass.third.sheHaiTimes, null);
      expect(fourClass.fourth.sheHaiTimes, 4);
      expect(fourClass.first.sheHaiTimes, 4);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("子"));
    });
    test("三克 一贼 --- 涉害 3 --- 缀", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "未申酉戌亥子丑寅卯辰巳午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个克 2  --- 涉害 2
      String first = "午戊"; // 贼
      String second = "子午"; // 克
      String third = "卯辰"; // 克
      String fourth = "午申"; // 克
      dayJiaZi = JiaZi.WU_CHEN;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(fourClass.second.sheHaiTimes, 4);
      expect(fourClass.third.isSkySameYinYangWithDayGan, false);
      // print(fourClass.third.sheHaiTimes);
      expect(fourClass.fourth.sheHaiTimes, 0);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("子"));
    });
  });
}

/// "<四> <三> <二> <一>"
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
