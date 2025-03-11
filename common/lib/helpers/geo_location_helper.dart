import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:common/datamodel/geo_location.dart';

/// 地理位置数据加载和处理工具类
class GeoLocationHelper {
  /// 所有地理位置数据
  static List<GeoLocation> _allLocations = [];

  /// 按行政级别分组的地理位置数据
  static Map<GeoLevel, List<GeoLocation>> _locationsByLevel = {};

  /// 按编码索引的地理位置数据
  static Map<String, GeoLocation> _locationsByCode = {};

  /// 是否已初始化
  static bool _isInitialized = false;

  /// 初始化地理位置数据
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 从资源文件中加载 JSON 数据
      final String jsonString = await rootBundle
          .loadString('assets/dataset/province_city_area_lng_lat.json');
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;

      // 清空现有数据
      _allLocations = [];
      _locationsByLevel = {
        GeoLevel.country: [],
        GeoLevel.province: [],
        GeoLevel.city: [],
        GeoLevel.county: [],
      };
      _locationsByCode = {};

      // 解析 JSON 数据并转换为 GeoLocation 对象
      for (var item in jsonData) {
        try {
          // 解析级别
          final int levelValue = int.tryParse(item['level'].toString()) ?? 0;
          final GeoLevel level = GeoLevel.fromValue(levelValue);

          // 解析经纬度
          final double latitude =
              double.tryParse(item['latitude'].toString()) ?? 0.0;
          final double longitude =
              double.tryParse(item['longitude'].toString()) ?? 0.0;

          // 创建 GeoLocation 对象
          final GeoLocation location = GeoLocation(
            code: item['code'].toString(),
            parentCode: item['parentCode'].toString(),
            level: level,
            name: item['name'].toString(),
            latitude: latitude,
            longitude: longitude,
          );

          // 添加到集合中
          _allLocations.add(location);
          _locationsByLevel[level]?.add(location);
          _locationsByCode[location.code] = location;
        } catch (e) {
          print('解析地理位置数据出错: $e');
        }
      }

      _isInitialized = true;
      print('成功加载 ${_allLocations.length} 条地理位置数据');
    } catch (e) {
      print('加载地理位置数据失败: $e');
      rethrow;
    }
  }

  /// 获取所有地理位置数据
  static List<GeoLocation> getAllLocations() {
    _checkInitialized();
    return List.unmodifiable(_allLocations);
  }

  /// 按行政级别获取地理位置数据
  static List<GeoLocation> getLocationsByLevel(GeoLevel level) {
    _checkInitialized();
    return List.unmodifiable(_locationsByLevel[level] ?? []);
  }

  /// 按编码获取地理位置数据
  static GeoLocation? getLocationByCode(String code) {
    _checkInitialized();
    return _locationsByCode[code];
  }

  /// 获取指定地区的子地区
  static List<GeoLocation> getChildLocations(String parentCode) {
    _checkInitialized();
    return _allLocations
        .where((location) => location.parentCode == parentCode)
        .toList();
  }

  /// 按名称搜索地理位置
  static List<GeoLocation> searchLocationsByName(String keyword) {
    _checkInitialized();
    if (keyword.isEmpty) return [];

    return _allLocations
        .where((location) => location.name.contains(keyword))
        .toList();
  }

  /// 获取完整的地址路径（省市县）
  static String getFullAddressPath(String code) {
    _checkInitialized();

    final List<String> addressParts = [];
    String currentCode = code;

    // 最多循环 3 次，避免无限循环
    for (int i = 0; i < 3; i++) {
      final GeoLocation? location = _locationsByCode[currentCode];
      if (location == null) break;

      addressParts.insert(0, location.name);

      // 如果已经到达省级，则停止
      if (location.level == GeoLevel.province) break;

      currentCode = location.parentCode;
    }

    return addressParts.join(' ');
  }

  /// 检查是否已初始化
  static void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError('GeoLocationHelper 尚未初始化，请先调用 initialize() 方法');
    }
  }
}
