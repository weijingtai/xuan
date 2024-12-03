import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_five_xing_relationship.dart';
import 'package:common/model/enum_hou_tian_gua.dart';
import 'package:common/model/enum_month_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:tuple/tuple.dart';

void main() {
  var test_gong_data = {
    "休门":[
      Tuple2("坎","旺"),
      Tuple2("艮","死"),
      Tuple2("震","休"),
      Tuple2("巽","休"),
      Tuple2("离","囚"),
      Tuple2("坤","死"),
      Tuple2("兑","相"),
      Tuple2("乾","相"),
    ],
    "死门":[
      Tuple2("坎","囚"),
      Tuple2("艮","旺"),
      Tuple2("震","死"),
      Tuple2("巽","死"),
      Tuple2("离","相"),
      Tuple2("坤","旺"),
      Tuple2("兑","休"),
      Tuple2("乾","休"),
    ],
    "伤门":[
      Tuple2("坎","相"),
      Tuple2("艮","囚"),
      Tuple2("震","旺"),
      Tuple2("巽","旺"),
      Tuple2("离","休"),
      Tuple2("坤","囚"),
      Tuple2("兑","死"),
      Tuple2("乾","死"),
    ],
    "杜门":[
      Tuple2("坎","相"),
      Tuple2("艮","囚"),
      Tuple2("震","旺"),
      Tuple2("巽","旺"),
      Tuple2("离","休"),
      Tuple2("坤","囚"),
      Tuple2("兑","死"),
      Tuple2("乾","死"),
    ],
    "开门":[
      Tuple2("坎","休"),
      Tuple2("艮","相"),
      Tuple2("震","囚"),
      Tuple2("巽","囚"),
      Tuple2("离","死"),
      Tuple2("坤","相"),
      Tuple2("兑","旺"),
      Tuple2("乾","旺"),
    ],
    "惊门":[
      Tuple2("坎","休"),
      Tuple2("艮","相"),
      Tuple2("震","囚"),
      Tuple2("巽","囚"),
      Tuple2("离","死"),
      Tuple2("坤","相"),
      Tuple2("兑","旺"),
      Tuple2("乾","旺"),
    ],
    "生门":[
      Tuple2("坎","囚"),
      Tuple2("艮","旺"),
      Tuple2("震","死"),
      Tuple2("巽","死"),
      Tuple2("离","相"),
      Tuple2("坤","旺"),
      Tuple2("兑","休"),
      Tuple2("乾","休"),
    ],
    "景门":[
      Tuple2("坎","死"),
      Tuple2("艮","休"),
      Tuple2("震","相"),
      Tuple2("巽","相"),
      Tuple2("离","旺"),
      Tuple2("坤","休"),
      Tuple2("兑","囚"),
      Tuple2("乾","囚"),
    ],
  };
  var test_month_data = {
    "休门":[
      Tuple2('亥子',"旺"),
      Tuple2('辰戌丑未',"死"),
      Tuple2('寅卯',"休"),
      Tuple2('巳午',"囚"),
      Tuple2('申酉',"相"),
    ],
    "死门":[
      Tuple2('亥子',"囚"),
      Tuple2('辰戌丑未',"旺"),
      Tuple2('寅卯',"死"),
      Tuple2('巳午',"相"),
      Tuple2('申酉',"休"),
    ],
    "伤门":[
      Tuple2('亥子',"相"),
      Tuple2('辰戌丑未',"囚"),
      Tuple2('寅卯',"旺"),
      Tuple2('巳午',"休"),
      Tuple2('申酉',"死"),
    ],
    "杜门":[
      Tuple2('亥子',"相"),
      Tuple2('辰戌丑未',"囚"),
      Tuple2('寅卯',"旺"),
      Tuple2('巳午',"休"),
      Tuple2('申酉',"死"),
    ],
    "开门":[
      Tuple2('亥子',"休"),
      Tuple2('辰戌丑未',"相"),
      Tuple2('寅卯',"囚"),
      Tuple2('巳午',"死"),
      Tuple2('申酉',"旺"),
    ],
    "惊门":[
      Tuple2('亥子',"休"),
      Tuple2('辰戌丑未',"相"),
      Tuple2('寅卯',"囚"),
      Tuple2('巳午',"死"),
      Tuple2('申酉',"旺"),
    ],
    "生门":[
      Tuple2('亥子',"囚"),
      Tuple2('辰戌丑未',"旺"),
      Tuple2('寅卯',"死"),
      Tuple2('巳午',"相"),
      Tuple2('申酉',"休"),
    ],
    "景门":[
      Tuple2('亥子',"死"),
      Tuple2('辰戌丑未',"休"),
      Tuple2('寅卯',"相"),
      Tuple2('巳午',"旺"),
      Tuple2('申酉',"囚"),
    ],
  };
  group('八门 落宫 ‘旺相休囚死’', () {
    for (var entries in test_gong_data.entries) {
      var door = entries.key;
      for (var tuple in entries.value) {
        test("$door ${tuple.item2} 落 ${tuple.item1}",(){
          expect(EightDoorEnum.fromName(door).checkWithGong(HouTianGua.getGuaByName(tuple.item1)), FiveXingWangShuai.getWangShuaiByName(tuple.item2));
        });
      }
    }
  });

  group('八门 月令 ‘旺相休囚死’', () {
    var counter = 1;
    for (var entries in test_month_data.entries) {
      var door = entries.key;
      for (var tuple in entries.value) {
        test("$door ${tuple.item2} 月令 ${tuple.item1}",(){
          for (var yue in tuple.item1.split("")) {
            expect(EightDoorEnum.fromName(door).checkWithMonthToken(MonthToken.fromDiZhi(DiZhi.getFromValue(yue)!)), FiveXingWangShuai.getWangShuaiByName(tuple.item2));
          }
        });
      }
    }
  });
}
