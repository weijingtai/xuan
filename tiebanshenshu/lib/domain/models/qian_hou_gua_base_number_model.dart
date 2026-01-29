/// 前后卦取数法基础数模型
///
/// 用于保存前后卦取数法的完整计算过程和结果
///
/// 算法步骤：
/// - 步骤1：天地卦生成
/// - 步骤2：先后天卦生成
/// - 步骤3：互卦计算
/// - 步骤4：前卦取数（使用先天卦）
/// - 步骤5：后卦取数（使用后天卦）
/// - 步骤6：条文扩展
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';

/// 前后卦取数法基础数模型
///
/// 前后卦取数法算法说明：
/// - **前卦取数**：使用先天卦，千位=上卦后天数，百位=下卦后天数
/// - **后卦取数**：使用后天卦（与先天卦相同，不涉及爻变），十位=上卦后天数，个位=下卦后天数
/// - **基础数**：前卦数(千百位) + 后卦数(十位个位) = 四位条文数
/// - **条文扩展**：
///   - 前卦：递增96四次 [0, 96, 192, 288, 384]
///   - 后卦：递减96四次 [0, -96, -192, -288, -384]
///
/// 示例：
/// - 先天卦：震坤，震后天数=4，坤后天数=2 → 前卦数=42（千百位）
/// - 后天卦：震坤（与先天卦相同），震后天数=4，坤后天数=2 → 后卦数=42（十位个位）
/// - 基础数：4242
class QianHouGuaBaseNumberModel extends BaseNumberModel {
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
  final String tianGua;

  /// 地卦名称
  /// 由地数配卦得到
  final String diGua;

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

  /// 后天卦名称（双经卦，如"震坤"）
  /// 注意：在前后卦取数法中，后天卦与先天卦相同（不涉及爻变）
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
  final Enum64Gua? xiantianGuaHu;

  /// 后天卦的互卦
  /// 由2,3,4爻（上互）和3,4,5爻（下互）组成
  final Enum64Gua? houtianGuaHu;

  // ========== 步骤4: 前卦取数 (4个字段) ==========

  /// 前卦名称（等于先天卦）
  final Enum64Gua qianGuaName;

  /// 前卦上卦后天数（用作千位）
  final int qianGuaUpperNumber;

  /// 前卦下卦后天数（用作百位）
  final int qianGuaLowerNumber;

  /// 前卦基础数（千位+百位）
  /// 计算公式：qianGuaUpperNumber * 10 + qianGuaLowerNumber
  /// 示例：震坤 → 4*10 + 2 = 42
  final int qianGuaBaseNumber;

  // ========== 步骤5: 后卦取数 (4个字段) ==========

  /// 后卦名称（等于先天卦，不涉及爻变）
  final Enum64Gua houGuaName;

  /// 后卦上卦后天数（用作十位）
  final int houGuaUpperNumber;

  /// 后卦下卦后天数（用作个位）
  final int houGuaLowerNumber;

  /// 后卦基础数（十位+个位）
  /// 计算公式：houGuaUpperNumber * 10 + houGuaLowerNumber
  /// 示例：震坤 → 4*10 + 2 = 42
  final int houGuaBaseNumber;

  // ========== 步骤6: 条文扩展 (4个字段) ==========

  /// 前卦条文编号列表
  /// 递增96四次：[baseNumber, baseNumber+96, baseNumber+192, baseNumber+288, baseNumber+384]
  final List<int> qianGuaTiaoWenNumbers;

  /// 后卦条文编号列表
  /// 递减96四次：[baseNumber, baseNumber-96, baseNumber-192, baseNumber-288, baseNumber-384]
  final List<int> houGuaTiaoWenNumbers;

  /// 前卦条文计算公式
  /// 示例："前卦基础数42 + [0, 96, 192, 288, 384]"
  final String qianGuaCalculationFormula;

  /// 后卦条文计算公式
  /// 示例："后卦基础数42 + [0, -96, -192, -288, -384]"
  final String houGuaCalculationFormula;

  /// 构造函数
  const QianHouGuaBaseNumberModel({
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
    // 步骤4: 前卦取数
    required this.qianGuaName,
    required this.qianGuaUpperNumber,
    required this.qianGuaLowerNumber,
    required this.qianGuaBaseNumber,
    // 步骤5: 后卦取数
    required this.houGuaName,
    required this.houGuaUpperNumber,
    required this.houGuaLowerNumber,
    required this.houGuaBaseNumber,
    // 步骤6: 条文扩展
    required this.qianGuaTiaoWenNumbers,
    required this.houGuaTiaoWenNumbers,
    required this.qianGuaCalculationFormula,
    required this.houGuaCalculationFormula,
  });

  // ========== 便捷getter方法 ==========

  /// 获取四柱显示文本
  String get eightCharsDisplayText => eightChars.toString();

  /// 获取年柱显示文本
  String get yearZhuDisplayText => eightChars.year.ganZhiStr;

  /// 获取月柱显示文本
  String get monthZhuDisplayText => eightChars.month.ganZhiStr;

  /// 获取日柱显示文本
  String get dayZhuDisplayText => eightChars.day.ganZhiStr;

  /// 获取时柱显示文本
  String get timeZhuDisplayText => eightChars.time.ganZhiStr;

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

  /// 获取前卦取数说明
  String get qianGuaDescription =>
      '前卦：$qianGuaName → 千位=$qianGuaUpperNumber，百位=$qianGuaLowerNumber → 基础数=$qianGuaBaseNumber';

  /// 获取后卦取数说明
  String get houGuaDescription =>
      '后卦：$houGuaName → 十位=$houGuaUpperNumber，个位=$houGuaLowerNumber → 基础数=$houGuaBaseNumber';

  /// 获取完整基础数（四位数）
  int get fullBaseNumber => qianGuaBaseNumber * 100 + houGuaBaseNumber;

  // ========== 复制方法 ==========

  /// 复制并更新模型
  @override
  QianHouGuaBaseNumberModel copyWith({
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
    String? tianGua,
    String? diGua,
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
    Enum64Gua? qianGuaName,
    int? qianGuaUpperNumber,
    int? qianGuaLowerNumber,
    int? qianGuaBaseNumber,
    Enum64Gua? houGuaName,
    int? houGuaUpperNumber,
    int? houGuaLowerNumber,
    int? houGuaBaseNumber,
    List<int>? qianGuaTiaoWenNumbers,
    List<int>? houGuaTiaoWenNumbers,
    String? qianGuaCalculationFormula,
    String? houGuaCalculationFormula,
  }) {
    return QianHouGuaBaseNumberModel(
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
      qianGuaName: qianGuaName ?? this.qianGuaName,
      qianGuaUpperNumber: qianGuaUpperNumber ?? this.qianGuaUpperNumber,
      qianGuaLowerNumber: qianGuaLowerNumber ?? this.qianGuaLowerNumber,
      qianGuaBaseNumber: qianGuaBaseNumber ?? this.qianGuaBaseNumber,
      houGuaName: houGuaName ?? this.houGuaName,
      houGuaUpperNumber: houGuaUpperNumber ?? this.houGuaUpperNumber,
      houGuaLowerNumber: houGuaLowerNumber ?? this.houGuaLowerNumber,
      houGuaBaseNumber: houGuaBaseNumber ?? this.houGuaBaseNumber,
      qianGuaTiaoWenNumbers:
          qianGuaTiaoWenNumbers ?? this.qianGuaTiaoWenNumbers,
      houGuaTiaoWenNumbers: houGuaTiaoWenNumbers ?? this.houGuaTiaoWenNumbers,
      qianGuaCalculationFormula:
          qianGuaCalculationFormula ?? this.qianGuaCalculationFormula,
      houGuaCalculationFormula:
          houGuaCalculationFormula ?? this.houGuaCalculationFormula,
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
      // 步骤4: 前卦取数
      'qianGuaName': qianGuaName,
      'qianGuaUpperNumber': qianGuaUpperNumber,
      'qianGuaLowerNumber': qianGuaLowerNumber,
      'qianGuaBaseNumber': qianGuaBaseNumber,
      'qianGuaDescription': qianGuaDescription,
      // 步骤5: 后卦取数
      'houGuaName': houGuaName,
      'houGuaUpperNumber': houGuaUpperNumber,
      'houGuaLowerNumber': houGuaLowerNumber,
      'houGuaBaseNumber': houGuaBaseNumber,
      'houGuaDescription': houGuaDescription,
      // 步骤6: 条文扩展
      'qianGuaTiaoWenNumbers': qianGuaTiaoWenNumbers,
      'houGuaTiaoWenNumbers': houGuaTiaoWenNumbers,
      'qianGuaCalculationFormula': qianGuaCalculationFormula,
      'houGuaCalculationFormula': houGuaCalculationFormula,
      // 便捷信息
      'paramsSummary': paramsSummary,
      'fullBaseNumber': fullBaseNumber,
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'QianHouGuaBaseNumberModel('
        'name: $name, '
        'qianGua: $qianGuaName, '
        'houGua: $houGuaName, '
        'qianGuaBaseNumber: $qianGuaBaseNumber, '
        'houGuaBaseNumber: $houGuaBaseNumber, '
        'fullBaseNumber: $fullBaseNumber'
        ')';
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QianHouGuaBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.qianGuaName == qianGuaName &&
        other.houGuaName == houGuaName;
  }

  /// 哈希码
  @override
  int get hashCode {
    return baseNumber.hashCode ^
        name.hashCode ^
        qianGuaName.hashCode ^
        houGuaName.hashCode;
  }
}
