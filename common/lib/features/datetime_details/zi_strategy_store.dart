import 'package:common/features/datetime_details/calculation_strategy_config.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 运行期子时策略存储（开发阶段全局状态）
class ZiStrategyStore {
  static ZiShiStrategy current = CalculationStrategyConfig.defaultConfig.ziStrategy;

  static void set(ZiShiStrategy s) {
    current = s;
  }

  // SharedPreferences keys (kept in sync with settings card)
  static const String _spDefaultKey = 'calc_zi_strategy_default';

  /// Initialize from persisted default, if any
  static Future<void> initFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getString(_spDefaultKey);
      if (saved != null) {
        final parsed = _parse(saved);
        if (parsed != null) {
          current = parsed;
        }
      }
    } catch (_) {
      // Ignore failures; keep the in-memory default
    }
  }

  /// Map stored string (including legacy values) to enum
  static ZiShiStrategy? _parse(String? s) {
    switch (s) {
      case 'noDistinguishAt23':
        return ZiShiStrategy.noDistinguishAt23;
      case 'distinguishAt0FiveMouse':
        return ZiShiStrategy.distinguishAt0FiveMouse;
      case 'distinguishAt0Fixed':
        return ZiShiStrategy.distinguishAt0Fixed;
      case 'bandsStartAt0':
        return ZiShiStrategy.bandsStartAt0;
      // legacy values
      case 'startFrom23':
        return ZiShiStrategy.noDistinguishAt23;
      case 'startFrom0':
      case 'splitedZi':
        return ZiShiStrategy.distinguishAt0FiveMouse;
      default:
        return null;
    }
  }
}
