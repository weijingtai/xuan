import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("create daliuren with zeike(贼克)", () {
    List<DiZhi> diZhiList = DiZhi.listAll;
    DiZhi timeZhi = DiZhi.SHEN;
    DiZhi monthGeneral = DiZhi.WEI;
    List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, diZhiList);
    List<DiZhi> monthGeneralSeq =
        DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    List<GuiRen> godsNameList = GuiRen.clockwiseList;
    // JiaZi dayJiaZi = JiaZi.JIA_ZI;
    Map<DiZhi, DiZhi> currentTianDiMapper =
        Map<DiZhi, DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    Map<DiZhi, GuiRen> currentDiGodsMapper =
        Map<DiZhi, GuiRen>.fromIterables(diSeq, godsNameList);
    Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
    for (var di in diSeq) {
      currentPanWithGods[di] = DaLiuRenGong(
          guiRen: currentDiGodsMapper[di]!,
          skyPanDiZhi: currentTianDiMapper[di]!,
          groundPanDiZhi: di);
    }

    test("一个克", () {
      String first = "亥癸";
      String second = "午申"; // 克
      String third = "卯巳";
      String fourth = "辰酉";
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("午"));
    });
    test("一个贼", () {
      String first = "亥癸";
      String second = "酉亥";
      String third = "卯巳";
      String fourth = "丑卯"; // 贼
      // String fourClassString = "$first $second $third $fourth";
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("丑"));
    });
    test("一个克 一贼", () {
      // 一个克
      String first = "亥癸";
      String second = "午申"; // 克
      String third = "卯巳";
      String fourth = "丑卯"; // 贼
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("丑"));
    });
    test("两个贼 1", () {
      // // 两个贼 1
      String first = "子丙";
      String second = "未子";
      String third = "卯申"; // 贼
      String fourth = "戌卯"; // 贼
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // print("first ${fourClass.firstClass.zeiKeType?.name}");
      // print("second ${fourClass.secondClass.zeiKeType?.name}");
      // print("third ${fourClass.thirdClass.zeiKeType?.name}");
      // print("fourth ${fourClass.fourthClass.zeiKeType?.name}");
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("戌"));
    });
    test("两个贼 2", () {
      String first = "亥乙";
      String second = "午亥"; // 贼
      String third = "辰酉";
      String fourth = "亥辰"; // 贼
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      // expect(chuChuanDiZhi.sky, DiZhi.getFromValue("亥"));
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("亥"));
    });
    test("两个克 2", () {
      String first = "亥乙";
      String second = "午申"; // 克
      String third = "辰酉";
      String fourth = "亥巳"; // 克
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      // expect(chuChuanDiZhi.sky, DiZhi.getFromValue("亥"));
      ThreeChuan? chuChuanDiZhi =
          DaLiuRenKePan.checkByZeiKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(chuChuanDiZhi, isNotNull);
      expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("亥"));
    });

    // test('Counter increments smoke test', () {
    //   expect("ok", "ok", reason: "ok == ok");
    //   expect("ko", "ok", reason: "ko != ok");
    // });
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
