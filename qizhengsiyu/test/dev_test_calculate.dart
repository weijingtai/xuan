import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/star_enter_info.dart';
import 'package:qizhengsiyu/models/stars_angle.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/services/an_shen_li_ming_service.dart';
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';

void main() {
  double testSunangle = 211.02;
  group("立命", () {
    test('定命宫 丁酉月 乙巳时 卯时立命，卯宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.DING_YOU, JiaZi.YI_SI, testSunangle, false);
      expect(res, EnumTwelveGong.Mao);
    });
    test('定命宫 辛巳月 甲午时 卯时立命，午宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.XIN_SI, JiaZi.JIA_WU, testSunangle, false);
      expect(res, EnumTwelveGong.Wu);
    });
    test('定命宫 戊子月 壬午时 辰时立命，子宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.WU_ZI, JiaZi.REN_WU, testSunangle, false, DiZhi.CHEN);
      expect(res, EnumTwelveGong.Zi);
    });
    test('定命宫 己亥月 己酉时 卯时立命，酉宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.JI_HAI, JiaZi.JI_YOU, testSunangle);
      expect(res, EnumTwelveGong.You);
    });
    test('定命宫 庚戌月(太阳 211.02° 落宫卯宫1.02°) 乙未时 卯时立命，亥宫立命', () {
      /// 之前几种定命宫的方式是根据，得来，不是使用实际太阳的位置计算所得
      ///     // 每月太阳所在宫位
      //     // 子月在寅，丑月在丑
      //     // 寅月在子，卯月在亥
      //     // 辰月在戌，巳月在酉
      //     // 午月在申，未月在未
      //     // 申月在午，酉月在巳
      //     // 戌月在辰，亥月在卯
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.GENG_XU, JiaZi.YI_WEI, testSunangle, true, DiZhi.MAO);
      expect(res, EnumTwelveGong.Hai);
    });

    test('定命宫 庚戌月(太阳 211.02°) 乙未时 卯时立命，亥宫立命', () {
      /// 之前几种定命宫的方式是根据，得来，不是使用实际太阳的位置计算所得
      ///     // 每月太阳所在宫位
      //     // 子月在寅，丑月在丑
      //     // 寅月在子，卯月在亥
      //     // 辰月在戌，巳月在酉
      //     // 午月在申，未月在未
      //     // 申月在午，酉月在巳
      //     // 戌月在辰，亥月在卯
      var res = AnShenLiMingService.settleDownLifeGong(
          JiaZi.GENG_XU, JiaZi.YI_WEI, testSunangle, true, DiZhi.MAO);
      expect(res, EnumTwelveGong.Hai);
    });

    test('太阳 211.02° 落宫卯宫', () {
      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = AnShenLiMingService.sunEnterGongBySunsAngle(testSunangle);
      expect(res, EnumTwelveGong.Mao);
    });

    test('太阳 60° 落宫申宫', () {
      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = AnShenLiMingService.sunEnterGongBySunsAngle(60);
      expect(res, EnumTwelveGong.Shen);
    });
  });
  group("安身", () {
    test("太阴落宫逆数至酉，安身，己巳时 身宫 为丑宫", () {
      var lunarInfo = MoonInfo(
        angle: 35,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.You,
          atGongDegree: 15,
          inn: TwentyEightStarInn.Zhang_Yue_Lu,
          atInnDegree: 10,
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
        // required bool isHidden
      );
      var result =
          AnShenLiMingService.settleDownBodyGong(lunarInfo, JiaZi.JI_SI);
      expect(result, EnumTwelveGong.Chou);
    });
    test("太阴落宫逆数至酉，安身，壬午时 身宫为【申宫】", () {
      var lunarInfo = MoonInfo(
        angle: 171,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Si,
          atGongDegree: 21,
          inn: TwentyEightStarInn.Zhang_Yue_Lu,
          atInnDegree: 5.2,
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
        // required bool isHidden
      );
      var result =
          AnShenLiMingService.settleDownBodyGong(lunarInfo, JiaZi.REN_WU);
      // print(result.fullname);
      expect(result, EnumTwelveGong.Shen);
    });
    test("太阴落宫逆数至酉，安身乙未时 身宫为【寅宫】", () {
      var lunarInfo = MoonInfo(
        angle: 330.59,
        enterInfo: EnteredInfo(
          gong: EnumTwelveGong.Zi,
          atGongDegree: 0.59,
          inn: TwentyEightStarInn.Niu_Jin_Niu,
          atInnDegree: .4,
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
        // required bool isHidden
      );
      var result =
          AnShenLiMingService.settleDownBodyGong(lunarInfo, JiaZi.YI_WEI);
      print(result.fullname);
      expect(result, EnumTwelveGong.Yin);
    });
  });

  group("星体入宿度", () {
    test("黄道回归矫正古宿", () {
      var res = AnShenLiMingService.starEnterStarInn(
          testSunangle,
          QiZhengSiYuConstantResources
              .ZodiacTropicalCorrectedClassicStarsInnSystemMapper);

      expect(res.item1, TwentyEightStarInn.Jiao_Mu_Jiao);
      expect(res.item2, 211.02 - 201.3);
    });
    test("黄道恒星制", () {
      var res = AnShenLiMingService.starEnterStarInn(
          testSunangle,
          QiZhengSiYuConstantResources
              .ZodiacTropicalOriginalClassicStarsInnSystemMapper);
      expect(res.item1, TwentyEightStarInn.Di_Tu_Lu);
      expect(res.item2, 211.02 - 208.9);
    });
  });
}
