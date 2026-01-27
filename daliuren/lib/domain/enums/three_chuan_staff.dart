/// 涉害法的判断策略
enum SheHaiStrategy {
  /// 策略一：深浅法 (涉害归本家法)
  COMPREHENSIVE("深浅"),

  /// 策略二：孟仲法 (孟仲季直取法)
  MENG_PRIORITY("孟仲"),

  /// 策略三：两法参合 (孟仲为纲，深浅为目)
  COMBINED_APPROACH("两法参合");

  final String name;
  const SheHaiStrategy(this.name);
}

/// 贼克类型枚举 (用于 _ProcessedFourClassItem.zeiKeType)
enum ZeiKeType { ZEI, KE, NONE }
