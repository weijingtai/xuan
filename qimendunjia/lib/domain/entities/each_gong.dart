import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/enums/enum_six_jia.dart';
import 'base_entity.dart';

/// 单宫实体
///
/// 表示奇门盘中一个宫位的完整信息（天地人神四盘）
class EachGong extends Equatable {
  /// 宫位号（1-9）
  final int gongNumber;

  /// 宫位卦象
  final HouTianGua gongGua;

  /// 九星
  final NineStarsEnum star;

  /// 八门
  final EightDoorEnum door;

  /// 八神（天盘）
  final EightGodsEnum god;

  /// 八神（地盘）
  final EightGodsEnum diGod;

  /// 天盘天干
  final TianGan tianPan;

  /// 地盘天干
  final TianGan diPan;

  /// 天盘暗干
  final TianGan tianPanAnGan;

  /// 人盘暗干
  final TianGan renPanAnGan;

  /// 隐干
  final TianGan yinGan;

  /// 天盘寄干（中五宫专用）
  final TianGan? tianPanJiGan;

  /// 地盘寄干（中五宫专用）
  final TianGan? diPanJiGan;

  /// 六甲旬首
  final SixJia? sixJiaXunHeader;

  /// 是否击天禽
  final bool isJiTianQin;

  EachGong({
    required this.gongNumber,
    required this.gongGua,
    required this.star,
    required this.door,
    required this.god,
    required this.diGod,
    required this.tianPan,
    required this.diPan,
    required this.tianPanAnGan,
    required this.renPanAnGan,
    required this.yinGan,
    this.tianPanJiGan,
    this.diPanJiGan,
    this.sixJiaXunHeader,
    this.isJiTianQin = false,
  });

  @override
  List<Object?> get props => [
        gongNumber,
        gongGua,
        star,
        door,
        god,
        diGod,
        tianPan,
        diPan,
        tianPanAnGan,
        renPanAnGan,
        yinGan,
        tianPanJiGan,
        diPanJiGan,
        sixJiaXunHeader,
        isJiTianQin,
      ];

  // ==================== 业务方法 ====================

  /// 九星是否伏吟（星在原宫）
  bool get isStarFuYin => star.originalGong == gongGua;

  /// 九星是否反吟（星在对宫）
  bool get isStarFanYin {
    final fanYinGua = switch (gongGua) {
      HouTianGua.Kan => HouTianGua.Li,
      HouTianGua.Li => HouTianGua.Kan,
      HouTianGua.Zhen => HouTianGua.Dui,
      HouTianGua.Dui => HouTianGua.Zhen,
      HouTianGua.Xun => HouTianGua.Qian,
      HouTianGua.Qian => HouTianGua.Xun,
      HouTianGua.Kun => HouTianGua.Gen,
      HouTianGua.Gen => HouTianGua.Kun,
      HouTianGua.Center => HouTianGua.Center,
    };
    return star.originalGong == fanYinGua;
  }

  /// 八门是否伏吟（门在原宫）
  bool get isDoorFuYin => door.originalGong == gongGua;

  /// 八门是否反吟（门在对宫）
  bool get isDoorFanYin {
    final fanYinGua = switch (gongGua) {
      HouTianGua.Kan => HouTianGua.Li,
      HouTianGua.Li => HouTianGua.Kan,
      HouTianGua.Zhen => HouTianGua.Dui,
      HouTianGua.Dui => HouTianGua.Zhen,
      HouTianGua.Xun => HouTianGua.Qian,
      HouTianGua.Qian => HouTianGua.Xun,
      HouTianGua.Kun => HouTianGua.Gen,
      HouTianGua.Gen => HouTianGua.Kun,
      HouTianGua.Center => HouTianGua.Center,
    };
    return door.originalGong == fanYinGua;
  }

  /// 天地干比和
  bool get isBiHe => tianPan == diPan;

  /// 获取宫位简要描述
  String get brief => '${gongGua.name}宫: ${star.name} ${door.name} ${god.name}';

  /// 获取天地盘描述
  String get ganDescription => '天盘${tianPan.name} 地盘${diPan.name}';

  /// 复制并修改部分属性
  EachGong copyWith({
    int? gongNumber,
    HouTianGua? gongGua,
    NineStarsEnum? star,
    EightDoorEnum? door,
    EightGodsEnum? god,
    EightGodsEnum? diGod,
    TianGan? tianPan,
    TianGan? diPan,
    TianGan? tianPanAnGan,
    TianGan? renPanAnGan,
    TianGan? yinGan,
    TianGan? tianPanJiGan,
    TianGan? diPanJiGan,
    SixJia? sixJiaXunHeader,
    bool? isJiTianQin,
  }) {
    return EachGong(
      gongNumber: gongNumber ?? this.gongNumber,
      gongGua: gongGua ?? this.gongGua,
      star: star ?? this.star,
      door: door ?? this.door,
      god: god ?? this.god,
      diGod: diGod ?? this.diGod,
      tianPan: tianPan ?? this.tianPan,
      diPan: diPan ?? this.diPan,
      tianPanAnGan: tianPanAnGan ?? this.tianPanAnGan,
      renPanAnGan: renPanAnGan ?? this.renPanAnGan,
      yinGan: yinGan ?? this.yinGan,
      tianPanJiGan: tianPanJiGan ?? this.tianPanJiGan,
      diPanJiGan: diPanJiGan ?? this.diPanJiGan,
      sixJiaXunHeader: sixJiaXunHeader ?? this.sixJiaXunHeader,
      isJiTianQin: isJiTianQin ?? this.isJiTianQin,
    );
  }
}
