import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/da_liu_ren_pan_model.dart';

class DaLiuRenRepositoryImpl implements DaLiuRenRepository {
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
    try {
      await Future.wait([
        _loadYuDingData(),
        _loadJuMapperData(),
        _loadPanData(YinYang.YANG),
        _loadPanData(YinYang.YIN),
      ]);
    } catch (e) {
      print('Warning: Failed to load some divination data: $e');
      // 允许部分数据加载失败，应用仍可继续运行
    }
  }

  Future<void> _loadYuDingData() async {
    if (_yuDingData != null) return;
    try {
      final jsonString = await rootBundle.loadString(_yuDingPath);
      final decoded = jsonDecode(jsonString);
      _yuDingData = decoded is List<dynamic>
          ? decoded
          : List<dynamic>.from(decoded);
    } catch (e) {
      print('Warning: Failed to load Yu Ding data: $e');
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
      print('Warning: Failed to load Ju Mapper data: $e');
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
      print('Warning: Failed to load ${yinYang.name} pan data: $e');
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
        jsonList = decoded is List<dynamic> ? decoded : List<dynamic>.from(decoded);
      }

      return jsonList
          .map((item) {
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
          })
          .toList();
    } catch (e) {
      print('Error converting JSON to DaLiuRenPanModel: $e');
      print('Runtime type: ${jsonDecode(jsonString).runtimeType}');
      // 返回空列表而不是崩溃
      return <DaLiuRenPanModel>[];
    }
  }

  @override
  Future<DaLiuRenKePan> calculateDivination(DateTime dateTime, {String? question}) async {
    try {
      // Ensure data is loaded
      await loadDivinationData();

      // Convert DateTime to Chinese calendar components using lunar package
      // This is a simplified placeholder - in real implementation this would use:
      // import 'package:lunar/calendar/Lunar.dart';
      // var lunar = Lunar.fromDate(dateTime);
      // var baZi = lunar.getBaZi();

      // For now, creating a placeholder calculation
      final eightChatStr = "甲子 丙寅 戊辰 庚午"; // Placeholder - would be calculated
      final monthGeneral = MonthGeneral.ZI_SHEN_HOU; // Would be calculated from jieqi

      final kePan = DaLiuRenKePan(
        panDateTime: dateTime,
        question: question,
        eightChatStr: eightChatStr,
        monthGeneral: monthGeneral,
      );

      return kePan;
    } catch (e) {
      // 在 Web 环境下如果遇到 JSArray 问题，使用简化的占位符
      print('Error in calculateDivination: $e');

      // 创建一个最简单的占位符对象
      final kePan = DaLiuRenKePan(
        panDateTime: dateTime,
        question: question,
        eightChatStr: "甲子 乙丑 丙寅 丁卯", // 简化的八字
        monthGeneral: MonthGeneral.ZI_SHEN_HOU,
      );

      return kePan;
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