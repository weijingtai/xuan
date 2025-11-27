import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/services/shen_sha_calculation_service.dart';
import '../../domain/entities/shen_sha_entity.dart';

/// 神煞数据加载服务实现类
class ShenShaDataServiceImpl implements ShenShaDataService {
  List<TianGanShenShaEntity>? _tianGanShenShaCache;
  List<YearShenShaEntity>? _yearShenShaCache;
  List<MonthShenShaEntity>? _monthShenShaCache;
  List<DiZhiShenShaEntity>? _diZhiShenShaCache;
  List<JiShenShaEntity>? _jiShenShaCache;
  List<XunShenShaEntity>? _xunShenShaCache;

  @override
  Future<List<TianGanShenShaEntity>> loadTianGanShenSha() async {
    if (_tianGanShenShaCache != null) {
      return _tianGanShenShaCache!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/shen_sha/6_shensha_gan.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _tianGanShenShaCache =
          jsonList.map((json) => TianGanShenShaEntity.fromJson(json)).toList();

      return _tianGanShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 天干神煞 data: $e');
    }
  }

  @override
  Future<List<YearShenShaEntity>> loadYearShenSha() async {
    if (_yearShenShaCache != null) {
      return _yearShenShaCache!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/shen_sha/6_shensha_year.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _yearShenShaCache =
          jsonList.map((json) => YearShenShaEntity.fromJson(json)).toList();

      return _yearShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 年支神煞 data: $e');
    }
  }

  @override
  Future<List<MonthShenShaEntity>> loadMonthShenSha() async {
    if (_monthShenShaCache != null) {
      return _monthShenShaCache!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/shen_sha/6_shensha_month.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _monthShenShaCache =
          jsonList.map((json) => MonthShenShaEntity.fromJson(json)).toList();

      return _monthShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 月支神煞 data: $e');
    }
  }

  @override
  Future<List<DiZhiShenShaEntity>> loadDiZhiShenSha() async {
    if (_diZhiShenShaCache != null) {
      return _diZhiShenShaCache!;
    }

    try {
      // 从年煞和月煞数据中提取地支神煞（按type分类）
      final yearShenShaList = await loadYearShenSha();
      final monthShenShaList = await loadMonthShenSha();

      _diZhiShenShaCache = [
        ...yearShenShaList
            .where((item) => item.type == '支煞')
            .map((item) => DiZhiShenShaEntity(
                  name: item.name,
                  jiXiong: item.jiXiong,
                  descriptionList: item.descriptionList,
                  type: item.type,
                  locationMapper: item.locationMapper,
                  locationDescriptionList: item.locationDescriptionList,
                  otherNameList: item.otherNameList,
                )),
        ...monthShenShaList
            .where((item) => item.type == '支煞')
            .map((item) => DiZhiShenShaEntity(
                  name: item.name,
                  jiXiong: item.jiXiong,
                  descriptionList: item.descriptionList,
                  type: item.type,
                  locationMapper: item.locationMapper,
                  locationDescriptionList: item.locationDescriptionList,
                  otherNameList: item.otherNameList,
                )),
      ];

      return _diZhiShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 地支神煞 data: $e');
    }
  }

  @override
  Future<List<JiShenShaEntity>> loadJiShenSha() async {
    if (_jiShenShaCache != null) {
      return _jiShenShaCache!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/shen_sha/6_shensha_ji.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _jiShenShaCache =
          jsonList.map((json) => JiShenShaEntity.fromJson(json)).toList();

      return _jiShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 季煞 data: $e');
    }
  }

  @override
  Future<List<XunShenShaEntity>> loadXunShenSha() async {
    if (_xunShenShaCache != null) {
      return _xunShenShaCache!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/shen_sha/6_shensha_xun.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _xunShenShaCache =
          jsonList.map((json) => XunShenShaEntity.fromJson(json)).toList();

      return _xunShenShaCache!;
    } catch (e) {
      throw Exception('Failed to load 旬煞 data: $e');
    }
  }

  @override
  Future<List<ShenShaEntity>> loadAllShenSha() async {
    try {
      final tianGanList = await loadTianGanShenSha();
      final yearList = await loadYearShenSha();
      final monthList = await loadMonthShenSha();
      final diZhiList = await loadDiZhiShenSha();
      final jiList = await loadJiShenSha();
      final xunList = await loadXunShenSha();

      return [
        ...tianGanList,
        ...yearList,
        ...monthList,
        ...diZhiList,
        ...jiList,
        ...xunList,
      ];
    } catch (e) {
      throw Exception('Failed to load all 神煞 data: $e');
    }
  }
}
