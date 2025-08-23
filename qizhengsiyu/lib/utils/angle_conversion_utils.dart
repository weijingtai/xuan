import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

/// 角度转换工具类
class AngleConverter {
  /// 根据所选的周天度量系统转换角度
  ///
  /// [angleInDegrees] - 从天文库获取的、基于360度的角度值
  /// [system] - 用户在配置中选择的周天度量系统
  ///
  /// 返回转换后的角度值。
  /// 如果系统是 Days365_25，则返回以“日”为单位的值。
  /// 否则，返回原始的度数值。
  static double convertAngle(double angleInDegrees, CircularSystem system) {
    if (system == CircularSystem.Days365_25) {
      return (angleInDegrees / 360.0) * 365.25;
    } else {
      return angleInDegrees;
    }
  }

  /// 根据所选的周天度量系统获取周天总数
  static double getTotalDivisions(CircularSystem system) {
    return switch (system) {
      CircularSystem.Days365_25 => 365.25,
      CircularSystem.Degrees360 => 360.0,
    };
  }
}
