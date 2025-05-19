import 'package:common/database/world_info_database.dart';
import 'package:common/datasource/loca_binary/country.pb.dart' as pb;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../local/regions.dart';

class WorldCountryRepository {
  static WorldCountryRepository? _instance;
  static pb.Countries? _cachedCountries;
  static List<RegionDataSet>? _cachedRegions;

  String allCountryPath;
  String regionJsonFilePath;

  // 私有构造函数
  WorldCountryRepository._(
      {required this.allCountryPath, required this.regionJsonFilePath});

  // 工厂构造函数
  factory WorldCountryRepository(
      {required String path, required String regionJsonFilePath}) {
    _instance ??= WorldCountryRepository._(
        allCountryPath: path, regionJsonFilePath: regionJsonFilePath);
    return _instance!;
  }

  Future<List<RegionDataSet>> loadRegionsFromAssets() async {
    if (_cachedRegions != null) {
      return _cachedRegions!;
    }
    try {
      final String jsonString = await rootBundle.loadString(regionJsonFilePath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedRegions = jsonList
          .map((json) => RegionDataSet.fromJson(json as Map<String, dynamic>))
          .toList();
      return _cachedRegions!;
    } catch (e) {
      throw Exception('Failed to load regions: $e');
    }
  }

  /// 加载 Protobuf 二进制数据
  Future<pb.Countries> loadAllCountriesFromAssets() async {
    // 如果已经加载过数据，直接返回缓存的数据
    if (_cachedCountries != null) {
      return _cachedCountries!;
    }
    try {
      // 1. 从 assets 加载二进制
      final ByteData data = await rootBundle.load(allCountryPath);
      final Uint8List buffer = data.buffer.asUint8List();

      // 2. 反序列化并缓存数据
      _cachedCountries = pb.Countries.fromBuffer(buffer);
      return _cachedCountries!;
    } catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }

  Future<List<pb.Country>> listCountriesByRegionId(int regionId) async {
    final pb.Countries countries = await loadAllCountriesFromAssets();
    return countries.countryList
        .where((country) => country.regionId == regionId)
        .toList();
  }

  Future<List<pb.State>> listStatesByCountryId(
      int regionId, int countryId) async {
    final pb.Countries countries = await loadAllCountriesFromAssets();
    return countries.countryList
        .firstWhere((t) => t.regionId == regionId && t.id == countryId)
        .states;
  }

  Future<List<pb.City>> listCitiesByStateId(
      int regionId, int countryId, int stateId) async {
    final pb.Countries countries = await loadAllCountriesFromAssets();
    return countries.countryList
        .firstWhere((t) => t.regionId == regionId && t.id == countryId)
        .states
        .firstWhere((s) => s.id == stateId)
        .cities;
  }

  Future<List<RegionDataSet>?> listAllRegion() async {
    final List<RegionDataSet>? regionList = await loadRegionsFromAssets();
    return regionList;
  }
}
