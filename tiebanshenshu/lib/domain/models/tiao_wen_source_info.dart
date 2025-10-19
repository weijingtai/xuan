/// 条文来源信息
///
/// 记录每个条文编号的计算来源和方法
library;

import '../../features/six_yao_gua/pure_six_yao_gua.dart';

/// 条文来源信息
class TiaoWenSourceInfo {
  /// 条文编号
  final int tiaoWenNumber;

  /// 来源卦象（可选）
  final Enum64Gua? sourceGua;

  /// 卦象索引（第几个卦，从1开始）
  final int? guaIndex;

  /// 基础数
  final int? baseNumber;

  /// 计算方法描述
  final String calculationMethod;

  /// 详细计算公式（可选）
  final String? calculationFormula;

  /// 附加信息（用于存储特定策略的额外信息）
  final Map<String, dynamic>? additionalInfo;

  const TiaoWenSourceInfo({
    required this.tiaoWenNumber,
    this.sourceGua,
    this.guaIndex,
    this.baseNumber,
    required this.calculationMethod,
    this.calculationFormula,
    this.additionalInfo,
  });

  /// 创建来自三基数的条文来源（八卦滚法）
  factory TiaoWenSourceInfo.fromThreeNumbers({
    required int tiaoWenNumber,
    required Enum64Gua sourceGua,
    required int guaIndex,
    required int a,
    required int b,
    required int c,
    required String formulaType,
  }) {
    String formula;
    switch (formulaType) {
      case 'a*100+b':
        formula = '$a×100+$b=$tiaoWenNumber';
        break;
      case 'a*100+c':
        formula = '$a×100+$c=$tiaoWenNumber';
        break;
      case 'b*100+a':
        formula = '$b×100+$a=$tiaoWenNumber';
        break;
      case 'b*100+c':
        formula = '$b×100+$c=$tiaoWenNumber';
        break;
      case 'c*100+a':
        formula = '$c×100+$a=$tiaoWenNumber';
        break;
      case 'c*100+b':
        formula = '$c×100+$b=$tiaoWenNumber';
        break;
      default:
        formula = formulaType;
    }

    return TiaoWenSourceInfo(
      tiaoWenNumber: tiaoWenNumber,
      sourceGua: sourceGua,
      guaIndex: guaIndex,
      calculationMethod: '三基数公式',
      calculationFormula: formula,
      additionalInfo: {'a': a, 'b': b, 'c': c, 'formulaType': formulaType},
    );
  }

  /// 创建来自秘数和先天数的条文来源（四门法）
  factory TiaoWenSourceInfo.fromSecretAndXiantian({
    required int tiaoWenNumber,
    required Enum64Gua sourceGua,
    required int guaIndex,
    required int secretNumber,
    required int xiantianNumber,
  }) {
    return TiaoWenSourceInfo(
      tiaoWenNumber: tiaoWenNumber,
      sourceGua: sourceGua,
      guaIndex: guaIndex,
      baseNumber: secretNumber,
      calculationMethod: '秘数+先天数',
      calculationFormula: '$secretNumber+$xiantianNumber=$tiaoWenNumber',
      additionalInfo: {
        'secretNumber': secretNumber,
        'xiantianNumber': xiantianNumber,
      },
    );
  }

  /// 创建【四门法】详细来源（秘数×常数−7 + 先天×47）
  factory TiaoWenSourceInfo.fromSiMenFa({
    required int tiaoWenNumber,
    required Enum64Gua secretGua,
    required int secretGuaIndex,
    required int secretNumber,
    required int xiantianNumber,
    required Enum64Gua xiantianGua,
    required int xiantianGuaIndex,
    required int secretConst,
  }) {
    final formula =
        '$xiantianNumber×47 + ($secretNumber×$secretConst − 7) = $tiaoWenNumber';

    return TiaoWenSourceInfo(
      tiaoWenNumber: tiaoWenNumber,
      sourceGua: secretGua,
      guaIndex: secretGuaIndex,
      baseNumber: secretNumber,
      calculationMethod: '秘数展开×常数−7 + 先天×47',
      calculationFormula: formula,
      additionalInfo: {
        'secretNumber': secretNumber,
        'xiantianNumber': xiantianNumber,
        'secretConst': secretConst,
        'xiantianFactor': 47,
        'secretGua': secretGua.name,
        'secretGuaIndex': secretGuaIndex,
        'xiantianGua': xiantianGua.name,
        'xiantianGuaIndex': xiantianGuaIndex,
      },
    );
  }

  /// 获取完整的来源描述
  String get fullDescription {
    final buffer = StringBuffer();

    if (guaIndex != null && sourceGua != null) {
      buffer.write('第$guaIndex卦(${sourceGua!.fullname}) ');
    }

    buffer.write(calculationMethod);

    if (calculationFormula != null) {
      buffer.write(': $calculationFormula');
    }

    return buffer.toString();
  }

  /// 获取简短描述
  String get shortDescription {
    if (guaIndex != null && sourceGua != null) {
      return '第$guaIndex卦 - $calculationMethod';
    }
    return calculationMethod;
  }

  @override
  String toString() {
    return 'TiaoWenSourceInfo(number: $tiaoWenNumber, ${fullDescription})';
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'tiaoWenNumber': tiaoWenNumber,
      'sourceGua': sourceGua?.name,
      'guaIndex': guaIndex,
      'baseNumber': baseNumber,
      'calculationMethod': calculationMethod,
      'calculationFormula': calculationFormula,
      'additionalInfo': additionalInfo,
    };
  }

  /// 从Map创建
  factory TiaoWenSourceInfo.fromMap(Map<String, dynamic> map) {
    return TiaoWenSourceInfo(
      tiaoWenNumber: map['tiaoWenNumber'] as int,
      sourceGua: map['sourceGua'] != null
          ? Enum64Gua.values.firstWhere((e) => e.name == map['sourceGua'])
          : null,
      guaIndex: map['guaIndex'] as int?,
      baseNumber: map['baseNumber'] as int?,
      calculationMethod: map['calculationMethod'] as String,
      calculationFormula: map['calculationFormula'] as String?,
      additionalInfo: map['additionalInfo'] != null
          ? Map<String, dynamic>.from(map['additionalInfo'] as Map)
          : null,
    );
  }
}
