import 'package:common/enums.dart';
import 'package:common/enums/enum_five_xing.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/utils/collections_utils.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart'; // 使用domain层的ObserverPosition
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:tuple/tuple.dart';

class HuaYaoManager {
  List<TianGanHuaYao> tianGanHuaYao = [];
  List<DiZhiHuaYao> diZhiHuaYao = [];
  List<OthersHuaYao> othersHuaYao = [];
  HuaYaoManager({
    required this.tianGanHuaYao,
    required this.diZhiHuaYao,
    required this.othersHuaYao,
  });
  // 科甲
  static EnumStars getKeJia(EnumTwelveGong mingGong) {
    // 命宫对宫的宫主星就为科甲
    final congFiveXing = mingGong.zhi.sixChongZhi;
    return EnumTwelveGong.getEnumTwelveGongByZhi(congFiveXing).sevenZheng;
  }

  // 人元禄
  static EnumStars generateRenYuanLu(
    JiaZi yearJiaZi,
    EnumTwelveGong mingGong,
  ) {
    // 年干五虎遁，从寅宫顺黄道十二宫逆数（顺时针），到命宫
    // 对应的干化曜就是 天元禄
    // 如甲辰年，命宫酉，甲己的五虎遁为丙，寅宫上安丙，顺数至酉宫，为辛干，辛干化曜为天元禄 -- 罗
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];
    final beiKe = targetGan.fiveXing.beiKe;
    final renYuanStar =
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == beiKe);

    return renYuanStar;
  }

  // 天元禄
  static EnumStars generateTianYuanLu(
    JiaZi yearJiaZi,
    EnumTwelveGong mingGong,
  ) {
    // 年干五虎遁，从寅宫顺黄道十二宫逆数（顺时针），到命宫
    // 对应的干化曜就是 天元禄
    // 如甲辰年，命宫酉，甲己的五虎遁为丙，寅宫上安丙，顺数至酉宫，为辛干，辛干化曜为天元禄 -- 罗
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];

    return EnumGuoLaoHuaYao.tianGanStarsMapper[targetGan]!;
  }

  // 地元禄
  static EnumStars generateDiYuanLu(JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    // 从卦气宫开始，逆时针至命宫(如为N个宫)
    final EnumTwelveGong starFrom =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    final starSeq = CollectUtils.changeSeq(
        starFrom, EnumTwelveGong.listAll.reversed.toList());

    final indexAt = starSeq.indexOf(mingGong);
    final tianGanSeq = CollectUtils.changeSeq(yearJiaZi.gan, TianGan.listAll);
    final countingTianGan = [...tianGanSeq, ...tianGanSeq];

    // 职元天干
    final atTianGan = countingTianGan[indexAt];
    // 地元禄
    // 卦气宫位逆时针数到命宫，对应的天干其五星对应的星体即为地元禄
    final diYuanLu =
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == atTianGan.fiveXing);
    return diYuanLu;
  }

  // 职元、局主、
  // 返回职元tuple.item1和局主tuple.item2
  static List<EnumStars> generateZhiYuanAndJuZhu(
      JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    // 从卦气宫开始，顺数至命宫(如为N个宫)
    // 以年干为开开始，继续数到，如为甲子年，则从甲开始向后数，数的个数为卦气到命宫的个数，甲->乙->N-1->N
    final EnumTwelveGong starFrom =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    final starSeq = CollectUtils.changeSeq(starFrom, EnumTwelveGong.listAll);

    final indexAt = starSeq.indexOf(mingGong);
    final tianGanSeq = CollectUtils.changeSeq(yearJiaZi.gan, TianGan.listAll);
    final countingTianGan = [...tianGanSeq, ...tianGanSeq];
    // 职元天干
    final atTianGan = countingTianGan[indexAt];
    // 局主天干 -- 职元天干五合
    final juZhuTianGan = atTianGan.getOtherTianGanFiveCombine();

    // print(atTianGan);
    // EnumGuoLaoHuaYao.tianGanStarsMapper[atTianGan.getOtherTianGanFiveCombine()];
    return [
      EnumGuoLaoHuaYao.tianGanStarsMapper[atTianGan]!, // 职元
      EnumGuoLaoHuaYao
          .tianGanStarsMapper[atTianGan.getOtherTianGanFiveCombine()]!, // 局主
    ];
  }

  // 马元，驿马所在宫位宫主星
  static EnumStars generateMaYuan(EnumTwelveGong yiMaGong) {
    return yiMaGong.sevenZheng;
  }

  // 寿元
  static EnumStars generateShouYuan(JiaZi yearJiaZi) {
    final FiveXing fiveXing = yearJiaZi.naYin.fiveXing;
    return EnumStars.fiveStars.firstWhere((t) => t.fiveXing == fiveXing);
  }

  // 天经、地纬
  // tuple.item1为天经，tuple.item2为地纬
  static Tuple2<EnumStars, EnumStars> generateTianJingAndDiWei(
      JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    // 以年干起五虎遁，顺时针数到命宫，天干五行对应的星体为：天经；地支对应的五行星体为地位
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];

    return Tuple2(
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == targetGan.fiveXing),
        EnumStars.fiveStars
            .firstWhere((e) => e.fiveXing == mingGong.zhi.fiveXing));
  }

  // 获取
  Map<HuaYao, EnumStars> generateTianGanHuaYaoBy(JiaZi yearJiaZi) {
    final res = <HuaYao, EnumStars>{};
    tianGanHuaYao.forEach((hy) {
      res[hy] = hy.locationMapper[yearJiaZi.gan]!;
    });
    return res;
  }

  // 获取
  Map<HuaYao, EnumStars> generateDiZhiHuaYaoBy(
      JiaZi yearJiaZi, JiaZi monthJiaZi) {
    final res = <HuaYao, EnumStars>{};
    diZhiHuaYao.forEach((hy) {
      if (hy.type == ShenShaType.DiZhi_year) {
        res[hy] = hy.locationMapper[yearJiaZi.zhi]!;
      } else if (hy.type == ShenShaType.DiZhi_month) {
        res[hy] = hy.locationMapper[monthJiaZi.zhi]!;
      }
    });
    return res;
  }

  // 获取其他化曜
  Map<HuaYao, EnumStars> generateOthersHuaYaoBy({
    required EnumTwelveGong mingGong,
    required JiaZi yearJiaZi,
    // required JiaZi monthJiaZi,
  }) {
    // 根据命宫计算官禄宫
    // final guaLuGong =
    // CollectUtils.changeSeq(mingGong, EnumTwelveGong.listAll)[3];

    Map<HuaYao, EnumStars> res = {};

    // 获取科甲
    final keJia = getKeJia(mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '科甲')] = keJia;

    // 获取人元禄、天元
    final tianJingDiWei = generateTianJingAndDiWei(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '天经')] = tianJingDiWei.item1;
    res[othersHuaYao.firstWhere((e) => e.name == '地纬')] = tianJingDiWei.item2;

    // 获取天元禄
    final tianYuanLu = generateTianYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '天元禄')] = tianYuanLu;

    // 获取人元禄
    final renYuanLu = generateRenYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '人元禄')] = renYuanLu;

    // 获取地元禄
    final diYuanLu = generateDiYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '地元禄')] = diYuanLu;

    // 获取职元
    final zhiYuanAndJuZhu = generateZhiYuanAndJuZhu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '职元')] = zhiYuanAndJuZhu[0];
    res[othersHuaYao.firstWhere((e) => e.name == '局主')] = zhiYuanAndJuZhu[1];

    // 获取马元
    final yiMaGong = DiZhiSanHe.getHorseBySingleDiZhi(yearJiaZi.zhi);
    final maYuan =
        generateMaYuan(EnumTwelveGong.getEnumTwelveGongByZhi(yiMaGong));
    res[othersHuaYao.firstWhere((e) => e.name == '马元')] = maYuan;

    // 获取寿元
    final shouYuan = generateShouYuan(yearJiaZi);
    res[othersHuaYao.firstWhere((e) => e.name == '寿元')] = shouYuan;

    return res;
  }

  // calculate all hua yao
  Map<HuaYao, EnumStars> calculate({
    // required ObserverPosition observerPosition,
    required EnumTwelveGong mingGong,
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
  }) {
    final res = <HuaYao, EnumStars>{};
    res.addAll(generateTianGanHuaYaoBy(yearJiaZi));
    res.addAll(generateDiZhiHuaYaoBy(yearJiaZi, monthJiaZi));
    res.addAll(
        generateOthersHuaYaoBy(yearJiaZi: yearJiaZi, mingGong: mingGong));
    return res;
  }
}
