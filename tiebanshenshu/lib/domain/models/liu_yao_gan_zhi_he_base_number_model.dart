/// 先后天卦六爻干支和数法基础数模型
///
/// 用于保存先后天卦六爻干支和数法的完整计算过程和结果
/// 包含以下算法步骤：
/// - 步骤1：天地卦生成
/// - 步骤2：先后天卦生成
/// - 步骤3：先天卦六爻纳甲配置
/// - 步骤4：先天卦干支和数计算
/// - 步骤5：后天卦六爻纳甲配置
/// - 步骤6：后天卦干支和数计算
/// - 步骤7：条文扩展
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';

/// 先后天卦六爻干支和数法基础数模型
///
/// 这个模型专门用于"先后天卦六爻干支和数法"算法
/// 包含完整的中间计算过程，包括六爻纳甲装配和干支太玄数之和计算
class LiuYaoGanZhiHeBaseNumberModel extends BaseNumberModel {
  // ========== 输入参数 (4个字段) ==========

  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
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
  /// 在本算法中，后天卦与先天卦可能相同或不同，取决于算法实现
  final Enum64Gua houtianGua;

  /// 先天卦上卦后天数
  final int xiantianUpperGuaNumber;

  /// 先天卦下卦后天数
  final int xiantianLowerGuaNumber;

  /// 后天卦上卦后天数
  final int houtianUpperGuaNumber;

  /// 后天卦下卦后天数
  final int houtianLowerGuaNumber;

  // ========== 步骤3-4: 先天卦六爻纳甲字段 (6个字段) ==========

  /// 先天卦六爻天干列表（从初爻到上爻）
  /// 示例：["甲", "甲", "甲", "壬", "壬", "壬"] (乾卦)
  final List<String> xiantianYaoTianGanList;

  /// 先天卦六爻地支列表（从初爻到上爻）
  /// 示例：["子", "寅", "辰", "午", "申", "戌"] (乾卦)
  final List<String> xiantianYaoDiZhiList;

  /// 先天卦六爻干支和数列表（从初爻到上爻）
  /// 每爻的和数 = 天干太玄数 + 地支太玄数（如果和==10则为0）
  /// 示例：[18, 16, 14, 15, 15, 14]
  final List<int> xiantianYaoSumList;

  /// 先天卦上三爻和数（千百位）
  /// 上三爻指的是四、五、上爻（索引3-5）
  final int xiantianUpperSum;

  /// 先天卦下三爻和数（十位个位）
  /// 下三爻指的是初、二、三爻（索引0-2）
  final int xiantianLowerSum;

  /// 先天卦基础数（四位数）
  /// = xiantianUpperSum * 100 + xiantianLowerSum
  final int xiantianBaseNumber;

  // ========== 步骤5-6: 后天卦六爻纳甲字段 (6个字段) ==========

  /// 后天卦六爻天干列表（从初爻到上爻）
  final List<String> houtianYaoTianGanList;

  /// 后天卦六爻地支列表（从初爻到上爻）
  final List<String> houtianYaoDiZhiList;

  /// 后天卦六爻干支和数列表（从初爻到上爻）
  final List<int> houtianYaoSumList;

  /// 后天卦上三爻和数（千百位）
  final int houtianUpperSum;

  /// 后天卦下三爻和数（十位个位）
  final int houtianLowerSum;

  /// 后天卦基础数（四位数）
  /// = houtianUpperSum * 100 + houtianLowerSum
  final int houtianBaseNumber;

  /// 构造函数
  const LiuYaoGanZhiHeBaseNumberModel({
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
    // 步骤3-4: 先天卦六爻纳甲
    required this.xiantianYaoTianGanList,
    required this.xiantianYaoDiZhiList,
    required this.xiantianYaoSumList,
    required this.xiantianUpperSum,
    required this.xiantianLowerSum,
    required this.xiantianBaseNumber,
    // 步骤5-6: 后天卦六爻纳甲
    required this.houtianYaoTianGanList,
    required this.houtianYaoDiZhiList,
    required this.houtianYaoSumList,
    required this.houtianUpperSum,
    required this.houtianLowerSum,
    required this.houtianBaseNumber,
  });

  /// 工厂构造函数（简化创建）
  factory LiuYaoGanZhiHeBaseNumberModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
    required List<int> ganNumList,
    required List<List<int>> zhiNumList,
    required int oddNumTotal,
    required int evenNumTotal,
    required int tianGuaNum,
    required int diGuaNum,
    required Enum8Gua tianGua,
    required Enum8Gua diGua,
    required bool usedThreeYuanWuGong,
    required YinYang yearYinYang,
    required Enum8Gua upperGua,
    required Enum8Gua lowerGua,
    required Enum64Gua xiantianGua,
    required Enum64Gua houtianGua,
    required int xiantianUpperGuaNumber,
    required int xiantianLowerGuaNumber,
    required int houtianUpperGuaNumber,
    required int houtianLowerGuaNumber,
    required List<String> xiantianYaoTianGanList,
    required List<String> xiantianYaoDiZhiList,
    required List<int> xiantianYaoSumList,
    required int xiantianUpperSum,
    required int xiantianLowerSum,
    required int xiantianBaseNumber,
    required List<String> houtianYaoTianGanList,
    required List<String> houtianYaoDiZhiList,
    required List<int> houtianYaoSumList,
    required int houtianUpperSum,
    required int houtianLowerSum,
    required int houtianBaseNumber,
  }) {
    return LiuYaoGanZhiHeBaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      ganNumList: ganNumList,
      zhiNumList: zhiNumList,
      oddNumTotal: oddNumTotal,
      evenNumTotal: evenNumTotal,
      tianGuaNum: tianGuaNum,
      diGuaNum: diGuaNum,
      tianGua: tianGua,
      diGua: diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong,
      yearYinYang: yearYinYang,
      upperGua: upperGua,
      lowerGua: lowerGua,
      xiantianGua: xiantianGua,
      houtianGua: houtianGua,
      xiantianUpperGuaNumber: xiantianUpperGuaNumber,
      xiantianLowerGuaNumber: xiantianLowerGuaNumber,
      houtianUpperGuaNumber: houtianUpperGuaNumber,
      houtianLowerGuaNumber: houtianLowerGuaNumber,
      xiantianYaoTianGanList: xiantianYaoTianGanList,
      xiantianYaoDiZhiList: xiantianYaoDiZhiList,
      xiantianYaoSumList: xiantianYaoSumList,
      xiantianUpperSum: xiantianUpperSum,
      xiantianLowerSum: xiantianLowerSum,
      xiantianBaseNumber: xiantianBaseNumber,
      houtianYaoTianGanList: houtianYaoTianGanList,
      houtianYaoDiZhiList: houtianYaoDiZhiList,
      houtianYaoSumList: houtianYaoSumList,
      houtianUpperSum: houtianUpperSum,
      houtianLowerSum: houtianLowerSum,
      houtianBaseNumber: houtianBaseNumber,
    );
  }

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

  /// 获取先天卦六爻纳甲摘要
  String get xiantianNajiaSummary =>
      '先天卦六爻纳甲: 上三爻和数=$xiantianUpperSum（千百位），下三爻和数=$xiantianLowerSum（十位个位），基础数=$xiantianBaseNumber';

  /// 获取后天卦六爻纳甲摘要
  String get houtianNajiaSummary =>
      '后天卦六爻纳甲: 上三爻和数=$houtianUpperSum（千百位），下三爻和数=$houtianLowerSum（十位个位），基础数=$houtianBaseNumber';

  // ========== 复制方法 ==========

  /// 复制并更新模型
  @override
  LiuYaoGanZhiHeBaseNumberModel copyWith({
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
    List<String>? xiantianYaoTianGanList,
    List<String>? xiantianYaoDiZhiList,
    List<int>? xiantianYaoSumList,
    int? xiantianUpperSum,
    int? xiantianLowerSum,
    int? xiantianBaseNumber,
    List<String>? houtianYaoTianGanList,
    List<String>? houtianYaoDiZhiList,
    List<int>? houtianYaoSumList,
    int? houtianUpperSum,
    int? houtianLowerSum,
    int? houtianBaseNumber,
  }) {
    return LiuYaoGanZhiHeBaseNumberModel(
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
      xiantianYaoTianGanList:
          xiantianYaoTianGanList ?? this.xiantianYaoTianGanList,
      xiantianYaoDiZhiList: xiantianYaoDiZhiList ?? this.xiantianYaoDiZhiList,
      xiantianYaoSumList: xiantianYaoSumList ?? this.xiantianYaoSumList,
      xiantianUpperSum: xiantianUpperSum ?? this.xiantianUpperSum,
      xiantianLowerSum: xiantianLowerSum ?? this.xiantianLowerSum,
      xiantianBaseNumber: xiantianBaseNumber ?? this.xiantianBaseNumber,
      houtianYaoTianGanList:
          houtianYaoTianGanList ?? this.houtianYaoTianGanList,
      houtianYaoDiZhiList: houtianYaoDiZhiList ?? this.houtianYaoDiZhiList,
      houtianYaoSumList: houtianYaoSumList ?? this.houtianYaoSumList,
      houtianUpperSum: houtianUpperSum ?? this.houtianUpperSum,
      houtianLowerSum: houtianLowerSum ?? this.houtianLowerSum,
      houtianBaseNumber: houtianBaseNumber ?? this.houtianBaseNumber,
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
      // 步骤3-4: 先天卦六爻纳甲
      'xiantianYaoTianGanList': xiantianYaoTianGanList,
      'xiantianYaoDiZhiList': xiantianYaoDiZhiList,
      'xiantianYaoSumList': xiantianYaoSumList,
      'xiantianUpperSum': xiantianUpperSum,
      'xiantianLowerSum': xiantianLowerSum,
      'xiantianBaseNumber': xiantianBaseNumber,
      'xiantianNajiaSummary': xiantianNajiaSummary,
      // 步骤5-6: 后天卦六爻纳甲
      'houtianYaoTianGanList': houtianYaoTianGanList,
      'houtianYaoDiZhiList': houtianYaoDiZhiList,
      'houtianYaoSumList': houtianYaoSumList,
      'houtianUpperSum': houtianUpperSum,
      'houtianLowerSum': houtianLowerSum,
      'houtianBaseNumber': houtianBaseNumber,
      'houtianNajiaSummary': houtianNajiaSummary,
      // 便捷信息
      'paramsSummary': paramsSummary,
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'LiuYaoGanZhiHeBaseNumberModel('
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

    return other is LiuYaoGanZhiHeBaseNumberModel &&
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
