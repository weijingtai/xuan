/// 条文数计算工具类
///
/// 提供四门法和八卦滚法的条文数计算功能
library;

import 'package:common/enums.dart';
import '../constant/constants.dart' as constants;
import '../features/six_yao_gua/pure_six_yao_gua.dart';

/// 条文数字计算器
class TiaoWenNumberCalculator {
  const TiaoWenNumberCalculator();

  /// 【四门法】计算秘数列表
  ///
  /// [isYangYear] 是否为阳年
  /// [fourGuaList] 四个卦象列表
  ///
  /// 返回秘数列表
  List<int> calculateSecretNumbers(
    bool isYangYear,
    List<Enum64Gua> fourGuaList,
  ) {
    final secretNumbers = <int>[];

    for (final gua in fourGuaList) {
      // 将卦转换为干支
      final (gan, zhi) = _guaToGanzhi(gua, isYangYear);

      // 获取太玄数
      final ganTaixuan = constants.taixuanGanNumberMapper[gan]!;
      final zhiTaixuan = constants.taixuanZhiNumberMapper[zhi]!;

      // 计算秘数
      int secretNum;
      if (isYangYear) {
        secretNum = int.parse('$ganTaixuan$zhiTaixuan');
      } else {
        secretNum = int.parse('$zhiTaixuan$ganTaixuan');
      }

      secretNumbers.add(secretNum);
    }

    return secretNumbers;
  }

  /// 【四门法】将卦转换为干支
  ///
  /// [gua] 卦象
  /// [isYangYear] 是否为阳年
  ///
  /// 返回 (天干, 地支) 的元组
  (String, String) _guaToGanzhi(Enum64Gua gua, bool isYangYear) {
    final upperGua = gua.top.name;
    final lowerGua = gua.bottom.name;

    // 获取天干
    final ganOptions = constants.guaTianganMapper[upperGua]!;
    String gan;
    if (ganOptions.length == 1) {
      gan = ganOptions[0];
    } else {
      // 根据年干阴阳选择
      gan = isYangYear ? ganOptions[0] : ganOptions[1];
    }

    // 获取地支
    final zhiOptions = constants.guaDizhiMapper[lowerGua]!;
    String zhi;
    if (zhiOptions.length == 1) {
      zhi = zhiOptions[0];
    } else {
      // 根据年干阴阳选择
      zhi = isYangYear ? zhiOptions[0] : zhiOptions[1];
    }

    return (gan, zhi);
  }

  /// 【四门法】计算先天数列表
  ///
  /// [fourGuaList] 四个卦象列表
  ///
  /// 返回先天数列表
  List<int> calculateXiantianNumbers(List<Enum64Gua> fourGuaList) {
    final xiantianNumbers = <int>[];

    for (final gua in fourGuaList) {
      final upperGua = gua.top.name;
      final lowerGua = gua.bottom.name;

      final upperNum = constants.xianTianGuaNumberMapper[upperGua]!;
      final lowerNum = constants.xianTianGuaNumberMapper[lowerGua]!;

      // 上卦为十位，下卦为个位
      final xiantianNum = int.parse('$upperNum$lowerNum');
      xiantianNumbers.add(xiantianNum);
    }

    return xiantianNumbers;
  }

  /// 【四门法】计算最终条文数
  ///
  /// [xiantianNumbers] 先天数列表
  /// [secretNumbers] 秘数列表
  ///
  /// 返回最终条文数列表
  List<int> calculateFinalTiaowen(
    List<int> xiantianNumbers,
    List<int> secretNumbers,
  ) {
    final finalTiaowenList = <int>[];

    // 将所有秘数展开为一维列表
    final allSecretNumbers = <int>[];
    for (final secretNum in secretNumbers) {
      // 使用原始的秘数计算公式
      const constants = [19, 37, 53, 79, 103, 237];
      final tiaowenNumbers = constants
          .map((consts) => secretNum * consts - 7)
          .toList();
      allSecretNumbers.addAll(tiaowenNumbers);
    }

    // 计算最终条文数
    for (final xiantianNum in xiantianNumbers) {
      for (final secretTiaowen in allSecretNumbers) {
        // 使用原始公式：先天数 * 47 + 秘数条文
        int eachNum = xiantianNum * 47 + secretTiaowen;

        // 调整范围到1000-13000之间
        if (eachNum < 1000) {
          finalTiaowenList.add(eachNum + 12000);
        } else if (eachNum > 13000) {
          final tmpRes = eachNum - 12000;
          if (tmpRes > 13000) {
            finalTiaowenList.add(tmpRes - 12000);
          } else {
            finalTiaowenList.add(tmpRes);
          }
        } else {
          finalTiaowenList.add(eachNum);
        }
      }
    }

    return finalTiaowenList;
  }

  /// 【八卦滚法】获取卦的三个基本数
  ///
  /// [guaName] 卦名
  ///
  /// 返回 (先天八卦顺序数a, 先天洛书数b, 后天洛书数c)
  (int, int, int) getGuaThreeNumbers(Enum64Gua guaName) {
    final upperGua = guaName.top.name;
    final lowerGua = guaName.bottom.name;

    // 先天八卦顺序
    final a = int.parse(
      '${constants.xianTianGuaNumberMapper[upperGua]}${constants.xianTianGuaNumberMapper[lowerGua]}',
    );

    // 先天洛书数
    final b = int.parse(
      '${constants.xiantianGuaLuoshuNumberMapper[upperGua]}${constants.xiantianGuaLuoshuNumberMapper[lowerGua]}',
    );

    // 后天洛书数
    final c = int.parse(
      '${constants.houtianGuaLuoshuNumberMapper[upperGua]}${constants.houtianGuaLuoshuNumberMapper[lowerGua]}',
    );

    return (a, b, c);
  }

  /// 【八卦滚法】计算卦的条文列表
  ///
  /// 根据三个基本数计算六个条文数：
  /// a*100+b, a*100+c, b*100+a, b*100+c, c*100+a, c*100+b
  ///
  /// [a], [b], [c] 三个基本数
  ///
  /// 返回 六个条文数
  List<int> calculateGuaTiaowenList(int a, int b, int c) {
    return [
      a * 100 + b,
      a * 100 + c,
      b * 100 + a,
      b * 100 + c,
      c * 100 + a,
      c * 100 + b,
    ];
  }

  /// 【八卦滚法】计算所有八卦的条文数
  ///
  /// [eightGuaList] 八个卦的列表
  ///
  /// 返回 所有条文数列表（8卦 × 6条文 = 48条）
  List<int> calculateEightGuaTiaowenNumbers(List<Enum64Gua> eightGuaList) {
    final tiaowenNumbers = <int>[];
    for (final gua in eightGuaList) {
      final (a, b, c) = getGuaThreeNumbers(gua);
      final guaTiaowen = calculateGuaTiaowenList(a, b, c);
      tiaowenNumbers.addAll(guaTiaowen);
    }
    return tiaowenNumbers;
  }
}
