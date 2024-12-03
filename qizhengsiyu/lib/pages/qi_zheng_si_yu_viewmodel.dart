import 'dart:math';

import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_jia_zi.dart';
import 'package:common/model/enum_month_general.dart';
import 'package:common/model/enum_month_token.dart';
import 'package:common/model/enum_twelve_ecliptic_gong.dart';
import 'package:common/model/enum_twelve_star_seq.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/services/an_shen_li_ming_service.dart';
import 'package:sweph/sweph.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:tuple/tuple.dart';

import '../enums/enum_moon_phases.dart';
import '../enums/enum_star_hidden_type.dart';
import '../enums/enum_stars.dart';
import '../enums/enum_twenty_eight_xing_xiu.dart';
import '../models/observer_position.dart';
import '../models/panel_stars_info.dart';
import '../models/star_xiu_type.dart';
import '../models/stars_angle.dart';
import '../models/eleven_stars_info.dart';
import '../qi_zheng_si_yu_constant_resources.dart';
import '../utils/star_walking_info_utils.dart';

class QiZhengSiYuViewModel extends ChangeNotifier{

  static final  _fiveStarsSeq = [
    EnumStars.Wood,
    EnumStars.Fire,
    EnumStars.Soil,
    EnumStars.Golden,
    EnumStars.Water
  ];

  // 本命星盘
  StarsAngle? _basicLifeStarsAngle;
  StarsAngle? get basicLifeStarsAngle => _basicLifeStarsAngle;
  PanelStarsInfo? _basicLifePanelStarsInfo;
  PanelStarsInfo? get basicLifePanelStarsInfo => _basicLifePanelStarsInfo;

  // 行限星盘, 起盘当时
  StarsAngle? _fateLifeStarsAngle;
  StarsAngle? get fateLifeStarsAngle => _fateLifeStarsAngle;
  PanelStarsInfo? _fateLifePanelStarsInfo;
  PanelStarsInfo? get fateLifePanelStarsInfo => _fateLifePanelStarsInfo;





  Map<EnumStars,FiveStarWalkingInfo>? _daXianMapper;
  Map<EnumStars,FiveStarWalkingInfo>? get daXianMapper => _daXianMapper;


  ObserverPosition? _observerPosition;

  BuildContext context;
  QiZhengSiYuViewModel(this.context);


  void reset(){
    if (_basicLifeStarsAngle != null){
      _basicLifeStarsAngle = null;
    }
    if (_fateLifeStarsAngle != null){
      _fateLifeStarsAngle = null;
    }
    if (_fateLifePanelStarsInfo != null){
      _fateLifeStarsAngle = null;
    }
    if (_basicLifePanelStarsInfo != null){
      _basicLifePanelStarsInfo = null;
    }
    _observerPosition = null;
  }
  void calculate(ObserverPosition observerPosition) {

    _doCalculateLifePanel(observerPosition);
    _observerPosition = observerPosition;

    notifyListeners();

    if (observerPosition.fateLifeUtcTime != null){
      _daXianMapper = calculateFiveStars();
      notifyListeners();
    }
  }

  _doCalculateLifePanel(ObserverPosition observerPosition){
    _basicLifeStarsAngle = calculateSevenZhengAngle(observerPosition,observerPosition.birthdayUtcTime);


    _basicLifePanelStarsInfo = calculateElevenStartInfo(
      _basicLifeStarsAngle!,
      EnumStarHiddenType.degree15,
      StarPanelType.ZodiacalSiderealOldStars.mapper,
      isDayOrNight:true
    );
    if (observerPosition.fateLifeDateTime != null){
      _fateLifeStarsAngle = calculateSevenZhengAngle(observerPosition,observerPosition.fateLifeUtcTime!);
      _fateLifePanelStarsInfo = calculateElevenStartInfo(
          _fateLifeStarsAngle!,
          EnumStarHiddenType.degree15,
          StarPanelType.ZodiacalSiderealOldStars.mapper,
          isDayOrNight:true
      );
    }
  }


  Map<EnumStars,FiveStarWalkingInfo> calculateFiveStars(){
    Map<EnumStars,FiveStarWalkingInfo> result = {};
    for (var i = 0; i < _fiveStarsSeq.length; i++){
      EnumStars star = _fiveStarsSeq[i];
      result[star] = StarWalkingInfoUtils.calculateStarWalkingInfo(star,_observerPosition!,StarsAngle.moirasFiveStartsMapper);
    }
    return result;
  }
  /// “日月合” 界定标准为 太阳与月亮在1°~2°度之间（占星普遍认为误差在0.5°之间为合理误差，故此处默认为1.5°）
  /// 日蚀的判断标准为：日月合[新月]+白昼+日罗合，其中“日罗合”一般认为在10~15°以内
  /// 月蚀的判断标准为：满月+夜晚+月计合，其中“月罗合”一般认为在10~15°以内
  PanelStarsInfo calculateElevenStartInfo(
      StarsAngle starsAngle,
      EnumStarHiddenType hiddenType,
      Map<TwentyEightStarInn,StarXiuType> mapper,{
        double isSunLunarTouchDegreeRange = 1.5,
        double eclipseDegreeRange = 15,
        bool isDayOrNight = false // true 为白天，false 为夜晚
      }){
    ElevenStarsInfo sunInfo = _doCalculateStarInfo(EnumStars.Sun,starsAngle.sun, mapper);
    MoonInfo moonInfo = _doCalculateMoonInfo(starsAngle.moon,sunInfo, mapper,isSunLunarTouchDegreeRange);

    ElevenStarsInfo qiInfo = _doCalculateStarInfo(EnumStars.Qi,starsAngle.qi, mapper);
    ElevenStarsInfo beiInfo = _doCalculateStarInfo(EnumStars.Bei,starsAngle.lilith, mapper);

    LouJiStarsInfo luoInfo = _doCalculateLuoJiInfo(EnumStars.Luo,starsAngle.northNode,sunInfo,moonInfo, mapper,eclipseDegreeRange);
    LouJiStarsInfo jiInfo = _doCalculateLuoJiInfo(EnumStars.Ji,starsAngle.southNode,sunInfo,moonInfo, mapper,eclipseDegreeRange);
    // StarsAngle.moirasFiveStartsMapper

    FiveStarsInfo goldenInfo = _doCalculateFiveStarInfo(EnumStars.Golden,starsAngle.golden,starsAngle.goldenSpeed, StarsAngle.moirasFiveStartsMapper[EnumStars.Golden]!,mapper);
    setupIsHidden(sunInfo,goldenInfo,hiddenType);
    FiveStarsInfo woodInfo = _doCalculateFiveStarInfo(EnumStars.Wood,starsAngle.wood,starsAngle.woodSpeed, StarsAngle.moirasFiveStartsMapper[EnumStars.Wood]!,mapper);
    setupIsHidden(sunInfo,woodInfo,hiddenType);
    FiveStarsInfo fireInfo = _doCalculateFiveStarInfo(EnumStars.Fire,starsAngle.fire,starsAngle.fireSpeed, StarsAngle.moirasFiveStartsMapper[EnumStars.Fire]!,mapper);
    setupIsHidden(sunInfo,fireInfo,hiddenType);
    FiveStarsInfo soilInfo = _doCalculateFiveStarInfo(EnumStars.Soil,starsAngle.soil,starsAngle.soilSpeed, StarsAngle.moirasFiveStartsMapper[EnumStars.Soil]!,mapper);
    setupIsHidden(sunInfo,soilInfo,hiddenType);
    FiveStarsInfo waterInfo = _doCalculateFiveStarInfo(EnumStars.Water,starsAngle.water,starsAngle.waterSpeed, StarsAngle.moirasFiveStartsMapper[EnumStars.Water]!,mapper);
    setupIsHidden(sunInfo,waterInfo,hiddenType);

    return PanelStarsInfo(
      sun: sunInfo,
       moon: moonInfo,
       qi: qiInfo,
       bei: beiInfo,
       luo: luoInfo,
       ji: jiInfo,
       golden: goldenInfo,
       wood: woodInfo,
       fire: fireInfo,
      soil: soilInfo,
      water: waterInfo,
        isSunEclipse:isDayOrNight?moonInfo.moonPhase == EnumMoonPhases.New && luoInfo.isRoundSun :false,
        isLunarEclipse:isDayOrNight?false:moonInfo.moonPhase == EnumMoonPhases.Full && jiInfo.isRoundMoon,
        isSunLunarTouch:isInDegreeRange(sunInfo.angle + isSunLunarTouchDegreeRange, sunInfo.angle - isSunLunarTouchDegreeRange, moonInfo.angle)
    );
  }
  MoonInfo _doCalculateMoonInfo(double moonAngle,ElevenStarsInfo sunInfo,Map<TwentyEightStarInn,StarXiuType> mapper,[double rangeDegree = 1]){
    Tuple2<EnumTwelveGong,double> sunEnteredGong = AnShenLiMingService.starEnterGong(moonAngle);
    Tuple2<TwentyEightStarInn,double> sunEnteredInn = AnShenLiMingService.starEnterStarInn(moonAngle,mapper);

    double moonPhase  = moonAngle - sunInfo.angle;
    if (moonPhase < 0){
      moonPhase += 360;
    }
    return MoonInfo(
      angle:moonAngle,
      enteredGong:sunEnteredGong.item1,
      enteredGongDegree:sunEnteredGong.item2,
      enteredStarInn:sunEnteredInn.item1,
      enteredStarInnDegree:sunEnteredInn.item2,
        moonPhase: EnumMoonPhases.fromAngle(moonPhase,offsetDegree:rangeDegree)
    );
  }
  ElevenStarsInfo _doCalculateStarInfo(EnumStars star,double starAngle,Map<TwentyEightStarInn,StarXiuType> mapper){
    Tuple2<EnumTwelveGong,double> sunEnteredGong = AnShenLiMingService.starEnterGong(starAngle);
    Tuple2<TwentyEightStarInn,double> sunEnteredInn = AnShenLiMingService.starEnterStarInn(starAngle,mapper);

    return ElevenStarsInfo(
      star: star,
      angle:starAngle,
      enteredGong:sunEnteredGong.item1,
      enteredGongDegree:sunEnteredGong.item2,
      enteredStarInn:sunEnteredInn.item1,
      enteredStarInnDegree:sunEnteredInn.item2,
    );
  }
  LouJiStarsInfo _doCalculateLuoJiInfo(
      EnumStars star,
      double starAngle,
      ElevenStarsInfo sunInfo,
      ElevenStarsInfo moonInfo,
      Map<TwentyEightStarInn,StarXiuType> mapper,
      double roundingSunMoonDegreeRange){
    Tuple2<EnumTwelveGong,double> sunEnteredGong = AnShenLiMingService.starEnterGong(starAngle);
    Tuple2<TwentyEightStarInn,double> sunEnteredInn = AnShenLiMingService.starEnterStarInn(starAngle,mapper);
    return LouJiStarsInfo(
      star: star,
      angle:starAngle,
      enteredGong:sunEnteredGong.item1,
      enteredGongDegree:sunEnteredGong.item2,
      enteredStarInn:sunEnteredInn.item1,
      enteredStarInnDegree:sunEnteredInn.item2,
        isRoundMoon:isInDegreeRange(moonInfo.angle + roundingSunMoonDegreeRange, moonInfo.angle - roundingSunMoonDegreeRange, starAngle),
        isRoundSun:isInDegreeRange(sunInfo.angle + roundingSunMoonDegreeRange, sunInfo.angle - roundingSunMoonDegreeRange, starAngle),
        roundDegreeRange:roundingSunMoonDegreeRange
    );
  }
  FiveStarsInfo _doCalculateFiveStarInfo(EnumStars star,double starAngle,double starSpeed,Tuple6<double,double,double,double,double?,double?> tuple6,Map<TwentyEightStarInn,StarXiuType> mapper){
    Tuple2<EnumTwelveGong,double> sunEnteredGong = AnShenLiMingService.starEnterGong(starAngle);
    Tuple2<TwentyEightStarInn,double> sunEnteredInn = AnShenLiMingService.starEnterStarInn(starAngle,mapper);

    return FiveStarsInfo(
        star: star,
        angle:starAngle,
        enteredGong:sunEnteredGong.item1,
        enteredGongDegree:sunEnteredGong.item2,
        enteredStarInn:sunEnteredInn.item1,
        enteredStarInnDegree:sunEnteredInn.item2,
        walkingSpeed: starSpeed,
        fiveStarWalkingType:StarWalkingInfoUtils.getWalkingType(starSpeed, tuple6)
    ) ;
  }


  ElevenStarsInfo setupIsHidden(ElevenStarsInfo sunInfo,FiveStarsInfo star,EnumStarHiddenType hiddenType){
    if (hiddenType == EnumStarHiddenType.degree15){
      double sunRangeDegreeStartAt = sunInfo.angle - 15;
      double sunRangeDegreeEndAt = sunInfo.angle + 15;

      if (isInDegreeRange(sunRangeDegreeStartAt,sunRangeDegreeEndAt,star.angle)){
      return star.copyWith(isHidden: true);
      }
    }else if (hiddenType == EnumStarHiddenType.sameGong && sunInfo.enteredGong == star.enteredGong){
      return star.copyWith(isHidden: true);
    }
    return star;
  }
  static bool isInDegreeRange(double theStartDegree,double theEndDegree,double doTestDegree){
    double startDegree = theStartDegree;
    if (startDegree < 0){
      startDegree += 360;
    }
    if (startDegree >= 0){
      startDegree -= 360;
    }
    double endDegree = theEndDegree;
    if (endDegree >= 360){
      endDegree -= 360;
    }
    if (endDegree < 0){
      endDegree += 360;
    }
    double testedDegree = doTestDegree;
    if (doTestDegree >= 360){
      doTestDegree -= 360;
    }
    if (doTestDegree < 0){
      doTestDegree += 360;
    }
    if (startDegree == endDegree){
      throw ArgumentError("startDegree == endDegree");
    }
    if (startDegree < endDegree){
      return testedDegree >= startDegree && testedDegree <= endDegree;
    }else{
      if (testedDegree >= startDegree){
        return true;
      }else{
        if (testedDegree <= endDegree) {
          return true;
        }
      }

    }
    return false;

    // return testedDegree >= startDegree && testedDegree <= endDegree;
  }


  StarsAngle calculateSevenZhengAngle(BaseObserverPosition observerPosition,DateTime datetime) {
    double _roundHelper(double number){
      // 保留小数点后两位，四舍五入
      num factor = pow(10, 2);
      return ((number * factor).round() / factor);
    }
    double _ziQi(){
      // # moria 软件中
      // # 2013-04-09 02:57 am 紫炁在戌0°
      // # 2013-04-10 02:57 am 紫炁在戌0°02′07″处
      // # 每24小时运行 02′07″ 或 0.0352° 度 28年运行一周，一年以365.2422天为准
      // # 紫炁的运行规律为 一日行三分五十七秒，一宫住二十八个月，二十八年行一周天，一日行3分57秒（百进制）
      // # 设置基准时间为上海时区
      tz.TZDateTime BASE_SHANG_HAI_TIME = tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
      // BASE_SHANG_HAI_TIME.toUtc();

      const angle_for_each_minutes = 0.0352 / (24 * 60);
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
      if (datetime.isAtSameMomentAs(BASE_SHANG_HAI_TIME)){
        return 0;
      }

      var diffInMinutes = datetime.isBefore(BASE_SHANG_HAI_TIME)
          ? BASE_SHANG_HAI_TIME.difference(datetime)
          : datetime.difference(BASE_SHANG_HAI_TIME);

      // minutes_difference = delta.total_seconds() // 60
      double result = diffInMinutes.inMinutes * angle_for_each_minutes;
      if (result >= 360){
        result -= 360;
      }

      return result;
    }
    // 设置观察者的位置
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,observerPosition.altitude);
    DateTime utcTime = datetime;

    final double julianDay = Sweph.swe_julday(utcTime.year,utcTime.month,utcTime.day,utcTime.hour+utcTime.minute/60,CalendarType.SE_GREG_CAL);

    var lunar = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    var sun = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);

    var golden = Sweph.swe_calc(julianDay, HeavenlyBody.SE_VENUS, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    var wood = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    var fire = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    var soil = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);

    // 计算北交点的黄道角度
    var northNode = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MEAN_NODE, SwephFlag.SEFLG_SWIEPH);
    double northNodeAngle = northNode.longitude;
    // 计算南交点的黄道角度
    double southNodeAngle = (northNodeAngle + 180) % 360;
    var lilith = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MEAN_APOG, SwephFlag.SEFLG_SWIEPH);

    return StarsAngle(
        moon: _roundHelper(lunar.longitude),
        sun: _roundHelper(sun.longitude),

        golden: _roundHelper(golden.longitude),
        goldenSpeed: _roundHelper(golden.speedInLongitude),

        wood: _roundHelper(wood.longitude),
        woodSpeed: _roundHelper(wood.speedInLongitude),

        water: _roundHelper(water.longitude),
        waterSpeed: _roundHelper(water.speedInLongitude),

        fire: _roundHelper(fire.longitude),
        fireSpeed: _roundHelper(fire.speedInLongitude),

        soil: _roundHelper(soil.longitude),
        soilSpeed: _roundHelper(soil.speedInLongitude),

        northNode: _roundHelper(northNodeAngle),
        southNode: _roundHelper(southNodeAngle),
        lilith: _roundHelper(lilith.longitude),
        qi:_roundHelper(_ziQi())
    );
  }

}