/// 八卦加则基础数模型
///
/// 扩展自BaseNumberModel，添加八卦加则算法特定的计算过程信息
library;

import 'package:common/enums.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';

/// 八卦加则基础数模型
///
/// 用于保存八卦加则算法的计算结果和详细的计算过程
/// 每个模型代表一个柱的一种装卦方法的计算结果
class BaGuaJiaZeBaseNumberModel extends BaseNumberModel {
  /// 算法方法："爻序法" / "纳甲法"
  final String method;

  /// 来源柱："年柱" / "月柱" / "日柱" / "时柱"
  final String pillarName;

  /// 干支
  final JiaZi ganZhi;

  /// 六爻卦象（保存中间结果）
  final PureSixYaoGua guaData;

  /// 上卦
  final Enum8Gua upperGua;

  /// 下卦
  final Enum8Gua lowerGua;

  /// 上卦数（后天）
  final int upperGuaNumber;

  /// 下卦数（后天）
  final int lowerGuaNumber;

  /// 六爻地支总和
  final int yaoSum;

  /// 计算公式
  final String formula;

  const BaGuaJiaZeBaseNumberModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    required this.method,
    required this.pillarName,
    required this.ganZhi,
    required this.guaData,
    required this.upperGua,
    required this.lowerGua,
    required this.upperGuaNumber,
    required this.lowerGuaNumber,
    required this.yaoSum,
    required this.formula,
  });

  /// 创建八卦加则基础数模型的工厂方法
  ///
  /// [baseNumber] 基础数值
  /// [name] 基础数名称
  /// [description] 基础数描述
  /// [source] 基础数来源
  /// [method] 算法方法（爻序法/纳甲法）
  /// [pillarName] 来源柱名称
  /// [ganZhi] 干支
  /// [guaData] 六爻卦象数据
  /// [upperGua] 上卦
  /// [lowerGua] 下卦
  /// [upperGuaNumber] 上卦后天数
  /// [lowerGuaNumber] 下卦后天数
  /// [yaoSum] 六爻地支总和
  /// [formula] 计算公式
  factory BaGuaJiaZeBaseNumberModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required String method,
    required String pillarName,
    required JiaZi ganZhi,
    required PureSixYaoGua guaData,
    required Enum8Gua upperGua,
    required Enum8Gua lowerGua,
    required int upperGuaNumber,
    required int lowerGuaNumber,
    required int yaoSum,
    required String formula,
  }) {
    return BaGuaJiaZeBaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      method: method,
      pillarName: pillarName,
      ganZhi: ganZhi,
      guaData: guaData,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber,
      yaoSum: yaoSum,
      formula: formula,
    );
  }

  /// 获取方法显示文本
  String get methodDisplayText => method;

  /// 获取柱名显示文本
  String get pillarDisplayText => pillarName;

  /// 获取干支显示文本
  String get ganZhiDisplayText => ganZhi.name;

  /// 获取上卦显示文本
  String get upperGuaDisplayText => '${upperGua.name}($upperGuaNumber)';

  /// 获取下卦显示文本
  String get lowerGuaDisplayText => '${lowerGua.name}($lowerGuaNumber)';

  /// 获取六爻详情列表（用于UI展示）
  List<YaoDetailModel> get yaoDetails {
    final details = <YaoDetailModel>[];

    for (int i = 0; i < guaData.yaoList.length; i++) {
      final yao = guaData.yaoList[i];
      final positionLabel = PureSixYaoGua.getYaoPositionLabel(i);

      details.add(
        YaoDetailModel(
          position: i,
          positionLabel: positionLabel,
          yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
          diZhi: yao.naZhi?.name ?? '未配',
          number: yao.naZhi != null ? _getYaoDiZhiNumber(yao.naZhi!) : 0,
        ),
      );
    }

    return details;
  }

  /// 获取地支对应的数字
  int _getYaoDiZhiNumber(DiZhi diZhi) {
    // 这里使用constants中的yaoDiZhiNumberMapper
    // 为了避免循环依赖，这里简化处理
    // 实际使用时应该从constants中获取
    final mapper = {
      DiZhi.ZI: 30,
      DiZhi.CHOU: 30,
      DiZhi.YIN: 60,
      DiZhi.MAO: 60,
      DiZhi.CHEN: 90,
      DiZhi.SI: 90,
      DiZhi.WU: 120,
      DiZhi.WEI: 120,
      DiZhi.SHEN: 150,
      DiZhi.YOU: 150,
      DiZhi.XU: 180,
      DiZhi.HAI: 180,
    };
    return mapper[diZhi] ?? 0;
  }

  /// 复制并更新八卦加则基础数信息
  @override
  BaGuaJiaZeBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    String? method,
    String? pillarName,
    JiaZi? ganZhi,
    PureSixYaoGua? guaData,
    Enum8Gua? upperGua,
    Enum8Gua? lowerGua,
    int? upperGuaNumber,
    int? lowerGuaNumber,
    int? yaoSum,
    String? formula,
  }) {
    return BaGuaJiaZeBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      method: method ?? this.method,
      pillarName: pillarName ?? this.pillarName,
      ganZhi: ganZhi ?? this.ganZhi,
      guaData: guaData ?? this.guaData,
      upperGua: upperGua ?? this.upperGua,
      lowerGua: lowerGua ?? this.lowerGua,
      upperGuaNumber: upperGuaNumber ?? this.upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber ?? this.lowerGuaNumber,
      yaoSum: yaoSum ?? this.yaoSum,
      formula: formula ?? this.formula,
    );
  }

  /// 转换为Map用于调试和序列化
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'method': method,
      'pillarName': pillarName,
      'ganZhi': ganZhi.name,
      'upperGua': upperGua.name,
      'lowerGua': lowerGua.name,
      'upperGuaNumber': upperGuaNumber,
      'lowerGuaNumber': lowerGuaNumber,
      'yaoSum': yaoSum,
      'formula': formula,
      'yaoDetails': yaoDetails.map((d) => d.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'BaGuaJiaZeBaseNumberModel('
        'baseNumber: $baseNumber, '
        'pillarName: $pillarName, '
        'method: $method, '
        'ganZhi: ${ganZhi.name}, '
        'formula: $formula'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaGuaJiaZeBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.method == method &&
        other.pillarName == pillarName &&
        other.ganZhi == ganZhi;
  }

  @override
  int get hashCode {
    return baseNumber.hashCode ^
        method.hashCode ^
        pillarName.hashCode ^
        ganZhi.hashCode;
  }
}

/// 爻详情模型（用于UI展示）
class YaoDetailModel {
  /// 爻位（0-5）
  final int position;

  /// 爻位标签："初" / "二" / "三" / "四" / "五" / "上"
  final String positionLabel;

  /// 阴阳性："阳" / "阴"
  final String yinYang;

  /// 地支名称
  final String diZhi;

  /// 地支对应的数字
  final int number;

  const YaoDetailModel({
    required this.position,
    required this.positionLabel,
    required this.yinYang,
    required this.diZhi,
    required this.number,
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'positionLabel': positionLabel,
      'yinYang': yinYang,
      'diZhi': diZhi,
      'number': number,
    };
  }

  @override
  String toString() {
    return '$positionLabel爻($yinYang): $diZhi($number)';
  }
}
