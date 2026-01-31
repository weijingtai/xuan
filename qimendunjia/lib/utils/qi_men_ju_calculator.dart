import 'package:common/enums.dart';
import 'package:intl/intl.dart';
import 'package:common/adapters/lunar_adapter.dart';
import 'package:qimendunjia/enums/enum_three_yuan.dart';
import 'package:qimendunjia/enums/enum_zhi_run_type.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/utils/zheng_shou_dong_zhi_list.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_arrange_plate_type.dart';

class QiMenJuCalculator {}

abstract class ShiJiaQiMenJuCalculator {
  // 时家奇门，局计算
  final ArrangeType arrangeType;
  final DateTime dateTime;
  // final JiaZi dayJiaZi;
  // final TwentyFourJieQi jieQi;

  static final YANG_DUN_JIE_QI_JU_NUMER = {
    TwentyFourJieQi.DONG_ZHI: const Tuple3(1, 7, 4),
    TwentyFourJieQi.XIAO_HAN: const Tuple3(2, 8, 5),
    TwentyFourJieQi.DA_HAN: const Tuple3(3, 9, 6),
    TwentyFourJieQi.LI_CHUN: const Tuple3(8, 5, 2),
    TwentyFourJieQi.YU_SHUI: const Tuple3(9, 6, 3),
    TwentyFourJieQi.JING_ZHE: const Tuple3(1, 7, 4),
    TwentyFourJieQi.CHUN_FEN: const Tuple3(3, 9, 6),
    TwentyFourJieQi.QING_MING: const Tuple3(4, 1, 7),
    TwentyFourJieQi.GU_YU: const Tuple3(5, 2, 8),
    TwentyFourJieQi.LI_XIA: const Tuple3(4, 1, 7),
    TwentyFourJieQi.XIAO_MAN: const Tuple3(5, 2, 8),
    TwentyFourJieQi.MANG_ZHONG: const Tuple3(6, 3, 9),
  };
  static List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> get yangDunList {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> result = [];
    for (var entries in YANG_DUN_JIE_QI_JU_NUMER.entries) {
      result.add(Tuple3(entries.value.item1, EnumThreeYuan.START, entries.key));
      result
          .add(Tuple3(entries.value.item2, EnumThreeYuan.MIDDLE, entries.key));
      result.add(Tuple3(entries.value.item3, EnumThreeYuan.END, entries.key));
    }
    return result;
  }

  static final YIN_DUN_JIE_QI_JU_NUMER = {
    TwentyFourJieQi.XIA_ZHI: const Tuple3(9, 3, 6),
    TwentyFourJieQi.XIAO_SHU: const Tuple3(8, 2, 5),
    TwentyFourJieQi.DA_SHU: const Tuple3(7, 1, 4),
    TwentyFourJieQi.LI_QIU: const Tuple3(2, 5, 8),
    TwentyFourJieQi.CHU_SHU: const Tuple3(1, 4, 7),
    TwentyFourJieQi.BAI_LU: const Tuple3(9, 3, 6),
    TwentyFourJieQi.QIU_FEN: const Tuple3(7, 1, 4),
    TwentyFourJieQi.HAN_LU: const Tuple3(6, 9, 3),
    TwentyFourJieQi.SHUANG_JIANG: const Tuple3(5, 8, 2),
    TwentyFourJieQi.LI_DONG: const Tuple3(6, 9, 3),
    TwentyFourJieQi.XIAO_XUE: const Tuple3(5, 8, 2),
    TwentyFourJieQi.DA_XUE: const Tuple3(4, 7, 1),
  };

  static List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> get yinDunList {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> result = [];
    for (var entries in YIN_DUN_JIE_QI_JU_NUMER.entries) {
      result.add(Tuple3(entries.value.item1, EnumThreeYuan.START, entries.key));
      result
          .add(Tuple3(entries.value.item2, EnumThreeYuan.MIDDLE, entries.key));
      result.add(Tuple3(entries.value.item3, EnumThreeYuan.END, entries.key));
    }
    return result;
  }

  const ShiJiaQiMenJuCalculator({
    required this.dateTime,
    required this.arrangeType,
    // required this.dayJiaZi,
    // required this.jieQi,
  });

  static EnumThreeYuan getThreeYuanByFuHead(JiaZi fouTou) {
    if (DiZhi.fourMuYu.contains(fouTou.diZhi)) {
      return EnumThreeYuan.START;
    } else if (DiZhi.fourYiMa.contains(fouTou.diZhi)) {
      return EnumThreeYuan.MIDDLE;
    } else {
      return EnumThreeYuan.END;
    }
  }

  ShiJiaJu calculate();
}

// 拆补
class ChaiBuCalculator extends ShiJiaQiMenJuCalculator {
  ChaiBuCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.CHAI_BU,
        );
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  /// 拆补法 凡 甲己为符头
  static JiaZi getFuTouByDayJiaZi(JiaZi dayGanZhi) {
    // 2. 获取日的干支
    // 3. 根据日的干支获取符头，
    int model = dayGanZhi.number % 5;
    JiaZi fuTou;
    if (model % 5 == 0) {
      // 当前为日干支为 每一符头的最后一个
      fuTou = JiaZi.getByNumber(dayGanZhi.number - 4);
    } else if (model == 1) {
      // 当前日干支为 为 符头自己
      fuTou = dayGanZhi;
    } else {
      // 当前日干支为 符头的前一个
      fuTou = JiaZi.getByNumber(dayGanZhi.number - model + 1);
    }
    return fuTou;
  }

  ShiJiaJu _doCalculate() {
    LunarAdapter lunar = LunarAdapter.fromDate(dateTime);
    JiaZi dayGanZhi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;

    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    // 1. 根据节气查看当前节气是阴遁还是阳遁
    YinYang yinYangDun = jieQi.yinYangDun;
    if (dateTime.hour == 23) {
      dayGanZhi = JiaZi.getByNumber((dayGanZhi.number + 1) % 60);
    }
    // 2. 获取符头
    JiaZi fuTou = getFuTouByDayJiaZi(dayGanZhi);
    // 根据符头地支查看三元
    EnumThreeYuan threeYuan =
        ShiJiaQiMenJuCalculator.getThreeYuanByFuHead(fuTou);
    // print(threeYuan.name);
    Tuple3<int, int, int> juTuple;
    if (yinYangDun.isYang) {
      juTuple = ShiJiaQiMenJuCalculator.YANG_DUN_JIE_QI_JU_NUMER[jieQi]!;
    } else {
      juTuple = ShiJiaQiMenJuCalculator.YIN_DUN_JIE_QI_JU_NUMER[jieQi]!;
    }
    int juNumber;
    switch (threeYuan) {
      case EnumThreeYuan.START:
        juNumber = juTuple.item1;
        break;
      case EnumThreeYuan.MIDDLE:
        juNumber = juTuple.item2;
        break;
      // case EnumThreeYuan.END:
      default:
        juNumber = juTuple.item3;
    }

    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: juNumber,
        fuTouJiaZi: fuTou,
        yinYangDun: yinYangDun,
        jieQiAt: jieQi,
        jieQiStartAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms()),
        jieQiEnd: TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()),
        jieQiEndAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getNextJieQi().getSolar().toYmdHms()),
        atThreeYuan: threeYuan,
        fourZhuEightChar: [
          lunar.getYearInGanZhi(),
          lunar.getMonthInGanZhi(),
          dayGanZhi.name,
          lunar.getTimeInGanZhi()
        ].join(" ").toString());
    // return ShiJiaJu();
  }
}

// 置润
class ZhiRunCalculator extends ShiJiaQiMenJuCalculator {
  ZhiRunCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.ZHI_RUN,
        );
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  /// 置润法 只有甲子、己卯、甲午、己酉 为上元符头
  JiaZi getFuTouByDayJiaZi(JiaZi dayGanZhi) {
    // 2. 获取日的干支
    // 3. 根据日的干支获取符头，
    JiaZi fuTou;
    if (dayGanZhi.number <= 15) {
      fuTou = JiaZi.JIA_ZI; // 甲子
    } else if (dayGanZhi.number > 15 && dayGanZhi.number <= 30) {
      fuTou = JiaZi.JI_MAO; // 己卯
    } else if (dayGanZhi.number > 30 && dayGanZhi.number <= 45) {
      fuTou = JiaZi.JIA_WU; // 甲午
    } else {
      fuTou = JiaZi.JI_YOU; // 己酉
    }
    return fuTou;
  }

  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  ShiJiaJu _doCalculate() {
    LunarAdapter lunar = LunarAdapter.fromDate(dateTime);
    String timeGanZhi = lunar.getTimeInGanZhi();
    if (dateTime.hour == 23) {
      // 时辰如果是23点之后 需要将日干支调整为下一天
      // 影响年月日的干支
      lunar = LunarAdapter.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayJiaZi.name,
      timeGanZhi
    ].join(" ").toString();

    // 起局时间所在的这一年节气
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    DateTime jieQiStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 1. 根据节气查看当前节气是阴遁还是阳遁
    JiaZi fuTou = getFuTouByDayJiaZi(dayJiaZi);

    // 符头那天
    LunarAdapter fuTouLunar= lunar; // 当天是符头
    DateTime fuTouDateTime = dateTime;
    if (fuTou != dayJiaZi) {
      // 当天不是符头，找到符头那天

      // 相差的天数，用于构建符头那天
      int days = dayJiaZi.number - fuTou.number;
      print("符头干支: ${fuTou.name}");
      fuTouDateTime = dateTime.subtract(Duration(days: days - 1));
      print(dayJiaZi.name);
      print(dateTime);
      print("符头时间：$fuTouDateTime,当前节气为${jieQi.name}，开始于$jieQiStartAt");
      fuTouLunar = LunarAdapter.fromDate(fuTouDateTime);
      print(fuTouLunar.getDayInGanZhi());
    }
    Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> tuple = doCa(dateTime);

    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: tuple.item1,
        fuTouJiaZi: fuTou,
        yinYangDun: tuple.item3.yinYangDun,
        jieQiAt: jieQi,
        jieQiStartAt: jieQiStartAt,
        jieQiEnd: TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()),
        jieQiEndAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getNextJieQi().getSolar().toYmdHms()),
        atThreeYuan: tuple.item2,
        fourZhuEightChar: eightChar,
        panJuJieQi: tuple.item3,
        juDayNumber: tuple.item4);
  }

  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> doCa(DateTime dateTime) {
    // 上一个正授冬至时间

    final lastZhengShouDongZhiDateTime =
        ZhengShouDongZhiList.getPreviousZhengShouDongZhi(dateTime);

    int diffInDays = dateTime.difference(lastZhengShouDongZhiDateTime).inDays;
    var findLunarByDateTime = dateTime;
    if (dateTime.hour == 23) {
      // 如果时间为子时 则天为下一天
      diffInDays += 1;
      findLunarByDateTime.add(const Duration(hours: 1));
    }

    var diffYears = diffInDays ~/ 365;
    if (diffYears == 0) {
      return insideOneYear(lastZhengShouDongZhiDateTime, findLunarByDateTime);
    } else {
      return otherYears(lastZhengShouDongZhiDateTime, dateTime);
    }
    // 目标天 所在年的 冬至、夏至 节气时间
  }

  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> insideOneYear(
      DateTime zhengShouDongZhi, DateTime targetDateTime) {
    DateTime targetTime = targetDateTime;
    if (targetTime.hour == 23) {
      targetTime = targetTime.add(const Duration(hours: 1)); // 给为第二天
    }
    int finalDiffDays = targetTime.difference(zhengShouDongZhi).inDays;
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> dunList = [];
    if (finalDiffDays < 180) {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
    } else if (finalDiffDays < 360) {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
    } else {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
    }

    dunList = dunList.skip(finalDiffDays ~/ 5).toList();

    return Tuple4(dunList.first.item1, dunList.first.item2, dunList.first.item3,
        finalDiffDays % 5 + 1);
  }

  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> otherYears(
      DateTime zhengShouDongZhi, DateTime panDateTime) {
    // Tuple4<int,EnumThreeYuan,TwentyFourJieQi,int> otherYears(int diffInDays,DateTime findLunarByDateTime){
    LunarAdapter startLunar= LunarAdapter.fromDate(zhengShouDongZhi);
    DateTime targetDateTime = panDateTime;
    if (targetDateTime.hour == 23) {
      targetDateTime = targetDateTime.add(const Duration(hours: 1)); // 给为第二天
    }
    LunarAdapter targetLunar= LunarAdapter.fromDate(targetDateTime);

    int yearStart = zhengShouDongZhi.year + 1; // 正授日冬至实为第二年冬至 所以“+1”
    int targetEnd = targetDateTime.year;
    // 需要判断是否对targetEnd 进行+1， 因为 targetDateTime可能实际属于下一年的冬至

    // print("正授冬至日为 ${zhengShouDongZhi}");
    // 获取两个时间点中每一年的冬夏而至节气的日奇
    // WARNING 当前实现是基于两个时间但不在同一年内，进行的
    List<DateTime> dateTimes = [];
    for (var i = yearStart; i <= targetEnd; i++) {
      // print("第${i}年");
      LunarAdapter tmpLunar= LunarAdapter.fromDate(DateTime(i, 1, 1));
      DateTime thisYearDongZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["冬至"]!.toYmdHms());
      DateTime thisYearXiaZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["夏至"]!.toYmdHms());
      // TODO 没有根据子时修改为第二天

      // 将时间调整为 前一天子时开始时间
      thisYearDongZhi = DateTime(thisYearDongZhi.year, thisYearDongZhi.month,
          thisYearDongZhi.day - 1, 22, 59, 59);
      thisYearXiaZhi = DateTime(thisYearXiaZhi.year, thisYearXiaZhi.month,
          thisYearXiaZhi.day - 1, 22, 59, 59);

      dateTimes.add(thisYearDongZhi);
      dateTimes.add(thisYearXiaZhi);

      // print("第$i年 冬至 $thisYearDongZhi");
      // print("第$i年 夏至 $thisYearXiaZhi");
    }
    // 检查targetDateTime 的前一个 二至节是冬至还是夏至
    String targetDateJieQi = targetLunar.getJieQi();
    if (targetDateJieQi.isEmpty) {
      targetDateJieQi = targetLunar.getPrevJieQi().getName();
    }
    TwentyFourJieQi previousTwoZhiJie =
        TwentyFourJieQi.fromName(targetDateJieQi).yinYangDun.isYang
            ? TwentyFourJieQi.DONG_ZHI
            : TwentyFourJieQi.XIA_ZHI;
    DateTime previousJieQiDateTime = dateFormatter
        .parse(targetLunar.getJieQiTable()[previousTwoZhiJie.name]!.toYmdHms());

    // TODO 没有根据子时修改为第二天
    // 将时间调整为 前一天子时开始时间
    previousJieQiDateTime = DateTime(previousJieQiDateTime.year,
        previousJieQiDateTime.month, previousJieQiDateTime.day, 0, 1);
    // print("目标日期的前一个二至节为 ${previousTwoZhiJie
    //     .name} $previousJieQiDateTime");
    // print("目标日期为$targetDateTime");
    if (targetDateTime.month == 12 && targetDateTime.day >= 18) {
      // 如果目标日期为12月，则判断日期是否在在下一年冬至开始后，
      DateTime tmp2 = DateTime(
          targetDateTime.year, targetDateTime.month + 3, targetDateTime.day);
      LunarAdapter tmp2Lunar= LunarAdapter.fromDate(tmp2);
      DateTime theDongZhiDate =
          dateFormatter.parse(tmp2Lunar.getJieQiTable()["冬至"]!.toYmdHms());
      if (theDongZhiDate.isBefore(targetDateTime)) {
        theDongZhiDate = DateTime(theDongZhiDate.year, theDongZhiDate.month,
            theDongZhiDate.day - 1, 22, 59, 59);
        dateTimes.add(theDongZhiDate);
      }
    }

    // print(dateFormatter.parse(tmp2Lunar.getJieQiTable()["冬至"]!.toYmdHms()));

    // dateTimes.add(previousJieQiDateTime);

    // print(dateTimes.map((dt) => dt.toString()));

    List<int> daysBetweenEachTwoZhi = [];
    for (int i = 1; i < dateTimes.length; i++) {
      daysBetweenEachTwoZhi
          .add(dateTimes[i].difference(dateTimes[i - 1]).inDays + 1);
    }
    // print(daysBetweenEachTwoZhi.map((d) => d));
    // print("-------------------");
    YinYang finishedDun = YinYang.YIN; // true为阳遁完成，false为阴遁完成，哪个遁完成则需要使用另一个完成
    int previousLoopBalance = 0; // 负数标识需要loop补全（从新的中减去），正数需要加上
    EnumZhiRunType nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> dunList = [];
    for (int i = 0; i < daysBetweenEachTwoZhi.length; i++) {
      if (i == 0 || i % 2 == 0) {
        // 使用阳遁
        int days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
          days = daysBetweenEachTwoZhi[i] - previousLoopBalance;
        } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
          days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        }
        // print("阳遁 ---- $days 天 --- $i");
        dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
        if (days == 180) {
          // print("正授结束，无超神，接气之类。阳遁正好180天");
          nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
        } else if (days > 180) {
          if (days - 180 >= 9) {
            previousLoopBalance = 15 - (days - 180); //
            // print(
            //     "阳遁180天已经用完，然而并没有夏至没到，其时间超过9天（为${days-180}），需要进行置润操作，重复芒种节三元15天，阴遁开始需要向后延 $previousLoopBalance 天");
            nextDunShuldBe = EnumZhiRunType.JIE_QI;

            dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList
                .sublist(ShiJiaQiMenJuCalculator.yangDunList.length - 3));
          } else {
            previousLoopBalance = days - 180; // 夏至开始之前 需要去除被冬至“借走”的这几天
            // print(
            //     "阳遁180天已经用完，然而并没有夏至没到，夏至需要超神补全 $previousLoopBalance 天（提前n天开始阴遁）");
            nextDunShuldBe = EnumZhiRunType.CHAO_SHEN;
          }
        } else {
          previousLoopBalance = 180 - days;
          // print(
          //     "阳遁180天未用完，但夏至节已经到来，阴遁开始需要向后延 $previousLoopBalance 天");
          nextDunShuldBe = EnumZhiRunType.JIE_QI;
        }
        finishedDun = YinYang.YANG;
      } else {
        // 使用阴遁
        int days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
          days = daysBetweenEachTwoZhi[i] - previousLoopBalance;
        } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
          days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        }
        // print("阴遁 ---- $days 天 --- $i");
        dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
        if (days == 180) {
          // print("正授结束，无超神，接气之类。阴遁正好180天");
          nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
        } else if (days > 180) {
          if (days - 180 >= 9) {
            previousLoopBalance = 15 - (days - 180); //
            // addAll last three of yinDunList
            dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList
                .sublist(ShiJiaQiMenJuCalculator.yinDunList.length - 3));
            // print(
            //     "阴遁180天已经用完，然而并没有冬至，其时间超过9天（为${days-180}），需要进行置润操作，重复大雪节三元15天，阳遁开始需要向后延 $previousLoopBalance 天");
            nextDunShuldBe = EnumZhiRunType.JIE_QI;
          } else {
            previousLoopBalance = days - 180; // 夏至开始之前 需要去除被冬至“借走”的这几天
            // print(
            //     "阴遁180天已经用完，然而并没有冬至，冬至需要超神补全 $previousLoopBalance 天（提前n天开始阳遁）");
            nextDunShuldBe = EnumZhiRunType.CHAO_SHEN;
          }
        } else {
          previousLoopBalance = 180 - days;
          // print(
          //     "阴遁180天未用完，但冬至节已经到来，阳遁开始需要向后延 $previousLoopBalance 天");
          nextDunShuldBe = EnumZhiRunType.JIE_QI;
        }
        finishedDun = YinYang.YIN;
      }
      // daysBetweenEachTwoZhi[i];
    }
    // 判断 target
    int totalDiffInDays = targetDateTime.difference(dateTimes.first).inDays;
    // print("$totalDiffInDays ${dunList.length * 5}");
    if (dunList.length * 5 <= totalDiffInDays) {
      if (finishedDun.isYang) {
        // 阳遁list已经结束了
        // print("天数不足，需要使用补全阴遁 $totalDiffInDays ${dunList.length * 5}");
        dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
      } else {
        // print("天数不足，需要使用补全阳遁  $totalDiffInDays ${dunList.length * 5}");
        dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
      }
    }

    var resultList = dunList.skip(totalDiffInDays ~/ 5).toList();
    // print(resultList.length);

    return Tuple4(resultList.first.item1, resultList.first.item2,
        resultList.first.item3, totalDiffInDays % 5 + 1);
  }

  @Deprecated("")
  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> otherYears2(
      DateTime zhengShouDongZhi, DateTime targetDateTime) {
    // Tuple4<int,EnumThreeYuan,TwentyFourJieQi,int> otherYears(int diffInDays,DateTime findLunarByDateTime){
    LunarAdapter startLunar= LunarAdapter.fromDate(zhengShouDongZhi);
    LunarAdapter targetLunar= LunarAdapter.fromDate(targetDateTime);

    int yearStart = zhengShouDongZhi.year + 1; // 正授日冬至实为第二年冬至 所以“+1”
    int targetEnd = targetDateTime.year;
    // 需要判断是否对targetEnd 进行+1， 因为 targetDateTime可能实际属于下一年的冬至

    print("正授冬至日为 $zhengShouDongZhi");
    // 获取两个时间点中每一年的冬夏而至节气的日奇
    // WARNING 当前实现是基于两个时间但不在同一年内，进行的
    List<DateTime> dateTimes = [];
    for (var i = yearStart; i <= targetEnd; i++) {
      print("第$i年");
      LunarAdapter tmpLunar= LunarAdapter.fromDate(DateTime(i, 1, 1));
      DateTime thisYearDongZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["冬至"]!.toYmdHms());
      DateTime thisYearXiaZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["夏至"]!.toYmdHms());
      // TODO 没有根据子时修改为第二天

      // 将时间调整为 前一天子时开始时间
      thisYearDongZhi = DateTime(thisYearDongZhi.year, thisYearDongZhi.month,
          thisYearDongZhi.day - 1, 22, 59, 59);
      thisYearXiaZhi = DateTime(thisYearXiaZhi.year, thisYearXiaZhi.month,
          thisYearXiaZhi.day - 1, 22, 59, 59);

      dateTimes.add(thisYearDongZhi);
      dateTimes.add(thisYearXiaZhi);

      print("第$i年 冬至 $thisYearDongZhi");
      print("第$i年 夏至 $thisYearXiaZhi");
    }

    // 检查targetDateTime 的前一个 二至节是冬至还是夏至
    String targetDateJieQi = targetLunar.getJieQi();
    if (targetDateJieQi.isEmpty) {
      targetDateJieQi = targetLunar.getPrevJieQi().getName();
    }
    TwentyFourJieQi previousTwoZhiJie =
        TwentyFourJieQi.fromName(targetDateJieQi).yinYangDun.isYang
            ? TwentyFourJieQi.DONG_ZHI
            : TwentyFourJieQi.XIA_ZHI;
    DateTime previousJieQiDateTime = dateFormatter
        .parse(targetLunar.getJieQiTable()[previousTwoZhiJie.name]!.toYmdHms());

    // TODO 没有根据子时修改为第二天
    // 将时间调整为 前一天子时开始时间
    previousJieQiDateTime = DateTime(previousJieQiDateTime.year,
        previousJieQiDateTime.month, previousJieQiDateTime.day, 0, 1);
    print("目标日期的前一个二至节为 ${previousTwoZhiJie.name} $previousJieQiDateTime");
    print("目标日期为$targetDateTime");
    if (targetDateTime.month == 12 && targetDateTime.day >= 18) {
      // 如果目标日期为12月，则判断日期是否在在下一年冬至开始后，
      DateTime tmp2 = DateTime(
          targetDateTime.year, targetDateTime.month + 3, targetDateTime.day);
      LunarAdapter tmp2Lunar= LunarAdapter.fromDate(tmp2);
      DateTime theDongZhiDate =
          dateFormatter.parse(tmp2Lunar.getJieQiTable()["冬至"]!.toYmdHms());
      if (theDongZhiDate.isBefore(targetDateTime)) {
        theDongZhiDate = DateTime(theDongZhiDate.year, theDongZhiDate.month,
            theDongZhiDate.day - 1, 22, 59, 59);
        dateTimes.add(theDongZhiDate);
      }
    }

    // print(dateFormatter.parse(tmp2Lunar.getJieQiTable()["冬至"]!.toYmdHms()));

    // dateTimes.add(previousJieQiDateTime);

    print(dateTimes.map((dt) => dt.toString()));

    List<int> daysBetweenEachTwoZhi = [];
    for (int i = 1; i < dateTimes.length; i++) {
      daysBetweenEachTwoZhi
          .add(dateTimes[i].difference(dateTimes[i - 1]).inDays + 1);
    }
    print(daysBetweenEachTwoZhi.map((d) => d));
    print("-------------------");
    YinYang finishedDun = YinYang.YIN; // true为阳遁完成，false为阴遁完成，哪个遁完成则需要使用另一个完成
    int previousLoopBalance = 0; // 负数标识需要loop补全（从新的中减去），正数需要加上
    EnumZhiRunType nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
    for (int i = 0; i < daysBetweenEachTwoZhi.length; i++) {
      if (i == 0 || i % 2 == 0) {
        // 使用阳遁
        int days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
          days = daysBetweenEachTwoZhi[i] - previousLoopBalance;
        } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
          days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        }
        print("阳遁 ---- $days 天 --- $i");
        if (days == 180) {
          print("正授结束，无超神，接气之类。阳遁正好180天");
          nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
        } else if (days > 180) {
          if (days - 180 >= 9) {
            previousLoopBalance = 15 - (days - 180); //
            print(
                "阳遁180天已经用完，然而并没有夏至没到，其时间超过9天（为${days - 180}），需要进行置润操作，重复芒种节三元15天，阴遁开始需要向后延 $previousLoopBalance 天");
            nextDunShuldBe = EnumZhiRunType.JIE_QI;
          } else {
            previousLoopBalance = days - 180; // 夏至开始之前 需要去除被冬至“借走”的这几天
            print(
                "阳遁180天已经用完，然而并没有夏至没到，夏至需要超神补全 $previousLoopBalance 天（提前n天开始阴遁）");
            nextDunShuldBe = EnumZhiRunType.CHAO_SHEN;
          }
        } else {
          previousLoopBalance = 180 - days;
          print("阳遁180天未用完，但夏至节已经到来，阴遁开始需要向后延 $previousLoopBalance 天");
          nextDunShuldBe = EnumZhiRunType.JIE_QI;
        }
        finishedDun = YinYang.YANG;
      } else {
        // 使用阴遁
        int days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
          days = daysBetweenEachTwoZhi[i] - previousLoopBalance;
        } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
          days = daysBetweenEachTwoZhi[i] + previousLoopBalance;
        }
        print("阴遁 ---- $days 天 --- $i");
        if (days == 180) {
          print("正授结束，无超神，接气之类。阴遁正好180天");
          nextDunShuldBe = EnumZhiRunType.ZHENG_SHOU;
        } else if (days > 180) {
          if (days - 180 >= 9) {
            previousLoopBalance = 15 - (days - 180); //
            print(
                "阴遁180天已经用完，然而并没有冬至，其时间超过9天（为${days - 180}），需要进行置润操作，重复大雪节三元15天，阳遁开始需要向后延 $previousLoopBalance 天");
            nextDunShuldBe = EnumZhiRunType.JIE_QI;
          } else {
            previousLoopBalance = days - 180; // 夏至开始之前 需要去除被冬至“借走”的这几天
            print(
                "阴遁180天已经用完，然而并没有冬至，冬至需要超神补全 $previousLoopBalance 天（提前n天开始阳遁）");
            nextDunShuldBe = EnumZhiRunType.CHAO_SHEN;
          }
        } else {
          previousLoopBalance = 180 - days;
          print("阴遁180天未用完，但冬至节已经到来，阳遁开始需要向后延 $previousLoopBalance 天");
          nextDunShuldBe = EnumZhiRunType.JIE_QI;
        }
        finishedDun = YinYang.YIN;
      }
      // daysBetweenEachTwoZhi[i];
    }
    // 判断 target

    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> dunList;
    if (finishedDun.isYang) {
      // 阳遁list已经结束了
      print("使用阴遁 $previousLoopBalance ${nextDunShuldBe.name}");
      dunList = ShiJiaQiMenJuCalculator.yinDunList;
      if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
        dunList = ShiJiaQiMenJuCalculator.yinDunList
            .skip((previousLoopBalance) ~/ 5)
            .toList();
        // dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3,
        //     (previousLoopBalance % 5) + 1);
      } else if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
        int completedYuan = previousLoopBalance ~/ 5;
        if (completedYuan == 0) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        } else if (completedYuan == 1) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        } else if (completedYuan == 2) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 4],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        }
        dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3,
        //     previousLoopBalance % 5 + 1);
      } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
        // throw UnimplementedError("使用阴遁 置润");
        int completedYuan = previousLoopBalance ~/ 5;
        if (completedYuan == 0) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        } else if (completedYuan == 1) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        } else if (completedYuan == 2) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 4],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yangDunList[ShiJiaQiMenJuCalculator.yangDunList.length - 2],
            ShiJiaQiMenJuCalculator.yangDunList.last
          ];
        }
        dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
      } else {
        // 默认为正授
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3, 1);
      }
    } else {
      print("使用阳遁 $previousLoopBalance ${nextDunShuldBe.name}");
      dunList = ShiJiaQiMenJuCalculator.yangDunList;
      if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
        dunList = ShiJiaQiMenJuCalculator.yangDunList
            .skip(previousLoopBalance ~/ 5)
            .toList();
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3,
        //     previousLoopBalance % 5 + 1);
      } else if (nextDunShuldBe == EnumZhiRunType.JIE_QI) {
        int completedYuan = previousLoopBalance ~/ 5;
        if (completedYuan == 0) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        } else if (completedYuan == 1) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        } else if (completedYuan == 2) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 4],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        }
        dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3,
        //     (15 - previousLoopBalance) % 5);
      } else if (nextDunShuldBe == EnumZhiRunType.CHAO_SHEN) {
        int completedYuan = previousLoopBalance ~/ 5;
        if (completedYuan == 0) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        } else if (completedYuan == 1) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        } else if (completedYuan == 2) {
          dunList = [
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 4],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 3],
            ShiJiaQiMenJuCalculator
                .yinDunList[ShiJiaQiMenJuCalculator.yinDunList.length - 2],
            ShiJiaQiMenJuCalculator.yinDunList.last
          ];
        }
        dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);

        print(
            "阴遁 置润 $previousLoopBalance $completedYuan ${previousLoopBalance % 5 + 1}");
        // throw UnimplementedError("使用阴遁 置润");
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3,
        //     (15 - previousLoopBalance) % 5);
      } else {
        // 默认为正授
        // return Tuple4(
        //     dunList.first.item1, dunList.first.item2, dunList.first.item3, 1);
      }
      // targetLunar.getJieQi() ?? targetLunar.getPrevJieQi();
    }
    int finalDiffInDays = targetDateTime.difference(dateTimes.last).inDays;
    print(
        "diff in days targetDateTime - lastTwoZhi $finalDiffInDays, $previousLoopBalance = ${previousLoopBalance - finalDiffInDays}");

    int finishedYuan = finalDiffInDays ~/ 5;
    dunList = dunList.skip(finishedYuan).toList();

    if (EnumZhiRunType.CHAO_SHEN == nextDunShuldBe) {
      finalDiffInDays += previousLoopBalance - 1;
    } else if (EnumZhiRunType.JIE_QI == nextDunShuldBe) {
      finalDiffInDays -= previousLoopBalance;
    } else if (EnumZhiRunType.CHAO_SHEN == nextDunShuldBe) {
      finalDiffInDays -= previousLoopBalance;
    }
    print("${nextDunShuldBe.name} ${finalDiffInDays % 5} ");

    return Tuple4(dunList.first.item1, dunList.first.item2, dunList.first.item3,
        finalDiffInDays % 5 + 1);
  }

  @Deprecated("")
  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> insideOneYear2(
      int diffInDays, DateTime findLunarByDateTime) {
    LunarAdapter dateTimeInLunar= LunarAdapter.fromDate(findLunarByDateTime);
    var dongZhi =
        dateFormatter.parse(dateTimeInLunar.getJieQiTable()["冬至"]!.toYmdHms());
    var dongZhiJieDateOnly = DateTime(dongZhi.year, dongZhi.month, dongZhi.day);
    var xiaZhi =
        dateFormatter.parse(dateTimeInLunar.getJieQiTable()["夏至"]!.toYmdHms());
    var xiaZhiJieDateOnly = DateTime(xiaZhi.year, xiaZhi.month, xiaZhi.day);
    print(
        "目标时间（$findLunarByDateTime） 当年 冬至节（$dongZhiJieDateOnly）, 夏至节（$xiaZhiJieDateOnly）");
    if (dateTime.isAtSameMomentAs(xiaZhiJieDateOnly) ||
        dateTime.isAfter(xiaZhiJieDateOnly)) {
      // 冬至节之后使用的阳遁
      int afterThatYearDongZhiDays =
          dateTime.difference(dongZhiJieDateOnly).inDays;
      if (dateTime.hour == 23) {
        afterThatYearDongZhiDays += 1;
      }

      print("夏至节之后使用的阳遁 - 是年夏至节之后第$afterThatYearDongZhiDays");

      var afterZhengShouInDays =
          xiaZhiJieDateOnly.difference(dongZhiJieDateOnly).inDays +
              1; // +1 为加上冬至节 这天

      print("当年夏至节距离正授冬至节 $afterZhengShouInDays天");
      if (afterZhengShouInDays == 180) {
        print("正授");
      } else {
        // int leftToXiaZhi = afterZhengShouInDays - 180 - 1;
        int leftToXiaZhi = afterZhengShouInDays - 180;
        if (leftToXiaZhi == 0) {
          // 使用阳遁第一局
          return Tuple4(
              ShiJiaQiMenJuCalculator.yangDunList.first.item1,
              ShiJiaQiMenJuCalculator.yangDunList.first.item2,
              ShiJiaQiMenJuCalculator.yangDunList.first.item3,
              1);
        } else if (leftToXiaZhi >= 9) {
          print("前一个节气进行了置润，所以阴遁向后推延了${15 - leftToXiaZhi}天");
          throw UnimplementedError("前一个节气进行了置润，所以阴遁向后推延了${15 - leftToXiaZhi}");
        } else {
          print("前一个节气不需要置润，将阴遁超神几日$leftToXiaZhi");
          // print(diffInDays);
          diffInDays -= leftToXiaZhi;
          // print(diffInDays);
        }
      }

      // 180 天之后，属于阴遁 使用夏至
      var days = diffInDays - 180;
      var completedFinishedYuan = days ~/ 5;
      var completedDay = days % 5;
      var yinDunList =
          ShiJiaQiMenJuCalculator.yinDunList.skip(completedFinishedYuan);

      print("ok");
      return Tuple4(yinDunList.first.item1, yinDunList.first.item2,
          yinDunList.first.item3, completedDay + 1);
    } else {
      // 冬至节之后使用的阳遁
      int afterThatYearDongZhiDays =
          dateTime.difference(dongZhiJieDateOnly).inDays;
      if (dateTime.hour == 23) {
        afterThatYearDongZhiDays += 1;
      }
      print("冬至节之后使用的阳遁 - 是年冬至节之后第$afterThatYearDongZhiDays");
      if (diffInDays < 180) {
        // 在一个阴阳遁之内
        var completedFinishedYuan = diffInDays ~/ 5;
        var completedDay = diffInDays % 5;
        print(
            "相差与正授冬至相差 $diffInDays天 完成的过完$completedFinishedYuan个‘元’ 零 $completedDay 天");
        print(ShiJiaQiMenJuCalculator.yangDunList.length);
        var yangDunList =
            ShiJiaQiMenJuCalculator.yangDunList.skip(completedFinishedYuan);

        // print("当前为：${yangDunList.first.item3.name} ${yangDunList.first.item2.name} ${yangDunList.first.item1}局 第${completedDay}天");
        return Tuple4(yangDunList.first.item1, yangDunList.first.item2,
            yangDunList.first.item3, completedDay + 1);
      } else {
        // 180 天之后，属于阴遁，需要使用夏至
        // 但需要检查是否超接置润
        var leftNotCountingDays = diffInDays - 180;
        if (leftNotCountingDays >= 9) {
          // 置润方法为，重复芒种节三元
          // 获取 最后3个item
          var lastThree = ShiJiaQiMenJuCalculator.yinDunList
              .skip(ShiJiaQiMenJuCalculator.yinDunList.length - 3);
          var completedFinishedYuan = leftNotCountingDays ~/ 5;
          var completedDay = leftNotCountingDays % 5;
          var dunList = lastThree.skip(completedFinishedYuan);
          return Tuple4(dunList.first.item1, dunList.first.item2,
              dunList.first.item3, completedDay + 1);
        } else {
          // 不需要置润，返回阳遁即刻
          // var days = diffInDays - 180;
          var completedFinishedYuan = leftNotCountingDays ~/ 5;
          var completedDay = leftNotCountingDays % 5;
          var yinDunList =
              ShiJiaQiMenJuCalculator.yinDunList.skip(completedFinishedYuan);

          return Tuple4(yinDunList.first.item1, yinDunList.first.item2,
              yinDunList.first.item3, completedDay + 1);
        }
      }
    }
  }

  @Deprecated("")
  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> doCa1(DateTime dateTime) {
    // 上一个正授冬至时间
    final lastZhengShouDongZhiDateTime = DateTime(2022, 12, 22, 0, 0);

    int diffInDays = dateTime.difference(lastZhengShouDongZhiDateTime).inDays;
    if (dateTime.hour == 23) {
      // 如果时间为子时 则天为下一天
      diffInDays += 1;
    }

    var diffYears = diffInDays ~/ 365;
    if (diffYears == 0) {
      // 为同一年
      if (diffInDays < 180) {
        // 在一个阴阳遁之内
        var completedFinishedYuan = diffInDays ~/ 5;
        var completedDay = diffInDays % 5;
        print(
            "相差与正授冬至相差 $diffInDays天 完成的过完$completedFinishedYuan个‘元’ 零 $completedDay 天");
        print(ShiJiaQiMenJuCalculator.yangDunList.length);
        var yangDunList =
            ShiJiaQiMenJuCalculator.yangDunList.skip(completedFinishedYuan);

        // print("当前为：${yangDunList.first.item3.name} ${yangDunList.first.item2.name} ${yangDunList.first.item1}局 第${completedDay}天");
        return Tuple4(yangDunList.first.item1, yangDunList.first.item2,
            yangDunList.first.item3, completedDay + 1);
      } else if (diffInDays < 360) {
        // 180 天之后，属于阴遁 使用夏至
        var days = diffInDays - 180;
        var completedFinishedYuan = days ~/ 5;
        var completedDay = days % 5;
        var yinDunList =
            ShiJiaQiMenJuCalculator.yinDunList.skip(completedFinishedYuan);

        return Tuple4(yinDunList.first.item1, yinDunList.first.item2,
            yinDunList.first.item3, completedDay + 1);
      } else {
        // 360, 361, 362, 363, 364, 365
        var days = diffInDays - 360;
        var completedFinishedYuan = days ~/ 5;
        var completedDay = days % 5;
        var yangDunList =
            ShiJiaQiMenJuCalculator.yangDunList.skip(completedFinishedYuan);

        print(
            "当前为：${yangDunList.first.item3.name} ${yangDunList.first.item2.name} ${yangDunList.first.item1}局 第${completedDay + 1}天");
        return Tuple4(yangDunList.first.item1, yangDunList.first.item2,
            yangDunList.first.item3, completedDay + 1);
      }
    } else {
      // print("-====== ${diffInDays - 365}");

      List<Tuple2<TwentyFourJieQi, DateTime>> twoZhiList = [];
      var getAllHelper =
          lastZhengShouDongZhiDateTime.add(const Duration(days: 365));
      for (int i = 0; i < diffYears; i++) {
        var lunar =
            LunarAdapter.fromDate(getAllHelper.add(Duration(days: 365 * diffYears)));
        twoZhiList.add(Tuple2(TwentyFourJieQi.DONG_ZHI,
            dateFormatter.parse(lunar.getJieQiTable()["冬至"]!.toYmdHms())));
        twoZhiList.add(Tuple2(TwentyFourJieQi.XIA_ZHI,
            dateFormatter.parse(lunar.getJieQiTable()["夏至"]!.toYmdHms())));
      }
      // print(twoZhiList.map((t)=>"${t.item1.name} ${t.item2}"));
      // print(twoZhiList.first.item2.difference(lastZhengShouDongZhiDateTime).inDays);
      // var diffInDays = twoZhiList.first.item2.difference(lastZhengShouDongZhiDateTime).inDays;
      var daysLeftAfter360 = diffInDays - 360;
      if ((diffInDays ~/ 180) % 2 == 0) {
        // 下一个节气为冬至，之后使用阳遁
        var completedDays = diffInDays % 360;
        // print("------- 下一个节气为冬至，之后使用阳遁，并且阳遁超神 $completedDays 天");
      } else {
        // 下一个节气为夏至，之后使用阴遁
      }
      int completedYuan = daysLeftAfter360 ~/ 5;
      // print("$completedYuan");
      int completedDay = daysLeftAfter360 % 5;
      var yangDunList = ShiJiaQiMenJuCalculator.yangDunList.skip(completedYuan);

      return Tuple4(yangDunList.first.item1, yangDunList.first.item2,
          yangDunList.first.item3, completedDay + 1);
    }
    // 从前一个冬至“正授”日开始，获取到目标时间（盘时间）每一年冬至夏至时间
    // 二至节时间列表

    throw UnimplementedError();
  }
}

// 茅山
class MaoShanCalculator extends ShiJiaQiMenJuCalculator {
  MaoShanCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.MAO_SHAN,
        );
  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  ShiJiaJu _doCalculate() {
    LunarAdapter lunar = LunarAdapter.fromDate(dateTime);
    String timeGanZhi = lunar.getTimeInGanZhi();
    if (dateTime.hour == 23) {
      // 时辰如果是23点之后 需要将日干支调整为下一天
      // 影响年月日的干支
      lunar = LunarAdapter.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayJiaZi.name,
      timeGanZhi
    ].join(" ").toString();

    // 起局时间所在的这一年节气
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    DateTime jieQiStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 节气开始时间应该为当天干支的子时
    jieQiStartAt = DateTime(
        jieQiStartAt.year, jieQiStartAt.month, jieQiStartAt.day - 1, 23, 0, 0);
    DateTime nextJieQiEndAt = dateFormatter.parse(
        lunar.getJieQiTable()[lunar.getNextJieQi().getName()]!.toYmdHms());
    DateTime jieQiEndAt = nextJieQiEndAt.subtract(const Duration(days: 1));
    jieQiEndAt =
        DateTime(jieQiEndAt.year, jieQiEndAt.month, jieQiEndAt.day, 23, 0, 0);
    int times = jieQiEndAt.difference(jieQiStartAt).inHours;
    // print("$jieQiName $jieQiStartAt $jieQiEndAt 相差 $times 小时");

    // TwentyFourJieQi jieQi24 = TwentyFourJieQi.fromName(jieQiName);
    Tuple3<int, int, int> dun;
    if (jieQi.yinYangDun.isYang) {
      dun = ShiJiaQiMenJuCalculator.YANG_DUN_JIE_QI_JU_NUMER[jieQi]!;
    } else {
      dun = ShiJiaQiMenJuCalculator.YIN_DUN_JIE_QI_JU_NUMER[jieQi]!;
    }

    int diffHourPanDateWithStartDate =
        dateTime.difference(jieQiStartAt).inHours;
    EnumThreeYuan yuan = EnumThreeYuan.START;
    int juNumber = 1;
    // 茅山法 前60时辰（120h） 为上元
    // 120-240h 为中元
    // 240-360h 为下元，不足没关系啊
    // 如果超出 360h则 重复下元
    if (diffHourPanDateWithStartDate <= 180) {
      yuan = EnumThreeYuan.START;
      juNumber = dun.item1;
    } else if (diffHourPanDateWithStartDate <= 360 &&
        diffHourPanDateWithStartDate > 180) {
      yuan = EnumThreeYuan.MIDDLE;
      juNumber = dun.item2;
    } else {
      yuan = EnumThreeYuan.END;
      juNumber = dun.item3;
    }

    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: juNumber,
        fuTouJiaZi: JiaZi.getFromGanZhiValue(
            LunarAdapter.fromDate(jieQiStartAt).getDayInGanZhi())!,
        yinYangDun: jieQi.yinYangDun,
        jieQiAt: jieQi,
        jieQiStartAt: jieQiStartAt,
        jieQiEnd: TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()),
        jieQiEndAt: nextJieQiEndAt,
        atThreeYuan: yuan,
        fourZhuEightChar: eightChar);
  }
}

// 阴盘
class YinPanCalculator extends ShiJiaQiMenJuCalculator {
  YinPanCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.YIN_PAN,
        );
  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  ShiJiaJu _doCalculate() {
    LunarAdapter lunar = LunarAdapter.fromDate(dateTime);
    String timeGanZhi = lunar.getTimeInGanZhi();
    if (dateTime.hour == 23) {
      // 时辰如果是23点之后 需要将日干支调整为下一天
      // 影响年月日的干支
      lunar = LunarAdapter.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayJiaZi.name,
      timeGanZhi
    ].join(" ").toString();

    // 年支序数
    int yearZhiIndex =
        JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!.diZhi.order;
    // 时支序数
    int timeZhiIndex = JiaZi.getFromGanZhiValue(timeGanZhi)!.diZhi.order;

    // 阴盘局为 局数取 （年支序数+月数+日数+时支序数）除9之余数。（如果正好整除则取9）
    int juNumber =
        (yearZhiIndex + lunar.getMonth() + lunar.getDay() + timeZhiIndex) % 9;
    if (juNumber == 0) {
      juNumber = 9;
    }
    // 冬至后使用阳遁，夏至后使用阴遁

    // 起局时间所在的这一年节气
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    DateTime jieQiStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 节气开始时间应该为当天干支的子时
    jieQiStartAt = DateTime(
        jieQiStartAt.year, jieQiStartAt.month, jieQiStartAt.day - 1, 23, 0, 0);
    DateTime nextJieQiEndAt = dateFormatter.parse(
        lunar.getJieQiTable()[lunar.getNextJieQi().getName()]!.toYmdHms());
    DateTime jieQiEndAt = nextJieQiEndAt.subtract(const Duration(days: 1));
    jieQiEndAt =
        DateTime(jieQiEndAt.year, jieQiEndAt.month, jieQiEndAt.day, 23, 0, 0);
    int times = jieQiEndAt.difference(jieQiStartAt).inHours;
    // print("$jieQiName $jieQiStartAt $jieQiEndAt 相差 $times 小时");

    // TwentyFourJieQi jieQi24 = TwentyFourJieQi.fromName(jieQiName);

    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: juNumber,
        fuTouJiaZi: JiaZi.getFromGanZhiValue(
            LunarAdapter.fromDate(jieQiStartAt).getDayInGanZhi())!,
        yinYangDun: jieQi.yinYangDun,
        jieQiAt: jieQi,
        jieQiStartAt: jieQiStartAt,
        jieQiEnd: TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()),
        jieQiEndAt: nextJieQiEndAt,
        atThreeYuan: EnumThreeYuan.NONE,
        fourZhuEightChar: eightChar);
  }
}
