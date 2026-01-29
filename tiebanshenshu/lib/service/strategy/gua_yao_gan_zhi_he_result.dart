/// GuaYaoGanZhiHe calculation result (for static method)
///
/// Used as the return type for the static method calculateFromGua64()
library;

import 'package:common/enums.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';

/// Result from GuaYaoGanZhiHe calculation
class GuaYaoGanZhiHeResult {
  /// Pure six yao gua
  final PureSixYaoGua pureSixYaoGua;

  /// 64 Gua
  final Enum64Gua gua64;

  /// Upper gua (outer gua)
  final Enum8Gua upperGua;

  /// Lower gua (inner gua)
  final Enum8Gua lowerGua;

  /// Six yao details
  final List<GuaYaoGanZhiHeYaoDetail> yaoDetails;

  /// Lower gua sum (yao 1+2+3)
  final int lowerGuaSum;

  /// Upper gua sum (yao 4+5+6)
  final int upperGuaSum;

  /// Formula string
  final String formula;

  /// TiaoWen number (base number)
  final int tiaoWenNumber;

  /// NaJia method used
  final GuaYaoGanZhiHeNaJiaMethod naJiaMethod;

  /// Description string
  final String description;

  const GuaYaoGanZhiHeResult({
    required this.pureSixYaoGua,
    required this.gua64,
    required this.upperGua,
    required this.lowerGua,
    required this.yaoDetails,
    required this.lowerGuaSum,
    required this.upperGuaSum,
    required this.formula,
    required this.tiaoWenNumber,
    required this.naJiaMethod,
    required this.description,
  });

  @override
  String toString() {
    return 'GuaYaoGanZhiHeResult('
        'gua64: ${gua64.name}, '
        'method: ${naJiaMethod.displayName}, '
        'tiaoWenNumber: $tiaoWenNumber, '
        'formula: $formula'
        ')';
  }

  /// Summary string
  String get summary =>
      '${naJiaMethod.displayName}: $formula = $tiaoWenNumber';

  /// Get all yao details as formatted string
  String get yaoDetailsSummary {
    final buffer = StringBuffer();
    for (final yao in yaoDetails) {
      buffer.writeln(yao.toString());
    }
    return buffer.toString();
  }
}
