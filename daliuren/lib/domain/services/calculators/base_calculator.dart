/// 计算器基类
///
/// 所有大六壬计算器的抽象基类,定义通用接口和行为
abstract class BaseCalculator {
  /// 计算器名称,用于日志和调试
  String get name;

  /// 验证输入参数是否有效
  ///
  /// 子类可以重写此方法实现自定义验证逻辑
  /// Returns: true表示验证通过, false表示验证失败
  bool validateInput(dynamic input) {
    return input != null;
  }
}
