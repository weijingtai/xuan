import 'yuan_tang_info.dart';
import '../../domain/pure_yuan_tang_gua.dart';
import '../../utils/yuan_tang_calculator.dart';

/// YuanTangInfo 扩展：便捷获取先天/后天大运列表
extension YuanTangInfoDaYunExt on YuanTangInfo {
  /// 计算先天大运列表（按虚岁起算）
  List<YuanTangDaYunPeriod> calculateXiantianDaYun(int startAge) {
    return YuanTangCalculator.calculateDaYun(xianTanGua, startAge);
  }

  /// 计算后天大运列表（按虚岁起算）
  List<YuanTangDaYunPeriod> calculateHoutianDaYun(int startAge) {
    return YuanTangCalculator.calculateDaYun(houTianGua, startAge);
  }
}