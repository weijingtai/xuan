import 'package:qimendunjia/model/each_gong.dart';
import 'package:common/enums.dart';
import 'package:qimendunjia/model/tian_gan.dart';

/// 盘面排列结果的封装类。
///
/// 包含排列好的九宫格数据以及重要的盘面参数，如值符、值使等。
class PlateArrangementResult {
  /// 排列好的九宫格映射。
  /// Key为后天八卦（代表宫位），Value为该宫的具体信息。
  final Map<HouTianGua, EachGong> gongMapper;

  /// 值使门。
  final EightDoorEnum zhiShiDoor;

  /// 值使门所在的宫位。
  final HouTianGua zhiShiDoorAtGong;

  /// 值符星。
  final NineStarsEnum zhiFuStar;

  /// 值符星所在的宫位（寄宫调整前）。
  final HouTianGua zhiFuStarAtGong;

  /// 中宫的天干 (通常在转盘中为空，飞盘中可能用到).
  final TianGan ganAtCenterGong;

  /// 值符天干。根据时家局和旬首确定。
  final TianGan zhiFuGan;

  /// 值符原始宫位数 (寄宫调整前的宫位数字，例如 1 代表坎宫)。
  final int zhiFuGongNumber;

  PlateArrangementResult({
    required this.gongMapper,
    required this.zhiShiDoor,
    required this.zhiShiDoorAtGong,
    required this.zhiFuStar,
    required this.zhiFuStarAtGong,
    required this.ganAtCenterGong,
    required this.zhiFuGan,
    required this.zhiFuGongNumber,
  });
}
