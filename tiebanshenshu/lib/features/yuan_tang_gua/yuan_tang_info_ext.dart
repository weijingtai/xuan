import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiebanshenshu/constant/constants.dart' as constants;
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

import 'pure_yuan_tang_gua.dart';
import 'yuan_tang_calculator.dart';
import 'yuan_tang_info.dart';

part 'yuan_tang_info_ext.g.dart';

/// YuanTangInfo 扩展：便捷获取先天/后天大运列表
extension YuanTangInfoDaYunExt on YuanTangInfo {
  /// 计算先天大运列表（按虚岁起算）
  List<YuanTangDaYunPeriod> calculateXiantianDaYun(int startAge) {
    return YuanTangCalculator.calculateDaYun(xianTanGua, startAge);
  }

  /// 计算后天大运列表（按虚岁起算）
  List<YuanTangDaYunPeriod> calculateHoutianDaYun(int startAge) {
    return YuanTangCalculator.calculateDaYun(houTianGua, startAge);
  }
}

/// YuanTangInfo 转换扩展：转换为 YuanTangBaseNumberModel
extension YuanTangInfoConversionExt on YuanTangInfo {
  /// 转换为 YuanTangBaseNumberModel
  ///
  /// 参数:
  /// - [tianDiGuaData]: 天地卦生成数据(ganNumList, zhiNumList, oddNumTotal等)
  /// - [tiaowenNumbers]: 条文编号数据
  /// - [baseNumber]: 基础数
  /// - [name]: 名称
  /// - [description]: 描述
  /// - [source]: 来源
  ///
  /// 返回: YuanTangBaseNumberModel
  YuanTangBaseNumberModel toBaseNumberModel({
    required TianDiGuaData tianDiGuaData,
    required TiaowenNumbers tiaowenNumbers,
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
  }) {
    // 计算先天卦大运
    final xiantianDayunList = YuanTangCalculator.calculateDaYun(xianTanGua, 1);

    // 计算后天卦大运
    final houtianDayunStartAge = xiantianDayunList.last.endAge + 1;
    final houtianDayunList = YuanTangCalculator.calculateDaYun(
      houTianGua,
      houtianDayunStartAge,
    );

    // 转换大运数据为旧格式(String-based)
    final xiantianDayunListOld = xiantianDayunList
        .map((d) => _convertDayunPeriodToOld(d))
        .toList();
    final houtianDayunListOld = houtianDayunList
        .map((d) => _convertDayunPeriodToOld(d))
        .toList();

    return YuanTangBaseNumberModel.create(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      // 输入参数
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterJieQi,
      birthMonth: birthMonth,
      // 步骤1: 天地卦数据
      ganNumList: tianDiGuaData.ganNumList,
      zhiNumList: tianDiGuaData.zhiNumList,
      oddNumTotal: tianDiGuaData.oddNumTotal,
      evenNumTotal: tianDiGuaData.evenNumTotal,
      tianGuaNum: tianDiGuaData.tianGuaNum,
      diGuaNum: tianDiGuaData.diGuaNum,
      tianGua: tianDiGuaData.tianGua,
      diGua: tianDiGuaData.diGua,
      usedThreeYuanWuGong: tianDiGuaData.usedThreeYuanWuGong,
      // 步骤2: 先天卦数据
      yearYinYang: yearYinYang,
      upperGua: xianTanGua.gua.top,
      lowerGua: xianTanGua.gua.bottom,
      xiantianGua: xianTanGua.gua,
      xiantianUpperGuaNumber: constants.houGuaNumberMapper[xianTanGua.gua.top]!,
      xiantianLowerGuaNumber:
          constants.houGuaNumberMapper[xianTanGua.gua.bottom]!,
      // 步骤3: 元堂装卦(先天卦)
      timeGanzhi: eightChars.time.name,
      timeYinYang: timeYinYang.isYang ? "阳" : "阴",
      totalYangYao: xianTanGua.gua.bottomTopBinaryList
          .where((b) => b == 1)
          .length,
      totalYinYao: xianTanGua.gua.bottomTopBinaryList
          .where((b) => b == 0)
          .length,
      zhiList: xianTanGua.yuanTangYaoList
          .map(
            (yao) =>
                yao.yangTangZhiList?.map((z) => z.name).toList() ?? <String>[],
          )
          .toList(),
      yuantangYaoIndex: xianTanGua.yuanTangYao.indexAtYaoList,
      yuantangYaoLabel: xianTanGua.yuanTangYao.name,
      // 步骤4: 后天卦数据
      houtianGua: houTianGua.gua,
      houtianUpperGuaNumber: constants.houGuaNumberMapper[houTianGua.gua.top]!,
      houtianLowerGuaNumber:
          constants.houGuaNumberMapper[houTianGua.gua.bottom]!,
      // 步骤4.5: 后天卦元堂装卦
      houtianZhiList: houTianGua.yuanTangYaoList
          .map(
            (yao) =>
                yao.yangTangZhiList?.map((z) => z.name).toList() ?? <String>[],
          )
          .toList(),
      houtianYuantangYaoIndex: houTianGua.yuanTangYao.indexAtYaoList,
      houtianYuantangYaoLabel: houTianGua.yuanTangYao.name,
      // 步骤5: 互卦
      xiantianGuaHu: xianTanGua.hu,
      houtianGuaHu: houTianGua.hu,
      // 步骤6: 大运
      xiantianDayunStartAge: 1,
      xiantianDayunList: xiantianDayunListOld,
      houtianDayunStartAge: houtianDayunStartAge,
      houtianDayunList: houtianDayunListOld,
      // 条文编号
      tiaowenNumberJiazeXiantiangua: tiaowenNumbers.jiazeXiantian,
      tiaowenNumberJiazeHoutiangua: tiaowenNumbers.jiazeHoutian,
      tiaowenNumberNajiaTaixuanXiantiangua: tiaowenNumbers.najiaTaixuanXiantian,
      tiaowenNumberNajiaTaixuanHoutiangua: tiaowenNumbers.najiaTaixuanHoutian,
      tiaowenNumberXiantianBenhu: tiaowenNumbers.benhuXiantian,
      tiaowenNumberHoutianBenhu: tiaowenNumbers.benhuHoutian,
      tiaowenNumberListXiantianGuahu: tiaowenNumbers.guahuListXiantian,
      tiaowenNumberListHoutianGuahu: tiaowenNumbers.guahuListHoutian,
    );
  }

  /// 转换新版大运数据为旧版格式
  YuanTangDayunPeriod _convertDayunPeriodToOld(YuanTangDaYunPeriod newDayun) {
    return YuanTangDayunPeriod(
      yaoPosition: newDayun.order.indexAtYaoList,
      yaoLabel: newDayun.order.name,
      yinYang: newDayun.yinYang.isYang ? "阳" : "阴",
      years: newDayun.years,
      startAge: newDayun.startAge,
      endAge: newDayun.endAge,
      diZhiList: newDayun.diZhiList?.map((z) => z.name).toList() ?? [],
    );
  }
}

/// 天地卦生成数据
///
/// 封装步骤1的所有计算中间结果
@JsonSerializable()
class TianDiGuaData {
  final List<int> ganNumList;
  final List<List<int>> zhiNumList;
  final int oddNumTotal;
  final int evenNumTotal;
  final int tianGuaNum;
  final int diGuaNum;
  final Enum8Gua tianGua;
  final Enum8Gua diGua;
  final bool usedThreeYuanWuGong;

  const TianDiGuaData({
    required this.ganNumList,
    required this.zhiNumList,
    required this.oddNumTotal,
    required this.evenNumTotal,
    required this.tianGuaNum,
    required this.diGuaNum,
    required this.tianGua,
    required this.diGua,
    required this.usedThreeYuanWuGong,
  });
  factory TianDiGuaData.fromJson(Map<String, dynamic> json) =>
      _$TianDiGuaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TianDiGuaDataToJson(this);
}

/// 条文编号数据
///
/// 封装所有条文计算结果
@JsonSerializable()
class TiaowenNumbers {
  final int jiazeXiantian;
  final int jiazeHoutian;
  final int najiaTaixuanXiantian;
  final int najiaTaixuanHoutian;
  final int benhuXiantian;
  final int benhuHoutian;
  final List<int> guahuListXiantian;
  final List<int> guahuListHoutian;

  const TiaowenNumbers({
    required this.jiazeXiantian,
    required this.jiazeHoutian,
    required this.najiaTaixuanXiantian,
    required this.najiaTaixuanHoutian,
    required this.benhuXiantian,
    required this.benhuHoutian,
    required this.guahuListXiantian,
    required this.guahuListHoutian,
  });
  factory TiaowenNumbers.fromJson(Map<String, dynamic> json) =>
      _$TiaowenNumbersFromJson(json);
  Map<String, dynamic> toJson() => _$TiaowenNumbersToJson(this);
}
