enum EnumTenGods {
  ZhenCai("正财", "财"),
  PanCai("偏财", "才"),
  ZhengYin("正印", "印"),
  PanYin("偏印", "枭"),
  ShiShen("食神", "食"),
  ShangGuan("伤官", "伤"),
  ZhengGuan("正官", "官"),
  PanGuan("偏官", "杀"),
  BiJian("比肩", "比"),
  JieCai("劫财", "劫");

  final String name;
  final String singleName;
  const EnumTenGods(this.name, this.singleName);

  String get shortName => singleName;
}
