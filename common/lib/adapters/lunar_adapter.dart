import 'package:intl/intl.dart';
import 'package:tyme/tyme.dart';

/// Adapter class to provide lunar-package-compatible API using tyme package.
/// This minimizes changes needed in code that heavily used the old lunar package.
class LunarAdapter {
  final DateTime _dateTime;
  late final SolarDay _solarDay;
  late final LunarDay _lunarDay;
  late final LunarHour _lunarHour;
  late final EightChar _eightChar;

  LunarAdapter.fromDate(DateTime dt) : _dateTime = dt {
    _solarDay = SolarDay.fromYmd(dt.year, dt.month, dt.day);
    _lunarDay = _solarDay.getLunarDay();
    final solarTime = SolarTime.fromYmdHms(
      dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second,
    );
    _lunarHour = solarTime.getLunarHour();
    _eightChar = _lunarHour.getEightChar();
  }

  /// Get BaZi as list of 4 GanZhi strings [year, month, day, hour]
  List<String> getBaZi() {
    return [
      _eightChar.getYear().getName(),
      _eightChar.getMonth().getName(),
      _eightChar.getDay().getName(),
      _eightChar.getHour().getName(),
    ];
  }

  String getYearInGanZhi() => _eightChar.getYear().getName();
  String getMonthInGanZhi() => _eightChar.getMonth().getName();
  String getDayInGanZhi() => _eightChar.getDay().getName();
  String getTimeInGanZhi() => _eightChar.getHour().getName();

  /// Get the Earth Branch of the time pillar
  String getTimeZhi() => _eightChar.getHour().getName().substring(1);

  /// Get the Earth Branch of the month pillar
  String getMonthZhi() => _eightChar.getMonth().getName().substring(1);

  /// Get lunar year
  int getYear() => _lunarDay.getLunarMonth().getLunarYear().getYear();

  /// Get lunar month (positive for regular, the actual month number)
  int getMonth() => _lunarDay.getLunarMonth().getMonthWithLeap();

  /// Get lunar day
  int getDay() => _lunarDay.getDay();

  /// Get lunar month in Chinese
  String getMonthInChinese() => _lunarDay.getLunarMonth().getName();

  /// Get lunar day in Chinese
  String getDayInChinese() => _lunarDay.getName();

  /// Check if the current date falls exactly on a JieQi
  /// Returns the JieQi name if on a JieQi day, null otherwise.
  JieQiResult? getCurrentJieQi() {
    final term = _solarDay.getTerm();
    final jd = term.getJulianDay();
    final st = jd.getSolarTime();
    final termDate = DateTime(
      st.getYear(), st.getMonth(), st.getDay(),
      st.getHour(), st.getMinute(), st.getSecond(),
    );

    // If the term time is on the same day and not after the current time
    if (termDate.year == _dateTime.year &&
        termDate.month == _dateTime.month &&
        termDate.day == _dateTime.day &&
        !termDate.isAfter(_dateTime)) {
      return JieQiResult(term.getName(), _solarTimeToDateTime(st));
    }
    return null;
  }

  /// Get the JieQi name of the current date (returns current if on JieQi, else previous)
  String getJieQi() {
    final current = getCurrentJieQi();
    if (current != null) return current.getName();
    return getPrevJieQi().getName();
  }

  /// Get previous JieQi (节气 only when onlyJie=true, otherwise any term)
  JieQiResult getPrevJieQi([bool onlyJie = false]) {
    final term = _solarDay.getTerm();
    final jd = term.getJulianDay();
    final st = jd.getSolarTime();
    final termAt = _solarTimeToDateTime(st);

    if (termAt.isAfter(_dateTime)) {
      final prevTerm = term.next(-1);
      final prevJd = prevTerm.getJulianDay();
      final prevSt = prevJd.getSolarTime();
      return JieQiResult(prevTerm.getName(), _solarTimeToDateTime(prevSt));
    }
    return JieQiResult(term.getName(), termAt);
  }

  /// Get previous Qi (中气, even-indexed solar terms)
  JieQiResult getPrevQi() {
    return getPrevJieQi();
  }

  /// Get next JieQi
  JieQiResult getNextJieQi([bool onlyJie = false]) {
    final term = _solarDay.getTerm();
    final jd = term.getJulianDay();
    final st = jd.getSolarTime();
    final termAt = _solarTimeToDateTime(st);

    if (!termAt.isAfter(_dateTime)) {
      final nextTerm = term.next(1);
      final nextJd = nextTerm.getJulianDay();
      final nextSt = nextJd.getSolarTime();
      return JieQiResult(nextTerm.getName(), _solarTimeToDateTime(nextSt));
    }
    return JieQiResult(term.getName(), termAt);
  }

  /// Get WuHou (72 phenology)
  String getWuHou() {
    return _solarDay.getPhenologyDay().getPhenology().getName();
  }

  /// Get JieQi table: Map<String, SolarTimeResult> for all 24 terms in the year
  Map<String, SolarTimeResult> getJieQiTable() {
    final year = _dateTime.year;
    final result = <String, SolarTimeResult>{};

    for (int i = 0; i < 24; i++) {
      final term = SolarTerm.fromIndex(year, i);
      final jd = term.getJulianDay();
      final st = jd.getSolarTime();
      result[term.getName()] = SolarTimeResult(st);
    }

    // Also check previous year's terms that might be relevant (e.g., 冬至 from previous year)
    for (int i = 0; i < 24; i++) {
      final term = SolarTerm.fromIndex(year - 1, i);
      final name = term.getName();
      if (!result.containsKey(name)) {
        final jd = term.getJulianDay();
        final st = jd.getSolarTime();
        // Only add if this term's date is closer to the current year
        final termDt = _solarTimeToDateTime(st);
        if (termDt.year == year || (termDt.year == year - 1 && termDt.month >= 11)) {
          result[name] = SolarTimeResult(st);
        }
      }
    }

    return result;
  }

  /// Check if the lunar month is a leap month
  bool isLeapMonth() => _lunarDay.getLunarMonth().isLeap();

  static DateTime _solarTimeToDateTime(SolarTime st) {
    return DateTime(
      st.getYear(),
      st.getMonth(),
      st.getDay(),
      st.getHour(),
      st.getMinute(),
      st.getSecond(),
    );
  }
}

/// Result object that mimics the old JieQi class from lunar package
class JieQiResult {
  final String _name;
  final DateTime _dateTime;

  JieQiResult(this._name, this._dateTime);

  String getName() => _name;

  SolarResult getSolar() => SolarResult(_dateTime);
}

/// Result object that mimics the old Solar class from lunar package
class SolarResult {
  final DateTime _dateTime;

  SolarResult(this._dateTime);

  String toYmdHms() {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(_dateTime);
  }

  SolarResult next(int days) {
    return SolarResult(_dateTime.add(Duration(days: days)));
  }
}

/// Result object that wraps SolarTime for use in JieQi tables
class SolarTimeResult {
  final SolarTime _solarTime;

  SolarTimeResult(this._solarTime);

  String toYmdHms() {
    final st = _solarTime;
    final y = st.getYear();
    final m = st.getMonth().toString().padLeft(2, '0');
    final d = st.getDay().toString().padLeft(2, '0');
    final h = st.getHour().toString().padLeft(2, '0');
    final mi = st.getMinute().toString().padLeft(2, '0');
    final s = st.getSecond().toString().padLeft(2, '0');
    return '$y-$m-$d $h:$mi:$s';
  }
}
