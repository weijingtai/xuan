import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/each_class.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/zei_key_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("create daliuren with zeike(贼克)", () {
    List<DiZhi> diZhiList = DiZhi.listAll;
    DiZhi timeZhi = DiZhi.SHEN;
    DiZhi monthGeneral = DiZhi.WEI;
    List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, diZhiList);
    List<DiZhi> monthGeneralSeq =
        DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    // List<String> guiRen.nameList = ["贵人","腾蛇","朱雀","六合","勾陈","青龙","天空","白虎","太常","玄武","太阴","天后"];
    List<GuiRen> guiRenNameList = GuiRen.clockwiseList;
    List<GuiRen> revGodsNameList = GuiRen.antiClockwiseList;

    JiaZi dayJiaZi = JiaZi.JIA_ZI;
    Map<DiZhi, DiZhi> currentTianDiMapper =
        Map<DiZhi, DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    Map<DiZhi, GuiRen> currentDiGodsMapper =
        Map<DiZhi, GuiRen>.fromIterables(diSeq, guiRenNameList);
    Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
    for (var di in diSeq) {
      currentPanWithGods[di] = DaLiuRenGong(
          guiRen: currentDiGodsMapper[di]!,
          skyPanDiZhi: currentTianDiMapper[di]!,
          groundPanDiZhi: di);
    }

    ["午", "申", "癸", "克"];
    String sky = "午";
    String ground = "申";
    String dayGan = "癸";
    String zeike = "克";

    test("课：$sky$ground，日干：$dayGan。贼克：“$zeike”，日干克上神，上神日干阴阳不同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("癸")!,
          1,
          DiZhi.getFromValue(sky)!,
          DiZhi.getFromValue(ground)!,
          GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.fromString(zeike));
      expect(eachClass.isSkyKeDayGan, false);
      expect(eachClass.isSkySameYinYangWithDayGan, false);
    });
    test("课：午申，日干：壬。贼克：“克”，日干克上神，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("壬")!, 1, DiZhi.WU, DiZhi.SHEN, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.KE);
      expect(eachClass.isSkyKeDayGan, false);
      expect(eachClass.isSkySameYinYangWithDayGan, true);
    });
    test("课：午申，日干：辛。贼克：“克”，上神克日干，上神日干阴阳不同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("辛")!, 1, DiZhi.WU, DiZhi.SHEN, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.KE);
      expect(eachClass.isSkyKeDayGan, true);
      expect(eachClass.isSkySameYinYangWithDayGan, false);
    });
    test("课：午申，日干：甲。贼克：“克”，上神无关日干，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("甲")!, 1, DiZhi.WU, DiZhi.SHEN, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.KE);
      expect(eachClass.isSkyKeDayGan, null);
      expect(eachClass.isSkySameYinYangWithDayGan, true);
    });
    test("课：午申，日干：乙。贼克：“克”，上神无关日干，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("乙")!, 1, DiZhi.WU, DiZhi.SHEN, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.KE);
      expect(eachClass.isSkyKeDayGan, null);
      expect(eachClass.isSkySameYinYangWithDayGan, false);
    });

    test("课：午亥，日干：甲。贼克：“贼”，上神无关日干，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("甲")!, 1, DiZhi.WU, DiZhi.HAI, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.ZEI);
      expect(eachClass.isSkyKeDayGan, null);
      expect(eachClass.isSkySameYinYangWithDayGan, true);
    });
    test("课：午亥，日干：乙。贼克：“贼”，上神无关日干，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("乙")!, 1, DiZhi.WU, DiZhi.HAI, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, EachClassZeiKeType.ZEI);
      expect(eachClass.isSkyKeDayGan, null);
      expect(eachClass.isSkySameYinYangWithDayGan, false);
    });

    test("课：午未，日干：乙。贼克：“无”，上神无关日干，上神日干阴阳同", () {
      EachClass eachClass = FourClass.createEachClass(
          TianGan.getFromValue("乙")!, 1, DiZhi.WU, DiZhi.WEI, GuiRen.GUI_REN);
      expect(eachClass.zeiKeType, null);
      expect(eachClass.isSkyKeDayGan, null);
      expect(eachClass.isSkySameYinYangWithDayGan, false);
    });
  });
}
