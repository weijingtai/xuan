import 'package:common/enums.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'kao_ke_session_models.dart';

/// 卦象计算辅助类
///
/// 根据基础数(四位数)计算上下卦
class GuaCalculationHelper {
  /// 八卦名称映射 (后天八卦)
  static const Map<int, String> _baGuaNames = {
    1: '乾',
    2: '兑',
    3: '离',
    4: '震',
    5: '巽',
    6: '坎',
    7: '艮',
    8: '坤',
  };

  /// 六十四卦名称映射 (简化版,实际应该有完整的64卦表)
  /// 格式: "上卦_下卦" -> "卦名"
  static const Map<String, String> _liuShiSiGuaNames = {
    '乾_乾': '乾为天',
    '乾_兑': '天泽履',
    '乾_离': '天火同人',
    '乾_震': '天雷无妄',
    '乾_巽': '天风姤',
    '乾_坎': '天水讼',
    '乾_艮': '天山遁',
    '乾_坤': '天地否',
    '兑_乾': '泽天夬',
    '兑_兑': '兑为泽',
    '兑_离': '泽火革',
    '兑_震': '泽雷随',
    '兑_巽': '泽风大过',
    '兑_坎': '泽水困',
    '兑_艮': '泽山咸',
    '兑_坤': '泽地萃',
    '离_乾': '火天大有',
    '离_兑': '火泽睽',
    '离_离': '离为火',
    '离_震': '火雷噬嗑',
    '离_巽': '火风鼎',
    '离_坎': '火水未济',
    '离_艮': '火山旅',
    '离_坤': '火地晋',
    '震_乾': '雷天大壮',
    '震_兑': '雷泽归妹',
    '震_离': '雷火丰',
    '震_震': '震为雷',
    '震_巽': '雷风恒',
    '震_坎': '雷水解',
    '震_艮': '雷山小过',
    '震_坤': '雷地豫',
    '巽_乾': '风天小畜',
    '巽_兑': '风泽中孚',
    '巽_离': '风火家人',
    '巽_震': '风雷益',
    '巽_巽': '巽为风',
    '巽_坎': '风水涣',
    '巽_艮': '风山渐',
    '巽_坤': '风地观',
    '坎_乾': '水天需',
    '坎_兑': '水泽节',
    '坎_离': '水火既济',
    '坎_震': '水雷屯',
    '坎_巽': '水风井',
    '坎_坎': '坎为水',
    '坎_艮': '水山蹇',
    '坎_坤': '水地比',
    '艮_乾': '山天大畜',
    '艮_兑': '山泽损',
    '艮_离': '山火贲',
    '艮_震': '山雷颐',
    '艮_巽': '山风蛊',
    '艮_坎': '山水蒙',
    '艮_艮': '艮为山',
    '艮_坤': '山地剥',
    '坤_乾': '地天泰',
    '坤_兑': '地泽临',
    '坤_离': '地火明夷',
    '坤_震': '地雷复',
    '坤_巽': '地风升',
    '坤_坎': '地水师',
    '坤_艮': '地山谦',
    '坤_坤': '坤为地',
  };

  /// 根据基础数计算卦象
  ///
  /// [baseNumber] 四位数的基础数(条文编号)
  ///
  /// 计算规则:
  /// 1. 分解四位数为前两位和后两位
  /// 2. 前两位作为上卦,后两位作为下卦
  /// 3. 如果大于8,则对8取模
  /// 4. 特殊规则: 如果取模后余数为5或10,则使用(原数-10)
  /// 5. 将数值映射到后天八卦
  static GuaCalculationResult calculateGua(int baseNumber) {
    final buffer = StringBuffer();
    buffer.writeln('【卦象计算过程】');
    buffer.writeln('基础数: $baseNumber');

    // 1. 分解四位数
    final qian = baseNumber ~/ 100; // 前两位
    final hou = baseNumber % 100; // 后两位

    buffer.writeln('前两位: $qian');
    buffer.writeln('后两位: $hou');

    // 2. 计算上卦数值
    int shangGuaNum = _calculateGuaNumber(qian, buffer, '上卦');

    // 3. 计算下卦数值
    int xiaGuaNum = _calculateGuaNumber(hou, buffer, '下卦');

    // 4. 映射到卦名
    final shangGuaName = _baGuaNames[shangGuaNum] ?? '未知';
    final xiaGuaName = _baGuaNames[xiaGuaNum] ?? '未知';

    final fullGuaName = _liuShiSiGuaNames['${shangGuaName}_$xiaGuaName'] ??
        '$shangGuaName$xiaGuaName卦';

    buffer.writeln('\n【结果】');
    buffer.writeln('上卦: $shangGuaNum -> $shangGuaName');
    buffer.writeln('下卦: $xiaGuaNum -> $xiaGuaName');
    buffer.writeln('完整卦名: $fullGuaName');

    return GuaCalculationResult(
      shangGuaNumber: shangGuaNum,
      xiaGuaNumber: xiaGuaNum,
      shangGuaName: shangGuaName,
      xiaGuaName: xiaGuaName,
      fullGuaName: fullGuaName,
      calculationDetail: buffer.toString(),
    );
  }

  /// 计算单个卦数
  ///
  /// [num] 输入的数值
  /// [buffer] 用于记录计算过程
  /// [label] 标签(上卦/下卦)
  static int _calculateGuaNumber(
    int num,
    StringBuffer buffer,
    String label,
  ) {
    buffer.writeln('\n[$label计算]');
    buffer.writeln('原始值: $num');

    if (num <= 8) {
      buffer.writeln('小于等于8,直接使用: $num');
      return num;
    }

    // 对8取模
    final remainder = num % 8;
    buffer.writeln('对8取模: $num % 8 = $remainder');

    // 特殊规则: 如果余数为5或10,则使用(原数-10)
    if (remainder == 5 || remainder == 10) {
      final result = num - 10;
      buffer.writeln('余数为$remainder,使用特殊规则: $num - 10 = $result');

      // 再次检查是否在1-8范围内
      if (result >= 1 && result <= 8) {
        return result;
      } else if (result > 8) {
        // 如果还是大于8,继续取模
        final finalResult = result % 8;
        buffer.writeln('结果仍大于8,再次取模: $result % 8 = $finalResult');
        return finalResult == 0 ? 8 : finalResult;
      } else {
        // 如果小于1,使用余数
        buffer.writeln('结果小于1,使用余数: $remainder');
        return remainder == 0 ? 8 : remainder;
      }
    }

    // 正常取模结果
    final result = remainder == 0 ? 8 : remainder;
    buffer.writeln('最终结果: $result');
    return result;
  }

  /// 获取卦名
  static String getGuaName(int guaNumber) {
    return _baGuaNames[guaNumber] ?? '未知';
  }

  /// 验证基础数是否有效
  static bool isValidBaseNumber(int baseNumber) {
    return baseNumber >= 1000 && baseNumber <= 9999;
  }

  /// 将 GuaCalculationHelper 的八卦数字映射到 Enum8Gua
  ///
  /// GuaCalculationHelper 使用的自定义编号：
  /// 1:乾 2:兑 3:离 4:震 5:巽 6:坎 7:艮 8:坤
  /// 这与先天和后天八卦的标准编号都不同
  static Enum8Gua? numberToEnum8Gua(int guaNumber) {
    // GuaCalculationHelper 的编号映射
    const Map<int, Enum8Gua> guaMapping = {
      1: Enum8Gua.Qian,  // 乾
      2: Enum8Gua.Dui,   // 兑
      3: Enum8Gua.Li,    // 离
      4: Enum8Gua.Zhen,  // 震
      5: Enum8Gua.Xun,   // 巽
      6: Enum8Gua.Kan,   // 坎
      7: Enum8Gua.Gen,   // 艮
      8: Enum8Gua.Kun,   // 坤
    };

    return guaMapping[guaNumber];
  }

  /// 从上下卦数字获取64卦
  ///
  /// [shangGuaNumber] 上卦数字 (1-8)
  /// [xiaGuaNumber] 下卦数字 (1-8)
  ///
  /// 返回对应的 Enum64Gua，如果找不到返回 null
  static Enum64Gua? getEnum64Gua(int shangGuaNumber, int xiaGuaNumber) {
    final shangGua = numberToEnum8Gua(shangGuaNumber);
    final xiaGua = numberToEnum8Gua(xiaGuaNumber);

    if (shangGua == null || xiaGua == null) {
      return null;
    }

    // 使用 Enum64Gua.values 查找匹配的64卦
    for (final gua in Enum64Gua.values) {
      if (gua.top == shangGua && gua.bottom == xiaGua) {
        return gua;
      }
    }

    return null;
  }
}
