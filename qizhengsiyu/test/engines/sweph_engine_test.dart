import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  group('SwephEngine', () {
    test('calculateStarPositions should return a list of star positions', () async {
      // Arrange
      final engine = SwephEngine();
      final config = BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
        panelSystemType: PanelSystemType.tropical,
        constellationSystemType: ConstellationSystemType.modern,
        houseDivisionSystem: HouseDivisionSystem.equal,
        settleLifeType: EnumSettleLifeType.Mao,
        lifeCountingToGong: EnumTwelveGong.Mao,
        bodyCountingToGong: EnumTwelveGong.Yin,
        settleBodyType: EnumSettleBodyType.moon,
        islifeGongBySunRealTimeLocation: true,
      );
      final observer = ObserverPosition(
        dateTime: DateTime.now(),
        longitude: 121.47,
        latitude: 31.23,
        altitude: 0,
        timezone: 'Asia/Shanghai',
        isDayBirth: true,
        yearGanZhi: JiaZi.getFromGanZhiValue('甲子')!,
        monthGanZhi: JiaZi.getFromGanZhiValue('丙寅')!,
        dayGanZhi: JiaZi.getFromGanZhiValue('丁卯')!,
        timeGanZhi: JiaZi.getFromGanZhiValue('戊辰')!,
      );

      // Act
      final positions = await engine.calculateStarPositions(observer.dateTime, observer, config);

      // Assert
      expect(positions, isNotEmpty);
      expect(positions.length, greaterThan(10)); // Should have at least 11 bodies
      expect(positions.first.starType, isA<EnumStars>());
      expect(positions.first.angleRawInfoSet, isNotEmpty);
      expect(positions.first.angleRawInfoSet.first.angle, isA<double>());
    });
  });
}
