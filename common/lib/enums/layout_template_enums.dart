enum PillarType {
  year('年'),
  month('月'),
  day('日'),
  hour('时'),
  ke('刻'),
  taiMeta('胎元'),
  taiMonth('胎月'),
  taiDay('胎日'),
  lifeHouse('身宫'),
  luckCycle('大运'),
  annual('流年'),
  monthly('流月'),
  daily('流日'),
  hourly('流刻'),
  separator('ui分割线');

  final String name;
  const PillarType(this.name);
}

enum RowType {
  heavenlyStem,
  earthlyBranch,
  tenGod,
  naYin,
  kongWang,
  xunShou,
  hiddenStems,
  hiddenStemsTenGod,
  hiddenStemsPrimary,
  hiddenStemsSecondary,
  hiddenStemsTertiary,
  hiddenStemsPrimaryGods,
  hiddenStemsSecondaryGods,
  hiddenStemsTertiaryGods,
  starYun,
  selfSiting,
}

enum BorderType { solid, dashed, dotted, none }

enum RowTextAlign { left, center, right }
