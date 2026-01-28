import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../enums/enum_jia_zi.dart';
import '../../models/eight_chars.dart';
import '../../models/jie_qi_info.dart';
import 'enum_calculate_strategy.dart';

part 'tai_yuan_model.g.dart';

/// 出生信息类
/// 用于胎元推算的基础数据
@JsonSerializable()
class TaiYuanModel extends Equatable {
  /// 受孕时间  只用当法为[TaiYuanCalculateStrategy.directConceptionDate]时有效 其余都只作为参考
  /// 当为通过"日元阴阳法"时，不需要确定具体的时间
  DateTime? conceptionDateTime;

  EightChars? ganZhi;

  // 三方库不支持序列化
  // Lunar? lunar;
  int? lunarMonth;
  int? lunarDay;
  JieQiInfo? jieQiInfo;

  // 只用明确的知道受孕时间才算作是精确的， 需要精确到时辰
  bool get isPrecisionConceptionDateTime =>
      TaiYuanCalculateStrategy.directConceptionDate == calculateStrategy;

  JiaZi taiYuanGanZhi;

  /// 调整后的胎元（用于早产或晚产情况）
  JiaZi? adjustedTaiYuan;

  int taiYuanBeforeMonth;

  /// 是否试管婴儿
  bool isTestTubeBaby;

  /// 胎元计算策略
  TaiYuanCalculateStrategy calculateStrategy;
  double totalMatureMonth = 0;

  bool get isPostmature => totalMatureMonth > 10;
  bool get isPremature => totalMatureMonth < 10;
  bool get isMature => totalMatureMonth == 10;

  TaiYuanModel({
    required this.taiYuanGanZhi,
    required this.taiYuanBeforeMonth,
    required this.calculateStrategy,
    this.totalMatureMonth = 0,
    this.isTestTubeBaby = false,
    this.adjustedTaiYuan,
    this.conceptionDateTime,
    this.ganZhi,
    // this.lunar,
    this.lunarMonth,
    this.lunarDay,
    this.jieQiInfo,
  });

  /// 从JSON创建实例
  factory TaiYuanModel.fromJson(Map<String, dynamic> json) =>
      _$TaiYuanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TaiYuanModelToJson(this);

  /// 是否有确切的受孕时间
  bool get hasConceptionDateTime => conceptionDateTime != null;

  /// 获取推荐的计算策略
  TaiYuanCalculateStrategy get recommendedStrategy {
    if (hasConceptionDateTime) {
      return TaiYuanCalculateStrategy.directConceptionDate;
    }
    return TaiYuanCalculateStrategy.monthPillarMethod;
  }

  /// 复制并修改部分属性
  TaiYuanModel copyWith({
    JiaZi? taiYuanGanZhi,
    JiaZi? adjustedTaiYuan,
    int? taiYuanBeforeMonth,
    DateTime? conceptionDateTime,
    bool? isTestTubeBaby,
    double? totalMatureMonth,
    EightChars? ganZhi,
    int? lunarMonth,
    int? lunarDay,
    // Lunar? lunar,
    JieQiInfo? jieQiInfo,
    TaiYuanCalculateStrategy? calculateStrategy,
  }) {
    return TaiYuanModel(
      conceptionDateTime: conceptionDateTime ?? this.conceptionDateTime,
      isTestTubeBaby: isTestTubeBaby ?? this.isTestTubeBaby,
      totalMatureMonth: totalMatureMonth ?? this.totalMatureMonth,
      ganZhi: ganZhi ?? this.ganZhi,
      // lunar: lunar ?? this.lunar,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      jieQiInfo: jieQiInfo ?? this.jieQiInfo,
      calculateStrategy: calculateStrategy ?? this.calculateStrategy,
      taiYuanGanZhi: taiYuanGanZhi ?? this.taiYuanGanZhi,
      adjustedTaiYuan: adjustedTaiYuan ?? this.adjustedTaiYuan,
      taiYuanBeforeMonth: taiYuanBeforeMonth ?? this.taiYuanBeforeMonth,
    );
  }

  @override
  List<Object?> get props => [
        taiYuanGanZhi,
        adjustedTaiYuan,
        taiYuanBeforeMonth,
        conceptionDateTime,
        isTestTubeBaby,
        totalMatureMonth,
        calculateStrategy,
      ];
  static calculateBeforeMonth(JiaZi taiYuanGanZhi, JiaZi birthMonthGanZhi) {
    var birthMontGanZhi = birthMonthGanZhi.number;
    var connGanZhi = taiYuanGanZhi.number;
    var monthDifference = birthMontGanZhi - connGanZhi;
    // 如果差值小于0，说明生时月份在后一个甲子中，相差的月份计算：
    if (monthDifference < 0) {
      monthDifference =
          JiaZi.listAll.last.number - connGanZhi + birthMontGanZhi;
    }
    return monthDifference;
  }
}
