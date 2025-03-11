import 'package:common/enums.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/models/star_enter_info.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';

class MockElevenStars {
  /// 创建测试用的完整星盘数据
  static Set<ElevenStarsInfo> createFullStarSet() {
    return {
      // 日月
      SunInfo(
        angle: 15.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 5.5,
        ),
      ),

      MoonInfo(
        angle: 195.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Wu,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Zhang_Yue_Lu,
          atInnDegree: 5.5,
        ),
        moonPhase: EnumMoonPhases.Full,
      ),

      // 五星
      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 13.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 13.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 3.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FiveStarsInfo(
        star: EnumStars.Venus,
        angle: 85.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Si,
          atGongDegree: 25.5,
          inn: TwentyEightStarInn.Wei_Yue_Yan,
          atInnDegree: 15.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.8,
      ),

      FiveStarsInfo(
        star: EnumStars.Mars,
        angle: 145.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Wei,
          atGongDegree: 25.5,
          inn: TwentyEightStarInn.Kui_Mu_Lang,
          atInnDegree: 5.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.5,
      ),

      FiveStarsInfo(
        star: EnumStars.Jupiter,
        angle: 265.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Xu,
          atGongDegree: 25.5,
          inn: TwentyEightStarInn.Xu_Ri_Shu,
          atInnDegree: 15.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.3,
      ),

      FiveStarsInfo(
        star: EnumStars.Saturn,
        angle: 325.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Hai,
          atGongDegree: 25.5,
          inn: TwentyEightStarInn.Wei_Yue_Yan,
          atInnDegree: 15.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.1,
      ),

      // 四余
      FourSlaveStarInfo(
        star: EnumStars.Luo,
        angle: 16.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 16.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 6.5,
        ),
        walkingSpeed: 0.0055,
      ),

      FourSlaveStarInfo(
        star: EnumStars.Ji,
        angle: 196.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Wu,
          atGongDegree: 16.5,
          inn: TwentyEightStarInn.Zhang_Yue_Lu,
          atInnDegree: 6.5,
        ),
        walkingSpeed: 0.0055,
      ),

      FourSlaveStarInfo.qi(
        angle: 95.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Si,
          atGongDegree: 5.5,
          inn: TwentyEightStarInn.Wei_Yue_Yan,
          atInnDegree: 25.5,
        ),
      ),

      FourSlaveStarInfo.bei(
        angle: 275.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Xu,
          atGongDegree: 5.5,
          inn: TwentyEightStarInn.Xu_Ri_Shu,
          atInnDegree: 25.5,
        ),
      ),
    };
  }

  /// 创建同宫测试数据
  static Set<ElevenStarsInfo> createSameGongStars() {
    return {
      // 在辰宫的三颗星：日、水星、罗星
      SunInfo(
        angle: 15.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 5.5,
        ),
      ),

      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 13.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 13.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 3.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FourSlaveStarInfo(
        star: EnumStars.Luo,
        angle: 16.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 16.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 6.5,
        ),
        walkingSpeed: 0.0055,
      ),
    };
  }

  /// 创建对宫测试数据（子午对冲）
  static Set<ElevenStarsInfo> createChongGongStars() {
    return {
      // 子宫的月亮
      MoonInfo(
        angle: 0.0,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Zi,
          atGongDegree: 15.0,
          inn: TwentyEightStarInn.Xu_Ri_Shu,
          atInnDegree: 5.0,
        ),
        moonPhase: EnumMoonPhases.Full,
      ),

      // 午宫的火星
      FiveStarsInfo(
        star: EnumStars.Mars,
        angle: 180.0,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Wu,
          atGongDegree: 15.0,
          inn: TwentyEightStarInn.Zhang_Yue_Lu,
          atInnDegree: 5.0,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.5,
      ),
    };
  }

  /// 创建同宿测试数据
  static Set<ElevenStarsInfo> createSameStarInnStars() {
    return {
      // 同在昴日星宿的两颗星
      SunInfo(
        angle: 45.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Yin,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 5.5,
        ),
      ),

      FiveStarsInfo(
        star: EnumStars.Venus,
        angle: 46.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Yin,
          atGongDegree: 16.5,
          inn: TwentyEightStarInn.Mao_Ri_Ji,
          atInnDegree: 6.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.8,
      ),
    };
  }

  /// 创建同经测试数据
  static Set<ElevenStarsInfo> createSameJingStars() {
    return {
      // 同属水经的两颗星（在不同星宿）
      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 15.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Chen,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Bi_Shui_Yu,
          atInnDegree: 5.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FiveStarsInfo(
        star: EnumStars.Saturn,
        angle: 45.5,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Yin,
          atGongDegree: 15.5,
          inn: TwentyEightStarInn.Zhen_Shui_Yin,
          atInnDegree: 5.5,
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.1,
      ),
    };
  }
}
