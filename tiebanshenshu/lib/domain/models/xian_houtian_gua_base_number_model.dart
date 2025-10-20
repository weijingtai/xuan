/// 先后天八卦基础数模型
///
/// 用于保存先后天八卦相关算法的完整计算过程和结果
/// 包含以下算法步骤：
/// - 步骤1：天地卦生成
/// - 步骤2：先后天卦生成
/// - 步骤3：互卦计算
/// - 步骤4：基础数计算
/// - 步骤5：条文扩展
library;

import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';

/// 先后天八卦基础数模型
///
/// 这是一个共享数据模型，用于多个先后天八卦相关算法：
/// - 算法1：先后天八卦加则法
/// - 算法2：先后天卦六爻干支和数法
/// - 其他基于先后天卦的算法
///
/// 包含完整的中间计算过程，便于调试和追踪
class XianHoutianGuaBaseNumberModel extends BaseNumberModel {
  // ========== 输入参数 (4个字段) ==========

  /// 四柱信息
  final EightChars eightChars;

  /// 性别："男" / "女"
  final Gender gender;

  /// 三元："上" / "中" / "下"
  final YuanYunOrder threeYuan;

  /// 出生节气后："夏至" / "冬至"
  final TwentyFourJieQi birthAfterZhi;

  // ========== 步骤1: 天地卦生成 (9个字段) ==========

  /// 四柱天干数列表
  /// 示例：[2, 6, 7, 2] (癸甲丁癸 → 癸=2, 甲=6, 丁=7, 癸=2)
  final List<int> ganNumList;

  /// 四柱地支数列表（每个地支两个数）
  /// 示例：[[7,2], [1,6], [9,4], [3,8]] (巳子酉卯)
  final List<List<int>> zhiNumList;

  /// 奇数总和（天干奇数 + 地支奇数）
  /// 用于计算天数
  final int oddNumTotal;

  /// 偶数总和（天干偶数 + 地支偶数）
  /// 用于计算地数
  final int evenNumTotal;

  /// 天数（奇数总和 模25）
  /// 特殊处理：当=25时为5
  final int tianGuaNum;

  /// 地数（偶数总和 模30）
  /// 特殊处理：当=30时为3
  final int diGuaNum;

  /// 天卦名称
  /// 由天数配卦得到
  final Enum8Gua tianGua;

  /// 地卦名称
  /// 由地数配卦得到
  final Enum8Gua diGua;

  /// 是否使用了三元五宫映射
  /// 当天数或地数为5时，需要查询三元五宫映射表
  final bool usedThreeYuanWuGong;

  // ========== 步骤2: 先后天卦生成 (9个字段) ==========

  /// 年份阴阳："阳" / "阴"
  /// 根据年干判断
  final YinYang yearYinYang;

  /// 上卦名称
  /// 根据年份阴阳和性别决定是天卦还是地卦
  final Enum8Gua upperGua;

  /// 下卦名称
  /// 根据年份阴阳和性别决定是天卦还是地卦
  final Enum8Gua lowerGua;

  /// 先天卦名称（双经卦，如"震坤"）
  final Enum64Gua xiantianGua;

  /// 后天卦名称（双经卦，如"坎震"）
  /// 注意：不同算法对"后天卦"的定义不同
  /// - 在先后天八卦加则法中，后天卦通常指先天卦本身（不涉及爻变）
  /// - 在元堂卦算法中，后天卦指元堂爻爻变后上下卦互换的结果
  /// 此处的houtianGua字段留给具体算法自行定义和使用
  final Enum64Gua houtianGua;

  /// 先天卦上卦后天数
  final int xiantianUpperGuaNumber;

  /// 先天卦下卦后天数
  final int xiantianLowerGuaNumber;

  /// 后天卦上卦后天数
  final int houtianUpperGuaNumber;

  /// 后天卦下卦后天数
  final int houtianLowerGuaNumber;

  // ========== 步骤3: 互卦计算 (2个字段) ==========

  /// 先天卦的互卦
  /// 由2,3,4爻（上互）和3,4,5爻（下互）组成
  final Enum64Gua xiantianGuaHu;

  /// 后天卦的互卦
  /// 由2,3,4爻（上互）和3,4,5爻（下互）组成
  final Enum64Gua houtianGuaHu;

  // ========== 步骤4: 基础数 (2个字段) ==========

  /// 先天卦基础数
  /// 不同算法有不同计算方法：
  /// - 加则法：使用加则计算
  /// - 六爻干支和数法：使用六爻纳甲太玄数之和
  final int xiantianBaseNumber;

  /// 后天卦基础数
  /// 不同算法有不同计算方法
  final int houtianBaseNumber;

  // ========== 步骤5: 条文扩展 (4个字段) ==========

  /// 先天卦条文编号列表
  /// 通过条文计算配置扩展得到
  final List<int> xiantianTiaoWenNumbers;

  /// 后天卦条文编号列表
  /// 通过条文计算配置扩展得到
  final List<int> houtianTiaoWenNumbers;

  /// 先天卦条文计算公式
  /// 示例："先天卦基础数3387 + [0, 96, 192, 288, 384]"
  final String xiantianCalculationFormula;

  /// 后天卦条文计算公式
  /// 示例："后天卦基础数2477 + [0, -96, -192, -288, -384]"
  final String houtianCalculationFormula;

  /// 构造函数
  const XianHoutianGuaBaseNumberModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    // 输入参数
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    // 步骤1: 天地卦
    required this.ganNumList,
    required this.zhiNumList,
    required this.oddNumTotal,
    required this.evenNumTotal,
    required this.tianGuaNum,
    required this.diGuaNum,
    required this.tianGua,
    required this.diGua,
    required this.usedThreeYuanWuGong,
    // 步骤2: 先后天卦
    required this.yearYinYang,
    required this.upperGua,
    required this.lowerGua,
    required this.xiantianGua,
    required this.houtianGua,
    required this.xiantianUpperGuaNumber,
    required this.xiantianLowerGuaNumber,
    required this.houtianUpperGuaNumber,
    required this.houtianLowerGuaNumber,
    // 步骤3: 互卦
    required this.xiantianGuaHu,
    required this.houtianGuaHu,
    // 步骤4: 基础数
    required this.xiantianBaseNumber,
    required this.houtianBaseNumber,
    // 步骤5: 条文扩展
    required this.xiantianTiaoWenNumbers,
    required this.houtianTiaoWenNumbers,
    required this.xiantianCalculationFormula,
    required this.houtianCalculationFormula,
  });

  // ========== 便捷getter方法 ==========

  /// 获取四柱显示文本
  String get eightCharsDisplayText => eightChars.toString();

  /// 获取年柱显示文本
  String get yearZhuDisplayText => eightChars.year.name;

  /// 获取月柱显示文本
  String get monthZhuDisplayText => eightChars.month.name;

  /// 获取日柱显示文本
  String get dayZhuDisplayText => eightChars.day.name;

  /// 获取时柱显示文本
  String get timeZhuDisplayText => eightChars.time.name;

  /// 获取上卦显示文本（带后天数）
  String get upperGuaDisplayText => '$upperGua($xiantianUpperGuaNumber)';

  /// 获取下卦显示文本（带后天数）
  String get lowerGuaDisplayText => '$lowerGua($xiantianLowerGuaNumber)';

  /// 获取天地卦计算公式
  String get tianDiGuaFormula =>
      '奇数和$oddNumTotal % 25 = $tianGuaNum → $tianGua, '
      '偶数和$evenNumTotal % 30 = $diGuaNum → $diGua';

  /// 获取先后天卦规则说明
  String get xianHoutianGuaRule {
    if (yearYinYang == "阳") {
      if (gender == "男") {
        return "阳年男性：天卦在上，地卦在下";
      } else {
        return "阳年女性：地卦在上，天卦在下";
      }
    } else {
      if (gender == "女") {
        return "阴年女性：天卦在上，地卦在下";
      } else {
        return "阴年男性：地卦在上，天卦在下";
      }
    }
  }

  /// 获取三元显示文本
  String get threeYuanDisplayText => '$threeYuan元';

  /// 获取参数摘要
  String get paramsSummary =>
      '$eightCharsDisplayText, $gender, $threeYuanDisplayText, $birthAfterZhi';

  // ========== 复制方法 ==========

  /// 复制并更新模型
  @override
  XianHoutianGuaBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    EightChars? eightChars,
    Gender? gender,
    YuanYunOrder? threeYuan,
    TwentyFourJieQi? birthAfterZhi,
    List<int>? ganNumList,
    List<List<int>>? zhiNumList,
    int? oddNumTotal,
    int? evenNumTotal,
    int? tianGuaNum,
    int? diGuaNum,
    Enum8Gua? tianGua,
    Enum8Gua? diGua,
    bool? usedThreeYuanWuGong,
    YinYang? yearYinYang,
    Enum8Gua? upperGua,
    Enum8Gua? lowerGua,
    Enum64Gua? xiantianGua,
    Enum64Gua? houtianGua,
    int? xiantianUpperGuaNumber,
    int? xiantianLowerGuaNumber,
    int? houtianUpperGuaNumber,
    int? houtianLowerGuaNumber,
    Enum64Gua? xiantianGuaHu,
    Enum64Gua? houtianGuaHu,
    int? xiantianBaseNumber,
    int? houtianBaseNumber,
    List<int>? xiantianTiaoWenNumbers,
    List<int>? houtianTiaoWenNumbers,
    String? xiantianCalculationFormula,
    String? houtianCalculationFormula,
  }) {
    return XianHoutianGuaBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      eightChars: eightChars ?? this.eightChars,
      gender: gender ?? this.gender,
      threeYuan: threeYuan ?? this.threeYuan,
      birthAfterZhi: birthAfterZhi ?? this.birthAfterZhi,
      ganNumList: ganNumList ?? this.ganNumList,
      zhiNumList: zhiNumList ?? this.zhiNumList,
      oddNumTotal: oddNumTotal ?? this.oddNumTotal,
      evenNumTotal: evenNumTotal ?? this.evenNumTotal,
      tianGuaNum: tianGuaNum ?? this.tianGuaNum,
      diGuaNum: diGuaNum ?? this.diGuaNum,
      tianGua: tianGua ?? this.tianGua,
      diGua: diGua ?? this.diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong ?? this.usedThreeYuanWuGong,
      yearYinYang: yearYinYang ?? this.yearYinYang,
      upperGua: upperGua ?? this.upperGua,
      lowerGua: lowerGua ?? this.lowerGua,
      xiantianGua: xiantianGua ?? this.xiantianGua,
      houtianGua: houtianGua ?? this.houtianGua,
      xiantianUpperGuaNumber:
          xiantianUpperGuaNumber ?? this.xiantianUpperGuaNumber,
      xiantianLowerGuaNumber:
          xiantianLowerGuaNumber ?? this.xiantianLowerGuaNumber,
      houtianUpperGuaNumber:
          houtianUpperGuaNumber ?? this.houtianUpperGuaNumber,
      houtianLowerGuaNumber:
          houtianLowerGuaNumber ?? this.houtianLowerGuaNumber,
      xiantianGuaHu: xiantianGuaHu ?? this.xiantianGuaHu,
      houtianGuaHu: houtianGuaHu ?? this.houtianGuaHu,
      xiantianBaseNumber: xiantianBaseNumber ?? this.xiantianBaseNumber,
      houtianBaseNumber: houtianBaseNumber ?? this.houtianBaseNumber,
      xiantianTiaoWenNumbers:
          xiantianTiaoWenNumbers ?? this.xiantianTiaoWenNumbers,
      houtianTiaoWenNumbers:
          houtianTiaoWenNumbers ?? this.houtianTiaoWenNumbers,
      xiantianCalculationFormula:
          xiantianCalculationFormula ?? this.xiantianCalculationFormula,
      houtianCalculationFormula:
          houtianCalculationFormula ?? this.houtianCalculationFormula,
    );
  }

  // ========== 序列化方法 ==========

  /// 转换为Map用于调试和序列化
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      // 输入参数
      'eightChars': eightChars.toString(),
      'gender': gender,
      'threeYuan': threeYuan,
      'birthAfterZhi': birthAfterZhi,
      // 步骤1: 天地卦
      'ganNumList': ganNumList,
      'zhiNumList': zhiNumList,
      'oddNumTotal': oddNumTotal,
      'evenNumTotal': evenNumTotal,
      'tianGuaNum': tianGuaNum,
      'diGuaNum': diGuaNum,
      'tianGua': tianGua,
      'diGua': diGua,
      'usedThreeYuanWuGong': usedThreeYuanWuGong,
      'tianDiGuaFormula': tianDiGuaFormula,
      // 步骤2: 先后天卦
      'yearYinYang': yearYinYang,
      'upperGua': upperGua,
      'lowerGua': lowerGua,
      'xiantianGua': xiantianGua,
      'houtianGua': houtianGua,
      'xiantianUpperGuaNumber': xiantianUpperGuaNumber,
      'xiantianLowerGuaNumber': xiantianLowerGuaNumber,
      'houtianUpperGuaNumber': houtianUpperGuaNumber,
      'houtianLowerGuaNumber': houtianLowerGuaNumber,
      'xianHoutianGuaRule': xianHoutianGuaRule,
      // 步骤3: 互卦
      'xiantianGuaHu': xiantianGuaHu,
      'houtianGuaHu': houtianGuaHu,
      // 步骤4: 基础数
      'xiantianBaseNumber': xiantianBaseNumber,
      'houtianBaseNumber': houtianBaseNumber,
      // 步骤5: 条文扩展
      'xiantianTiaoWenNumbers': xiantianTiaoWenNumbers,
      'houtianTiaoWenNumbers': houtianTiaoWenNumbers,
      'xiantianCalculationFormula': xiantianCalculationFormula,
      'houtianCalculationFormula': houtianCalculationFormula,
      // 便捷信息
      'paramsSummary': paramsSummary,
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'XianHoutianGuaBaseNumberModel('
        'name: $name, '
        'xiantianGua: $xiantianGua, '
        'houtianGua: $houtianGua, '
        'xiantianBaseNumber: $xiantianBaseNumber, '
        'houtianBaseNumber: $houtianBaseNumber'
        ')';
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is XianHoutianGuaBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.xiantianGua == xiantianGua &&
        other.houtianGua == houtianGua;
  }

  /// 哈希码
  @override
  int get hashCode {
    return baseNumber.hashCode ^
        name.hashCode ^
        xiantianGua.hashCode ^
        houtianGua.hashCode;
  }
}
