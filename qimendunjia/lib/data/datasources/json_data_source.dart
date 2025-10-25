import 'package:qimendunjia/utils/read_data_utils.dart';
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';

/// JSON 数据源
///
/// 负责加载和缓存 JSON 数据文件
/// 使用懒加载策略，只在需要时加载
class JsonDataSource {
  final Map<String, dynamic> _cache = {};

  /// 加载十干克应数据
  ///
  /// 返回 天盘干 -> 地盘干 -> 克应数据 的映射
  Future<Map<TianGan, Map<TianGan, TenGanKeYing>>> loadTenGanKeYing() async {
    const key = 'ten_gan_ke_ying';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<TianGan, Map<TianGan, TenGanKeYing>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readTenGanKeYing();
    _cache[key] = data;

    return data;
  }

  /// 加载十干克应格局数据
  ///
  /// 返回 天盘干 -> 地盘干 -> 格局数据 的映射
  Future<Map<TianGan, Map<TianGan, TenGanKeYingGeJu>>>
      loadTenGanKeYingGeJu() async {
    const key = 'ten_gan_ke_ying_ge_ju';
    if (_cache.containsKey(key)) {
      return _cache[key]
          as Map<TianGan, Map<TianGan, TenGanKeYingGeJu>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readTenGanKeYingGeJu();
    _cache[key] = data;

    return data;
  }

  /// 加载门星克应数据
  ///
  /// 返回 门 -> 星 -> 克应数据 的映射
  Future<Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>>>
      loadDoorStarKeYing() async {
    const key = 'door_star_ke_ying';
    if (_cache.containsKey(key)) {
      return _cache[key]
          as Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readDoorStarKeYing();
    _cache[key] = data;

    return data;
  }

  /// 加载八门克应数据
  ///
  /// 返回 门 -> 固定门 -> 阴阳 -> 克应数据 的映射
  Future<Map<EightDoorEnum, Map<EightDoorEnum, Map<YinYang, EightDoorKeYing>>>>
      loadEightDoorKeYing() async {
    const key = 'eight_door_ke_ying';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<EightDoorEnum,
          Map<EightDoorEnum, Map<YinYang, EightDoorKeYing>>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readEightDoorKeYing();
    _cache[key] = data;

    return data;
  }

  /// 加载三奇入宫数据
  ///
  /// 返回 宫 -> 天干 -> 入宫数据 的映射
  Future<Map<HouTianGua, Map<TianGan, QiYiRuGong>>> loadQiYiRuGong() async {
    const key = 'qi_yi_ru_gong';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<HouTianGua, Map<TianGan, QiYiRuGong>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readQiYiRuGong();
    _cache[key] = data;

    return data;
  }

  /// 加载八门干克应数据
  ///
  /// 返回 门 -> 天干 -> 克应字符串 的映射
  Future<Map<EightDoorEnum, Map<TianGan, String>>>
      loadEightDoorGanKeYing() async {
    const key = 'eight_door_gan_ke_ying';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<EightDoorEnum, Map<TianGan, String>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readDoorGanKeYing();
    _cache[key] = data;

    return data;
  }

  /// 加载天干入宫疾病数据
  ///
  /// 返回 宫 -> 天干 -> 疾病描述 的映射
  Future<Map<HouTianGua, Map<TianGan, String>>>
      loadTianGanRuGongDisease() async {
    const key = 'tian_gan_ru_gong_disease';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<HouTianGua, Map<TianGan, String>>;
    }

    // 使用现有的工具类加载
    final data = await ReadDataUtils.readQiYiRuGongDisease();
    _cache[key] = data;

    return data;
  }

  /// 清除所有已加载的数据缓存
  void clearCache() {
    _cache.clear();
  }

  /// 获取缓存大小
  int get cacheSize => _cache.length;

  /// 检查是否已加载某个数据集
  bool isLoaded(String key) => _cache.containsKey(key);
}
