// lib/domain/entities/yuding_entry.dart

/// Represents a single entry from "御定大六壬" (Yu Ding Da Liu Ren),
/// providing interpretations for a specific divination outcome.
class YuDingEntry {
  /// The title of the entry, often describing the Day GanZhi, Ju number, and GanShangShen.
  /// Example: "甲子日第一局干上子"
  final String title;

  /// Main textual body of the interpretation.
  final List<String> raw; // 原文

  /// Explanation of the lesson/divination type (课义).
  final String meaning;

  /// General explanation or solution (解曰).
  final String explanation;

  /// Predictive judgment or assertion (断曰).
  final String perdiction;

  /// Miscellaneous divinations or specific topic interpretations (杂占).
  /// Example: `{"出行": "宜出行，见贵人", "求财": "难遂"}`
  final Map<String, String> otherDetails;

  /// References to classic texts or sources for this interpretation (经典).
  /// Example: `{"毕法赋": "云云...", "指要": "如此..."}`
  final Map<String, String> ancientsBookTextMapper;

  YuDingEntry({
    required this.title,
    required this.raw,
    required this.meaning,
    required this.explanation,
    required this.perdiction,
    required this.otherDetails,
    required this.ancientsBookTextMapper,
  });

  // Consider Equatable
}
