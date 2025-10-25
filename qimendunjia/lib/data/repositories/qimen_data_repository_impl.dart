import 'package:common/enums.dart';
import 'package:qimendunjia/domain/repositories/qimen_data_repository.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';
import '../datasources/cache_data_source.dart';
import '../datasources/json_data_source.dart';

/// 奇门数据仓储实现
///
/// 负责管理数据加载和缓存
class QiMenDataRepositoryImpl implements QiMenDataRepository {
  final JsonDataSource _jsonDataSource;
  final CacheDataSource _cacheDataSource;

  QiMenDataRepositoryImpl(
    this._jsonDataSource,
    this._cacheDataSource,
  );

  @override
  Future<TenGanKeYing> getTenGanKeYing({
    required TianGan tianPan,
    required TianGan diPan,
  }) async {
    final cacheKey = 'ten_gan_${tianPan.name}_${diPan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<TenGanKeYing>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadTenGanKeYing();
    final result = data[tianPan]?[diPan];

    if (result == null) {
      throw QiMenDataNotFoundException(
        '未找到 ${tianPan.name}-${diPan.name} 的十干克应数据',
      );
    }

    // 3. 缓存结果
    await _cacheDataSource.set(cacheKey, result);

    return result;
  }

  @override
  Future<TenGanKeYingGeJu> getTenGanKeYingGeJu({
    required TianGan tianPan,
    required TianGan diPan,
  }) async {
    final cacheKey = 'ten_gan_geju_${tianPan.name}_${diPan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<TenGanKeYingGeJu>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadTenGanKeYingGeJu();
    final result = data[tianPan]?[diPan];

    if (result == null) {
      throw QiMenDataNotFoundException(
        '未找到 ${tianPan.name}-${diPan.name} 的十干克应格局数据',
      );
    }

    // 3. 缓存结果
    await _cacheDataSource.set(cacheKey, result);

    return result;
  }

  @override
  Future<DoorStarKeYing?> getDoorStarKeYing({
    required EightDoorEnum door,
    required NineStarsEnum star,
  }) async {
    final cacheKey = 'door_star_${door.name}_${star.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<DoorStarKeYing>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadDoorStarKeYing();
    final result = data[door]?[star];

    // 3. 缓存结果（即使为 null 也缓存，避免重复查找）
    if (result != null) {
      await _cacheDataSource.set(cacheKey, result);
    }

    return result;
  }

  @override
  Future<Map<YinYang, EightDoorKeYing>?> getEightDoorKeYing({
    required EightDoorEnum door,
    required EightDoorEnum fixDoor,
  }) async {
    final cacheKey = 'eight_door_${door.name}_${fixDoor.name}';

    // 1. 尝试从缓存获取
    final cached =
        await _cacheDataSource.get<Map<YinYang, EightDoorKeYing>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadEightDoorKeYing();
    final result = data[door]?[fixDoor];

    // 3. 缓存结果
    if (result != null) {
      await _cacheDataSource.set(cacheKey, result);
    }

    return result;
  }

  @override
  Future<QiYiRuGong?> getQiYiRuGong({
    required HouTianGua gong,
    required TianGan gan,
  }) async {
    final cacheKey = 'qi_yi_${gong.name}_${gan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<QiYiRuGong>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadQiYiRuGong();
    final result = data[gong]?[gan];

    // 3. 缓存结果
    if (result != null) {
      await _cacheDataSource.set(cacheKey, result);
    }

    return result;
  }

  @override
  Future<String?> getEightDoorGanKeYing({
    required EightDoorEnum door,
    required TianGan gan,
  }) async {
    final cacheKey = 'door_gan_${door.name}_${gan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<String>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadEightDoorGanKeYing();
    final result = data[door]?[gan];

    // 3. 缓存结果
    if (result != null) {
      await _cacheDataSource.set(cacheKey, result);
    }

    return result;
  }

  @override
  Future<String?> getTianGanRuGongDisease({
    required HouTianGua gong,
    required TianGan gan,
  }) async {
    final cacheKey = 'disease_${gong.name}_${gan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<String>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadTianGanRuGongDisease();
    final result = data[gong]?[gan];

    // 3. 缓存结果
    if (result != null) {
      await _cacheDataSource.set(cacheKey, result);
    }

    return result;
  }

  @override
  Future<void> clearCache() async {
    await _cacheDataSource.clear();
    _jsonDataSource.clearCache();
  }
}
