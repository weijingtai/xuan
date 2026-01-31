import 'package:common/enums.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/da_yun_pillar.dart';
import 'package:tyme/tyme.dart' hide Gender;
import 'package:intl/intl.dart';

class DaYunCalculator {
  List<DaYunPillar> calculate({
    required ChineseDateInfo dateInfo,
    required DateTime birthDateTime,
    required Gender gender,
    int stepDuration = 10,
    int pillarCount = 8,
  }) {
    // Step 1: Determine Direction
    final yearStem = dateInfo.eightChars.yearTianGan;
    final isYangYear = yearStem.isYang;

    final bool isForward;
    if (gender == Gender.male) {
      isForward = isYangYear; // Yang Male -> Forward
    } else {
      isForward = !isYangYear; // Yin Female -> Forward
    }

    // Step 2: Calculate Start Age using tyme
    final solarDay = SolarDay.fromYmd(
        birthDateTime.year, birthDateTime.month, birthDateTime.day);
    final term = solarDay.getTerm();

    // Get current term time
    final termJd = term.getJulianDay();
    final termTime = termJd.getSolarTime();
    final termAt = DateTime(
      termTime.getYear(),
      termTime.getMonth(),
      termTime.getDay(),
      termTime.getHour(),
      termTime.getMinute(),
      termTime.getSecond(),
    );

    // Determine prev and next jieqi times
    DateTime nextJieQiTime;
    DateTime prevJieQiTime;

    if (termAt.isAfter(birthDateTime)) {
      // Term hasn't started yet
      nextJieQiTime = termAt;
      final prevTerm = term.next(-1);
      final prevJd = prevTerm.getJulianDay();
      final prevTime = prevJd.getSolarTime();
      prevJieQiTime = DateTime(
        prevTime.getYear(),
        prevTime.getMonth(),
        prevTime.getDay(),
        prevTime.getHour(),
        prevTime.getMinute(),
        prevTime.getSecond(),
      );
    } else {
      // Term already started
      prevJieQiTime = termAt;
      final nextTerm = term.next(1);
      final nextJd = nextTerm.getJulianDay();
      final nextTime = nextJd.getSolarTime();
      nextJieQiTime = DateTime(
        nextTime.getYear(),
        nextTime.getMonth(),
        nextTime.getDay(),
        nextTime.getHour(),
        nextTime.getMinute(),
        nextTime.getSecond(),
      );
    }

    Duration timeDiff;
    if (isForward) {
      timeDiff = nextJieQiTime.difference(birthDateTime);
    } else {
      timeDiff = birthDateTime.difference(prevJieQiTime);
    }

    // 3 days = 1 year. Or 1 day = 4 months. Or 1 hour = 5 days' worth of calculation?
    // The rule is "三天为一岁" (3 days is 1 year), so we use that.
    final startAgeInYears = timeDiff.inHours / (3 * 24.0);
    final startAge = startAgeInYears.floor();

    // Step 3: Generate Pillars
    final daYunPillars = <DaYunPillar>[];
    JiaZi currentPillar = dateInfo.eightChars.month;
    int currentAge = startAge;

    for (int i = 0; i < pillarCount; i++) {
      if (isForward) {
        currentPillar = currentPillar.getNext();
      } else {
        currentPillar = currentPillar.getPrevious();
      }

      daYunPillars.add(DaYunPillar(
        startAge: currentAge,
        endAge: currentAge + stepDuration - 1,
        pillar: currentPillar,
        totalAge: stepDuration,
      ));

      currentAge += stepDuration;
    }

    return daYunPillars;
  }
}
