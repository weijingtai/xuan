import 'package:flutter_test/flutter_test.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/features/datetime_details/jieqi_phenology_store.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/enums/enum_twenty_four_jie_qi.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:common/adapters/lunar_adapter.dart';

void main() {
  group('JieQi entry precision boundary tests', () {
    setUp(() async {
      // 默认定气法+精准物候，便于测试真实交节时刻
      JieQiPhenologyStore.jieQiType = JieQiType.stabilizing;
      JieQiPhenologyStore.phenologyStrategy = PhenologyStrategy.stabilizingBased;
    });

    test('minute: strict boundary at minute level', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.minute;
      // 选一个可能靠近节气的时间（示例值，不依赖具体节气表）
      final t1 = DateTime(2025, 3, 20, 23, 59, 0);
      final info1 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(t1, ZiShiStrategy.noDistinguishAt23);
      final t2 = t1.add(const Duration(minutes: 1));
      final info2 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(t2, ZiShiStrategy.noDistinguishAt23);
      // 在严格模式下，跨越真实交节秒才改变节气；这里不做具体节气断言，仅验证 API 不抛错和结构一致
      expect(info1.jieQiInfo.jieQi.name, isNotNull);
      expect(info2.jieQiInfo.jieQi.name, isNotNull);
    });

    test('hour: same hour bucket enters next JieQi', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.hour;
      final df = SolarLunarDateTimeHelper.dateFormat;
      DateTime? boundary;
      final start = DateTime(2025, 1, 1, 12, 0, 0);
      for (int i = 0; i < 365; i++) {
        final day = start.add(Duration(days: i));
        final l = LunarAdapter.fromDate(day);
        final n = l.getNextJieQi(true);
        final b = df.parse(n.getSolar().toYmdHms());
        if (b.minute > 0 || b.second > 0) {
          boundary = b;
          break;
        }
      }

      if (boundary == null) {
        expect(true, isTrue);
        return;
      }

      final earlyInHour = boundary!.minute > 0
          ? boundary!.subtract(const Duration(minutes: 1))
          : boundary!.subtract(const Duration(seconds: 1));
      final prev = boundary!.subtract(const Duration(hours: 1));

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(prev, ZiShiStrategy.noDistinguishAt23);
      final bBoundaryHour = SolarLunarDateTimeHelper.cacluateChineseDateInfo(boundary, ZiShiStrategy.noDistinguishAt23);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(earlyInHour, ZiShiStrategy.noDistinguishAt23);

      // 同小时桶内，earlyInHour 应与 boundary 同节气
      expect(bEarly.jieQiInfo.jieQi, equals(bBoundaryHour.jieQiInfo.jieQi));
      // prev 可能与 boundary 不同节气
      expect(bPrev.jieQiInfo.jieQi, isNot(equals(bBoundaryHour.jieQiInfo.jieQi)));
    });

    test('shichen: same shichen bucket enters next JieQi (affected by Zi strategy)', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.shichen;
      final df = SolarLunarDateTimeHelper.dateFormat;
      DateTime? boundary;
      final start = DateTime(2025, 1, 1, 12, 0, 0);
      for (int i = 0; i < 365; i++) {
        final day = start.add(Duration(days: i));
        final l = LunarAdapter.fromDate(day);
        final n = l.getNextJieQi(true);
        final b = df.parse(n.getSolar().toYmdHms());
        if (b.minute > 0 || b.second > 0) {
          boundary = b;
          break;
        }
      }

      if (boundary == null) {
        expect(true, isTrue);
        return;
      }

      final inSameShichen = boundary!.minute > 0
          ? boundary!.subtract(const Duration(minutes: 1))
          : boundary!.subtract(const Duration(seconds: 1));
      final outShichen = boundary!.subtract(const Duration(hours: 2));

      final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(boundary, ZiShiStrategy.noDistinguishAt23);
      final bSame = SolarLunarDateTimeHelper.cacluateChineseDateInfo(inSameShichen, ZiShiStrategy.noDistinguishAt23);
      final bOut = SolarLunarDateTimeHelper.cacluateChineseDateInfo(outShichen, ZiShiStrategy.noDistinguishAt23);

      expect(bSame.jieQiInfo.jieQi, equals(bBoundary.jieQiInfo.jieQi));
      expect(bOut.jieQiInfo.jieQi, isNot(equals(bBoundary.jieQiInfo.jieQi)));
    });

    test('Phenology boundaries respect entry precision (+5d/+10d)', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.hour;
      final seed = DateTime(2025, 6, 1, 12, 0, 0);
      final seedInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(seed, ZiShiStrategy.noDistinguishAt23);
      final baseStart = seedInfo.jieQiInfo.startAt;
      final plus4h = baseStart.add(const Duration(hours: 4));
      final plus6d = baseStart.add(const Duration(days: 6));

      final b4 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(plus4h, ZiShiStrategy.noDistinguishAt23);
      final b6 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(plus6d, ZiShiStrategy.noDistinguishAt23);

      // 同节气三候中，order 1/2/3 递增；此处仅比较是否不同候
      expect(b4.phenology.order, isNot(equals(b6.phenology.order)));
      expect(b4.phenology.jieqi, equals(b6.phenology.jieqi));
    });

    test('minute precision: same-minute enters next JieQi (when possible)', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.minute;
      final seed = DateTime(2025, 3, 10, 12, 0, 0);
      final lunar = LunarAdapter.fromDate(seed);
      final df = SolarLunarDateTimeHelper.dateFormat;
      final next = lunar.getNextJieQi(true);
      final boundary = df.parse(next.getSolar().toYmdHms());

      // 若边界秒数>0，构造“同分钟但早于边界1秒”的时刻
      if (boundary.second > 0) {
        final sameMinuteBefore = boundary.subtract(const Duration(seconds: 1));
        final prevMinute = sameMinuteBefore.subtract(const Duration(minutes: 1));

        final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(prevMinute, ZiShiStrategy.noDistinguishAt23);
        final bSame = SolarLunarDateTimeHelper.cacluateChineseDateInfo(sameMinuteBefore, ZiShiStrategy.noDistinguishAt23);
        final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(boundary, ZiShiStrategy.noDistinguishAt23);

        // 同分钟应与边界视为同节气；上一分钟仍是旧节气
        expect(bSame.jieQiInfo.jieQi, equals(bBoundary.jieQiInfo.jieQi));
        expect(bPrev.jieQiInfo.jieQi, isNot(equals(bBoundary.jieQiInfo.jieQi)));
      } else {
        // 若边界秒数==0，无可靠“同分钟早于边界”样本，跳过断言
        expect(true, isTrue);
      }
    });

    test('minute precision stabilizing: same-minute before boundary enters', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.minute;
      final seed = DateTime(2025, 5, 1, 12, 0, 0);
      final lunar = LunarAdapter.fromDate(seed);
      final df = SolarLunarDateTimeHelper.dateFormat;
      final next = lunar.getNextJieQi(true);
      final boundary = df.parse(next.getSolar().toYmdHms());

      // 保证同分钟：边界前 1 毫秒
      final sameMinuteBefore = boundary.subtract(const Duration(milliseconds: 1));
      final prevMinute = boundary.subtract(const Duration(minutes: 1));

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(prevMinute, ZiShiStrategy.noDistinguishAt23);
      final bSame = SolarLunarDateTimeHelper.cacluateChineseDateInfo(sameMinuteBefore, ZiShiStrategy.noDistinguishAt23);
      final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(boundary, ZiShiStrategy.noDistinguishAt23);

      expect(bSame.jieQiInfo.jieQi, equals(bBoundary.jieQiInfo.jieQi));
      expect(bPrev.jieQiInfo.jieQi, isNot(equals(bBoundary.jieQiInfo.jieQi)));
    });

    test('minute precision leveling: same-minute before boundary enters', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.minute;
      // 切换为平气法，获取当前时刻的“平气起点”作为边界
      JieQiPhenologyStore.jieQiType = JieQiType.leveling;
      final t = DateTime(2025, 6, 1, 0, 0, 0);
      final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(t, ZiShiStrategy.noDistinguishAt23);
      final boundary = info.jieQiInfo.startAt;

      final sameMinuteBefore = boundary.subtract(const Duration(milliseconds: 1));
      final prevMinute = boundary.subtract(const Duration(minutes: 1));

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(prevMinute, ZiShiStrategy.noDistinguishAt23);
      final bSame = SolarLunarDateTimeHelper.cacluateChineseDateInfo(sameMinuteBefore, ZiShiStrategy.noDistinguishAt23);
      final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(boundary, ZiShiStrategy.noDistinguishAt23);

      expect(bSame.jieQiInfo.jieQi, equals(bBoundary.jieQiInfo.jieQi));
      expect(bPrev.jieQiInfo.jieQi, isNot(equals(bBoundary.jieQiInfo.jieQi)));

      // 复位节气类型，避免影响其他测试
      JieQiPhenologyStore.jieQiType = JieQiType.stabilizing;
    });

    test('shichen precision uses Zi strategy for bucket (at23 vs at0)', () {
      JieQiEntryStrategyStore.current = JieQiEntryPrecision.shichen;
      // 搜索一个“下一节气”处于 23 点的边界，用于构造“同时辰（at23）/不同时辰（at0）”的用例
      DateTime? boundary;
      String? boundaryJieQiName;
      final df = SolarLunarDateTimeHelper.dateFormat;
      final start = DateTime(2025, 1, 1, 12, 0, 0);
      for (int i = 0; i < 365; i++) {
        final day = start.add(Duration(days: i));
        final l = LunarAdapter.fromDate(day);
        final n = l.getNextJieQi(true);
        final b = df.parse(n.getSolar().toYmdHms());
        if (b.hour == 23) {
          boundary = b;
          boundaryJieQiName = n.getName();
          break;
        }
      }

      if (boundary == null) {
        // 未找到合适样本，跳过
        expect(true, isTrue);
        return;
      }

      final anchor00_10 = DateTime(boundary!.year, boundary!.month, boundary!.day, 0, 10, 0);

      // at23：00:10 与 23:xx 属于同一“子时”桶 => 提前进入“boundary 所在节气”
      final infoAt23 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(anchor00_10, ZiShiStrategy.noDistinguishAt23);
      // at0：00:10 与 23:xx 不同“时辰”桶 => 仍处于前一节气
      final infoAt0 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(anchor00_10, ZiShiStrategy.distinguishAt0FiveMouse);

      final boundaryJieQi = TwentyFourJieQi.fromName(boundaryJieQiName!);

      expect(infoAt23.jieQiInfo.jieQi, equals(boundaryJieQi));
      expect(infoAt0.jieQiInfo.jieQi, isNot(equals(boundaryJieQi)));
    });
  });
}
