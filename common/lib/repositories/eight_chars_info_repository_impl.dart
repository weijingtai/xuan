import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'eight_chars_info_repository.dart';

class EightCharsInfoRepositoryImpl implements EightCharsInfoRepository {
  static const _benMingRowOrderKey = 'benMingRowOrder';
  static const _liuYunRowOrderKey = 'liuYunRowOrder';
  static const _benMingPillarOrderKey = 'benMingPillarOrder';
  static const _liuYunPillarOrderKey = 'liuYunPillarOrder';
  static const _rowVisibilityKey = 'rowVisibility';
  static const _benMingPillarVisibilityKey = 'benMingPillarVisibility';
  static const _liuYunPillarVisibilityKey = 'liuYunPillarVisibility';

  // Helper for saving lists
  Future<void> _saveList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  // Helper for loading lists
  Future<List<String>?> _loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  // Helper for saving maps
  Future<void> _saveMap(String key, Map<String, bool> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  // Helper for loading maps
  Future<Map<String, bool>> _loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return decodedMap.map((key, value) => MapEntry(key, value as bool));
    }
    return {}; // Return empty map if not found
  }

  @override
  Future<void> saveBenMingRowOrder(List<String> order) => _saveList(_benMingRowOrderKey, order);
  @override
  Future<List<String>?> loadBenMingRowOrder() => _loadList(_benMingRowOrderKey);

  @override
  Future<void> saveLiuYunRowOrder(List<String> order) => _saveList(_liuYunRowOrderKey, order);
  @override
  Future<List<String>?> loadLiuYunRowOrder() => _loadList(_liuYunRowOrderKey);

  @override
  Future<void> saveBenMingPillarOrder(List<String> order) => _saveList(_benMingPillarOrderKey, order);
  @override
  Future<List<String>?> loadBenMingPillarOrder() => _loadList(_benMingPillarOrderKey);

  @override
  Future<void> saveLiuYunPillarOrder(List<String> order) => _saveList(_liuYunPillarOrderKey, order);
  @override
  Future<List<String>?> loadLiuYunPillarOrder() => _loadList(_liuYunPillarOrderKey);

  @override
  Future<void> saveRowVisibility(Map<String, bool> visibility) => _saveMap(_rowVisibilityKey, visibility);
  @override
  Future<Map<String, bool>> loadRowVisibility() => _loadMap(_rowVisibilityKey);

  @override
  Future<void> saveBenMingPillarVisibility(Map<String, bool> visibility) => _saveMap(_benMingPillarVisibilityKey, visibility);
  @override
  Future<Map<String, bool>> loadBenMingPillarVisibility() => _loadMap(_benMingPillarVisibilityKey);

  @override
  Future<void> saveLiuYunPillarVisibility(Map<String, bool> visibility) => _saveMap(_liuYunPillarVisibilityKey, visibility);
  @override
  Future<Map<String, bool>> loadLiuYunPillarVisibility() => _loadMap(_liuYunPillarVisibilityKey);
}
