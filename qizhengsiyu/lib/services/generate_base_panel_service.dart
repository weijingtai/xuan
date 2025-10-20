import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/models/da_xian_panel_model.dart';
import 'package:qizhengsiyu/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';
import 'package:timezone/timezone.dart' as tz;

import '../enums/enum_panel_system_type.dart';
import '../enums/enum_qi_zheng.dart';
import '../enums/enum_settle_life_body.dart';
import '../domain/entities/models/base_panel_model.dart'; // 使用domain层的模型
import '../domain/entities/models/naming_degree_pair.dart'; // 使用domain层的模型
import '../domain/entities/models/observer_position.dart'; // 使用domain层的模型
import '../utils/star_enter_info_calculator.dart';
import 'an_shen_li_ming_service.dart';
import 'star_angle_strategy.dart';

class GenerateBasePanelService {
  final BasePanelConfig panelConfig;
  final ObserverPosition observerPosition;
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;

  final ZhouTianModelManager zhouTianModelManager;

  GenerateBasePanelService(
      {required this.panelConfig,
      required this.observerPosition,
      required this.shenShaManager,
      required this.huaYaoManager,
      required this.zhouTianModelManager});

  Future<BasePanelModel> calculate() async {
    // final resultMapper = await getAllStarAngleRawInfo();

    final result = await Future.wait([
      // getZhouTianModel(),
      getAllStarAngleRawInfo(observerPosition),
    ]);
    final ZhouTianModel zhouTianModel =
        zhouTianModelManager.getZhouTianModelBy(panelConfig);

    // 1. 星体原始信息
    final Map<EnumStars, StarAngleSpeed> starAngleMapper =
        result.first as Map<EnumStars, StarAngleSpeed>;
    // 2. 计算星体进入宫位信息
    final Map<EnumStars, EnteredInfo> enteredGongMapper =
        getStarEnteredInfoMapper(starAngleMapper, zhouTianModel);

    // 3. 计算五星运行状态
    final Map<EnumStars, StarAngleSpeed> fiveStarMapper =
        Map.fromEntries(starAngleMapper.entries.where((t) => t.key.isFiveStar));
    final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper =
        calculateFiveStarskWalingStatus(fiveStarMapper);

    // 4. 计算四主（命宫主、身宫主、命度主、身度主）
    final BodyLifeModel bodyLifeModel = calculateLifeBodyAndMaster(
        zhouTianModel,
        enteredGongMapper[EnumStars.Sun]!,
        enteredGongMapper[EnumStars.Moon]!);
    // 5. 根据命宫位置，排序命理十二宫
    final Map<EnumTwelveGong, EnumDestinyTwelveGong> twelveGongMapper =
        orderDestinyTwelveGong(bodyLifeModel);
    // 6. 计算神煞位置
    final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper =
        shenShaManager.calculate(
            observerPosition.yearGanZhi,
            observerPosition.monthGanZhi,
            observerPosition.timeGanZhi,
            bodyLifeModel.lifeGong,
            enteredGongMapper[EnumStars.Sun]!.enterGongInfo.gong,
            enteredGongMapper[EnumStars.Moon]!.enterGongInfo.gong,
            observerPosition.isDayBirth);
    // 7. 计算化曜位置
    final Map<HuaYao, EnumStars> huaYaoMapper = huaYaoManager.calculate(
      mingGong: bodyLifeModel.lifeGong,
      yearJiaZi: observerPosition.yearGanZhi,
      monthJiaZi: observerPosition.monthGanZhi,
    );
    final List<HuaYaoStarPair> huaYaoStarPairList = huaYaoMapper.entries
        .map((e) => HuaYaoStarPair(e.key, e.value))
        .toList();
    // 8. 计算十二长生
    final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper =
        calculateTwelveLong(observerPosition.yearGanZhi);

    // 8.1. 根据十二长生enum 构建出对应 zhangsheng12ShenSha 并加入在神煞中,
    for (var i = 0; i < twelveZhangShengGongMapper.entries.length; i++) {
      final gong = twelveZhangShengGongMapper.entries.elementAt(i).key;
      shenShaMapper[gong]!.insert(
          0,
          ZhangSheng12ShenSha(
              twelveZhangShengGongMapper.entries.elementAt(i).value.name,
              JiXiongEnum.PING,
              null,
              null));
    }

    return BasePanelModel(
      starAngleMapper: starAngleMapper,
      enteredGongMapper: enteredGongMapper,
      fiveStarWalkingTypeMapper: fiveStarWalkingTypeMapper,
      bodyLifeModel: bodyLifeModel,
      twelveGongMapper: twelveGongMapper,
      shenShaMapper: shenShaMapper,
      huaYaoStarPairList: huaYaoStarPairList,
      twelveZhangShengGongMapper: twelveZhangShengGongMapper,
    );
  }

  Future<DaXianPanelModel> calculateDaXia(
      BasePanelModel basePanel, ObserverPosition daXianObserver) async {
    // 大限与 计算星命基础命盘一样，但是不计算 四主 与 命理十二宫的位置。
    // 在计算神煞时则是借用原局的命宫等位置进行计算

    // TODO: 需要提取公共函数
    final result = await Future.wait([
      getZhouTianModel(),
      getAllStarAngleRawInfo(daXianObserver),
    ]);
    final ZhouTianModel zhouTianModel = result[0] as ZhouTianModel;

    // 1. 星体原始信息
    final Map<EnumStars, StarAngleSpeed> starAngleMapper =
        result[1] as Map<EnumStars, StarAngleSpeed>;
    // 2. 计算星体进入宫位信息
    final Map<EnumStars, EnteredInfo> enteredGongMapper =
        getStarEnteredInfoMapper(starAngleMapper, zhouTianModel);

    // 3. 计算五星运行状态
    final Map<EnumStars, StarAngleSpeed> fiveStarMapper =
        Map.fromEntries(starAngleMapper.entries.where((t) => t.key.isFiveStar));
    final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper =
        calculateFiveStarskWalingStatus(fiveStarMapper);

    // 6. 计算神煞位置
    final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper =
        shenShaManager.calculate(
            daXianObserver.yearGanZhi,
            daXianObserver.monthGanZhi,
            daXianObserver.timeGanZhi,
            basePanel.bodyLifeModel.lifeGong,
            enteredGongMapper[EnumStars.Sun]!.enterGongInfo.gong,
            enteredGongMapper[EnumStars.Moon]!.enterGongInfo.gong,
            daXianObserver.isDayBirth);
    // 7. 计算化曜位置
    final Map<HuaYao, EnumStars> huaYaoMapper = huaYaoManager.calculate(
      mingGong: basePanel.bodyLifeModel.lifeGong,
      yearJiaZi: daXianObserver.yearGanZhi,
      monthJiaZi: daXianObserver.monthGanZhi,
    );
    final List<HuaYaoStarPair> huaYaoStarPairList = huaYaoMapper.entries
        .map((e) => HuaYaoStarPair(e.key, e.value))
        .toList();
    // 8. 计算十二长生
    final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper =
        calculateTwelveLong(daXianObserver.yearGanZhi);
    // 8.1. 根据十二长生enum 构建出对应 zhangsheng12ShenSha 并加入在神煞中,
    for (var i = 0; i < twelveZhangShengGongMapper.entries.length; i++) {
      final entry = twelveZhangShengGongMapper.entries.elementAt(i);
      final gong = entry.key;
      // 插入到第一个
      shenShaMapper[gong]!.insert(0,
          ZhangSheng12ShenSha(entry.value.name, JiXiongEnum.PING, null, null));
    }
    return DaXianPanelModel(
      starAngleMapper: starAngleMapper,
      enteredGongMapper: enteredGongMapper,
      fiveStarWalkingTypeMapper: fiveStarWalkingTypeMapper,
      shenShaMapper: shenShaMapper,
      huaYaoStarPairList: huaYaoStarPairList,
      twelveZhangShengGongMapper: twelveZhangShengGongMapper,
    );
  }

  Map<EnumTwelveGong, TwelveZhangSheng> calculateTwelveLong(JiaZi yearJiaZi) {
    // 年纳音五行 计算长生十二宫
    final yearNaYinFiveXing = yearJiaZi.naYin.fiveXing;
    final yearNaYinZhangSheng =
        TwelveZhangSheng.fiveXingZhangShengMapper[yearNaYinFiveXing]!;
    final result = <EnumTwelveGong, TwelveZhangSheng>{};
    for (var i = 0; i < yearNaYinZhangSheng.length; i++) {
      final zhangShengGong =
          EnumTwelveGong.getEnumTwelveGongByZhi(yearNaYinZhangSheng[i]);
      final zhangSheng = TwelveZhangSheng.values[i];
      result[zhangShengGong] = zhangSheng;
    }

    return result;
  }

  Map<EnumTwelveGong, EnumDestinyTwelveGong> orderDestinyTwelveGong(
      BodyLifeModel bodyLifeModel) {
    final lifeGong = bodyLifeModel.lifeGong;
    final revservedDiZhiList = DiZhi.values.reversed
        .map((dz) => EnumTwelveGong.getEnumTwelveGongByZhi(dz))
        .toList();
    final twelveGongStartWithLifGong =
        CollectUtils.changeSeq(lifeGong, revservedDiZhiList);
    final result = <EnumTwelveGong, EnumDestinyTwelveGong>{};
    final orderedDestinyGong =
        EnumDestinyTwelveGong.getOrderedDestinyTwelveGongList();
    for (var i = 0; i < twelveGongStartWithLifGong.length; i++) {
      final gong = twelveGongStartWithLifGong[i];
      final destinyGong = orderedDestinyGong[i];
      result[gong] = destinyGong;
    }

    return result;
  }

  /// 计算四主（命宫主、身宫主、命度主、身度主）
  BodyLifeModel calculateLifeBodyAndMaster(ZhouTianModel zhouTianModel,
      EnteredInfo sunEnteredInfo, EnteredInfo moonEnteredInfo) {
    JiaZi monthGanZhi = observerPosition.monthGanZhi;
    JiaZi timeGanZhi = observerPosition.timeGanZhi;

    final EnumTwelveGong lifeCountingToGong;
    switch (panelConfig.settleLifeType) {
      case EnumSettleLifeType.Mao:
        lifeCountingToGong = EnumTwelveGong.Mao;
        break;
      case EnumSettleLifeType.YinMaoChen:
        lifeCountingToGong = panelConfig.lifeCountingToGong;
      case EnumSettleLifeType.Mannual:
        throw UnimplementedError('不支持的立命方式:${panelConfig.settleLifeType}');
      case EnumSettleLifeType.Ascendant:
        throw UnimplementedError('不支持的立命方式:${panelConfig.settleLifeType}');
    }
    final EnumTwelveGong bodyCountingToGong;

    // 计算命宫
    final lifeGong = SettleLifeBodyService.settleLifeGong(
      sunEnteredInfo,
      lifeCountingToGong,
      observerPosition.monthGanZhi,
      observerPosition.timeGanZhi,
      panelConfig.islifeGongBySunRealTimeLocation,
    );

    // 计算身宫
    final bodyBody = SettleLifeBodyService.settleBodyGong(
      moonEnteredInfo,
      panelConfig.bodyCountingToGong,
      panelConfig.settleBodyType == EnumSettleBodyType.moon ? null : timeGanZhi,
    );
    // 根据太阳入宫的度数，以及命宫，确定命度
    // 太阳入宫度数，放在命宫中对应的度数就为命度
    // final lifeDegreeAtGong = sunEnteredInfo.atGongDegree;
    final gongPositionSeq = StarEnterInfoCalculator.generateGongSequence(
        zhouTianModel.zeroPointAtGong, zhouTianModel.gongDegreeSeq);
    final constellationPositionSeq =
        StarEnterInfoCalculator.generateConstellationSequence(
            zhouTianModel.zeroPointAtConstellation,
            zhouTianModel.starInnDegreeSeq);

    final lifeConstellationMaster = calculateLifeBodyConstellation(
        sunEnteredInfo.enterGongInfo,
        constellationPositionSeq,
        gongPositionSeq);
    final bodyConstellation = calculateLifeBodyConstellation(
        moonEnteredInfo.enterGongInfo,
        constellationPositionSeq,
        gongPositionSeq);
    return BodyLifeModel(
        lifeGongInfo:
            GongDegree(gong: lifeGong, degree: sunEnteredInfo.atGongDegree),
        lifeConstellationInfo: lifeConstellationMaster,
        bodyGongInfo:
            GongDegree(gong: bodyBody, degree: moonEnteredInfo.atGongDegree),
        bodyConstellationInfo: bodyConstellation);
  }

  ConstellationDegree calculateLifeBodyConstellation(
      GongDegree atGongDegree,
      List<ConstellationPosition> constellationPositionSeq,
      List<GongPosition> gongPositionSeq) {
    final lifeDegreeAtGongIndex =
        gongPositionSeq.indexWhere((t) => t.gong == atGongDegree.gong);
    double targetDegree = 0;
    if (gongPositionSeq.length == 12) {
      // 周天起始的位置为某个宫的0度，无需考虑是否“截断”
      targetDegree = gongPositionSeq[lifeDegreeAtGongIndex].startAtDegree +
          atGongDegree.degree;
    } else {
      // 周天起始的位置为某个宫位中的刻度，需要考虑“截断”
      if (lifeDegreeAtGongIndex == 0 || lifeDegreeAtGongIndex == 12) {
        // “截断”
        // lifeDegree = lifeDegreeAtGong;
        // 宫位截断段后，在seq头不得部分
        double gongSplitedLastPart = gongPositionSeq.first.endAtDegree -
            gongPositionSeq.first.startAtDegree;
        // 宫位截断后，在seq最后的部分
        double gongSplitedFirstPart = gongPositionSeq.last.degree;
        if (targetDegree <= gongSplitedFirstPart) {
          targetDegree = 330 + gongSplitedLastPart + atGongDegree.degree;
        } else {
          // 说明命度落点在宫位截断后的后半部分，也就是周天0度到宫位截断段
          // 需要将命度减去宫位截断段后的前段的长度
          targetDegree = atGongDegree.degree - gongSplitedFirstPart;
        }
      } else {
        targetDegree = gongPositionSeq[lifeDegreeAtGongIndex].startAtDegree +
            atGongDegree.degree;
      }
    }

    // 根据命度在周天的角度，确定命度所在的星宿
    final ConstellationDegree targetConstellation =
        StarEnterInfoCalculator.doFindConstellation(
            targetDegree, constellationPositionSeq);
    return targetConstellation;
  }

  Map<EnumStars, BaseFiveStarWalkingInfo> calculateFiveStarskWalingStatus(
      Map<EnumStars, StarAngleSpeed> starAngleMapper) {
    Map<EnumStars, BaseFiveStarWalkingInfo> result = {};
    for (var starAngle in starAngleMapper.entries) {
      final EnumStars star = starAngle.key;
      final double speed = starAngle.value.speed;

      final walkingTypeThreshold =
          StarWalkingTypeThreshold.moirasFiveStarsThresholdMapper[star]!;
      final walkingType = StarWalkingInfoUtils.getWalkingTypeByThreshold(
          speed, walkingTypeThreshold);
      result[star] = BaseFiveStarWalkingInfo(
        star: star,
        speed: speed,
        walkingType: walkingType,
        threshold: walkingTypeThreshold,
      );
    }
    return result;
  }

  Future<ZhouTianModel> getZhouTianModel() async {
    final ZhouTianModel zhouTianModel;

    final String assertName;
    if (panelConfig.celestialCoordinateSystem ==
        CelestialCoordinateSystem.ecliptic) {
      if (panelConfig.panelSystemType == PanelSystemType.tropical) {
        switch (panelConfig.constellationSystemType) {
          case ConstellationSystemType.classical:
            assertName = 'ecliptic_tropical_classical.json';
            break;
          case ConstellationSystemType.adjustedClassical:
            assertName = 'ecliptic_tropical_classical_adjested.json';
            break;
          case ConstellationSystemType.modern:
            assertName = 'ecplictic_tropical_morden.json';
            break;
        }
      } else {
        throw UnimplementedError(
            '不支持的星盘制式:${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
      }
    } else {
      if (panelConfig.panelSystemType == PanelSystemType.sidereal &&
          panelConfig.celestialCoordinateSystem ==
              CelestialCoordinateSystem.skyEquatorial) {
        switch (panelConfig.houseDivisionSystem) {
          case HouseDivisionSystem.equal:
            assertName = 'yuan_sky_equatorial_sidereal.json';
            break;
          case HouseDivisionSystem.equatorialSunMoon:
            // assertName = 'yuan_sky_equatorial_sidereal_sun_moon.json';
            throw UnimplementedError(
                '没有对应的宫位制式:${panelConfig.houseDivisionSystem}');
            break;
          case HouseDivisionSystem.equatorialZiWu:
            // assertName = 'yuan_sky_equatorial_sidereal_equal_zi_wu.json';
            throw UnimplementedError(
                '没有对应的宫位制式:${panelConfig.houseDivisionSystem}');
            break;
          case HouseDivisionSystem.equatorialFourZheng:
            // assertName = 'yuan_sky_equatorial_sidereal_four_zheng.json';
            throw UnimplementedError(
                '没有对应的宫位制式:${panelConfig.houseDivisionSystem}');
            break;
          default:
            throw UnimplementedError(
                '没有对应的宫位制式:${panelConfig.houseDivisionSystem}');
        }
        // zhouTianModel = jsonDecode(
        // File('assets/qizhengsiyu/yuan_sky_equatorial_sidereal.json')
        // .readAsStringSync());
      } else {
        throw UnimplementedError(
            '不支持的星盘制式:${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
      }
    }
    final jsonString =
        await rootBundle.loadString('assets/qizhengsiyu/$assertName');
    zhouTianModel = ZhouTianModel.fromJson(jsonDecode(jsonString));
    return zhouTianModel;
  }

  Map<EnumStars, EnteredInfo> getStarEnteredInfoMapper(
      Map<EnumStars, StarAngleSpeed> starAngleMapper,
      ZhouTianModel zhouTianModel) {
    final starDegreeSeq = starAngleMapper.entries
        .map((e) => StarDegree(star: e.key, degree: e.value.angle))
        .toList();
    final enteredInfoSeq = StarEnterInfoCalculator(zhouTianModel: zhouTianModel)
        .calculate(starDegreeSeq);
    final result = <EnumStars, EnteredInfo>{};
    for (var e in enteredInfoSeq) {
      result[e.originalStar.star] = e;
    }
    return result;
    // read ecliptic_tropical_calassical.json from assets
  }

  Future<Map<EnumStars, StarAngleSpeed>> getAllStarAngleRawInfo(
      ObserverPosition observerPosition) async {
    final StarAngleStrategy starAngleStrategy;
    final StarAngleSpeed qiStarInfo;
    if (panelConfig.celestialCoordinateSystem ==
        CelestialCoordinateSystem.ecliptic) {
      if (panelConfig.panelSystemType == PanelSystemType.tropical) {
        starAngleStrategy = EclipticTropicalStrategy();
        qiStarInfo = StarAngleSpeed(
          angle: ziQi(observerPosition.dateTime),
          speed: 0.0352,
        );
      } else {
        throw UnimplementedError(
            '不支持的星盘制式:${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
      }
    } else {
      if (panelConfig.panelSystemType == PanelSystemType.sidereal &&
          panelConfig.celestialCoordinateSystem ==
              CelestialCoordinateSystem.skyEquatorial) {
        qiStarInfo = StarAngleSpeed(
          angle: shouShiLiCalculateZiQiPosition(observerPosition.dateTime,
              circleDegrees: 365.25),
          speed: 0.0352,
        );
        starAngleStrategy = EquatorialSiderealStrategy();
      } else {
        throw UnimplementedError(
            '不支持的星盘制式:${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
      }
    }

    double julianDay = JulianDayConverter.dateTimeToJulianDay(
        observerPosition.dateTime.toUtc());
    final geopos = [
      observerPosition.longitude,
      observerPosition.latitude,
      observerPosition.altitude,
    ];

    final results = await Future.wait([
      EnumStars.Sun,
      EnumStars.Moon,
      EnumStars.Jupiter,
      EnumStars.Saturn,
      EnumStars.Mars,
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Bei,
      EnumStars.Ji
    ].map((e) =>
        Future.sync(() => starAngleStrategy.calculate(e, julianDay, geopos))));
    Map<EnumStars, StarAngleSpeed> resultMapper = {};

    resultMapper[EnumStars.Sun] =
        StarAngleSpeed(angle: results[0].angle, speed: results[0].speed);
    resultMapper[EnumStars.Moon] =
        StarAngleSpeed(angle: results[1].angle, speed: results[1].speed);
    resultMapper[EnumStars.Jupiter] =
        StarAngleSpeed(angle: results[2].angle, speed: results[2].speed);
    resultMapper[EnumStars.Saturn] =
        StarAngleSpeed(angle: results[3].angle, speed: results[3].speed);
    resultMapper[EnumStars.Mars] =
        StarAngleSpeed(angle: results[4].angle, speed: results[4].speed);
    resultMapper[EnumStars.Mercury] =
        StarAngleSpeed(angle: results[5].angle, speed: results[5].speed);
    resultMapper[EnumStars.Venus] =
        StarAngleSpeed(angle: results[6].angle, speed: results[6].speed);
    resultMapper[EnumStars.Bei] =
        StarAngleSpeed(angle: results[7].angle, speed: results[7].speed);
    resultMapper[EnumStars.Ji] =
        StarAngleSpeed(angle: results[8].angle, speed: results[8].speed);
    resultMapper[EnumStars.Luo] = resultMapper[EnumStars.Ji]!
        .copyWith(angle: (results[8].angle + 180) % 360);

    resultMapper[EnumStars.Qi] = qiStarInfo;
    return resultMapper;
  }

  // 总述： 紫炁计算，基于《授时历》，使用笨办法计算紫炁的位置。
// --- 常量定义 ---
// 基于《授时历》的参考时间点 (假设为 UTC)
  static DateTime referenceDateTimeUtc = DateTime.utc(1280, 12, 14, 1, 29, 36);

// --- !!! 重要假设与占位符 !!! ---
// 参考位置: 女宿二度 (Nǚ Xiù èr dù)
// 假设已转换为标准 360 度体系下的度数。
// !!! 如果你有更精确的转换值，请务必替换这里的数值 !!!
  static double referencePositionDegrees = 284.0; // 假设此值基于 360 度圆周

// 紫气每年运行度数 (来自用户描述，假设基于 360 度圆周)
  static double annualRateDegrees = 13.050460;
// 回归年平均天数
  static double daysInTropicalYear = 365.2425;
// 紫气每日运行度数 (根据年速率计算，假设基于 360 度圆周)
  static double dailyRateDegrees = annualRateDegrees / daysInTropicalYear;

  /// 使用基于《授时历》的 "笨办法" 计算紫气 (Zǐ Qì) 的位置。
  ///
  /// 允许指定用于归一化的圆周总度数。
  ///
  /// [targetDateTime]: 需要计算位置的目标日期和时间。
  /// [circleDegrees]: (可选) 指定圆周的总度数，用于结果归一化。
  ///                  例如：360.0 (标准度数), 365.25 (中国古度/周天度数)。
  ///                  默认为 360.0。
  ///
  /// 返回值: 紫气的位置，已根据 [circleDegrees] 归一化。
  ///
  /// 注意: 此函数假设输入的 referencePositionDegrees 和 dailyRateDegrees
  /// 是基于标准 360 度圆周的。最终的归一化步骤将结果调整到 [0, circleDegrees) 范围内。
  static double shouShiLiCalculateZiQiPosition(
    DateTime targetDateTime, {
    double circleDegrees = 360.0, // 默认圆周为 360 度
  }) {
    // 基本输入检查
    if (circleDegrees <= 0) {
      throw ArgumentError('circleDegrees 参数必须为正数。');
    }

    // 确保目标时间也使用 UTC 进行计算
    final DateTime targetDateTimeUtc = targetDateTime.toUtc();

    // 计算目标时间与参考时间之间的时间差
    final Duration difference =
        targetDateTimeUtc.difference(referenceDateTimeUtc);

    // 将时间差转换为以天为单位的小数形式
    final double differenceInDays =
        difference.inMicroseconds / Duration.microsecondsPerDay;

    // 根据每日速率计算总的角度位移 (基于 360 度体系)
    final double angularShift = differenceInDays * dailyRateDegrees;

    // 计算未归一化的位置 (基于 360 度体系)
    final double rawPosition = referencePositionDegrees + angularShift;

    // 将结果归一化到 [0, circleDegrees) 范围内
    double normalizedPosition = rawPosition % circleDegrees;
    if (normalizedPosition < 0) {
      // 如果取模结果为负，加上一个周期使其变为正数
      normalizedPosition += circleDegrees;
    }

    return normalizedPosition;
  }

  double ziQi(DateTime datetime) {
    // # moria 软件中
    // # 2013-04-09 02:57 am 紫炁在戌0°
    // # 2013-04-10 02:57 am 紫炁在戌0°02′07″处
    // # 每24小时运行 02′07″ 或 0.0352° 度 28年运行一周，一年以365.2422天为准
    // # 紫炁的运行规律为 一日行三分五十七秒，一宫住二十八个月，二十八年行一周天，一日行3分57秒（百进制）

    // TODO:  replace timeZone from Fixed to TimeZone
    tz.TZDateTime baseShangHaiTime =
        tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
    // BASE_SHANG_HAI_TIME.toUtc();

    const angleForEachMinutes = 0.0352 / (24 * 60);
    // final localTime = tz.TZDateTime(
    //     tz.getLocation(observerPosition.timezone),
    //     datetime.year,
    //     datetime.month,
    //     datetime.day,
    //     datetime.hour,
    //     datetime.minute);
    // final targetTime = tz.TZDateTime.from(localTime, tz.getLocation('Asia/Shanghai'));
    //
    // if (targetTime.isAtSameMomentAs(BASE_SHANG_HAI_TIME)){
    //   return 0;
    // }
    //
    // var diffInMinutes = targetTime.isBefore(BASE_SHANG_HAI_TIME)
    //     ? BASE_SHANG_HAI_TIME.difference(targetTime)
    //     : targetTime.difference(BASE_SHANG_HAI_TIME);
    if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
      return 0;
    }

    var diffInMinutes = datetime.isBefore(baseShangHaiTime)
        ? baseShangHaiTime.difference(datetime)
        : datetime.difference(baseShangHaiTime);

    // minutes_difference = delta.total_seconds() // 60
    double result = diffInMinutes.inMinutes * angleForEachMinutes;
    if (result >= 360) {
      result -= 360;
    }

    return result;
  }
}
