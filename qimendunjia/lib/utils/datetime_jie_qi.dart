// 写一个 DateTime 的扩展类，用于获取节气
// 导入 lunar 包以进行精确的节气计算
import 'package:lunar/lunar.dart';

// 扩展 DateTime 类以添加获取当前节气的功能
extension SolarTerm on DateTime {
  // 获取当前日期所在的节气
  // 使用 lunar 包进行计算，以提高准确性
  String getSolarTerm() {
    // 从 DateTime 创建 Lunar 实例
    final lunarDate = Lunar.fromDate(this);
    // 获取当前日期所在的节气，如果当天不是节气，则获取上一个节气
    // lunar.getJieQi() 会返回当天的节气，如果不是节气则为空
    // lunar.getCurrentJieQi() 会返回当前日期所在的节气（如果当天不是节气，则取最近的一个）
    // 根据需求，我们希望获取当前日期所属的节气区间，因此使用 getCurrentJieQi
    final currentJieQi = lunarDate.getCurrentJieQi();
    if (currentJieQi != null) {
      return currentJieQi.getName();
    } else {
      // 理论上 lunarDate.getCurrentJieQi() 总能返回一个有效的节气名称
      // 但作为预防措施，如果获取失败，则尝试获取下一个节气作为回退
      // 注意：lunar 包的行为可能需要进一步确认以确定最佳的回退策略
      final nextJieQi = lunarDate.getNextJieQi();
      if (nextJieQi != null) {
        return nextJieQi.getName();
      }
    }
    // 如果两种方法都失败，则返回一个默认值或抛出异常
    // 此处返回空字符串，调用者应处理此情况
    return '';
  }
}

// void main() {
//   // 测试代码示例
//   // print(DateTime.parse("2023-08-31").getSolarTerm()); // 预期: 处暑
//   // print(DateTime.parse("2022-12-14").getSolarTerm());  // 预期: 大雪
//   // print(DateTime.now().getSolarTerm()); // 获取当前日期的节气
// }
