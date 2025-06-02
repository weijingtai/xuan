class YearMonth {
  final int year;
  final int month;
  YearMonth(this.year, this.month);

  @override
  String toString() {
    if (month > 0) {
      return '$year/$month';
    }
    return '$year';
  }

  YearMonth operator -(YearMonth other) {
    int newYear = year - other.year;
    int newMonth = month - other.month;
    if (newMonth < 0) {
      newMonth += 12;
      newYear--;
    }
    return YearMonth(newYear, newMonth);
  }

  YearMonth operator +(YearMonth other) {
    int newYear = year + other.year;
    int newMonth = month + other.month;
    if (newMonth >= 12) {
      newMonth -= 12;
      newYear++;
    }
    return YearMonth(newYear, newMonth);
  }

  // 转换为总月数
  int toTotalMonths() {
    return year * 12 + month;
  }

  // 从总月数创建YearMonth
  static YearMonth fromTotalMonths(int totalMonths) {
    return YearMonth(totalMonths ~/ 12, totalMonths % 12);
  }

  // 转换为double年份（用于兼容旧逻辑）
  double toDoubleYear() {
    return year + month / 12.0;
  }

  // 从double年份创建YearMonth
  static YearMonth fromDoubleYear(double doubleYear) {
    int yearPart = doubleYear.toInt();
    double fractionalPart = doubleYear - yearPart;
    int monthPart = (fractionalPart * 12).round();
    return YearMonth(yearPart, monthPart);
  }

  static YearMonth fromYear(int year) {
    return YearMonth(year, 0);
  }

  static YearMonth oneYear() {
    return YearMonth(1, 0);
  }

  static YearMonth zero() {
    return YearMonth(0, 0);
  }

  static YearMonth halfYear() {
    return YearMonth(0, 6);
  }

  // 在YearMonth类中添加quarterYear静态方法
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

  // 判断是否为整年
  bool get isWholeYear => month == 0;

  // 判断是否为半年
  bool get isHalfYear => month == 6;

  // 判断是否为季度（3个月）
  bool get isQuarterYear => month == 3;

  // 判断是否为三季度（9个月）
  bool get isThreeQuarterYear => month == 9;

  // 判断是否为标准分割点（整年、半年、季度、三季度）
  bool get isStandardDivision =>
      isWholeYear || isHalfYear || isQuarterYear || isThreeQuarterYear;

  // 获取最小计算单位（月数）
  int get minimumCalculationUnit {
    if (isWholeYear) return 12;
    if (isHalfYear) return 6;
    if (isQuarterYear || isThreeQuarterYear) return 3;
    return 1; // 其他情况按月计算
  }

  // 比较操作符
  bool operator >(YearMonth other) {
    return toTotalMonths() > other.toTotalMonths();
  }

  bool operator <(YearMonth other) {
    return toTotalMonths() < other.toTotalMonths();
  }

  bool operator >=(YearMonth other) {
    return toTotalMonths() >= other.toTotalMonths();
  }

  bool operator <=(YearMonth other) {
    return toTotalMonths() <= other.toTotalMonths();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YearMonth && other.year == year && other.month == month;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}
