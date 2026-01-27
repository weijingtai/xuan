import 'dart:convert';
import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lunar/lunar.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/models/panel_config.dart';
import 'package:qizhengsiyu/models/star_enter_info.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';
import 'package:qizhengsiyu/services/an_shen_li_ming_service.dart';
import 'package:qizhengsiyu/services/generate_base_panel_service.dart';
import 'package:sweph/sweph.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';

import '../enums/enum_moon_phases.dart';
import '../enums/enum_settle_life_body.dart';
import '../enums/enum_star_hidden_type.dart';
import '../models/base_panel_model.dart';
import '../models/di_zhi_shen_sha.dart';
import '../models/hua_yao.dart';
import '../models/naming_degree_pair.dart';
import '../models/observer_position.dart';
import '../models/panel_stars_info.dart';
import '../models/star_angle_speed.dart';
import '../models/star_inn_gong_degree.dart';
import '../models/stars_angle.dart';
import '../models/eleven_stars_info.dart';
import '../qi_zheng_si_yu_constant_resources.dart';
import '../utils/star_walking_info_utils.dart';
import 'StarsResolver.dart';

class QiZhengSiYuViewModel extends ChangeNotifier {
  static final _fiveStarsSeq = [
    EnumStars.Jupiter,
    EnumStars.Mars,
    EnumStars.Saturn,
    EnumStars.Venus,
    EnumStars.Mercury
  ];
  // 本命星盘
  StarsAngle? _basicLifeStarsAngle;
  StarsAngle? get basicLifeStarsAngle => _basicLifeStarsAngle;

  double _baseMiniSafetyAngle = 0;
  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  double _fateMiniSafetyAngle = 0;
  List<UIStarModel> _uiFateLifeStars = [];
  List<UIStarModel> get uiFateLifeStars => _uiFateLifeStars;

  PanelStarsInfo? _basicLifePanelStarsInfo;
  PanelStarsInfo? get basicLifePanelStarsInfo => _basicLifePanelStarsInfo;

  // 行限星盘, 起盘当时
  StarsAngle? _fateLifeStarsAngle;
  StarsAngle? get fateLifeStarsAngle => _fateLifeStarsAngle;
  PanelStarsInfo? _fateLifePanelStarsInfo;
  PanelStarsInfo? get fateLifePanelStarsInfo => _fateLifePanelStarsInfo;

  Map<EnumStars, FiveStarWalkingInfo>? _daXianMapper;
  Map<EnumStars, FiveStarWalkingInfo>? get daXianMapper => _daXianMapper;

  ObserverPosition? _observerPosition;

  BuildContext context;
  QiZhengSiYuViewModel(this.context);

  HuaYaoManager? _huaYaoManager;
  HuaYaoManager get huaYaoManager {
    return _huaYaoManager!;
  }

  ShenShaManager? _shenShaManager;
  ShenShaManager get shenShaManager {
    return _shenShaManager!;
  }

  Future<void> init() async {
    final result = await Future.wait([
      loadShenShaManager(),
      loadHuaYaoManager(),
    ]);
    _shenShaManager = result[0] as ShenShaManager;
    _huaYaoManager = result[1] as HuaYaoManager;
  }

  void calculateBasicStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double basicLifeStarCenterCircleSize) {
    _baseMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        basicLifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    _baseMiniSafetyAngle =
        _baseMiniSafetyAngle.ceilToDouble() + 2.0; // 增加2度，使得UI层面更加好看
  }

  void calculateFateStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double lifeStarCenterCircleSize) {
    _fateMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        lifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    _fateMiniSafetyAngle =
        _fateMiniSafetyAngle.ceilToDouble() + 2.0; // 增加2度，使得UI层面更加好看
  }

  void reset() {
    if (_basicLifeStarsAngle != null) {
      _basicLifeStarsAngle = null;
    }
    if (_fateLifeStarsAngle != null) {
      _fateLifeStarsAngle = null;
    }
    if (_fateLifePanelStarsInfo != null) {
      _fateLifeStarsAngle = null;
    }
    if (_basicLifePanelStarsInfo != null) {
      _basicLifePanelStarsInfo = null;
    }
    _observerPosition = null;
  }

  void calculate(ObserverPosition observerPosition) {
    _doCalculateLifePanel(observerPosition);
    _observerPosition = observerPosition;

    notifyListeners();

    // if (observerPosition.fateLifeUtcTime != null) {
    //   _daXianMapper = calculateFiveStars();
    //   notifyListeners();
    // }
  }

  _doCalculateLifePanel(ObserverPosition observerPosition) {
    _basicLifeStarsAngle = calculateAllStarsAngleOnZodiac(
        observerPosition, observerPosition.utcDateTime);

    _basicLifePanelStarsInfo = calculateElevenStartInfo(
        _basicLifeStarsAngle!,
        EnumStarHiddenType.degree15,
        StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper.mapper,
        isDayOrNight: true);

    // TODO: 所有的ui数据都应该被存储到数据库中，这样减少计算量
    _uiBasicLifeStars =
        calculateUIStars(_basicLifeStarsAngle!, _baseMiniSafetyAngle);

    // if (observerPosition.fateLifeDateTime != null) {
    //   _fateLifeStarsAngle = calculateAllStarsAngleOnZodiac(
    //       observerPosition, observerPosition.fateLifeUtcTime!);
    //   _fateLifePanelStarsInfo = calculateElevenStartInfo(
    //       _fateLifeStarsAngle!,
    //       EnumStarHiddenType.degree15,
    //       StarPanelType
    //           .ZodiacTropicalOriginalClassicStarsInnSystemMapper.mapper,
    //       isDayOrNight: true);
    //   _uiFateLifeStars =
    //       calculateUIStars(_fateLifeStarsAngle!, _fateMiniSafetyAngle);
    //   // TODO: 所有的ui数据都应该被存储到数据库中，这样减少计算量
    // }
  }

  List<UIStarModel> calculateUIStarsFromMapper(
      Map<EnumStars, StarAngleSpeed> starsAngleMapper, double miniSafetyAngle) {
    List<UIStarModel> unadjustedStarList = [
      UIStarModel(
        star: EnumStars.Sun,
        originalAngle: starsAngleMapper[EnumStars.Sun]!.angle,
        priority: 4,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Moon,
        originalAngle: starsAngleMapper[EnumStars.Moon]!.angle,
        priority: 3,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Venus,
        originalAngle: starsAngleMapper[EnumStars.Venus]!.angle,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Jupiter,
        originalAngle: starsAngleMapper[EnumStars.Jupiter]!.angle,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mercury,
        originalAngle: starsAngleMapper[EnumStars.Mercury]!.angle,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mars,
        originalAngle: starsAngleMapper[EnumStars.Mars]!.angle,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Saturn,
        originalAngle: starsAngleMapper[EnumStars.Saturn]!.angle,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Qi,
        originalAngle: starsAngleMapper[EnumStars.Qi]!.angle,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Bei,
        originalAngle: starsAngleMapper[EnumStars.Bei]!.angle,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Luo,
        originalAngle: starsAngleMapper[EnumStars.Luo]!.angle,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Ji,
        originalAngle: starsAngleMapper[EnumStars.Ji]!.angle,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
    ];
    return StarsResolver.resolveUIStars(unadjustedStarList);
  }

  List<UIStarModel> calculateUIStars(
      StarsAngle starsAngle, double miniSafetyAngle) {
    List<UIStarModel> unadjustedStarList = [
      UIStarModel(
        star: EnumStars.Sun,
        originalAngle: starsAngle.sun,
        priority: 4,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Moon,
        originalAngle: starsAngle.moon,
        priority: 3,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Venus,
        originalAngle: starsAngle.venus,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Jupiter,
        originalAngle: starsAngle.jupiter,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mercury,
        originalAngle: starsAngle.water,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mars,
        originalAngle: starsAngle.mars,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Saturn,
        originalAngle: starsAngle.saturn,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Qi,
        originalAngle: starsAngle.qi,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Bei,
        originalAngle: starsAngle.lilith,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Luo,
        originalAngle: starsAngle.southNode,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Ji,
        originalAngle: starsAngle.northNode,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
    ];
    return StarsResolver.resolveUIStars(unadjustedStarList);
  }

  Map<EnumStars, FiveStarWalkingInfo> calculateFiveStars() {
    Map<EnumStars, FiveStarWalkingInfo> result = {};
    for (var i = 0; i < _fiveStarsSeq.length; i++) {
      EnumStars star = _fiveStarsSeq[i];
      result[star] = StarWalkingInfoUtils.calculateStarWalkingInfo(
          star, _observerPosition!, StarsAngle.moirasFiveStartsMapper);
    }
    return result;
  }

  /// “日月合” 界定标准为 太阳与月亮在1°~2°度之间（占星普遍认为误差在0.5°之间为合理误差，故此处默认为1.5°）
  /// 日蚀的判断标准为：日月合[新月]+白昼+日罗合，其中“日罗合”一般认为在10~15°以内
  /// 月蚀的判断标准为：满月+夜晚+月计合，其中“月罗合”一般认为在10~15°以内
  @deprecated
  PanelStarsInfo calculateElevenStartInfo(
      StarsAngle starsAngle,
      EnumStarHiddenType hiddenType,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper,
      {double isSunLunarTouchDegreeRange = 1.5,
      double eclipseDegreeRange = 15,
      bool isDayOrNight = false // true 为白天，false 为夜晚
      }) {
    ElevenStarsInfo sunInfo =
        _doCalculateStarInfo(EnumStars.Sun, starsAngle.sun, mapper);
    MoonInfo moonInfo = _doCalculateMoonInfo(
        starsAngle.moon, sunInfo, mapper, isSunLunarTouchDegreeRange);

    ElevenStarsInfo qiInfo =
        _doCalculateStarInfo(EnumStars.Qi, starsAngle.qi, mapper);
    ElevenStarsInfo beiInfo =
        _doCalculateStarInfo(EnumStars.Bei, starsAngle.lilith, mapper);

    LouJiStarsInfo luoInfo = _doCalculateLuoJiInfo(EnumStars.Luo,
        starsAngle.northNode, sunInfo, moonInfo, mapper, eclipseDegreeRange);
    LouJiStarsInfo jiInfo = _doCalculateLuoJiInfo(EnumStars.Ji,
        starsAngle.southNode, sunInfo, moonInfo, mapper, eclipseDegreeRange);
    // StarsAngle.moirasFiveStartsMapper

    FiveStarsInfo venusInfo = _doCalculateFiveStarInfo(
        EnumStars.Venus,
        starsAngle.venus,
        starsAngle.venusSpeed,
        StarsAngle.moirasFiveStartsMapper[EnumStars.Venus]!,
        mapper);
    // setupIsHidden(sunInfo, VenusInfo, hiddenType);
    FiveStarsInfo jupiterInfo = _doCalculateFiveStarInfo(
        EnumStars.Jupiter,
        starsAngle.jupiter,
        starsAngle.jupiterSpeed,
        StarsAngle.moirasFiveStartsMapper[EnumStars.Jupiter]!,
        mapper);
    // setupIsHidden(sunInfo, JupiterInfo, hiddenType);
    FiveStarsInfo marsInfo = _doCalculateFiveStarInfo(
        EnumStars.Mars,
        starsAngle.mars,
        starsAngle.marsSpeed,
        StarsAngle.moirasFiveStartsMapper[EnumStars.Mars]!,
        mapper);
    // setupIsHidden(sunInfo, MarsInfo, hiddenType);
    FiveStarsInfo saturnInfo = _doCalculateFiveStarInfo(
        EnumStars.Saturn,
        starsAngle.saturn,
        starsAngle.saturnSpeed,
        StarsAngle.moirasFiveStartsMapper[EnumStars.Saturn]!,
        mapper);
    // setupIsHidden(sunInfo, SaturnInfo, hiddenType);
    FiveStarsInfo waterInfo = _doCalculateFiveStarInfo(
        EnumStars.Mercury,
        starsAngle.water,
        starsAngle.waterSpeed,
        StarsAngle.moirasFiveStartsMapper[EnumStars.Mercury]!,
        mapper);
    // setupIsHidden(sunInfo, waterInfo, hiddenType);

    return PanelStarsInfo(
        sun: sunInfo,
        moon: moonInfo,
        qi: qiInfo,
        bei: beiInfo,
        luo: luoInfo,
        ji: jiInfo,
        venus: venusInfo,
        jupiter: jupiterInfo,
        mars: marsInfo,
        saturn: saturnInfo,
        water: waterInfo,
        isSunEclipse: false,
        isLunarEclipse: false,
        isSunLunarTouch: false
        // isSunEclipse: isDayOrNight
        //     ? moonInfo.moonPhase == EnumMoonPhases.New && luoInfo.isRoundSun
        //     : false,
        // isLunarEclipse: isDayOrNight
        //     ? false
        //     : moonInfo.moonPhase == EnumMoonPhases.Full && jiInfo.isRoundMoon,
        // isSunLunarTouch: isInDegreeRange(
        //     sunInfo.angle + isSunLunarTouchDegreeRange,
        //     sunInfo.angle - isSunLunarTouchDegreeRange,
        //     moonInfo.angle)
        );
  }

  MoonInfo _doCalculateMoonInfo(double moonAngle, ElevenStarsInfo sunInfo,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper,
      [double rangeDegree = 1]) {
    Tuple2<EnumTwelveGong, double> sunEnteredGong =
        SettleLifeBodyService.starEnterGong(moonAngle);
    Tuple2<Enum28Constellations, double> sunEnteredInn =
        SettleLifeBodyService.starEnterStarInn(moonAngle, mapper);

    double moonPhase = moonAngle - sunInfo.angle;
    if (moonPhase < 0) {
      moonPhase += 360;
    }
    return MoonInfo(
        angle: moonAngle,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Moon, degree: moonAngle),
          enterGongInfo: GongDegree(
              gong: sunEnteredGong.item1, degree: sunEnteredGong.item2),
          enterInnInfo: ConstellationDegree(
              constellation: sunEnteredInn.item1, degree: sunEnteredInn.item2),
        ),
        moonPhase:
            EnumMoonPhases.fromAngle(moonPhase, offsetDegree: rangeDegree));
  }

  ElevenStarsInfo _doCalculateStarInfo(EnumStars star, double starAngle,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    Tuple2<EnumTwelveGong, double> sunEnteredGong =
        SettleLifeBodyService.starEnterGong(starAngle);
    Tuple2<Enum28Constellations, double> sunEnteredInn =
        SettleLifeBodyService.starEnterStarInn(starAngle, mapper);

    return ElevenStarsInfo(
        star: star,
        angle: starAngle,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: star, degree: starAngle),
          enterGongInfo: GongDegree(
              gong: sunEnteredGong.item1, degree: sunEnteredGong.item2),
          enterInnInfo: ConstellationDegree(
              constellation: sunEnteredInn.item1, degree: sunEnteredInn.item2),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.1,
        priority: EnumStarsPriority.Primary);
  }

  LouJiStarsInfo _doCalculateLuoJiInfo(
      EnumStars star,
      double starAngle,
      ElevenStarsInfo sunInfo,
      ElevenStarsInfo moonInfo,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper,
      double roundingSunMoonDegreeRange) {
    Tuple2<EnumTwelveGong, double> sunEnteredGong =
        SettleLifeBodyService.starEnterGong(starAngle);
    Tuple2<Enum28Constellations, double> sunEnteredInn =
        SettleLifeBodyService.starEnterStarInn(starAngle, mapper);
    return LouJiStarsInfo(
      star: star,
      angle: starAngle,
      enterInfo: EnteredInfo(
        originalStar: StarDegree(star: star, degree: starAngle),
        enterGongInfo: GongDegree(
            gong: sunEnteredGong.item1, degree: sunEnteredGong.item2),
        enterInnInfo: ConstellationDegree(
            constellation: sunEnteredInn.item1, degree: sunEnteredInn.item2),
      ),
      // isRoundMoon: isInDegreeRange(
      //     moonInfo.angle + roundingSunMoonDegreeRange,
      //     moonInfo.angle - roundingSunMoonDegreeRange,
      //     starAngle),
      // isRoundSun: isInDegreeRange(sunInfo.angle + roundingSunMoonDegreeRange,
      //     sunInfo.angle - roundingSunMoonDegreeRange, starAngle),
      // roundDegreeRange: roundingSunMoonDegreeRange
    );
  }

  FiveStarsInfo _doCalculateFiveStarInfo(
      EnumStars star,
      double starAngle,
      double starSpeed,
      Tuple6<double, double, double, double, double?, double?> tuple6,
      Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper) {
    Tuple2<EnumTwelveGong, double> sunEnteredGong =
        SettleLifeBodyService.starEnterGong(starAngle);
    Tuple2<Enum28Constellations, double> sunEnteredInn =
        SettleLifeBodyService.starEnterStarInn(starAngle, mapper);

    return FiveStarsInfo(
        star: star,
        angle: starAngle,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: star, degree: starAngle),
          enterGongInfo: GongDegree(
              gong: sunEnteredGong.item1, degree: sunEnteredGong.item2),
          enterInnInfo: ConstellationDegree(
              constellation: sunEnteredInn.item1, degree: sunEnteredInn.item2),
        ),
        walkingSpeed: starSpeed,
        fiveStarWalkingType:
            StarWalkingInfoUtils.getWalkingType(starSpeed, tuple6));
  }

  // ElevenStarsInfo setupIsHidden(ElevenStarsInfo sunInfo, FiveStarsInfo star,
  //     EnumStarHiddenType hiddenType) {
  //   if (hiddenType == EnumStarHiddenType.degree15) {
  //     double sunRangeDegreeStartAt = sunInfo.angle - 15;
  //     double sunRangeDegreeEndAt = sunInfo.angle + 15;

  //     if (isInDegreeRange(
  //         sunRangeDegreeStartAt, sunRangeDegreeEndAt, star.angle)) {
  //       return star.copyWith(isHidden: true);
  //     }
  //   } else if (hiddenType == EnumStarHiddenType.sameGong &&
  //       sunInfo.enteredGong == star.enteredGong) {
  //     return star.copyWith(isHidden: true);
  //   }
  //   return star;
  // }

  static bool isInDegreeRange(
      double theStartDegree, double theEndDegree, double doTestDegree) {
    double startDegree = theStartDegree;
    if (startDegree < 0) {
      startDegree += 360;
    }
    if (startDegree >= 0) {
      startDegree -= 360;
    }
    double endDegree = theEndDegree;
    if (endDegree >= 360) {
      endDegree -= 360;
    }
    if (endDegree < 0) {
      endDegree += 360;
    }
    double testedDegree = doTestDegree;
    if (doTestDegree >= 360) {
      doTestDegree -= 360;
    }
    if (doTestDegree < 0) {
      doTestDegree += 360;
    }
    if (startDegree == endDegree) {
      throw ArgumentError("startDegree == endDegree");
    }
    if (startDegree < endDegree) {
      return testedDegree >= startDegree && testedDegree <= endDegree;
    } else {
      if (testedDegree >= startDegree) {
        return true;
      } else {
        if (testedDegree <= endDegree) {
          return true;
        }
      }
    }
    return false;

    // return testedDegree >= startDegree && testedDegree <= endDegree;
  }

  StarsAngle calculateAllStarsAngleOnZodiac(
      BaseObserverPosition observerPosition, DateTime datetime) {
    double roundHelper(double number) {
      // 保留小数点后两位，四舍五入
      num factor = pow(10, 2);
      return ((number * factor).round() / factor);
    }

    double ziQi() {
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

    // 设置观察者的位置
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = datetime;

    final double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    var lunar =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    var sun =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);

    var Venus = Sweph.swe_calc(julianDay, HeavenlyBody.SE_VENUS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Jupiter = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Mars = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Saturn = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);

    // 计算北交点的黄道角度
    var northNode = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_NODE, SwephFlag.SEFLG_SWIEPH);
    double northNodeAngle = northNode.longitude;
    // 计算南交点的黄道角度
    double southNodeAngle = (northNodeAngle + 180) % 360;
    var lilith = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_APOG, SwephFlag.SEFLG_SWIEPH);

    return StarsAngle(
        moon: roundHelper(lunar.longitude),
        sun: roundHelper(sun.longitude),
        venus: roundHelper(Venus.longitude),
        venusSpeed: roundHelper(Venus.speedInLongitude),
        jupiter: roundHelper(Jupiter.longitude),
        jupiterSpeed: roundHelper(Jupiter.speedInLongitude),
        water: roundHelper(water.longitude),
        waterSpeed: roundHelper(water.speedInLongitude),
        mars: roundHelper(Mars.longitude),
        marsSpeed: roundHelper(Mars.speedInLongitude),
        saturn: roundHelper(Saturn.longitude),
        saturnSpeed: roundHelper(Saturn.speedInLongitude),
        northNode: roundHelper(northNodeAngle),
        southNode: roundHelper(southNodeAngle),
        lilith: roundHelper(lilith.longitude),
        qi: roundHelper(ziQi()));
  }

  // ... 现有代码 ...

  /// 计算赤道坐标系下所有星体的角度
  // StarsAngle calculateAllStarsAngleOnEquatorial(
  //     BaseObserverPosition observerPosition, DateTime datetime) {
  //   double roundHelper(double number) {
  //     // 保留小数点后两位，四舍五入
  //     num factor = pow(10, 2);
  //     return ((number * factor).round() / factor);
  //   }

  //   // 设置观察者的位置
  //   Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
  //       observerPosition.altitude);
  //   DateTime utcTime = datetime;

  //   final double julianDay = Sweph.swe_julday(
  //       utcTime.year,
  //       utcTime.month,
  //       utcTime.day,
  //       utcTime.hour + utcTime.minute / 60,
  //       CalendarType.SE_GREG_CAL);

  //   var lunar = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON,
  //       SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_EQUATORIAL);
  //   var sun = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_SUN,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);

  //   var Venus = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_VENUS,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);
  //   var Jupiter = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_JUPITER,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);
  //   var water = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_MERCURY,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);
  //   var Mars = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_MARS,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);
  //   var Saturn = Sweph.swe_calc(
  //       julianDay,
  //       HeavenlyBody.SE_SATURN,
  //       SwephFlag.SEFLG_SWIEPH |
  //           SwephFlag.SEFLG_EQUATORIAL |
  //           SwephFlag.SEFLG_SPEED);

  //   // 计算北交点的赤道角度
  //   var northNode = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MEAN_NODE,
  //       SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_EQUATORIAL);
  //   double northNodeAngle = northNode.longitude;
  //   // 计算南交点的赤道角度
  //   double southNodeAngle = (northNodeAngle + 180) % 360;
  //   var lilith = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MEAN_APOG,
  //       SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_EQUATORIAL);

  //   // 紫气计算方法与黄道坐标系相同，但需要转换到赤道坐标系
  //   double ziQiEcliptic = _calculateZiQi(datetime);
  //   // 将紫气从黄道坐标转换为赤道坐标
  //   // double ziQiEquatorial =
  //       // _convertEclipticToEquatorial(ziQiEcliptic, julianDay);

  //   return StarsAngle(
  //       moon: roundHelper(lunar.longitude),
  //       sun: roundHelper(sun.longitude),
  //       Venus: roundHelper(Venus.longitude),
  //       VenusSpeed: roundHelper(Venus.speedInLongitude),
  //       Jupiter: roundHelper(Jupiter.longitude),
  //       JupiterSpeed: roundHelper(Jupiter.speedInLongitude),
  //       water: roundHelper(water.longitude),
  //       waterSpeed: roundHelper(water.speedInLongitude),
  //       Mars: roundHelper(Mars.longitude),
  //       MarsSpeed: roundHelper(Mars.speedInLongitude),
  //       Saturn: roundHelper(Saturn.longitude),
  //       SaturnSpeed: roundHelper(Saturn.speedInLongitude),
  //       northNode: roundHelper(northNodeAngle),
  //       southNode: roundHelper(southNodeAngle),
  //       lilith: roundHelper(lilith.longitude),
  //       qi: roundHelper(ziQiEquatorial));
  // }

  /// 计算紫气在黄道坐标系中的位置
  double _calculateZiQi(DateTime datetime) {
    // 紫气基准时间：2013-04-09 02:57 am 紫气在戌0°
    tz.TZDateTime baseShangHaiTime =
        tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);

    const angleForEachMinutes = 0.0352 / (24 * 60);

    if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
      return 0;
    }

    var diffInMinutes = datetime.isBefore(baseShangHaiTime)
        ? baseShangHaiTime.difference(datetime)
        : datetime.difference(baseShangHaiTime);

    double result = diffInMinutes.inMinutes * angleForEachMinutes;
    if (result >= 360) {
      result -= 360;
    }

    return result;
  }

  /// 将黄道坐标转换为赤道坐标
  // double _convertEclipticToEquatorial(
  //     double eclipticLongitude, double julianDay) {
  //   // 获取当前的黄赤交角
  //   double obliquity = Sweph.swe_get_epsilon(julianDay, SwephFlag.SEFLG_SWIEPH);

  //   // 转换为弧度
  //   double eclipticLongitudeRad = eclipticLongitude * pi / 180;
  //   double obliquityRad = obliquity * pi / 180;

  //   // 黄道坐标转赤道坐标公式
  //   // tan(α) = sin(λ) * cos(ε) / cos(λ)
  //   // 其中 α 是赤经，λ 是黄经，ε 是黄赤交角
  //   double rightAscension = atan2(sin(eclipticLongitudeRad) * cos(obliquityRad),
  //       cos(eclipticLongitudeRad));

  //   // 转换为度数并确保在0-360范围内
  //   double rightAscensionDeg = rightAscension * 180 / pi;
  //   if (rightAscensionDeg < 0) {
  //     rightAscensionDeg += 360;
  //   }

  //   return rightAscensionDeg;
  // }

  // ... 现有代码 ...
  GenerateBasePanelService? generateBasePanelService;
  calculateBasePanel(DivinationInfoModel divinationInfo) async {
    generateBasePanelService = GenerateBasePanelService(
        observerPosition: convertToObserverPosition(divinationInfo),
        panelConfig: generatePanelConfig(),
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
        zhouTianModelManager: ZhouTianModelManager.instance);
    BasePanelModel basePanelModel = await generateBasePanelService!.calculate();
    List<UIStarModel> uiBaseStarLis = calculateUIStarsFromMapper(
        basePanelModel.starAngleMapper, _baseMiniSafetyAngle);
    _uiBasicLifeStars = uiBaseStarLis;
    notifyListeners();
    print(divinationInfo.divinationDatetime.datetime);

    // StarsAngle starsAngle = basePanelModel.starAngleMapper[EnumStars.moon]!;
    print(jsonEncode(basePanelModel));
  }

  BasePanelConfig generatePanelConfig() {
    return BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
        houseDivisionSystem: HouseDivisionSystem.equal,
        panelSystemType: PanelSystemType.tropical,
        constellationSystemType: ConstellationSystemType.classical,
        settleLifeType: EnumSettleLifeType.Mao,
        settleBodyType: EnumSettleBodyType.moon,
        islifeGongBySunRealTimeLocation: true);
  }

  ObserverPosition convertToObserverPosition(
      DivinationInfoModel divinationInfo) {
    DateTime birthdayUtcTime =
        divinationInfo.divinationDatetime.datetime.toUtc();
    // if (fateLifeDateTime != null) {
    //   fateLifeUtcTime = toUtcTime(timezone, fateLifeDateTime!);
    // }
    Lunar lunar = Lunar.fromDate(birthdayUtcTime);
    return ObserverPosition(
        dateTime: divinationInfo.divinationDatetime.datetime,
        latitude:
            divinationInfo.divinationDatetime.location!.coordinates!.latitude,
        longitude:
            divinationInfo.divinationDatetime.location!.coordinates!.longitude,
        altitude: 0,
        timezone: divinationInfo.divinationDatetime.location!.address!.timezone,
        dayGanZhi: JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!,
        yearGanZhi: JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!,
        monthGanZhi: JiaZi.getFromGanZhiValue(lunar.getMonthInGanZhi())!,
        timeGanZhi: JiaZi.getFromGanZhiValue(lunar.getTimeInGanZhi())!,
        isDayBirth: true);
  }

  Future<ShenShaManager> loadShenShaManager() async {
    // 并行加载所有神煞数据
    final List<String> jsonStrings = await Future.wait([
      rootBundle.loadString('assets/shen_sha/74_shensha_tiangan.json'),
      rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_year.json'),
      rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_month.json'),
      rootBundle.loadString('assets/shen_sha/74_shensha_ganzhi.json'),
      rootBundle.loadString('assets/shen_sha/74_shensha_bundle.json'),
      rootBundle.loadString('assets/shen_sha/74_shensha_others.json'),
    ]);

    final tianGanJsonString = jsonStrings[0];
    final yearDiZhiJsonString = jsonStrings[1];
    final monthDiZhiJsonString = jsonStrings[2];
    final ganzhiJsonString = jsonStrings[3];
    final bundledShenShaJsonString = jsonStrings[4];
    final otherShenShaJsonString = jsonStrings[5];

    final tianGanList = json.decode(tianGanJsonString) as List;
    List<TianGanShenSha> tianGanShenSha =
        tianGanList.map((e) => TianGanShenSha.fromJson(e)).toList();

    final yearDiZhiList = json.decode(yearDiZhiJsonString) as List;
    List<YearDiZhiShenSha> yearDiZhiShenSha =
        yearDiZhiList.map((e) => YearDiZhiShenSha.fromJson(e)).toList();

    final monthDiZhiList = json.decode(monthDiZhiJsonString) as List;
    List<DiZhiShenSha> monthDiZhiShenSha =
        monthDiZhiList.map((e) => MonthDiZhiShenSha.fromJson(e)).toList();

    final ganzhiList = json.decode(ganzhiJsonString) as List;
    List<GanZhiShenSha> ganzhiShenSha =
        ganzhiList.map((e) => GanZhiShenSha.fromJson(e)).toList();

    final bundledShenShaList = json.decode(bundledShenShaJsonString) as List;
    List<BundledShenSha> bundledShenSha =
        bundledShenShaList.map((e) => BundledShenSha.fromJson(e)).toList();

    final otherShenShaList = json.decode(otherShenShaJsonString) as List;
    List<OtherShenSha> otherShenSha =
        otherShenShaList.map((e) => OtherShenSha.fromJson(e)).toList();

    return ShenShaManager(
        tianGanShenSha: tianGanShenSha,
        yearDiZhiShenSha: yearDiZhiShenSha,
        monthDiZhiShenSha: monthDiZhiShenSha,
        ganZhiShenSha: ganzhiShenSha,
        bundledShenSha: bundledShenSha,
        otherShenSha: otherShenSha);
  }

  Future<HuaYaoManager> loadHuaYaoManager() async {
    final result = await Future.wait([
      rootBundle.loadString('assets/shen_sha/74_huayao_tiangan.json'),
      rootBundle.loadString('assets/shen_sha/74_huayao_dizhi.json'),
      rootBundle.loadString('assets/shen_sha/74_huayao_others.json'),
    ]);

    // 天干化曜
    final tianGanHuaYaoJsonString = result[0];
    // 地支化曜
    final diZhiHuaYaoJsonString = result[1];
    // 其他化曜
    final othersHuaYaoJsonString = result[2];

    final tianGanList = json.decode(tianGanHuaYaoJsonString) as List;
    List<TianGanHuaYao> tianGanHuaYao =
        tianGanList.map((e) => TianGanHuaYao.fromJson(e)).toList();

    final diZhiList = json.decode(diZhiHuaYaoJsonString) as List;
    List<DiZhiHuaYao> diZhiHuaYao =
        diZhiList.map((e) => DiZhiHuaYao.fromJson(e)).toList();

    final othersHuaYaoList = json.decode(othersHuaYaoJsonString) as List;
    List<OthersHuaYao> othersHuaYao =
        othersHuaYaoList.map((e) => OthersHuaYao.fromJson(e)).toList();

    return HuaYaoManager(
      tianGanHuaYao: tianGanHuaYao,
      diZhiHuaYao: diZhiHuaYao,
      othersHuaYao: othersHuaYao,
    );
  }
}
