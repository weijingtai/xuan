import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('八神 落宫宫卦 判断 旺衰', () {
    Map<String, List<Tuple2<String, String>>> testGongData = {
      "值符": [
        const Tuple2("坎", "囚"),
        const Tuple2("艮", "相"),
        const Tuple2("震", "死"),
        const Tuple2("巽", "死"),
        const Tuple2("离", "旺"),
        const Tuple2("坤", "相"),
        const Tuple2("兑", "休"),
        const Tuple2("乾", "休"),
      ],
      "螣蛇": [
        const Tuple2("坎", "死"),
        const Tuple2("艮", "休"),
        const Tuple2("震", "旺"),
        const Tuple2("巽", "旺"),
        const Tuple2("离", "相"),
        const Tuple2("坤", "休"),
        const Tuple2("兑", "囚"),
        const Tuple2("乾", "囚"),
      ],
      "太阴": [
        const Tuple2("坎", "休"),
        const Tuple2("艮", "旺"),
        const Tuple2("震", "囚"),
        const Tuple2("巽", "囚"),
        const Tuple2("离", "死"),
        const Tuple2("坤", "旺"),
        const Tuple2("兑", "相"),
        const Tuple2("乾", "相"),
      ],
      "六合": [
        const Tuple2("坎", "旺"),
        const Tuple2("艮", "囚"),
        const Tuple2("震", "相"),
        const Tuple2("巽", "相"),
        const Tuple2("离", "休"),
        const Tuple2("坤", "囚"),
        const Tuple2("兑", "死"),
        const Tuple2("乾", "死"),
      ],
      "白虎": [
        const Tuple2("坎", "休"),
        const Tuple2("艮", "旺"),
        const Tuple2("震", "囚"),
        const Tuple2("巽", "囚"),
        const Tuple2("离", "死"),
        const Tuple2("坤", "旺"),
        const Tuple2("兑", "相"),
        const Tuple2("乾", "相"),
      ],
      "玄武": [
        const Tuple2("坎", "相"),
        const Tuple2("艮", "死"),
        const Tuple2("震", "休"),
        const Tuple2("巽", "休"),
        const Tuple2("离", "囚"),
        const Tuple2("坤", "死"),
        const Tuple2("兑", "旺"),
        const Tuple2("乾", "旺"),
      ],
      "九天": [
        const Tuple2("坎", "休"),
        const Tuple2("艮", "旺"),
        const Tuple2("震", "囚"),
        const Tuple2("巽", "囚"),
        const Tuple2("离", "死"),
        const Tuple2("坤", "旺"),
        const Tuple2("兑", "相"),
        const Tuple2("乾", "相"),
      ],
      "九地": [
        const Tuple2("坎", "囚"),
        const Tuple2("艮", "相"),
        const Tuple2("震", "死"),
        const Tuple2("巽", "死"),
        const Tuple2("离", "旺"),
        const Tuple2("坤", "相"),
        const Tuple2("兑", "休"),
        const Tuple2("乾", "休"),
      ],
    };
    for (var entry in testGongData.entries) {
      for (var tuple in entry.value) {
        test("${entry.key} 落[${tuple.item1}] ${tuple.item2}", () {
          expect(
              FiveEnergyStatus.getWangShuaiByName(tuple.item2),
              EightGodsEnum.fromName(entry.key).checkWangShuaiWithGongGua(
                  HouTianGua.getGuaByName(tuple.item1)));
        });
      }
    }
  });

  group('八神 落宫 地盘干 纳卦 判断 旺衰', () {
    Map<String, List<Tuple2<String, String>>> testGongData = {
      "值符": [
        const Tuple2("戊", "囚"),
        const Tuple2("丙", "相"),
        const Tuple2("庚", "死"),
        const Tuple2("辛", "死"),
        const Tuple2("己", "旺"),
        const Tuple2("乙", "相"),
        const Tuple2("癸", "相"),
        const Tuple2("丁", "休"),
        const Tuple2("壬", "休"),
      ],
    };
    for (var entry in testGongData.entries) {
      for (var tuple in entry.value) {
        test("${entry.key} 落地干[${tuple.item1}] ${tuple.item2}", () {
          expect(
              FiveEnergyStatus.getWangShuaiByName(tuple.item2),
              EightGodsEnum.fromName(entry.key).checkWangShuaiWithDiPanGanNaGua(
                  TianGan.getFromValue(tuple.item1)!));
        });
      }
    }
  });
}
