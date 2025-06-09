import 'package:json_annotation/json_annotation.dart';

part 'year_month.g.dart';

@JsonSerializable()
class YearMonth {
  final int year;
  final int month;
  final int? day; // 允许为null，如果只关心年月

  // 常量定义 - 整合两个版本的常量
  static const int daysInMonthNonLeap = 30; // 或更精确的平均值，或实际日历计算
  static const double avgDaysInMonth = 30.4375; // 365.25 / 12
  static const double avgDaysInYear = 365.2425;

  YearMonth(this.year, this.month, [this.day]);

  @override
  String toString() {
    // 使用中文格式（来自增量版本）
    String s = '${year}年${month}月';
    if (day != null && day! > 0) {
      s += '${day}日';
    }
    return s;
  }

  // 减法运算符（保留现有实现）
  YearMonth operator -(YearMonth other) {
    int newYear = year - other.year;
    int newMonth = month - other.month;
    if (newMonth < 0) {
      newMonth += 12;
      newYear--;
    }
    return YearMonth(newYear, newMonth);
  }

  // 加法运算符（使用增量版本的高精度实现）
  YearMonth operator +(YearMonth other) {
    int newYear = year + other.year;
    int newMonth = month + other.month;
    int newDay = (day ?? 0) + (other.day ?? 0);

    // 处理月份进位
    if (newMonth >= 12) {
      newYear += newMonth ~/ 12;
      newMonth = newMonth % 12;
    }

    // 处理天数进位（简化处理，假设每月30天）
    if (newDay >= 30) {
      newMonth += newDay ~/ 30;
      newDay = newDay % 30;

      // 再次检查月份进位
      if (newMonth >= 12) {
        newYear += newMonth ~/ 12;
        newMonth = newMonth % 12;
      }
    }

    return YearMonth(newYear, newMonth, newDay > 0 ? newDay : null);
  }

  // 总月数计算（改进版本，考虑天数）
  int toTotalMonths() {
    return year * 12 + month + ((day ?? 0) / avgDaysInMonth).round();
  }

  // 从总月数创建YearMonth（保留现有实现）
  static YearMonth fromTotalMonths(int totalMonths) {
    return YearMonth(totalMonths ~/ 12, totalMonths % 12);
  }

  // 总天数计算（使用增量版本的实现）
  int toTotalDays() {
    return (year * avgDaysInYear).round() +
        (month * avgDaysInMonth).round() +
        (day ?? 0);
  }

  // 总天数计算 但以小时返回
  int toDaysInHour() {
    int yearInHour = (year * avgDaysInYear * 24).round(); // 每年为365天，6小时
    int monthInHour = (month * avgDaysInMonth * 24).round(); // 每个月为30天，24小时

    return yearInHour + monthInHour + (day == null ? 0 : day! * 24);
  }

  // 从总天数创建YearMonth（使用增量版本的改进实现）
  static YearMonth fromTotalDays(int totalDays) {
    if (totalDays == 0) return YearMonth(0, 0, 0);

    // 这是一个近似转换，更精确需要考虑具体起始日期
    int years = (totalDays / avgDaysInYear).floor();
    int remainingDaysAfterYears = totalDays - (years * avgDaysInYear).round();
    int months = (remainingDaysAfterYears / avgDaysInMonth).floor();
    int finalDays = remainingDaysAfterYears - (months * avgDaysInMonth).round();

    if (finalDays < 0) finalDays = 0; // 避免负数天

    if (finalDays >= 30 && months < 11) {
      // 简单进位
      months += (finalDays ~/ 30);
      finalDays %= 30;
    }

    if (months >= 12) {
      years += (months ~/ 12);
      months %= 12;
    }

    return YearMonth(years, months, finalDays > 0 ? finalDays : null);
  }

  // 转换为double年份（保留现有实现）
  double toDoubleYear() {
    return year + month / 12.0;
  }

  // 从double年份创建YearMonth（使用增量版本的改进实现）
  static YearMonth fromDoubleYear(double decimalYears) {
    int totalDays = (decimalYears * avgDaysInYear).round();
    return fromTotalDays(totalDays);
  }

  // 静态工厂方法（保留现有实现）
  static YearMonth fromYear(int year) {
    return YearMonth(year, 0);
  }

  static YearMonth oneYear() {
    return YearMonth(1, 0);
  }

  // zero方法（使用增量版本的实现）
  static YearMonth zero() => YearMonth(0, 0, 0);

  static YearMonth halfYear() {
    return YearMonth(0, 6);
  }

  static YearMonth quarterYear() => YearMonth(0, 3);

  static YearMonth threeQuarterYear() {
    return YearMonth(0, 9);
  }

  static YearMonth fromMonths(int months) {
    assert(months >= 0);
    if (months >= 12) {
      return YearMonth(months ~/ 12, months % 12);
    }
    return YearMonth(0, months);
  }

  // 判断方法（保留现有实现）
  bool get isWholeYear => month == 0;
  bool get isHalfYear => month == 6;
  bool get isQuarterYear => month == 3;
  bool get isThreeQuarterYear => month == 9;
  bool get isStandardDivision =>
      isWholeYear || isHalfYear || isQuarterYear || isThreeQuarterYear;

  int get minimumCalculationUnit {
    if (isWholeYear) return 12;
    if (isHalfYear) return 6;
    if (isQuarterYear || isThreeQuarterYear) return 3;
    return 1;
  }

  // 比较操作符（保留现有实现，但使用天数比较以提高精度）
  bool operator >(YearMonth other) {
    return toTotalDays() > other.toTotalDays();
  }

  bool operator <(YearMonth other) {
    return toTotalDays() < other.toTotalDays();
  }

  bool operator >=(YearMonth other) {
    return toTotalDays() >= other.toTotalDays();
  }

  bool operator <=(YearMonth other) {
    return toTotalDays() <= other.toTotalDays();
  }

  // 天数运算方法（使用增量版本的实现）
  YearMonth addDays(int daysToAdd) {
    return YearMonth.fromTotalDays(this.toTotalDays() + daysToAdd);
  }

  YearMonth subtractDays(int days) {
    int currentTotalDays = toTotalDays();
    return YearMonth.fromTotalDays(currentTotalDays - days);
  }

  // 相等性和哈希码（保留现有实现）
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YearMonth &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ (day?.hashCode ?? 0);

  factory YearMonth.fromJson(Map<String, dynamic> json) =>
      _$YearMonthFromJson(json);
  Map<String, dynamic> toJson() => _$YearMonthToJson(this);
}
