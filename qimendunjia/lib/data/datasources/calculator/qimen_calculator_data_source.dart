import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/utils/qi_men_ju_calculator.dart';

/// 奇门计算器数据源接口
///
/// 定义计算局数的标准接口
abstract class QiMenCalculatorDataSource {
  /// 计算局数
  ///
  /// [dateTime] 起盘时间
  ///
  /// 返回计算好的局信息
  Future<ShiJiaJu> calculate(DateTime dateTime);

  /// 获取计算器名称
  String get name;
}

/// 拆补法计算器数据源
class ChaiBuCalculatorDataSource implements QiMenCalculatorDataSource {
  @override
  Future<ShiJiaJu> calculate(DateTime dateTime) async {
    final calculator = ChaiBuCalculator(dateTime: dateTime);
    return calculator.calculate();
  }

  @override
  String get name => '拆补法';
}

/// 置润法计算器数据源
class ZhiRunCalculatorDataSource implements QiMenCalculatorDataSource {
  @override
  Future<ShiJiaJu> calculate(DateTime dateTime) async {
    final calculator = ZhiRunCalculator(dateTime: dateTime);
    return calculator.calculate();
  }

  @override
  String get name => '置润法';
}

/// 茅山法计算器数据源
class MaoShanCalculatorDataSource implements QiMenCalculatorDataSource {
  @override
  Future<ShiJiaJu> calculate(DateTime dateTime) async {
    final calculator = MaoShanCalculator(dateTime: dateTime);
    return calculator.calculate();
  }

  @override
  String get name => '茅山法';
}

/// 阴盘法计算器数据源
class YinPanCalculatorDataSource implements QiMenCalculatorDataSource {
  @override
  Future<ShiJiaJu> calculate(DateTime dateTime) async {
    final calculator = YinPanCalculator(dateTime: dateTime);
    return calculator.calculate();
  }

  @override
  String get name => '阴盘法';
}
