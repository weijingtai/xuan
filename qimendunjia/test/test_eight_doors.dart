import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';

void main() {
  group('测试八门与月令将的旺相休囚死', () {
    test("休门 旺于 亥子月", () {
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.HAI),
          FiveEnergyStatus.WANG);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.ZI),
          FiveEnergyStatus.WANG);
    });
    test("休门 相于 申酉月", () {
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.SHEN),
          FiveEnergyStatus.XIANG);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.YOU),
          FiveEnergyStatus.XIANG);
    });
    test("休门 休于 寅卯月", () {
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.MAO),
          FiveEnergyStatus.XIU);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.YIN),
          FiveEnergyStatus.XIU);
    });
    test("休门 囚于 巳午月", () {
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.SI),
          FiveEnergyStatus.QIU);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.WU),
          FiveEnergyStatus.QIU);
    });
    test("休门 死于 辰戌丑未月", () {
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.CHEN),
          FiveEnergyStatus.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.XU),
          FiveEnergyStatus.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.WEI),
          FiveEnergyStatus.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.CHOU),
          FiveEnergyStatus.SI);
    });
  });
}
