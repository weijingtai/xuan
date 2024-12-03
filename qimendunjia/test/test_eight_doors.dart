import 'package:common/model/enum_five_xing_relationship.dart';
import 'package:common/model/enum_month_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';

void main() {
  group('测试八门与月令将的旺相休囚死', () {
    test("休门 旺于 亥子月",(){
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.HAI), FiveXingWangShuai.WANG);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.ZI), FiveXingWangShuai.WANG);
    });
    test("休门 相于 申酉月",(){
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.SHEN), FiveXingWangShuai.XIANG);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.YOU), FiveXingWangShuai.XIANG);
    });
    test("休门 休于 寅卯月",(){
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.MAO), FiveXingWangShuai.XIU);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.YIN), FiveXingWangShuai.XIU);
    });
    test("休门 囚于 巳午月",(){
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.SI), FiveXingWangShuai.QIU);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.WU), FiveXingWangShuai.QIU);
    });
    test("休门 死于 辰戌丑未月",(){
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.CHEN), FiveXingWangShuai.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.XU), FiveXingWangShuai.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.WEI), FiveXingWangShuai.SI);
      expect(EightDoorEnum.XIU.checkWithMonthToken(MonthToken.CHOU), FiveXingWangShuai.SI);
    });
  });
}
