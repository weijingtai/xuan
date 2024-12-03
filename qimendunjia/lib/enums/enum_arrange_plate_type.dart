enum PlateType{
  ZHUAN_PAN("转盘"), // 转盘
  FEI_PAN("飞盘");

  final String name;
  const PlateType(this.name);
}

enum ArrangeType{
  CHAI_BU("拆补"),
  ZHI_RUN("置润"),
  MAO_SHAN("茅山"),
  YIN_PAN("阴盘"),
  MANUALLY("手动");

  final String name;
  const ArrangeType(this.name);

}