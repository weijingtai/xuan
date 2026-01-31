import 'package:common/enums.dart';
import 'package:common/adapters/lunar_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qimendunjia/enums/enum_three_yuan.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';

import 'package:qimendunjia/utils/qi_men_ju_calculator.dart';
import 'package:tuple/tuple.dart';

void main() {
  final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  group("阴盘", () {
    test("阴盘", () {
      DateTime targetDateTime = DateTime(2018, 3, 20, 12, 14, 0);
      YinPanCalculator maoShan = YinPanCalculator(
        dateTime: targetDateTime,
      );

      ShiJiaJu ju = maoShan.calculate();
      expect(ju.juNumber, 6);
      expect(ju.yinYangDun, YinYang.YANG);
    });
  });
  group("茅山法", () {
    test("茅山", () {
      DateTime targetDateTime = DateTime(2018, 3, 20, 12, 14, 0);
      MaoShanCalculator maoShan = MaoShanCalculator(
        dateTime: targetDateTime,
      );

      maoShan.calculate();
    });
    test("茅山", () {
      DateTime targetDateTime = DateTime(2025, 6, 24, 12, 14, 0);
      MaoShanCalculator maoShan = MaoShanCalculator(
        dateTime: targetDateTime,
      );

      maoShan.calculate();
    });
  });
  group("置润法 数格子法确定阴遁局数", () {
    test("2025-06-24 夏至：上元第1天 阴遁九局", () {
      DateTime targetDateTime = DateTime(2025, 6, 24, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 9);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.XIA_ZHI);
      expect(result.item4, 1);
    });

    test("2025-08-20 立秋：下元第3天 阴遁八局", () {
      DateTime targetDateTime = DateTime(2025, 8, 20, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 8);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.LI_QIU);
      expect(result.item4, 3);
    });

    test("数格子法确定阴遁局数 冬至：上元第2天 阳遁一局", () {
      DateTime targetDateTime = DateTime(2024, 12, 27, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 1);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.DONG_ZHI);
      expect(result.item4, 2);
    });

    test("数格子法确定阴遁局数 2024-12-22 大雪：下元第2天 阴遁一局", () {
      DateTime targetDateTime = DateTime(2024, 12, 22, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 1);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.DA_XUE);
      expect(result.item4, 2);
    });

    test("数格子法确定阴遁局数 夏至：中元第4天 阴遁三局", () {
      DateTime targetDateTime = DateTime(2024, 6, 22, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 3);
      expect(result.item2, EnumThreeYuan.MIDDLE);
      expect(result.item3, TwentyFourJieQi.XIA_ZHI);
      expect(result.item4, 4);
    });

    test("数格子法确定阴遁局数 冬至：中元第2天 阳遁七局", () {
      DateTime targetDateTime = DateTime(2023, 12, 23, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 7);
      expect(result.item2, EnumThreeYuan.MIDDLE);
      expect(result.item3, TwentyFourJieQi.DONG_ZHI);
      expect(result.item4, 2);
    });
  });

  group("depected", () {
    test("置润 正授过后 >= 360天之内 阳遁 2023-12-22 是年冬至节当天，这天使用“阳遁”冬至中元7局第1天", () {
      DateTime targetDateTime = DateTime(2023, 12, 22, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      expect(result.item1, 7);
      expect(result.item2, EnumThreeYuan.MIDDLE);
      expect(result.item3, TwentyFourJieQi.DONG_ZHI);
      expect(result.item4, 1);
    });

    test(
        "置润 正授过后 >= 360天之内 阳遁 2023-12-21 是年大雪最后一天（冬至前一天），这天使用“阳遁”冬至上元1局第5天（此元最后一天）",
        () {
      DateTime targetDateTime = DateTime(2023, 12, 21, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);

      expect(result.item1, 1);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.DONG_ZHI);
      expect(result.item4, 5);
    });

    test("置润 正授过后 >= 360天之内 阳遁 2023-12-17 是年大雪后第6天，这天使用“阳遁”冬至上元1局第1天（阳遁第一天）",
        () {
      DateTime targetDateTime = DateTime(2023, 12, 17, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 1);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.DONG_ZHI);
      expect(result.item4, 1);
    });
    test("置润 正授过后 180~360天之内 阴遁 2023-12-16 是年大雪后第5天，这天使用阴遁大雪下元1局第5天（元最后一天）",
        () {
      DateTime targetDateTime = DateTime(2023, 12, 16, 12, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 1);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.DA_XUE);
      expect(result.item4, 5);
    });
    test("置润 正授过后 180~360天之内 阴遁 2023-06-20 23:14 是年夏至节当天，这天夏至阴遁使用上元9局2天", () {
      DateTime targetDateTime = DateTime(2023, 6, 20, 23, 14, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 9);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.XIA_ZHI);
      expect(result.item4, 2);
    });

    test(
        "置润 正授过后 180~360天之内 阴遁 2023-06-20 是年芒种最后一天（夏至前一天），这天夏至阴遁使用上元9局1天（即，阴遁第一局第一天）",
        () {
      DateTime targetDateTime = DateTime(2023, 6, 20, 9, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 9);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.XIA_ZHI);
      expect(result.item4, 1);
    });

    test("置润 正授过后 180天内4 2023-04-05 23:10 是年清明节第一天，这天使用清明上元4局第1天 ", () {
      DateTime targetDateTime = DateTime(2023, 4, 5, 23, 10, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      print(
          "${result.item1} ${result.item2.name} ${result.item3.name} ${result.item4}");
      expect(result.item1, 4);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.QING_MING);
      expect(result.item4, 1);
    });

    test("置润 正授过后 180天内4 2023-04-5 是年清明节第一天， 这天使用春分下元6局第5天（最后一天） ", () {
      DateTime targetDateTime = DateTime(2023, 4, 5, 9, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 6);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.CHUN_FEN);
      expect(result.item4, 5);
    });

    test("置润 正授过后 180天内4 2023-04-6 是年清明后第一天， 这天使用清明上元4局第1天", () {
      DateTime targetDateTime = DateTime(2023, 4, 6, 9, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 4);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.QING_MING);
      expect(result.item4, 1);
    });

    test("置润 正授过后 180天内3 2023-06-19 是年芒种最后二天， 这天使用芒种下元9局第5天（最后一天）", () {
      DateTime targetDateTime = DateTime(2023, 6, 19, 9, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 9);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.MANG_ZHONG);
      expect(result.item4, 5);
    });

    test("置润 正授过后 180天内3 2023-04-21 是年谷雨第一天， 这天使用谷雨上元5局第一天", () {
      DateTime targetDateTime = DateTime(2023, 4, 21, 9, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 5);
      expect(result.item2, EnumThreeYuan.START);
      expect(result.item3, TwentyFourJieQi.GU_YU);
      expect(result.item4, 1);
    });

    test("置润 正授过后 180天内2  2023-04-20 是年谷雨节当天， 这天使用清明下元7局第五天（最后一天）", () {
      DateTime targetDateTime = DateTime(2023, 4, 20, 6, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 7);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.QING_MING);
      expect(result.item4, 5);
    });

    test("置润 正授过后 180天内1  2023-04-19 是年清明最后一天， 这天使用清明下元7局第四天", () {
      DateTime targetDateTime = DateTime(2023, 4, 19, 6, 0, 0);
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: targetDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> result =
          zhirun.doCa(targetDateTime);
      expect(result.item1, 7);
      expect(result.item2, EnumThreeYuan.END);
      expect(result.item3, TwentyFourJieQi.QING_MING);
      expect(result.item4, 4);
    });

    test('置润法 2', () {
      DateTime zhengShouDongZhi = DateTime(2022, 12, 22); // 冬至 正授 上元第一天 阳一局
      LunarAdapter lunar = LunarAdapter.fromDate(DateTime(2023, 5, 23, 12, 0, 0));
      String targetJieQiSt = "夏至";
      DateTime otherJieQiDateTime =
          dateFormatter.parse(lunar.getJieQiTable()[targetJieQiSt]!.toYmdHms());
      // 23点之后调整为第二天
      // if (otherJieQiDateTime.hour == 23){
      //   otherJieQiDateTime = otherJieQiDateTime.add(Duration(hours: 1));
      // }
      // print(ShiJiaQiMenJuCalculator.yangDunList);
      print("$targetJieQiSt $otherJieQiDateTime");
      int toTargetDiffDays =
          otherJieQiDateTime.difference(zhengShouDongZhi).inDays;
      print("正授冬至 到 目标节气 $targetJieQiSt 共 $toTargetDiffDays 天");
      DateTime targetJieQiDateTime =
          zhengShouDongZhi.add(Duration(days: toTargetDiffDays));
      print(
          "${LunarAdapter.fromDate(targetJieQiDateTime).getJieQi()} $targetJieQiDateTime");

      int fullXun = toTargetDiffDays ~/ 15; // 完整走过一节气 三候
      print("从正授开始到targetJieQiSt 共 $fullXun 个完整的节气三元");

      print("第一个180天为阳遁，此时阳遁已经结束");
      DateTime xiaZhiYinDunStartAt;
      int startBeforeDays = 0;
      if (toTargetDiffDays > 180) {
        startBeforeDays = toTargetDiffDays - 180;
        print("夏至阴遁将会提前$startBeforeDays开始（超神）");
        xiaZhiYinDunStartAt =
            targetJieQiDateTime.subtract(Duration(days: startBeforeDays));
        print("夏至阴遁开始于 $xiaZhiYinDunStartAt, 为 超神");
      } else if (toTargetDiffDays < 180) {
        print("阴遁需要超神");
        if (180 - toTargetDiffDays >= 9) {
          print("阳遁不足太多，需要进行置润操作，即将阳遁最后节气芒种的三元重复使用一遍，且阴遁夏至变为接气");
        } else {
          print("阳遁随有不足但并未不足9天，无需进行置润操作，将阴遁夏至上元提前到这天");
        }
      } else {
        print("正授");
      }
      Iterable<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> newList =
          ShiJiaQiMenJuCalculator.yinDunList;
      print("目标日期，已经是阴遁开始后的第${startBeforeDays + 1}天");

      print(
          "${newList.first.item3.name} ${newList.first.item2.name}第${startBeforeDays + 1}天 第${newList.first.item1}局 ");

      int fullXunLeft = toTargetDiffDays % 15; // 到下一个节气前 剩余的天数
      // print(toTargetDiffDays ~/ 15);
      print("----------");

      // leftDaysFinishedXun 当 leftDaysFinishedXun
      // 为 ‘0’时表示，目标日期正在“上元”
      // 为 ‘1’时表示，目标日期正在“中元”
      // 为 ‘2’时表示，目标日期在“下元”
      //
      // leftDaysInXun 表示 在“元”中的第几天

      int leftDaysFinishedXun = fullXunLeft ~/ 5; // 剩余天数中 已完成的旬
      // print("已走完的元：$leftDaysFinishedXun");
      int leftDaysInXun = fullXunLeft % 5; // 已走完的天
      // print(leftDaysInXun);
      // print("newList lenght ${newList.length}");
      newList = newList.skip(leftDaysInXun + 1);
      // print(newList.first);
      // print("juNumber ${newList.first.item3.name} ${newList.first.item2.name} 第${newList.first.item1}局, 第${leftDaysInXun+1}天");
      // Tuple3<int,EnumThreeYuan,TwentyFourJieQi> juNumber = newList.toList();
      // print("juNumber ${juNumber.item3.name} ${juNumber.item2.name} ${juNumber.item1}");

      // print(toDongZhiDays % 15);
      // newList.skip(count)

      // print("");
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: otherJieQiDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      // zhirun.calculate();
    });

    test('置润法 1', () {
      DateTime zhengShouDongZhi = DateTime(
        2022,
        12,
        22,
      ); // 冬至 正授 上元第一天 阳一局
      // DateTime _tmpOther = DateTime(2023,1,20,);
      // print(_tmpOther.difference(zhengShouDongZhi).inDays);

      LunarAdapter lunar =
          LunarAdapter.fromDate(DateTime(zhengShouDongZhi.year + 1, 9, 12, 12, 0, 0));
      String targetJieQiSt = "大寒";
      print(lunar.getJieQiTable()[targetJieQiSt]!.toYmdHms());
      DateTime otherJieQiDateTime =
          dateFormatter.parse(lunar.getJieQiTable()[targetJieQiSt]!.toYmdHms());
      // 23点之后调整为第二天
      // if (otherJieQiDateTime.hour == 23){
      //   otherJieQiDateTime = otherJieQiDateTime.add(Duration(hours: 1));
      // }
      // print(ShiJiaQiMenJuCalculator.yangDunList);
      print("冬至（正授） $zhengShouDongZhi");
      print("$targetJieQiSt $otherJieQiDateTime");
      int diffInDays = otherJieQiDateTime.difference(zhengShouDongZhi).inDays;
      print("正授冬至 到 目标节气 $targetJieQiSt 共 $diffInDays 天");
      // DateTime dongZhiDateTime = zhengShouDongZhi.add(Duration(days: toDongZhiDays));
      // print("${LunarAdapter.fromDate(dongZhiDateTime).getJieQi()} $dongZhiDateTime");

      int fullXun = diffInDays ~/ 15; // 完整走过一节气 三候
      print("从正授开始到targetJieQiSt 共 $fullXun 完整的节气三元");
      Iterable<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> newList =
          ShiJiaQiMenJuCalculator.yangDunList.skip(fullXun * 3);
      print(
          "${newList.first.item3.name} ${newList.first.item2.name} ${newList.first.item1}");

      int fullXunLeft = diffInDays % 15; // 到下一个节气前 剩余的天数
      print(diffInDays ~/ 15);

      // leftDaysFinishedXun 当 leftDaysFinishedXun
      // 为 ‘0’时表示，目标日期正在“上元”
      // 为 ‘1’时表示，目标日期正在“中元”
      // 为 ‘2’时表示，目标日期在“下元”
      //
      // leftDaysInXun 表示 在“元”中的第几天

      int leftDaysFinishedXun = fullXunLeft ~/ 5; // 剩余天数中 已完成的旬
      print("已走完的元：$leftDaysFinishedXun");
      int leftDaysInXun = fullXunLeft % 5; // 已走完的天
      print(leftDaysInXun);
      print("newList lenght ${newList.length}");
      newList = newList.skip(leftDaysInXun + 1);
      print(newList.first);
      print(
          "juNumber ${newList.first.item3.name} ${newList.first.item2.name} 第${newList.first.item1}局, 第${leftDaysInXun + 1}天");
      // Tuple3<int,EnumThreeYuan,TwentyFourJieQi> juNumber = newList.toList();
      // print("juNumber ${juNumber.item3.name} ${juNumber.item2.name} ${juNumber.item1}");

      // print(diffInDays % 15);
      // newList.skip(count)

      print("");
      ZhiRunCalculator zhirun = ZhiRunCalculator(
        dateTime: otherJieQiDateTime,
        // arrangeType:ArrangeType.ZHI_RUN,
      );
      // zhirun.calculate();
    });
  });
}
