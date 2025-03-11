import 'package:sweph/sweph.dart';
import 'package:common/enums.dart';

import '../models/star_angle_raw_info.dart';
import '../enums/enum_panel_system_type.dart';

abstract class StarAngleStrategy {
  Future<StarAngleRawInfo> calculate(
      EnumStars star, double julianDay, List<double> geopos);
}

class EquatorialSiderealStrategy implements StarAngleStrategy {
  @override
  Future<StarAngleRawInfo> calculate(
      EnumStars star, double julianDay, List<double> geopos) async {
    final sweph = Sweph();
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    CoordinatesWithSpeed result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SIDEREAL |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_EQUATORIAL);

    return StarAngleRawInfo(
      starInnSystem: StarInnSystem.Sidereal,
      coordinateSystem: CoordinateSystem.Equatorial,
      angle: result.longitude, // 赤经
      speed: result.speedInLongitude, // 赤经速度
    );
  }
}

class EquatorialTropicalStrategy implements StarAngleStrategy {
  @override
  Future<StarAngleRawInfo> calculate(
      EnumStars star, double julianDay, List<double> geopos) async {
    // final sweph = Sweph();
    // await sweph.setSidMode(Sweph.SIDM_TROP_ZOD);
    // await sweph.setTopo(geopos[0], geopos[1], geopos[2]);
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_J2000);
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    final result = await Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_EQUATORIAL);

    return StarAngleRawInfo(
      starInnSystem: StarInnSystem.Tropical,
      coordinateSystem: CoordinateSystem.Equatorial,
      angle: result.longitude, // 赤经
      speed: result.speedInLongitude, // 赤经速度
    );
  }
}

class EclipticSiderealStrategy implements StarAngleStrategy {
  @override
  Future<StarAngleRawInfo> calculate(
      EnumStars star, double julianDay, List<double> geopos) async {
    final sweph = Sweph();
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI); // 设置恒星黄道
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    CoordinatesWithSpeed result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SIDEREAL |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_XYZ); // 使用黄道坐标标志和恒星制标志

    return StarAngleRawInfo(
      starInnSystem: StarInnSystem.Sidereal,
      coordinateSystem: CoordinateSystem.Ecliptic,
      angle: result.longitude, // 黄经
      speed: result.speedInLongitude, // 黄经速度
    );
  }
}

class EclipticTropicalStrategy implements StarAngleStrategy {
  @override
  Future<StarAngleRawInfo> calculate(
      EnumStars star, double julianDay, List<double> geopos) async {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_J2000); // 设置回归黄道
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    CoordinatesWithSpeed result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_XYZ); // 使用黄道坐标标志

    return StarAngleRawInfo(
      starInnSystem: StarInnSystem.Tropical,
      coordinateSystem: CoordinateSystem.Ecliptic,
      angle: result.longitude, // 黄经
      speed: result.speedInLongitude, // 黄经速度
    );
  }
}

HeavenlyBody _getSwephStar(EnumStars star) {
  switch (star) {
    case EnumStars.Sun:
      return HeavenlyBody.SE_SUN;
    case EnumStars.Moon:
      return HeavenlyBody.SE_MOON;
    case EnumStars.Mercury:
      return HeavenlyBody.SE_MERCURY;
    case EnumStars.Venus:
      return HeavenlyBody.SE_VENUS;
    case EnumStars.Mars:
      return HeavenlyBody.SE_JUPITER;
    case EnumStars.Jupiter:
      return HeavenlyBody.SE_JUPITER;
    case EnumStars.Saturn:
      return HeavenlyBody.SE_SATURN;
    default:
      throw ArgumentError('Invalid star type');
  }
}
