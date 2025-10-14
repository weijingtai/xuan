import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/utils/yuan_tang_gua_helper.dart' as yt_helper;
import 'package:tiebanshenshu/domain/pure_yuan_tang_gua.dart';

/// 元堂卦 Feature 服务：统一封装先/后天卦生成与装卦，返回纯模型
class YuanTangGuaService {
  /// 生成先天纯元堂卦
  static PureYuanTangGua buildXiantianPureGua({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    // 天地卦
    final tianDi = yt_helper.YuanTangGuaHelper.generateTianDiGua(
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
    );
    final tianGua = tianDi.$1;
    final diGua = tianDi.$2;

    // 先天卦（上下）
    final xiantian = yt_helper.YuanTangGuaHelper.generateXiantianGua(
      eightChars: eightChars,
      gender: gender,
      tianGua: tianGua,
      diGua: diGua,
    );
    final xiantianGua = xiantian.$4;

    // 先天元堂装卦（地支与元堂位）
    final zhuang = yt_helper.YuanTangGuaHelper.yuantangZhuanggua(
      eightChars: eightChars,
      xiantianGua: xiantianGua,
      gender: gender,
      birthAfterZhi: birthAfterZhi,
    );
    final yuantangYaoIndex = zhuang.$1;
    final zhiList = zhuang.$3;

    // 构建纯模型（自下而上的地支列表）
    return PureYuanTangGua.fromStrings(
      gua: xiantianGua,
      zhiListBottomToTop: zhiList,
      yuantangYaoIndex: yuantangYaoIndex,
    );
  }

  /// 生成后天纯元堂卦（含至尊卦特例处理）
  static PureYuanTangGua buildHoutianPureGua({
    required DivinationDatetimeModel divination,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    final eightChars = divination.bazi;

    // 先天部分（为后天计算提供前置结果）
    final xiantianPure = buildXiantianPureGua(
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
    );

    // 后天卦（遵循特例：坎坎/坎震/坎艮且元堂在五/上，根据阴阳月决定是否互换）
    final houtianTuple = yt_helper.YuanTangGuaHelper.generateHoutianGua(
      xiantianGua: xiantianPure.gua,
      yuantangYaoIndex: xiantianPure.yuantangYaoIndex,
      birthMonth: divination.lunarMonth,
    );
    final houtianGua = houtianTuple.$1;

    // 后天元堂装卦（地支与元堂位）
    final houtianZhuang = yt_helper.YuanTangGuaHelper.houtianYuantangZhuanggua(
      eightChars: eightChars,
      houtianGua: houtianGua,
      gender: gender,
      birthAfterZhi: birthAfterZhi,
    );
    final houtianYuantangYaoIndex = houtianZhuang.$1;
    final houtianZhiList = houtianZhuang.$3;

    return PureYuanTangGua.fromStrings(
      gua: houtianGua,
      zhiListBottomToTop: houtianZhiList,
      yuantangYaoIndex: houtianYuantangYaoIndex,
    );
  }
}