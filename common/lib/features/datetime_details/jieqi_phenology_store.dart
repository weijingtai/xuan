import 'package:shared_preferences/shared_preferences.dart';
import 'input_info_params.dart';

/// Runtime store for JieQi and Phenology strategies with persisted defaults
class JieQiPhenologyStore {
  /// Current JieQi type selection. Defaults to config default (stabilizing / 定气法).
  static JieQiType jieQiType = JieQiType.stabilizing;

  /// Phenology calculation base:
  /// - stabilizingBased: use 定气法节气交节时刻作为基准 + n*5 天
  /// - levelingBased: use 平气法节气交节时刻作为基准 + n*5 天
  static PhenologyStrategy phenologyStrategy = PhenologyStrategy.stabilizingBased;

  static const String _spJieQiDefaultKey = 'calc_jieqi_type_default';
  static const String _spPhenologyDefaultKey = 'calc_phenology_strategy_default';

  static Future<void> initFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final jq = sp.getString(_spJieQiDefaultKey);
      final ph = sp.getString(_spPhenologyDefaultKey);
      final parsedJq = _parseJieQi(jq);
      final parsedPh = _parsePhenology(ph);
      if (parsedJq != null) jieQiType = parsedJq;
      if (parsedPh != null) phenologyStrategy = parsedPh;
    } catch (_) {
      // ignore
    }
  }

  static Future<void> persistDefaults({JieQiType? jq, PhenologyStrategy? ph}) async {
    final sp = await SharedPreferences.getInstance();
    if (jq != null) await sp.setString(_spJieQiDefaultKey, _jieQiToString(jq));
    if (ph != null) await sp.setString(_spPhenologyDefaultKey, _phenologyToString(ph));
  }

  static String _jieQiToString(JieQiType t) => switch (t) {
        JieQiType.leveling => 'leveling',
        JieQiType.stabilizing => 'stabilizing',
      };
  static JieQiType? _parseJieQi(String? s) => switch (s) {
        'leveling' => JieQiType.leveling,
        'stabilizing' => JieQiType.stabilizing,
        _ => null,
      };

  static String _phenologyToString(PhenologyStrategy t) => switch (t) {
        PhenologyStrategy.stabilizingBased => 'stabilizingBased',
        PhenologyStrategy.levelingBased => 'levelingBased',
      };
  static PhenologyStrategy? _parsePhenology(String? s) => switch (s) {
        'stabilizingBased' => PhenologyStrategy.stabilizingBased,
        'levelingBased' => PhenologyStrategy.levelingBased,
        _ => null,
      };
}

/// 物候计算策略（相对于所选节气基准）
enum PhenologyStrategy {
  /// 基于定气法节气交节时刻，物候时刻 = 交节 + n*5 天
  stabilizingBased,
  /// 基于平气法节气交节时刻，物候时刻 = 交节 + n*5 天
  levelingBased,
}
