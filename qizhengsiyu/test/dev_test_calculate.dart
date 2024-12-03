import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_jia_zi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_stars.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_twenty_eight_xing_xiu.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/stars_angle.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/services/an_shen_li_ming_service.dart';
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';

void main() {

  double test_sunAngle = 211.02;
  group("立命",(){

    test('定命宫 丁酉月 乙巳时 卯时立命，卯宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.DING_YOU,JiaZi.YI_SI,test_sunAngle,false);
      expect(res, EnumTwelveGong.Mao);
    });
    test('定命宫 辛巳月 甲午时 卯时立命，午宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.XIN_SI,JiaZi.JIA_WU,test_sunAngle,false);
      expect(res, EnumTwelveGong.Wu);
    });
    test('定命宫 戊子月 壬午时 辰时立命，子宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.WU_ZI,JiaZi.REN_WU,test_sunAngle,false,DiZhi.CHEN);
      expect(res, EnumTwelveGong.Zi);
    });
    test('定命宫 己亥月 己酉时 卯时立命，酉宫立命', () {
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.JI_HAI,JiaZi.JI_YOU,test_sunAngle);
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
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.GENG_XU,JiaZi.YI_WEI,test_sunAngle,true,DiZhi.MAO);
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
      var res = AnShenLiMingService.settleDownLifeGong(JiaZi.GENG_XU,JiaZi.YI_WEI,test_sunAngle,true,DiZhi.MAO);
      expect(res, EnumTwelveGong.Hai);
    });

    test('太阳 211.02° 落宫卯宫', () {

      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = AnShenLiMingService.sunEnterGongBySunsAngle(test_sunAngle);
      expect(res, EnumTwelveGong.Mao);
    });

    test('太阳 60° 落宫申宫', () {
      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = AnShenLiMingService.sunEnterGongBySunsAngle(60);
      expect(res, EnumTwelveGong.Shen);
    });
  });
  group("安身", (){

    test("太阴落宫逆数至酉，安身，己巳时 身宫 为丑宫", (){
      var lunarInfo = ElevenStarsInfo(
        star:EnumStars.Moon,
        angle:35,
        enteredGong:EnumTwelveGong.You,
        enteredGongDegree:5,
        enteredStarInn:TwentyEightStarInn.Wei_Tu_Zhi,
        enteredStarInnDegree:8.5,
      );
      var result = AnShenLiMingService.settleDownBodyGong(lunarInfo,JiaZi.JI_SI);
      print(result.fullname);
      expect(result, EnumTwelveGong.Chou);
    });
    test("太阴落宫逆数至酉，安身，壬午时 身宫为【申宫】", (){
      var lunarInfo = ElevenStarsInfo(
        star:EnumStars.Moon,
        angle:171,
        enteredGong:EnumTwelveGong.Si,
        enteredGongDegree:21,
        enteredStarInn:TwentyEightStarInn.Zhang_Yue_Lu,
        enteredStarInnDegree:5.2,
      );
      var result = AnShenLiMingService.settleDownBodyGong(lunarInfo,JiaZi.REN_WU);
      print(result.fullname);
      expect(result, EnumTwelveGong.Shen);
    });
    test("太阴落宫逆数至酉，安身乙未时 身宫为【寅宫】", (){
      var lunarInfo = ElevenStarsInfo(
        star:EnumStars.Moon,
        angle:330.59,
        enteredGong:EnumTwelveGong.Zi,
        enteredGongDegree:0.59,
        enteredStarInn:TwentyEightStarInn.Niu_Jin_Niu,
        enteredStarInnDegree:.4,
      );
      var result = AnShenLiMingService.settleDownBodyGong(lunarInfo,JiaZi.YI_WEI);
      print(result.fullname);
      expect(result, EnumTwelveGong.Yin);
    });
  });

  group("星体入宿度", (){
    test("黄道回归矫正古宿", (){

      var res =AnShenLiMingService.starEnterStarInn(test_sunAngle, QiZhengSiYuConstantResources.ZodiacalCorrectedOldStarsMapper);

      expect(res.item1, TwentyEightStarInn.Jiao_Mu_Jiao);
      expect(res.item2, 211.02 - 201.3);
    });
    test("黄道恒星制", (){

      var res =AnShenLiMingService.starEnterStarInn(test_sunAngle, QiZhengSiYuConstantResources.ZodiacalSiderealOldStarsMapper);
      expect(res.item1, TwentyEightStarInn.Di_Tu_Lu);
      expect(res.item2, 211.02 - 208.9);
    });
  });
}
