import 'package:shared_preferences/shared_preferences.dart';

/// 交节方案精度（用于节气与物候交接判定）
enum JieQiEntryPrecision {
  shichen, // 按“时辰”（2小时一段，受子时日界影响）
  hour,    // 按小时
  minute,  // 按分钟（推荐）
  second,  // 按秒（最严格）
}

class JieQiEntryStrategyStore {
  static const String _spKey = 'calc_jieqi_entry_precision_default';

  /// 默认推荐使用“分钟”
  static JieQiEntryPrecision current = JieQiEntryPrecision.minute;

  static Future<void> initFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(_spKey);
      final p = _parse(s);
      if (p != null) current = p;
    } catch (_) {}
  }

  static Future<void> persistDefault(JieQiEntryPrecision p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKey, _toString(p));
  }

  static String _toString(JieQiEntryPrecision p) => switch (p) {
        JieQiEntryPrecision.shichen => 'shichen',
        JieQiEntryPrecision.hour => 'hour',
        JieQiEntryPrecision.minute => 'minute',
        JieQiEntryPrecision.second => 'second',
      };
  static JieQiEntryPrecision? _parse(String? s) => switch (s) {
        'shichen' => JieQiEntryPrecision.shichen,
        'hour' => JieQiEntryPrecision.hour,
        'minute' => JieQiEntryPrecision.minute,
        'second' => JieQiEntryPrecision.second,
        // 兼容旧值
        'minuteSecond' => JieQiEntryPrecision.minute,
        _ => null,
      };
}
