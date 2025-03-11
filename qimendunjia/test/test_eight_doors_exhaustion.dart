import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:tuple/tuple.dart';

void main() {
  var testGongData = {
    "休门": [
      const Tuple2("坎", "旺"),
      const Tuple2("艮", "死"),
      const Tuple2("震", "休"),
      const Tuple2("巽", "休"),
      const Tuple2("离", "囚"),
      const Tuple2("坤", "死"),
      const Tuple2("兑", "相"),
      const Tuple2("乾", "相"),
    ],
    "死门": [
      const Tuple2("坎", "囚"),
      const Tuple2("艮", "旺"),
      const Tuple2("震", "死"),
      const Tuple2("巽", "死"),
      const Tuple2("离", "相"),
      const Tuple2("坤", "旺"),
      const Tuple2("兑", "休"),
      const Tuple2("乾", "休"),
    ],
    "伤门": [
      const Tuple2("坎", "相"),
      const Tuple2("艮", "囚"),
      const Tuple2("震", "旺"),
      const Tuple2("巽", "旺"),
      const Tuple2("离", "休"),
      const Tuple2("坤", "囚"),
      const Tuple2("兑", "死"),
      const Tuple2("乾", "死"),
    ],
    "杜门": [
      const Tuple2("坎", "相"),
      const Tuple2("艮", "囚"),
      const Tuple2("震", "旺"),
      const Tuple2("巽", "旺"),
      const Tuple2("离", "休"),
      const Tuple2("坤", "囚"),
      const Tuple2("兑", "死"),
      const Tuple2("乾", "死"),
    ],
    "开门": [
      const Tuple2("坎", "休"),
      const Tuple2("艮", "相"),
      const Tuple2("震", "囚"),
      const Tuple2("巽", "囚"),
      const Tuple2("离", "死"),
      const Tuple2("坤", "相"),
      const Tuple2("兑", "旺"),
      const Tuple2("乾", "旺"),
    ],
    "惊门": [
      const Tuple2("坎", "休"),
      const Tuple2("艮", "相"),
      const Tuple2("震", "囚"),
      const Tuple2("巽", "囚"),
      const Tuple2("离", "死"),
      const Tuple2("坤", "相"),
      const Tuple2("兑", "旺"),
      const Tuple2("乾", "旺"),
    ],
    "生门": [
      const Tuple2("坎", "囚"),
      const Tuple2("艮", "旺"),
      const Tuple2("震", "死"),
      const Tuple2("巽", "死"),
      const Tuple2("离", "相"),
      const Tuple2("坤", "旺"),
      const Tuple2("兑", "休"),
      const Tuple2("乾", "休"),
    ],
    "景门": [
      const Tuple2("坎", "死"),
      const Tuple2("艮", "休"),
      const Tuple2("震", "相"),
      const Tuple2("巽", "相"),
      const Tuple2("离", "旺"),
      const Tuple2("坤", "休"),
      const Tuple2("兑", "囚"),
      const Tuple2("乾", "囚"),
    ],
  };
  var testMonthData = {
    "休门": [
      const Tuple2('亥子', "旺"),
      const Tuple2('辰戌丑未', "死"),
      const Tuple2('寅卯', "休"),
      const Tuple2('巳午', "囚"),
      const Tuple2('申酉', "相"),
    ],
    "死门": [
      const Tuple2('亥子', "囚"),
      const Tuple2('辰戌丑未', "旺"),
      const Tuple2('寅卯', "死"),
      const Tuple2('巳午', "相"),
      const Tuple2('申酉', "休"),
    ],
    "伤门": [
      const Tuple2('亥子', "相"),
      const Tuple2('辰戌丑未', "囚"),
      const Tuple2('寅卯', "旺"),
      const Tuple2('巳午', "休"),
      const Tuple2('申酉', "死"),
    ],
    "杜门": [
      const Tuple2('亥子', "相"),
      const Tuple2('辰戌丑未', "囚"),
      const Tuple2('寅卯', "旺"),
      const Tuple2('巳午', "休"),
      const Tuple2('申酉', "死"),
    ],
    "开门": [
      const Tuple2('亥子', "休"),
      const Tuple2('辰戌丑未', "相"),
      const Tuple2('寅卯', "囚"),
      const Tuple2('巳午', "死"),
      const Tuple2('申酉', "旺"),
    ],
    "惊门": [
      const Tuple2('亥子', "休"),
      const Tuple2('辰戌丑未', "相"),
      const Tuple2('寅卯', "囚"),
      const Tuple2('巳午', "死"),
      const Tuple2('申酉', "旺"),
    ],
    "生门": [
      const Tuple2('亥子', "囚"),
      const Tuple2('辰戌丑未', "旺"),
      const Tuple2('寅卯', "死"),
      const Tuple2('巳午', "相"),
      const Tuple2('申酉', "休"),
    ],
    "景门": [
      const Tuple2('亥子', "死"),
      const Tuple2('辰戌丑未', "休"),
      const Tuple2('寅卯', "相"),
      const Tuple2('巳午', "旺"),
      const Tuple2('申酉', "囚"),
    ],
  };
  group('八门 落宫 ‘旺相休囚死’', () {
    for (var entries in testGongData.entries) {
      var door = entries.key;
      for (var tuple in entries.value) {
        test("$door ${tuple.item2} 落 ${tuple.item1}", () {
          expect(
              EightDoorEnum.fromName(door)
                  .checkWithGong(HouTianGua.getGuaByName(tuple.item1)),
              FiveEnergyStatus.getWangShuaiByName(tuple.item2));
        });
      }
    }
  });

  group('八门 月令 ‘旺相休囚死’', () {
    var counter = 1;
    for (var entries in testMonthData.entries) {
      var door = entries.key;
      for (var tuple in entries.value) {
        test("$door ${tuple.item2} 月令 ${tuple.item1}", () {
          for (var yue in tuple.item1.split("")) {
            expect(
                EightDoorEnum.fromName(door).checkWithMonthToken(
                    MonthToken.fromDiZhi(DiZhi.getFromValue(yue)!)),
                FiveEnergyStatus.getWangShuaiByName(tuple.item2));
          }
        });
      }
    }
  });
}
