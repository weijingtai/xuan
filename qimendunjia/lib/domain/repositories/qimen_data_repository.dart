import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';

/// 奇门数据仓储接口
///
/// 负责加载奇门遁甲的静态数据（克应、格局等）
abstract class QiMenDataRepository {
  /// 获取十干克应
  ///
  /// [tianPan] 天盘天干
  /// [diPan] 地盘天干
  ///
  /// 返回对应的十干克应数据
  ///
  /// 抛出 [QiMenDataNotFoundException] 当数据不存在时
  Future<TenGanKeYing> getTenGanKeYing({
    required TianGan tianPan,
    required TianGan diPan,
  });

  /// 获取门星克应
  ///
  /// [door] 八门
  /// [star] 九星
  ///
  /// 返回对应的门星克应数据，如果不存在返回 null
  Future<DoorStarKeYing?> getDoorStarKeYing({
    required EightDoorEnum door,
    required NineStarsEnum star,
  });

  /// 获取八门克应
  ///
  /// [door] 当前八门
  /// [fixDoor] 固定八门
  ///
  /// 返回对应的八门克应数据（阴阳两种情况），如果不存在返回 null
  Future<Map<YinYang, EightDoorKeYing>?> getEightDoorKeYing({
    required EightDoorEnum door,
    required EightDoorEnum fixDoor,
  });

  /// 获取三奇入宫
  ///
  /// [gong] 宫位
  /// [gan] 天干
  ///
  /// 返回对应的三奇入宫数据，如果不存在返回 null
  Future<QiYiRuGong?> getQiYiRuGong({
    required HouTianGua gong,
    required TianGan gan,
  });

  /// 获取十干克应格局
  ///
  /// [tianPan] 天盘天干
  /// [diPan] 地盘天干
  ///
  /// 返回对应的十干克应格局数据
  ///
  /// 抛出 [QiMenDataNotFoundException] 当数据不存在时
  Future<TenGanKeYingGeJu> getTenGanKeYingGeJu({
    required TianGan tianPan,
    required TianGan diPan,
  });

  /// 获取八门干克应字符串
  ///
  /// [door] 八门
  /// [gan] 天干
  ///
  /// 返回对应的克应描述文本，如果不存在返回 null
  Future<String?> getEightDoorGanKeYing({
    required EightDoorEnum door,
    required TianGan gan,
  });

  /// 获取天干入宫疾病信息
  ///
  /// [gong] 宫位
  /// [gan] 天干
  ///
  /// 返回对应的疾病信息描述，如果不存在返回 null
  Future<String?> getTianGanRuGongDisease({
    required HouTianGua gong,
    required TianGan gan,
  });

  /// 清除缓存
  ///
  /// 清除所有已加载的数据缓存
  Future<void> clearCache();
}

/// 奇门数据未找到异常
class QiMenDataNotFoundException implements Exception {
  final String message;

  QiMenDataNotFoundException(this.message);

  @override
  String toString() => 'QiMenDataNotFoundException: $message';
}
