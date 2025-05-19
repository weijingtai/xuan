import 'fate_manager.dart';

// 竹罗三限
class ZhuLuoSanXianManager extends FateManager {
  @override
  void calculate(DateTime date) {
    // 实现竹罗三限的具体计算逻辑
    print('计算竹罗三限...');

    // 处理完成后传递给下一个处理器
    passToNext(date);
  }
}
