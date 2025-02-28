enum EnumTianGuanHuaYao {
  Lu("禄"),
  An("暗"),
  Fu("福"),
  Hao("耗"),
  YinBi("荫"),
  Gui("贵"),
  Xing("刑"),
  Yin("印"),
  Qiu("囚"),
  Quan("权");

  final String name;
  const EnumTianGuanHuaYao(this.name);

  List<EnumTianGuanHuaYao> get originalSeq =>
      [Lu, An, Fu, Hao, YinBi, Gui, Xing, Yin, Qiu, Quan];
}
