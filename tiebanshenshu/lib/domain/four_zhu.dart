import '../constant/constants.dart' as Constants;

/// 四柱类 - 包含年月日时的干支信息
class FourZhu {
  final String yearGanzhi;
  final String monthGanzhi;
  final String dayGanzhi;
  final String timeGanzhi;

  FourZhu({
    required this.yearGanzhi,
    required this.monthGanzhi,
    required this.dayGanzhi,
    required this.timeGanzhi,
  });

  /// 年干是否为阳干
  bool get isYangGanYear {
    return Constants.tianGanYinYangMapper[yearGan]!;
  }

  /// 日干是否为阳干
  bool get isYangGanDay {
    return Constants.tianGanYinYangMapper[dayGan]!;
  }

  /// 年干太玄数
  int get yearGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[yearGan]!;
  }

  /// 月干太玄数
  int get monthGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[monthGan]!;
  }

  /// 日干太玄数
  int get dayGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[dayGan]!;
  }

  /// 时干太玄数
  int get timeGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[timeGan]!;
  }

  /// 年支太玄数
  int get yearZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[yearZhi]!;
  }

  /// 月支太玄数
  int get monthZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[monthZhi]!;
  }

  /// 日支太玄数
  int get dayZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[dayZhi]!;
  }

  /// 时支太玄数
  int get timeZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[timeZhi]!;
  }

  /// 年干
  String get yearGan {
    return yearGanzhi[0];
  }

  /// 年支
  String get yearZhi {
    return yearGanzhi[yearGanzhi.length - 1];
  }

  /// 月干
  String get monthGan {
    return monthGanzhi[0];
  }

  /// 月支
  String get monthZhi {
    return monthGanzhi[monthGanzhi.length - 1];
  }

  /// 日干
  String get dayGan {
    return dayGanzhi[0];
  }

  /// 日支
  String get dayZhi {
    return dayGanzhi[dayGanzhi.length - 1];
  }

  /// 时干
  String get timeGan {
    return timeGanzhi[0];
  }

  /// 时支
  String get timeZhi {
    return timeGanzhi[timeGanzhi.length - 1];
  }

  @override
  String toString() {
    return 'FourZhu(年: $yearGanzhi, 月: $monthGanzhi, 日: $dayGanzhi, 时: $timeGanzhi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FourZhu &&
        other.yearGanzhi == yearGanzhi &&
        other.monthGanzhi == monthGanzhi &&
        other.dayGanzhi == dayGanzhi &&
        other.timeGanzhi == timeGanzhi;
  }

  @override
  int get hashCode {
    return yearGanzhi.hashCode ^
        monthGanzhi.hashCode ^
        dayGanzhi.hashCode ^
        timeGanzhi.hashCode;
  }
}
