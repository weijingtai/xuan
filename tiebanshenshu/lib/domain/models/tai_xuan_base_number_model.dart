/// 太玄取数法基础数模型
///
/// 扩展自BaseNumberModel，添加太玄取数法特定的计算过程信息
/// 支持两种纳甲方案：年干阴阳纳甲和传统内外卦纳甲
library;

import 'package:common/enums.dart';
import 'base_number_model.dart';

/// 太玄纳甲方法枚举
///
/// 定义两种太玄纳甲方案
enum TaiXuanNaJiaMethod {
  /// 年干阴阳纳甲：根据年干阴阳决定纳甲天干配置
  /// - 阳年：使用 yangGuaYaoTianGan
  /// - 阴年：使用 yinGuaYaoTianGan
  yearGanYinYang,

  /// 传统内外卦纳甲：根据当前卦的阴阳决定纳甲天干配置
  /// - 阳卦（乾震坎艮）：使用 outerGuaYaoTianGan
  /// - 阴卦（坤巽离兑）：使用 innerGuaYaoTianGan
  innerOuterGua,
}

/// 太玄纳甲方法扩展
extension TaiXuanNaJiaMethodExtension on TaiXuanNaJiaMethod {
  /// 获取中文显示名称
  String get displayName {
    switch (this) {
      case TaiXuanNaJiaMethod.yearGanYinYang:
        return '年干阴阳纳甲';
      case TaiXuanNaJiaMethod.innerOuterGua:
        return '传统内外卦纳甲';
    }
  }

  /// 获取简短标识
  String get shortName {
    switch (this) {
      case TaiXuanNaJiaMethod.yearGanYinYang:
        return '年干阴阳';
      case TaiXuanNaJiaMethod.innerOuterGua:
        return '内外卦';
    }
  }
}

/// 太玄爻详情模型
///
/// 用于保存每个爻的详细信息，包括纳甲天干地支、太玄数等
class TaiXuanYaoDetail {
  /// 爻位（0-5），0为初爻，5为上爻
  final int position;

  /// 爻位标签："初" / "二" / "三" / "四" / "五" / "上"
  final String positionLabel;

  /// 纳甲天干
  final TianGan tianGan;

  /// 纳甲地支
  final DiZhi diZhi;

  /// 天干太玄数
  final int taiXuanGanNumber;

  /// 地支太玄数
  final int taiXuanZhiNumber;

  /// 该爻总太玄数（天干+地支）
  final int taiXuanNumber;

  /// 阴阳性："阴" or "阳"
  final String yinYang;

  /// 是否被过滤（天干+地支的和为10）
  final bool isFiltered;

  const TaiXuanYaoDetail({
    required this.position,
    required this.positionLabel,
    required this.tianGan,
    required this.diZhi,
    required this.taiXuanGanNumber,
    required this.taiXuanZhiNumber,
    required this.taiXuanNumber,
    required this.yinYang,
    required this.isFiltered,
  });

  /// 转换为Map用于调试和序列化
  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'positionLabel': positionLabel,
      'tianGan': tianGan.name,
      'diZhi': diZhi.name,
      'taiXuanGanNumber': taiXuanGanNumber,
      'taiXuanZhiNumber': taiXuanZhiNumber,
      'taiXuanNumber': taiXuanNumber,
      'yinYang': yinYang,
      'isFiltered': isFiltered,
    };
  }

  @override
  String toString() {
    return '$positionLabel爻($yinYang): ${tianGan.name}${diZhi.name} = '
        '$taiXuanGanNumber+$taiXuanZhiNumber = $taiXuanNumber'
        '${isFiltered ? " (已过滤)" : ""}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaiXuanYaoDetail &&
        other.position == position &&
        other.tianGan == tianGan &&
        other.diZhi == diZhi;
  }

  @override
  int get hashCode {
    return position.hashCode ^ tianGan.hashCode ^ diZhi.hashCode;
  }
}

/// 太玄取数法基础数模型
///
/// 用于保存太玄取数法算法的计算结果和详细的计算过程
/// 每个模型代表一个柱的一种纳甲方案的计算结果
class TaiXuanBaseNumberModel extends BaseNumberModel {
  /// 来源柱："年柱" / "月柱" / "日柱" / "时柱"
  final String pillarName;

  /// 干支
  final JiaZi ganzhi;

  /// 上卦
  final Enum8Gua upperGua;

  /// 下卦
  final Enum8Gua lowerGua;

  /// 上卦后天数
  final int upperGuaNumber;

  /// 下卦后天数
  final int lowerGuaNumber;

  /// 纳甲方法
  final TaiXuanNaJiaMethod naJiaMethod;

  /// 上卦三爻太玄数总和（过滤和为10的爻后）
  final int upperGuaSum;

  /// 下卦三爻太玄数总和（过滤和为10的爻后）
  final int lowerGuaSum;

  /// 六爻详情列表（从下到上：初、二、三、四、五、上）
  final List<TaiXuanYaoDetail> yaoDetails;

  /// 计算公式字符串
  final String formula;

  const TaiXuanBaseNumberModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    required this.pillarName,
    required this.ganzhi,
    required this.upperGua,
    required this.lowerGua,
    required this.upperGuaNumber,
    required this.lowerGuaNumber,
    required this.naJiaMethod,
    required this.upperGuaSum,
    required this.lowerGuaSum,
    required this.yaoDetails,
    required this.formula,
  });

  /// 创建太玄基础数模型的工厂方法
  ///
  /// [baseNumber] 基础数值
  /// [name] 基础数名称
  /// [description] 基础数描述
  /// [source] 基础数来源
  /// [pillarName] 来源柱名称
  /// [ganzhi] 干支
  /// [upperGua] 上卦
  /// [lowerGua] 下卦
  /// [upperGuaNumber] 上卦后天数
  /// [lowerGuaNumber] 下卦后天数
  /// [naJiaMethod] 纳甲方法
  /// [upperGuaSum] 上卦总和
  /// [lowerGuaSum] 下卦总和
  /// [yaoDetails] 六爻详情
  /// [formula] 计算公式
  factory TaiXuanBaseNumberModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required String pillarName,
    required JiaZi ganzhi,
    required Enum8Gua upperGua,
    required Enum8Gua lowerGua,
    required int upperGuaNumber,
    required int lowerGuaNumber,
    required TaiXuanNaJiaMethod naJiaMethod,
    required int upperGuaSum,
    required int lowerGuaSum,
    required List<TaiXuanYaoDetail> yaoDetails,
    required String formula,
  }) {
    return TaiXuanBaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      pillarName: pillarName,
      ganzhi: ganzhi,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber,
      naJiaMethod: naJiaMethod,
      upperGuaSum: upperGuaSum,
      lowerGuaSum: lowerGuaSum,
      yaoDetails: yaoDetails,
      formula: formula,
    );
  }

  /// 获取纳甲方法显示文本
  String get naJiaMethodDisplayText => naJiaMethod.displayName;

  /// 获取纳甲方法简短标识
  String get naJiaMethodShortName => naJiaMethod.shortName;

  /// 获取柱名显示文本
  String get pillarDisplayText => pillarName;

  /// 获取干支显示文本
  String get ganzhiDisplayText => ganzhi.name;

  /// 获取上卦显示文本
  String get upperGuaDisplayText => '${upperGua.name}($upperGuaNumber)';

  /// 获取下卦显示文本
  String get lowerGuaDisplayText => '${lowerGua.name}($lowerGuaNumber)';

  /// 获取被过滤的爻列表
  List<TaiXuanYaoDetail> get filteredYaos {
    return yaoDetails.where((yao) => yao.isFiltered).toList();
  }

  /// 获取未被过滤的爻列表
  List<TaiXuanYaoDetail> get activeYaos {
    return yaoDetails.where((yao) => !yao.isFiltered).toList();
  }

  /// 复制并更新太玄基础数信息
  @override
  TaiXuanBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    String? pillarName,
    JiaZi? ganzhi,
    Enum8Gua? upperGua,
    Enum8Gua? lowerGua,
    int? upperGuaNumber,
    int? lowerGuaNumber,
    TaiXuanNaJiaMethod? naJiaMethod,
    int? upperGuaSum,
    int? lowerGuaSum,
    List<TaiXuanYaoDetail>? yaoDetails,
    String? formula,
  }) {
    return TaiXuanBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      pillarName: pillarName ?? this.pillarName,
      ganzhi: ganzhi ?? this.ganzhi,
      upperGua: upperGua ?? this.upperGua,
      lowerGua: lowerGua ?? this.lowerGua,
      upperGuaNumber: upperGuaNumber ?? this.upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber ?? this.lowerGuaNumber,
      naJiaMethod: naJiaMethod ?? this.naJiaMethod,
      upperGuaSum: upperGuaSum ?? this.upperGuaSum,
      lowerGuaSum: lowerGuaSum ?? this.lowerGuaSum,
      yaoDetails: yaoDetails ?? this.yaoDetails,
      formula: formula ?? this.formula,
    );
  }

  /// 转换为Map用于调试和序列化
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'pillarName': pillarName,
      'ganzhi': ganzhi.name,
      'upperGua': upperGua.name,
      'lowerGua': lowerGua.name,
      'upperGuaNumber': upperGuaNumber,
      'lowerGuaNumber': lowerGuaNumber,
      'naJiaMethod': naJiaMethod.name,
      'naJiaMethodDisplay': naJiaMethodDisplayText,
      'upperGuaSum': upperGuaSum,
      'lowerGuaSum': lowerGuaSum,
      'formula': formula,
      'yaoDetails': yaoDetails.map((d) => d.toMap()).toList(),
      'filteredYaoCount': filteredYaos.length,
      'activeYaoCount': activeYaos.length,
    };
  }

  @override
  String toString() {
    return 'TaiXuanBaseNumberModel('
        'baseNumber: $baseNumber, '
        'pillarName: $pillarName, '
        'naJiaMethod: ${naJiaMethod.name}, '
        'ganzhi: ${ganzhi.name}, '
        'formula: $formula'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaiXuanBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.pillarName == pillarName &&
        other.naJiaMethod == naJiaMethod &&
        other.ganzhi == ganzhi;
  }

  @override
  int get hashCode {
    return baseNumber.hashCode ^
        pillarName.hashCode ^
        naJiaMethod.hashCode ^
        ganzhi.hashCode;
  }
}
