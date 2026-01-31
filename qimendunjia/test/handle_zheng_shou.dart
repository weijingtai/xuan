import 'dart:io';

import 'package:common/adapters/lunar_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qimendunjia/utils/zheng_shou_dong_zhi_list.dart';

void main() {
  group("正授冬至， datetime to millisecond", () {
    test("ok", () {
      ZhengShouDongZhiList.ZhengShouDongZhi.map(
              (e) => e.subtract(const Duration(days: 1)))
          .map((e) => e.millisecondsSinceEpoch)
          .forEach((e) {
        // print((e + 61978496400941) ~/100000);
        print((e + 61978582800941) ~/ 100000);
      });
    });
  });

  group("正授冬至，准备数据", () {
    DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateFormat dateOnlyFormatter = DateFormat("yyyy-MM-dd");
    test("", () {
      // 读取数据
      var file = File("zheng_shou_dong_zhi.txt");
      List<String> lines = file.readAsLinesSync();
      List<DateTime> zhengShouDongZhiDateList = [];
      for (String line in lines) {
        List<String> tmp = line.split(" ");
        DateTime dateTime = dateOnlyFormatter.parse("${tmp[1]} 00:00:00");
        dateTime = DateTime(
            dateTime.year, dateTime.month, dateTime.day - 1, 22, 59, 59);
        zhengShouDongZhiDateList.add(dateTime);
      }
      // zhengShouDongZhiDateList.map((e)=>e.millisecondsSinceEpoch).forEach((e){
      // print((e + 61978496400941) ~/100000);
      // });

      // DateTime res = findClosestNumber(zhengShouDongZhiDateList, 2023);
      // print(res);
    });
  });
  group("冬至日为正授 1 ~ 9999", () {
    DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    test("", () {
      // for (var i = 1; i < 9999;i++){
      LunarAdapter lunar = LunarAdapter.fromDate(DateTime(1, 12, 30));
      DateTime dongZhiDateTime =
          dateFormatter.parse(lunar.getJieQiTable()["冬至"]!.toYmdHms());
      String dayGanZhi = LunarAdapter.fromDate(dongZhiDateTime).getDayInGanZhi();
      if (["甲子", "己卯", "甲午", "己酉"].contains(dayGanZhi)) {
        print("$dayGanZhi $dongZhiDateTime");
      }
      // }
    });
  });
}

DateTime findClosestNumber(List<DateTime> arr, int target) {
  int left = 0;
  int right = arr.length - 1;
  DateTime result = DateTime(5, 12, 23);

  while (left <= right) {
    int mid = left + (right - left) ~/ 2;

    if (arr[mid].year <= target) {
      result = arr[mid];
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }

  return result;
}
