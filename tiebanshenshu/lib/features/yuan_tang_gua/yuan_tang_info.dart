import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../enums.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../service/strategy/yuan_tang_strategy.dart';
import 'pure_yuan_tang_gua.dart';
import 'yuan_tang_info_ext.dart';
part 'yuan_tang_info.g.dart';

@JsonSerializable()
class YuanTangInfo {
  // ========== 输入参数 ==========
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;
  final CalanderType calanderType;
  final int birthMonth;
  YinYang get monthYinYan => birthMonth % 2 == 0 ? YinYang.YIN : YinYang.YANG;

  YinYang get yearYinYang => eightChars.year.gan.yinYang;

  /// 时柱干支
  DiZhi get timeZhi => eightChars.time.diZhi;

  /// 时辰阴阳（"阳" / "阴"）
  YinYang get timeYinYang =>
      [
        DiZhi.ZI,
        DiZhi.CHOU,
        DiZhi.YIN,
        DiZhi.MAO,
        DiZhi.CHEN,
        DiZhi.SI,
      ].contains(timeZhi)
      ? YinYang.YANG
      : YinYang.YIN;

  /// 出生节气（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterJieQi;

  final PureYuanTangGua xianTanGua;
  final PureYuanTangGua houTianGua;

  /// 天地卦生成数据（可选，用于需要详细计算过程的场景）
  final TianDiGuaData? tianDiGuaData;

  /// 构造函数：初始化所有最终字段
  const YuanTangInfo({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.calanderType,
    required this.birthMonth,
    required this.birthAfterJieQi,
    required this.xianTanGua,
    required this.houTianGua,
    this.tianDiGuaData,
  });

  factory YuanTangInfo.fromJson(Map<String, dynamic> json) =>
      _$YuanTangInfoFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangInfoToJson(this);
}

/// 元堂流运聚合数据
///
/// 将大运、流年、流月相关数据以聚合方式集中管理，便于上层使用
class YuanTangFlowAggregate {
  /// 出生年份（公元纪年，如 1990）
  final int birthYear;

  /// 先天大运列表（来自基础模型）
  final List<YuanTangDayunPeriod> xiantianDayunList;

  /// 后天大运列表（来自基础模型）
  final List<YuanTangDayunPeriod> houtianDayunList;

  /// 全部流年卦列表（一次性计算缓存）
  final List<YuanTangLiunianGua> allLiunianList;

  /// 元堂爻位置（用于流月计算）
  final int yuantangYaoIndex;

  /// 按年龄缓存的流月列表
  final Map<int, List<YuanTangLiuyueGua>> _liuyueCache = {};

  YuanTangFlowAggregate({
    required this.birthYear,
    required this.xiantianDayunList,
    required this.houtianDayunList,
    required this.allLiunianList,
    required this.yuantangYaoIndex,
  });

  /// 从基础模型构建聚合（计算全部流年）
  static YuanTangFlowAggregate fromModel({
    required YuanTangBaseNumberModel model,
    required int birthYear,
    required YuanTangStrategy strategy,
  }) {
    final allLiunianList = strategy.calculateAllLiunianGua(model, birthYear);
    return YuanTangFlowAggregate(
      birthYear: birthYear,
      xiantianDayunList: model.xiantianDayunList,
      houtianDayunList: model.houtianDayunList,
      allLiunianList: allLiunianList,
      yuantangYaoIndex: model.yuantangYaoIndex,
    );
  }

  /// 获取指定年龄的12个流月卦（带缓存）
  List<YuanTangLiuyueGua> getLiuyueForAge(int age, YuanTangStrategy strategy) {
    final cached = _liuyueCache[age];
    if (cached != null) return cached;

    final liunian = allLiunianList.firstWhere(
      (g) => g.age == age,
      orElse: () => throw StateError('未找到年龄为$age的流年卦'),
    );

    final liuyue = strategy.calculateLiuyueForAge(
      age,
      liunian.gua,
      yuantangYaoIndex,
    );
    _liuyueCache[age] = liuyue;
    return liuyue;
  }
}

extension YuanTangInfoFlowExt on YuanTangInfo {
  /// 在 YuanTangInfo 上附加/构建流运聚合，便于上层统一获取
  YuanTangFlowAggregate attachFlowAggregate({
    required YuanTangBaseNumberModel model,
    required int birthYear,
    required YuanTangStrategy strategy,
  }) {
    return YuanTangFlowAggregate.fromModel(
      model: model,
      birthYear: birthYear,
      strategy: strategy,
    );
  }
}
