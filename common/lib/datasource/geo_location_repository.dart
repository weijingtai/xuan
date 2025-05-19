import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:common/datamodel/geo_location.dart';

class GeoLocationRepository {
  static GeoLocationRepository? _instance;
  static List<GeoLocation>? _cachedLocations;
  static Map<GeoLevel, List<GeoLocation>>? _cachedLocationsByLevel;
  static Map<String, GeoLocation>? _cachedLocationsByCode;

  String geoLocationPath;

  // 私有构造函数
  GeoLocationRepository._({required this.geoLocationPath});

  // 工厂构造函数
  factory GeoLocationRepository({required String path}) {
    _instance ??= GeoLocationRepository._(geoLocationPath: path);
    return _instance!;
  }

  /// 从资源文件加载数据
  Future<void> loadLocationsFromAssets() async {
    if (_cachedLocations != null) {
      return;
    }

    try {
      final String jsonString = await rootBundle.loadString(geoLocationPath);
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;

      _cachedLocations = [];
      _cachedLocationsByLevel = {
        GeoLevel.country: [],
        GeoLevel.province: [],
        GeoLevel.city: [],
        GeoLevel.county: [],
      };
      _cachedLocationsByCode = {};

      for (var item in jsonData) {
        try {
          final int levelValue = int.tryParse(item['level'].toString()) ?? 0;
          final GeoLevel level = GeoLevel.fromValue(levelValue);

          final double latitude =
              double.tryParse(item['latitude'].toString()) ?? 0.0;
          final double longitude =
              double.tryParse(item['longitude'].toString()) ?? 0.0;

          final GeoLocation location = GeoLocation(
            code: item['code'].toString(),
            parentCode: item['parentCode'].toString(),
            level: level,
            name: item['name'].toString(),
            latitude: latitude,
            longitude: longitude,
          );

          _cachedLocations!.add(location);
          _cachedLocationsByLevel![level]?.add(location);
          _cachedLocationsByCode![location.code] = location;
        } catch (e) {
          throw Exception('解析地理位置数据出错: $e');
        }
      }
    } catch (e) {
      throw Exception('加载地理位置数据失败: $e');
    }
  }

  /// 获取所有地理位置数据
  Future<List<GeoLocation>> getAllLocations() async {
    await _checkInitialized();
    return List.unmodifiable(_cachedLocations!);
  }

  /// 按行政级别获取地理位置数据
  Future<List<GeoLocation>> listAllByLevel(GeoLevel level) async {
    await _checkInitialized();
    return List.unmodifiable(_cachedLocationsByLevel![level] ?? []);
  }

  /// 按行政级别获取地理位置数据
  Future<List<GeoLocation>> listCitiesByProvince(String provinceCode) async {
    await _checkInitialized();
    return List.unmodifiable(_cachedLocationsByLevel![GeoLevel.city]!
            .where((c) => c.parentCode == provinceCode)
            .toList() ??
        []);
  }

  Future<List<GeoLocation>> listCountiesByProvince(String cityCode) async {
    await _checkInitialized();
    return List.unmodifiable(_cachedLocationsByLevel![GeoLevel.county]!
            .where((c) => c.parentCode == cityCode)
            .toList() ??
        []);
  }

  /// 按编码获取地理位置数据
  Future<GeoLocation?> getLocationByCode(String code) async {
    await _checkInitialized();
    return _cachedLocationsByCode![code];
  }

  /// 获取指定地区的子地区
  Future<List<GeoLocation>> getChildLocations(String parentCode) async {
    await _checkInitialized();
    return _cachedLocations!
        .where((location) => location.parentCode == parentCode)
        .toList();
  }

  /// 按名称搜索地理位置
  Future<List<GeoLocation>> searchLocationsByName(String keyword) async {
    await _checkInitialized();
    if (keyword.isEmpty) return [];

    return _cachedLocations!
        .where((location) => location.name.contains(keyword))
        .toList();
  }

  /// 获取完整的地址路径（省市县）
  Future<String> getFullAddressPath(String code) async {
    await _checkInitialized();

    final List<String> addressParts = [];
    String currentCode = code;

    for (int i = 0; i < 3; i++) {
      final GeoLocation? location = _cachedLocationsByCode![currentCode];
      if (location == null) break;

      addressParts.insert(0, location.name);

      if (location.level == GeoLevel.province) break;

      currentCode = location.parentCode;
    }

    return addressParts.join(' ');
  }

  /// 检查是否已初始化
  Future<void> _checkInitialized() async {
    if (_cachedLocations == null) {
      await loadLocationsFromAssets();
    }
  }
}
