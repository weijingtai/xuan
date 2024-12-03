import 'package:common/model/enum_five_xing_relationship.dart';
import 'package:common/model/enum_hou_tian_gua.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:common/model/enum_twelve_zhang_sheng.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/utils/nine_yi_utils.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('八神 落宫宫卦 判断 旺衰', () {
    Map<String,List<Tuple2<String,String>>> test_gong_data = {
      "值符":[
        Tuple2("坎", "囚"),
        Tuple2("艮", "相"),
        Tuple2("震", "死"),
        Tuple2("巽", "死"),
        Tuple2("离", "旺"),
        Tuple2("坤", "相"),
        Tuple2("兑", "休"),
        Tuple2("乾", "休"),
    ],
      "螣蛇":[
        Tuple2("坎", "死"),
        Tuple2("艮", "休"),
        Tuple2("震", "旺"),
        Tuple2("巽", "旺"),
        Tuple2("离", "相"),
        Tuple2("坤", "休"),
        Tuple2("兑", "囚"),
        Tuple2("乾", "囚"),
      ],
      "太阴":[
        Tuple2("坎", "休"),
        Tuple2("艮", "旺"),
        Tuple2("震", "囚"),
        Tuple2("巽", "囚"),
        Tuple2("离", "死"),
        Tuple2("坤", "旺"),
        Tuple2("兑", "相"),
        Tuple2("乾", "相"),
      ],
      "六合":[
        Tuple2("坎", "旺"),
        Tuple2("艮", "囚"),
        Tuple2("震", "相"),
        Tuple2("巽", "相"),
        Tuple2("离", "休"),
        Tuple2("坤", "囚"),
        Tuple2("兑", "死"),
        Tuple2("乾", "死"),
      ],
      "白虎":[
        Tuple2("坎", "休"),
        Tuple2("艮", "旺"),
        Tuple2("震", "囚"),
        Tuple2("巽", "囚"),
        Tuple2("离", "死"),
        Tuple2("坤", "旺"),
        Tuple2("兑", "相"),
        Tuple2("乾", "相"),
      ],
      "玄武":[
        Tuple2("坎", "相"),
        Tuple2("艮", "死"),
        Tuple2("震", "休"),
        Tuple2("巽", "休"),
        Tuple2("离", "囚"),
        Tuple2("坤", "死"),
        Tuple2("兑", "旺"),
        Tuple2("乾", "旺"),
      ],
      "九天":[
        Tuple2("坎", "休"),
        Tuple2("艮", "旺"),
        Tuple2("震", "囚"),
        Tuple2("巽", "囚"),
        Tuple2("离", "死"),
        Tuple2("坤", "旺"),
        Tuple2("兑", "相"),
        Tuple2("乾", "相"),
      ],
      "九地":[
        Tuple2("坎", "囚"),
        Tuple2("艮", "相"),
        Tuple2("震", "死"),
        Tuple2("巽", "死"),
        Tuple2("离", "旺"),
        Tuple2("坤", "相"),
        Tuple2("兑", "休"),
        Tuple2("乾", "休"),
      ],
    };
    for (var entry in test_gong_data.entries) {
      for (var tuple in entry.value) {
        test("${entry.key} 落[${tuple.item1}] ${tuple.item2}",() {
          expect(FiveXingWangShuai.getWangShuaiByName(tuple.item2), EightGodsEnum.fromName(entry.key).checkWangShuaiWithGongGua(HouTianGua.getGuaByName(tuple.item1)));
        });
      }
    }
  });

  group('八神 落宫 地盘干 纳卦 判断 旺衰', () {
    Map<String,List<Tuple2<String,String>>> test_gong_data = {
      "值符":[
        Tuple2("戊", "囚"),
        Tuple2("丙", "相"),
        Tuple2("庚", "死"),
        Tuple2("辛", "死"),
        Tuple2("己", "旺"),
        Tuple2("乙", "相"),
        Tuple2("癸", "相"),
        Tuple2("丁", "休"),
        Tuple2("壬", "休"),
      ],

    };
    for (var entry in test_gong_data.entries) {
      for (var tuple in entry.value) {
        test("${entry.key} 落地干[${tuple.item1}] ${tuple.item2}",() {
          expect(FiveXingWangShuai.getWangShuaiByName(tuple.item2), EightGodsEnum.fromName(entry.key).checkWangShuaiWithDiPanGanNaGua(TianGan.getFromValue(tuple.item1)!));
        });
      }
    }
  });
}
