import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_most_popular_ge_ju.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'base_entity.dart';
import 'each_gong.dart';
import 'shi_jia_ju.dart';

/// 奇门盘实体
///
/// 表示完整的奇门遁甲盘局（天地人神四盘+格局信息）
class QiMenPan extends Equatable implements Entity {
  @override
  final String id;

  /// 起盘时间
  final DateTime panDateTime;

  /// 局信息
  final ShiJiaJu shiJiaJu;

  /// 盘类型（转盘/飞盘）
  final PlateType plateType;

  /// 九宫信息映射（卦象 -> 宫位信息）
  final Map<HouTianGua, EachGong> gongMapper;

  // ==================== 值符值使 ====================

  /// 值使门
  final EightDoorEnum zhiShiDoor;

  /// 值使门所在宫
  final HouTianGua zhiShiDoorAtGong;

  /// 值符星
  final NineStarsEnum zhiFuStar;

  /// 值符星所在宫
  final HouTianGua zhiFuStarAtGong;

  // ==================== 伏吟反吟 ====================

  /// 星伏吟
  final bool isStarFuYin;

  /// 星反吟
  final bool isStarFanYin;

  /// 门伏吟
  final bool isDoorFuYin;

  /// 门反吟
  final bool isDoorFanYin;

  /// 干伏吟
  final bool isGanFuYin;

  /// 干反吟
  final bool isGanFanYin;

  // ==================== 格局信息 ====================

  /// 格局列表
  final List<EnumMostPopularGeJu>? panGeJuList;

  // ==================== 其他信息 ====================

  /// 驿马位
  final DiZhi horseLocation;

  QiMenPan({
    required this.id,
    required this.panDateTime,
    required this.shiJiaJu,
    required this.plateType,
    required this.gongMapper,
    required this.zhiShiDoor,
    required this.zhiShiDoorAtGong,
    required this.zhiFuStar,
    required this.zhiFuStarAtGong,
    required this.isStarFuYin,
    required this.isStarFanYin,
    required this.isDoorFuYin,
    required this.isDoorFanYin,
    required this.isGanFuYin,
    required this.isGanFanYin,
    required this.horseLocation,
    this.panGeJuList,
  });

  @override
  List<Object?> get props => [
        id,
        panDateTime,
        shiJiaJu,
        plateType,
        gongMapper,
        zhiShiDoor,
        zhiShiDoorAtGong,
        zhiFuStar,
        zhiFuStarAtGong,
        isStarFuYin,
        isStarFanYin,
        isDoorFuYin,
        isDoorFanYin,
        isGanFuYin,
        isGanFanYin,
        panGeJuList,
        horseLocation,
      ];

  // ==================== 业务方法 ====================

  /// 是否存在任何伏吟
  bool get hasAnyFuYin => isStarFuYin || isDoorFuYin || isGanFuYin;

  /// 是否存在任何反吟
  bool get hasAnyFanYin => isStarFanYin || isDoorFanYin || isGanFanYin;

  /// 获取指定宫位信息
  EachGong? getGong(HouTianGua gua) => gongMapper[gua];

  /// 获取坎宫
  EachGong? get kanGong => getGong(HouTianGua.Kan);

  /// 获取坤宫
  EachGong? get kunGong => getGong(HouTianGua.Kun);

  /// 获取震宫
  EachGong? get zhenGong => getGong(HouTianGua.Zhen);

  /// 获取巽宫
  EachGong? get xunGong => getGong(HouTianGua.Xun);

  /// 获取中宫
  EachGong? get centerGong => getGong(HouTianGua.Center);

  /// 获取乾宫
  EachGong? get qianGong => getGong(HouTianGua.Qian);

  /// 获取兑宫
  EachGong? get duiGong => getGong(HouTianGua.Dui);

  /// 获取艮宫
  EachGong? get genGong => getGong(HouTianGua.Gen);

  /// 获取离宫
  EachGong? get liGong => getGong(HouTianGua.Li);

  /// 获取盘局简要描述
  String get brief =>
      '${shiJiaJu.juDescription} ${plateType.name} ${_formatDateTime(panDateTime)}';

  /// 获取格局数量
  int get geJuCount => panGeJuList?.length ?? 0;

  /// 是否包含指定格局
  bool hasGeJu(EnumMostPopularGeJu geJu) {
    return panGeJuList?.contains(geJu) ?? false;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour}时';
  }

  /// 复制并修改部分属性
  QiMenPan copyWith({
    String? id,
    DateTime? panDateTime,
    ShiJiaJu? shiJiaJu,
    PlateType? plateType,
    Map<HouTianGua, EachGong>? gongMapper,
    EightDoorEnum? zhiShiDoor,
    HouTianGua? zhiShiDoorAtGong,
    NineStarsEnum? zhiFuStar,
    HouTianGua? zhiFuStarAtGong,
    bool? isStarFuYin,
    bool? isStarFanYin,
    bool? isDoorFuYin,
    bool? isDoorFanYin,
    bool? isGanFuYin,
    bool? isGanFanYin,
    List<EnumMostPopularGeJu>? panGeJuList,
    DiZhi? horseLocation,
  }) {
    return QiMenPan(
      id: id ?? this.id,
      panDateTime: panDateTime ?? this.panDateTime,
      shiJiaJu: shiJiaJu ?? this.shiJiaJu,
      plateType: plateType ?? this.plateType,
      gongMapper: gongMapper ?? this.gongMapper,
      zhiShiDoor: zhiShiDoor ?? this.zhiShiDoor,
      zhiShiDoorAtGong: zhiShiDoorAtGong ?? this.zhiShiDoorAtGong,
      zhiFuStar: zhiFuStar ?? this.zhiFuStar,
      zhiFuStarAtGong: zhiFuStarAtGong ?? this.zhiFuStarAtGong,
      isStarFuYin: isStarFuYin ?? this.isStarFuYin,
      isStarFanYin: isStarFanYin ?? this.isStarFanYin,
      isDoorFuYin: isDoorFuYin ?? this.isDoorFuYin,
      isDoorFanYin: isDoorFanYin ?? this.isDoorFanYin,
      isGanFuYin: isGanFuYin ?? this.isGanFuYin,
      isGanFanYin: isGanFanYin ?? this.isGanFanYin,
      panGeJuList: panGeJuList ?? this.panGeJuList,
      horseLocation: horseLocation ?? this.horseLocation,
    );
  }
}
