import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/domain/services/da_liu_ren_calculation_service.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/da_liu_ren_pan_model.dart';

class DaLiuRenRepositoryImpl implements DaLiuRenRepository {
  final DaLiuRenCalculationService calculationService;

  DaLiuRenRepositoryImpl({required this.calculationService});
  static const String _yangAssetPath = "assets/da_liu_ren/甲午庚牛羊_阳.json";
  static const String _yinAssetPath = "assets/da_liu_ren/甲午庚牛羊_阴.json";
  static const String _juMapperPath = "assets/da_liu_ren/ju_mapper.json";
  static const String _yuDingPath = "assets/da_liu_ren/御定大六壬.json";

  List<dynamic>? _yuDingData;
  Map<String, dynamic>? _juMapperData;
  List<DaLiuRenPanModel>? _yangPanData;
  List<DaLiuRenPanModel>? _yinPanData;

  @override
  Future<void> loadDivinationData() async {
    logger.d('🟡 [Repository] loadDivinationData() called');
    try {
      await Future.wait([
        _loadYuDingData(),
        _loadJuMapperData(),
        _loadPanData(YinYang.YANG),
        _loadPanData(YinYang.YIN),
      ]);
      logger.d('🟡 [Repository] All divination data loaded successfully');
    } catch (e) {
      logger.e('🔴 [Repository] Failed to load some divination data: $e');
      // 允许部分数据加载失败，应用仍可继续运行
    }
  }

  Future<void> _loadYuDingData() async {
    if (_yuDingData != null) return;
    try {
      final jsonString = await rootBundle.loadString(_yuDingPath);
      final decoded = jsonDecode(jsonString);
      _yuDingData =
          decoded is List<dynamic> ? decoded : List<dynamic>.from(decoded);
    } catch (e) {
      logger.w('Warning: Failed to load Yu Ding data: $e');
      _yuDingData = <dynamic>[];
    }
  }

  Future<void> _loadJuMapperData() async {
    if (_juMapperData != null) return;
    try {
      final jsonString = await rootBundle.loadString(_juMapperPath);
      final decoded = jsonDecode(jsonString);
      _juMapperData = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded);
    } catch (e) {
      logger.w('Warning: Failed to load Ju Mapper data: $e');
      _juMapperData = <String, dynamic>{};
    }
  }

  Future<void> _loadPanData(YinYang yinYang) async {
    try {
      final assetPath = yinYang.isYang ? _yangAssetPath : _yinAssetPath;
      final jsonString = await rootBundle.loadString(assetPath);
      final panList = _convertJsonToDaLiuRenPanModel(jsonString);

      if (yinYang.isYang) {
        _yangPanData = panList;
      } else {
        _yinPanData = panList;
      }
    } catch (e) {
      logger.w('Warning: Failed to load ${yinYang.name} pan data: $e');
      // 设置空列表作为默认值
      if (yinYang.isYang) {
        _yangPanData = <DaLiuRenPanModel>[];
      } else {
        _yinPanData = <DaLiuRenPanModel>[];
      }
    }
  }

  List<DaLiuRenPanModel> _convertJsonToDaLiuRenPanModel(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      List<dynamic> jsonList;

      // 处理 Web 平台的 JSArray 类型转换问题
      if (kIsWeb) {
        // Web 平台特殊处理
        if (decoded.runtimeType.toString().contains('JSArray')) {
          // 强制转换 JSArray 为 Dart List
          jsonList = List<dynamic>.from(decoded);
        } else if (decoded is List<dynamic>) {
          jsonList = decoded;
        } else {
          jsonList = List<dynamic>.from(decoded);
        }
      } else {
        // 非 Web 平台的正常处理
        jsonList =
            decoded is List<dynamic> ? decoded : List<dynamic>.from(decoded);
      }

      return jsonList.map((item) {
        Map<String, dynamic> itemMap;
        if (kIsWeb && item.runtimeType.toString().contains('JSObject')) {
          // Web 平台的 JSObject 转换
          itemMap = Map<String, dynamic>.from(item);
        } else if (item is Map<String, dynamic>) {
          itemMap = item;
        } else {
          itemMap = Map<String, dynamic>.from(item);
        }
        return DaLiuRenPanModel.fromJson(itemMap);
      }).toList();
    } catch (e) {
      logger.e('Error converting JSON to DaLiuRenPanModel: $e');
      logger.e('Runtime type: ${jsonDecode(jsonString).runtimeType}');
      // 返回空列表而不是崩溃
      return <DaLiuRenPanModel>[];
    }
  }

  @override
  Future<DaLiuRenKePan> calculateDivination(DateTime dateTime,
      {String? question}) async {
    logger.d('🟡 [Repository] calculateDivination() called for $dateTime');
    try {
      // Ensure data is loaded (for future use of YuDing data, etc.)
      await loadDivinationData();

      logger.d('🟡 [Repository] Calling CalculationService.calculate()...');
      // Use CalculationService to perform real calculation
      final kePan = calculationService.calculate(dateTime, question: question);
      logger
          .d('🟡 [Repository] CalculationService returned KePan successfully');

      return kePan;
    } catch (e) {
      logger.e('🔴 [Repository] Error in calculateDivination: $e');
      rethrow; // 不再吞掉异常,让上层处理
    }
  }

  Future<DaLiuRenPanModel> _getPanByJuNumber(
      JiaZi dayJiaZi, YinYang yinYangDun, int number) async {
    final resultList = yinYangDun.isYang ? _yangPanData! : _yinPanData!;
    final juNumberName = ConstResourcesMapper.chineseNumberMapper[number]!;
    return resultList.firstWhere(
        (pan) => pan.dayJiaZi == dayJiaZi && pan.juNumberName == juNumberName);
  }

  Future<DaLiuRenPanModel> _getPanByTimeZhi(
      JiaZi dayJiaZi, DiZhi shiZhi, YinYang yinYangDun) async {
    final resultList = yinYangDun.isYang ? _yangPanData! : _yinPanData!;
    return resultList
        .firstWhere((pan) => pan.dayJiaZi == dayJiaZi && pan.shiChen == shiZhi);
  }

  Future<int> _checkPanJu(
      JiaZi dayJiaZi, JiaZi timeJiaZi, YinYang yinYangDun) async {
    final mapper = _getJuMapper();
    return mapper[dayJiaZi.name]![timeJiaZi.diZhi.name]![
        yinYangDun.isYang ? "yang" : "yin"]!;
  }

  Map<String, Map<String, Map<String, int>>> _getJuMapper() {
    final decodedJson = _juMapperData as Map<String, dynamic>;
    return decodedJson.map((key, value) {
      return MapEntry(
        key,
        (value as Map<String, dynamic>).map((subKey, subValue) {
          return MapEntry(
            subKey,
            (subValue as Map<String, dynamic>).map((subSubKey, subSubValue) {
              return MapEntry(subSubKey, subSubValue as int);
            }),
          );
        }),
      );
    });
  }

  @override
  Future<List<dynamic>> getYuDingData() async {
    await _loadYuDingData();
    return _yuDingData!;
  }

  @override
  Future<Map<String, dynamic>> getJuMapperData() async {
    await _loadJuMapperData();
    return _juMapperData!;
  }
}
