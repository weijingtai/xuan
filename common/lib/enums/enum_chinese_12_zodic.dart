import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

enum EnumChinese12Zodiac {
  @JsonValue("鼠")
  Rat("鼠", DiZhi.ZI),
  @JsonValue("牛")
  Ox("牛", DiZhi.CHOU),
  @JsonValue("虎")
  Tiger("虎", DiZhi.YIN),
  @JsonValue("兔")
  Rabbit("兔", DiZhi.MAO),
  @JsonValue("龙")
  Dragon("龙", DiZhi.CHEN),
  @JsonValue("蛇")
  Snake("蛇", DiZhi.SI),
  @JsonValue("马")
  Horse("马", DiZhi.WU),
  @JsonValue("羊")
  Goat("羊", DiZhi.WEI),
  @JsonValue("猴")
  Monkey("猴", DiZhi.SHEN),
  @JsonValue("鸡")
  Rooster("鸡", DiZhi.YOU),
  @JsonValue("狗")
  Dog("狗", DiZhi.XU),
  @JsonValue("猪")
  Pig("猪", DiZhi.HAI);

  final String name;
  final DiZhi diZhi;
  const EnumChinese12Zodiac(this.name, this.diZhi);

  /// get by name
  static EnumChinese12Zodiac fromName(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  /// get by diZhi
  static EnumChinese12Zodiac fromDiZhi(DiZhi diZhi) {
    return values.firstWhere((e) => e.diZhi == diZhi);
  }
}
