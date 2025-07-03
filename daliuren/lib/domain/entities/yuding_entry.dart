// lib/domain/entities/yuding_entry.dart

/// Represents a single entry from "御定大六壬" (Yu Ding Da Liu Ren),
/// providing interpretations for a specific divination outcome.
class YuDingEntry {
  /// The title of the entry, often describing the Day GanZhi, Ju number, and GanShangShen.
  /// Example: "甲子日第一局干上子"
  final String title;

  /// Main textual body of the interpretation.
  final List<String> 原文;

  /// Explanation of the lesson/divination type (课义).
  final String 課義;

  /// General explanation or solution (解曰).
  final String 解曰;

  /// Predictive judgment or assertion (断曰).
  final String 斷曰;

  /// Miscellaneous divinations or specific topic interpretations (杂占).
  /// Example: `{"出行": "宜出行，见贵人", "求财": "难遂"}`
  final Map<String, String> 杂占;

  /// References to classic texts or sources for this interpretation (经典).
  /// Example: `{"毕法赋": "云云...", "指要": "如此..."}`
  final Map<String, String> 经典;

  YuDingEntry({
    required this.title,
    required this.原文,
    required this.課義,
    required this.解曰,
    required this.斷曰,
    required this.杂占,
    required this.经典,
  });

  // Consider Equatable
}
