// 写一个 DateTime 的扩展类，用于获取节气
import 'dart:math';

// 无法准确的获取季节，如 2023/08/31 是处暑 而结果确实白露
extension SolarTerm on DateTime {
  static const List<String> solarTerms = [
    '小寒',
    '大寒',
    '立春',
    '雨水',
    '惊蛰',
    '春分',
    '清明',
    '谷雨',
    '立夏',
    '小满',
    '芒种',
    '夏至',
    '小暑',
    '大暑',
    '立秋',
    '处暑',
    '白露',
    '秋分',
    '寒露',
    '霜降',
    '立冬',
    '小雪',
    '大雪',
    '冬至'
  ];

  // 节气黄经交点
  static const solarTermJieQi = [
    0,
    15,
    30,
    45,
    60,
    75,
    90,
    105,
    120,
    135,
    150,
    165,
    180,
    195,
    210,
    225,
    240,
    255,
    270,
    285,
    300,
    315,
    330,
    345
  ];

  // 计算黄经
  double getSolarLng() {
    int year = this.year;
    int days = difference(DateTime(year)).inDays;
    return (360 / 365.24) * days +
        (1.914 * sin((days * 2 * pi / 365.24) - 1.914)) % 360;
  }

  // 获取节气
  String getSolarTerm() {
    double lng = getSolarLng();
    int index = (lng / 15).floor() % 24;
    return solarTerms[index];
  }
}

// void main() {
//   print(DateTime.parse("2022-12-14").getSolarTerm());  // Expected: 大雪
// }
