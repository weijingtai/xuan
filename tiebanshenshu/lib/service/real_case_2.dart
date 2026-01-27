/// 案例2：定刻取数法
/// 1. 以被测者生辰为基准（如：出生在卯时，则以卯时为准）
/// 2. 查《八刻数表》根据出生时刻，查出相应的几基本数（每时辰8个刻钟选择最符合的条文，其条文数作为基本数）
/// 3. 将基本数转为后天卦（四位基本数，前两位相加为上卦、后两位相加为下卦。合数模8，取后天卦）
/// 4. 将 "第三步" 得到的卦进行纳甲配爻，按加则法取数
/// 5. 六爻配数相加为"卦总数"
/// 6. 上卦后天数千位 + 卦总数 - 下卦后天数 = "条文数"
/// 7. 条文数 ± 96 * n(n为1,2,3,4) 得出共8条

import '../domain/six_yao_gua.dart';
import '../utils/tiao_wen_calculator.dart';
import '../utils/utils.dart' as Utils;

/// 刻信息类
///
/// 用于存储时辰刻的相关信息
class KeInfo {
  /// 时支
  final String timeZhi;

  /// 刻序名称
  final String keOrderName;

  /// 数字
  final int number;

  /// 是否被接受
  final bool isAccepted;

  const KeInfo({
    required this.timeZhi,
    required this.keOrderName,
    required this.number,
    required this.isAccepted,
  });

  @override
  String toString() {
    return 'KeInfo(timeZhi: $timeZhi, keOrderName: $keOrderName, number: $number, isAccepted: $isAccepted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeInfo &&
        other.timeZhi == timeZhi &&
        other.keOrderName == keOrderName &&
        other.number == number &&
        other.isAccepted == isAccepted;
  }

  @override
  int get hashCode {
    return Object.hash(timeZhi, keOrderName, number, isAccepted);
  }
}

/// 条文数计算策略类
///
/// 实现"考时定刻"策略的条文数计算
@Deprecated("CorrectTimeAndKeCalculation")
class TiaoWenNumberCalculationStrategy {
  /// 策略名称
  static const String strategyName = "考时定刻";

  /// 出生时支
  final String birthTimeZhi;

  /// 刻信息列表
  final List<KeInfo> keInfoList = [];

  /// 基本数
  int _baseNumber = -1;

  /// 基本卦
  String? _baseGua;

  TiaoWenNumberCalculationStrategy({required this.birthTimeZhi});

  /// 获取基本数
  int get baseNumber => _baseNumber;

  /// 获取基本卦
  String? get baseGua => _baseGua;

  /// 添加刻信息并返回基本卦象和基本数
  ///
  /// 该方法用于将刻信息添加到刻信息列表中，并在该刻被接受时设置基本数和基本卦象。
  ///
  /// 参数:
  ///   [keInfo] 包含刻的详细信息，包括时支、刻序名、数字和是否被接受
  void appendKeInfo(KeInfo keInfo) {
    keInfoList.add(keInfo);
    if (keInfo.isAccepted) {
      _baseNumber = keInfo.number;
      _baseGua = Utils.digit4NumberToHouGua(_baseNumber);
    }
  }

  /// 将基本卦转换为六爻卦
  SixYaoGua get baseGuaToSixYaoGua {
    if (_baseGua == null) {
      throw ArgumentError('baseGua is null');
    }
    return SixYaoGua.generateFromGua(_baseGua!);
  }
}
