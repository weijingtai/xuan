import 'dart:math';
import 'dart:ui';

import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

/// Defines the strategy for mapping logical angles to the UI canvas.
abstract class DrawingStrategy {
  double getTotalDivisions();

  Offset mapAngleToCanvas(double angle, double radius, Offset center);

  List<double> getHouseDivisionAngles();

  String formatAngle(double angle);
}

/// Drawing strategy for the 360-degree system.
class DrawingStrategy360 implements DrawingStrategy {
  @override
  double getTotalDivisions() => 360.0;

  @override
  List<double> getHouseDivisionAngles() {
    return List.generate(12, (i) => i * 30.0);
  }

  @override
  String formatAngle(double angle) {
    return '${angle.toStringAsFixed(2)}°';
  }

  @override
  Offset mapAngleToCanvas(double angle, double radius, Offset center) {
    final double angleInRadians = (angle / 360.0) * 2 * pi - (pi / 2);
    final double x = center.dx + radius * cos(angleInRadians);
    final double y = center.dy + radius * sin(angleInRadians);
    return Offset(x, y);
  }
}

/// Drawing strategy for the 365-day system.
class DrawingStrategy365 implements DrawingStrategy {
  @override
  double getTotalDivisions() => 365.0;

  @override
  List<double> getHouseDivisionAngles() {
    final double houseSize = 365.0 / 12.0;
    return List.generate(12, (i) => i * houseSize);
  }

  @override
  String formatAngle(double angle) {
    return '${angle.toStringAsFixed(2)}日';
  }

  @override
  Offset mapAngleToCanvas(double angle, double radius, Offset center) {
    final double angleInRadians = (angle / 365.0) * 2 * pi - (pi / 2);
    final double x = center.dx + radius * cos(angleInRadians);
    final double y = center.dy + radius * sin(angleInRadians);
    return Offset(x, y);
  }
}

/// Drawing strategy for the 365.25-day system.
class DrawingStrategy365_25 implements DrawingStrategy {
  @override
  double getTotalDivisions() => 365.25;

  @override
  List<double> getHouseDivisionAngles() {
    final double houseSize = 365.25 / 12.0;
    return List.generate(12, (i) => i * houseSize);
  }

  @override
  String formatAngle(double angle) {
    return '${angle.toStringAsFixed(2)}日';
  }

  @override
  Offset mapAngleToCanvas(double angle, double radius, Offset center) {
    final double angleInRadians = (angle / 365.25) * 2 * pi - (pi / 2);
    final double x = center.dx + radius * cos(angleInRadians);
    final double y = center.dy + radius * sin(angleInRadians);
    return Offset(x, y);
  }
}
