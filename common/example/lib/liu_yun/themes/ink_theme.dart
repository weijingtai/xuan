import 'dart:ui';

class InkTheme {
  /// 纸纹主底色，用于整体卡片背景。
  static const paper = Color(0xFFF7F2E8);
  /// 纸纹高光，用于柔和的亮部叠加。
  static const paperHi = Color(0xFFFFFBF2);
  /// 柔和纸色，用于主体卡片面。
  static const paperSoft = Color(0xFFFDFaf5);
  /// 纸色替代，用于分层背景对比。
  static const paperAlt = Color(0xFFF6EFE3);
  /// 单元格纸底，用于日历/日柱格。
  static const paperCell = Color(0xFFFCFAF2);
  /// 表头纸底，用于年份/表头区域。
  static const paperHeader = Color(0xFFF7F4EF);
  /// 石色背景，用于整页背景底。
  static const paperStone = Color(0xFFF5F5F4);
  /// 低饱和纸色，用于未选中背景。
  static const paperMuted = Color(0xFFF2F2F2);
  /// 悬浮高亮纸色，用于 hover/选中底。
  static const paperHighlight = Color(0xFFF2EFE5);
  /// 通用浅底色，用于淡背景或渐变底。
  static const paperBackground = Color(0xFFFAFAF9);

  /// 主墨色，用于正文与主线条。
  static const ink = Color(0xFF2D2D2D);
  /// 深墨色，用于强对比文本。
  static const inkDeep = Color(0xFF1A1A1A);
  /// 浅墨色，用于暗色主题文字。
  static const inkSoft = Color(0xFFE5E5E5);
  /// 低对比墨色，用于辅助文字。
  static const inkMuted = Color(0xFF666666);
  /// 深边线墨色，用于暗色边框。
  static const inkBorderDark = Color(0xFF33302C);
  /// 深虚线墨色，用于暗背景虚线。
  static const inkDashDark = Color(0xFF57534E);
  /// 浅虚线墨色，用于浅背景虚线。
  static const inkDashLight = Color(0xFFD6D3D1);

  /// 印章主色，用于选中/重点强调。
  static const seal = Color(0xFFB23A2B);
  /// 朱砂色，用于强调标记与图形。
  static const cinnabar = Color(0xFFB22222);
  /// 朱砂替代，用于小型组件高亮。
  static const cinnabarAlt = Color(0xFFC0392B);
  /// 深朱砂色，用于表头/大字强调。
  static const cinnabarDeep = Color(0xFFB22D2A);

  /// 金色，用于主金属点缀。
  static const gold = Color(0xFFAA9460);
  /// 明亮金色，用于高光/重点强调。
  static const goldBright = Color(0xFFD4AF37);
  /// 金色线洗，用于描边与细线装饰。
  static const goldLine = Color.fromRGBO(170, 148, 96, 0.20);

  /// 主题红，用于月份/标题主色。
  static const primary = Color(0xFF9E2A2B);
  /// 主题亮红，用于暗色模式对比。
  static const primaryLight = Color(0xFFD64545);
  /// 绿色点缀，用于月柱分隔标记。
  static const accentGreen = Color(0xFF4A7C59);

  /// 细节灰，用于说明文字。
  static const textMuted = Color(0xFF8C8C8C);
  /// 浅边框色，用于浅底分割线。
  static const borderLight = Color(0xFFE3E0D8);
  /// 石色边框，用于卡片边界。
  static const borderStone = Color(0xFFD1CDC2);
  /// 中性灰，用于未选中标签。
  static const neutralGray = Color(0xFF9A9A9A);
  /// 背景灰，用于大面积背景区块。
  static const backgroundMuted = Color(0xFFE0E0E0);
  /// 策略蓝灰，用于时辰策略配色。
  static const strategyBlueGrey = Color(0xFF455A64);
  /// 策略绿色，用于时辰策略配色。
  static const strategyGreen = Color(0xFF2E7D32);

  /// 木元素色，用于五行背景色。
  static const elementWood = Color(0xFF4E7D58);
  /// 土元素色，用于五行背景色。
  static const elementEarth = Color(0xFFB89B4D);
  /// 金元素色，用于五行背景色。
  static const elementMetal = Color(0xFF7A7A7A);
  /// 水元素色，用于五行背景色。
  static const elementWater = Color(0xFF3E6D8C);

  /// 水印墨色，用于大字水印。
  static const watermarkInk = Color.fromRGBO(0, 0, 0, 0.06);

  static Color line([int a = 70]) => ink.withAlpha(a);
  static Color wash([int a = 18]) => ink.withAlpha(a);
  static Color washHi([int a = 10]) => ink.withAlpha(a);
  static Color sealWash([int a = 44]) => seal.withAlpha(a);
}
