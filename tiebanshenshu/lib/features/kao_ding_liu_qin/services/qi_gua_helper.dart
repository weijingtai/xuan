import 'package:common/enums.dart';
import '../../../constant/constants.dart';
import '../../../features/six_yao_gua/pure_six_yao_gua.dart';

/// 起卦结果
///
/// 包含上下卦信息和计算详情
class QiGuaResult {
  /// 下卦（内卦）数字
  final int xiaGuaNumber;

  /// 上卦（外卦）数字
  final int shangGuaNumber;

  /// 下卦（内卦）对应的八卦
  final Enum8Gua xiaGua;

  /// 上卦（外卦）对应的八卦
  final Enum8Gua shangGua;

  /// 天干数字
  final int ganNumber;

  /// 地支奇数
  final int zhiOddNumber;

  /// 地支偶数
  final int zhiEvenNumber;

  /// 计算公式说明
  final String formula;

  const QiGuaResult({
    required this.xiaGuaNumber,
    required this.shangGuaNumber,
    required this.xiaGua,
    required this.shangGua,
    required this.ganNumber,
    required this.zhiOddNumber,
    required this.zhiEvenNumber,
    required this.formula,
  });

  @override
  String toString() {
    return '起卦结果: ${shangGua.name}${xiaGua.name} (上卦=$shangGuaNumber, 下卦=$xiaGuaNumber)\n'
        '详情: 干=$ganNumber, 支奇=$zhiOddNumber, 支偶=$zhiEvenNumber\n'
        '公式: $formula';
  }
}

/// 起卦助手类
///
/// 实现考订六亲功能的起卦逻辑：
/// 1. 根据干支配数规则获取数字
/// 2. 将地支两数分为奇偶
/// 3. 下卦 = (干数 + 支奇数) % 8
/// 4. 上卦 = (干数 + 支偶数) % 8
/// 5. 转换为八卦
class QiGuaHelper {
  /// 从干支起卦
  ///
  /// [gan] 天干
  /// [zhi] 地支
  ///
  /// 返回起卦结果，包含上下卦信息
  static QiGuaResult qiGuaFromGanZhi(TianGan gan, DiZhi zhi) {
    // 1. 获取天干配数（使用常量表）
    final ganNumber = ganNumberMapper[gan]!;

    // 2. 获取地支配数（两个数字）
    final zhiNumbers = zhiNumberMapper[zhi]!;
    final zhiOddNumber = zhiNumbers[0]; // 奇数
    final zhiEvenNumber = zhiNumbers[1]; // 偶数

    // 3. 计算下卦（内卦）= (干数 + 支奇数) % 8
    int xiaGuaNumber = (ganNumber + zhiOddNumber) % 8;
    if (xiaGuaNumber == 0) xiaGuaNumber = 8;

    // 4. 计算上卦（外卦）= (干数 + 支偶数) % 8
    int shangGuaNumber = (ganNumber + zhiEvenNumber) % 8;
    if (shangGuaNumber == 0) shangGuaNumber = 8;

    // 5. 转换为八卦
    final xiaGua = _numberToXianTianGua(xiaGuaNumber);
    final shangGua = _numberToXianTianGua(shangGuaNumber);

    // 6. 生成公式说明
    final formula = '下卦: ($ganNumber + $zhiOddNumber) % 8 = $xiaGuaNumber → ${xiaGua.name}\n'
        '上卦: ($ganNumber + $zhiEvenNumber) % 8 = $shangGuaNumber → ${shangGua.name}';

    return QiGuaResult(
      xiaGuaNumber: xiaGuaNumber,
      shangGuaNumber: shangGuaNumber,
      xiaGua: xiaGua,
      shangGua: shangGua,
      ganNumber: ganNumber,
      zhiOddNumber: zhiOddNumber,
      zhiEvenNumber: zhiEvenNumber,
      formula: formula,
    );
  }

  /// 从干支字符串起卦（便捷方法）
  ///
  /// [jiaZi] 干支对象（如八字中的某一柱）
  ///
  /// 返回起卦结果
  static QiGuaResult qiGuaFromGanZhiPair(JiaZi jiaZi) {
    return qiGuaFromGanZhi(jiaZi.gan, jiaZi.zhi);
  }

  /// 将数字转换为先天八卦
  ///
  /// 使用先天八卦序数：1乾 2兑 3离 4震 5巽 6坎 7艮 8坤
  static Enum8Gua _numberToXianTianGua(int number) {
    return numberXianGuaMapper[number]!;
  }

  /// 验证起卦结果
  ///
  /// 检查起卦结果是否有效
  static bool validateQiGuaResult(QiGuaResult result) {
    // 检查数字范围
    if (result.xiaGuaNumber < 1 || result.xiaGuaNumber > 8) {
      return false;
    }
    if (result.shangGuaNumber < 1 || result.shangGuaNumber > 8) {
      return false;
    }

    // 检查八卦对象是否为null
    return true;
  }

  /// 获取64卦
  ///
  /// 根据上下卦组合获取64卦
  static Enum64Gua get64Gua(QiGuaResult qiGuaResult) {
    return Enum64Gua.getBy8Gua(
      qiGuaResult.shangGua,
      qiGuaResult.xiaGua,
    );
  }
}
