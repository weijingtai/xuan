import 'package:common/adapters/lunar_adapter.dart';
import 'package:common/enums.dart';
import 'package:qimendunjia/utils/datetime_jie_qi.dart';
import 'package:tuple/tuple.dart';

class ArrangePlateUtils {
  static final Map<JiaZi, TianGan> jiaZiXunShouMapper = {
    JiaZi.JIA_ZI: TianGan.WU, // 甲子戊
    JiaZi.JIA_XU: TianGan.JI, // 甲戌己
    JiaZi.JIA_SHEN: TianGan.GENG, // 甲申庚
    JiaZi.JIA_WU: TianGan.XIN, // 甲午辛
    JiaZi.JIA_CHEN: TianGan.REN, // 甲辰壬
    JiaZi.JIA_YIN: TianGan.GUI // 甲寅癸
  };
  static TianGan getXunShouByJiaZi(JiaZi jiaZi) {
    TianGan? res = ArrangePlateUtils.jiaZiXunShouMapper[jiaZi];
    if (res != null) {
      return res;
    }
    throw UnsupportedError("根据符头获取旬首，仅支持 六甲，不支持${jiaZi.name}");
  }

  /// tuple.item1 年
  /// tuple.item2 月
  /// tuple.item3 日
  /// tuple.item4 时
  /// tuple.item5 季节
  static Tuple5<String, String, String, String, String> getGanZhiDateString(
      DateTime utcDateTime) {
    final lunarCalendar = LunarAdapter.fromDate(utcDateTime);
    String jieQi = utcDateTime.getSolarTerm().toString();
    return Tuple5(
        lunarCalendar.getYearInGanZhi(),
        lunarCalendar.getMonthInGanZhi(),
        lunarCalendar.getDayInGanZhi(),
        lunarCalendar.getTimeInGanZhi(),
        jieQi);
  }

  //
  // tuple.item1 上元
  // tuple.item2 中元
  // tuple.item3 下元
  // tuple.item4  阴阳遁
  static int getJuNumber(Tuple4<int, int, int, bool> juTuple, int yunaType) {
    int juNumber = -1;
    if (yunaType == 0) {
      juNumber = juTuple.item1;
    } else if (yunaType == 1) {
      juNumber = juTuple.item2;
    } else if (yunaType == 2) {
      juNumber = juTuple.item3;
    }
    return juNumber;
  }

  // 阳逆阴顺，宫位顺序
  static List<int> yangShunYinNiSeq(int firstIndex, bool isYang) {
    List<int> juList = [];
    if (isYang) {
      juList = List.generate(9, (index) => index + 1).toList();
    } else {
      juList = List.generate(9, (index) => index + 1).reversed.toList();
    }
    // 让 juNumber成为第一个元素
    int currentIndex = juList.indexOf(firstIndex);

    List<int> juList1 = juList.sublist(currentIndex);
    List<int> juList2 = juList.sublist(0, currentIndex);
    juList = juList1 + juList2;

    return juList;
  }

  // 转盘奇门
  static List<int> turingListSeq(
      List<int> originalList, int shouldBeFirstIndex) {
    List<int> seq = originalList.toList(growable: true);
    if (originalList.first != shouldBeFirstIndex) {
      int index = originalList.indexOf(shouldBeFirstIndex);
      List<int> seq1 = originalList.sublist(index);
      List<int> seq2 = originalList.sublist(0, index);
      seq = seq1 + seq2;
    }
    return seq;
  }

  // 转盘奇门
  static List<String> turingStringListSeq(
      List<String> originalList, String shouldBeFirstIndex) {
    List<String> seq = originalList.toList(growable: true);
    if (originalList.first != shouldBeFirstIndex) {
      int index = originalList.indexOf(shouldBeFirstIndex);
      List<String> seq1 = originalList.sublist(index);
      List<String> seq2 = originalList.sublist(0, index);
      seq = seq1 + seq2;
    }
    return seq;
  }
}
