import 'package:common/enums.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/da_yun_pillar.dart';
import 'package:lunar/lunar.dart';
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

    // Step 2: Calculate Start Age
    final lunar = Lunar.fromDate(birthDateTime);
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

    // The lunar package finds the closest JieQi, which is what we need.
    final nextJieQi = lunar.getNextJieQi(true);
    final prevJieQi = lunar.getPrevJieQi(true);

    final nextJieQiTime = dateFormat.parse(nextJieQi.getSolar().toYmdHms());
    final prevJieQiTime = dateFormat.parse(prevJieQi.getSolar().toYmdHms());

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
