import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'da_liu_ren_test.dart';

void main() {
  group("create daliuren with 伏吟", () {
    DiZhi timeZhi = DiZhi.SHEN;

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

    test("伏吟 1 克", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "丑癸";
      String second = "丑丑";
      String third = "丑丑";
      String fourth = "丑丑";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFuYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("丑"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("戌"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("未"));
    });

    test("伏吟 2 贼", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      // List<DiZhi> tianPanList_dev="戌亥子丑寅卯辰巳午未申酉".split("").map((e)=>DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "辰乙";
      String second = "辰辰";
      String third = "未未";
      String fourth = "未未";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFuYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("辰"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("未"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("丑"));
    });

    test("伏吟 3 无克 阳", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      // List<DiZhi> tianPanList_dev="戌亥子丑寅卯辰巳午未申酉".split("").map((e)=>DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "寅甲";
      String second = "寅寅";
      String third = "辰辰";
      String fourth = "辰辰";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFuYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("寅"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("巳"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("申"));
    });
    test("伏吟 4 无克 阴", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      // List<DiZhi> tianPanList_dev="戌亥子丑寅卯辰巳午未申酉".split("").map((e)=>DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "未丁";
      String second = "未未";
      String third = "亥亥";
      String fourth = "亥亥";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFuYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("亥"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("未"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("丑"));
    });
    test("伏吟 5 无克 阳", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      // List<DiZhi> tianPanList_dev="戌亥子丑寅卯辰巳午未申酉".split("").map((e)=>DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "亥壬";
      String second = "亥亥";
      String third = "辰辰";
      String fourth = "辰辰";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFuYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("亥"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("辰"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("戌"));
    });
  });
}
