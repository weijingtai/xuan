import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/layout_template_dto.dart';

class LayoutTemplateLocalDataSource {
  const LayoutTemplateLocalDataSource();

  static const _storagePrefix = 'layout_templates';

  String _collectionKey(String collectionId) => '$_storagePrefix:$collectionId';

  Future<List<LayoutTemplateDto>> loadTemplates(String collectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_collectionKey(collectionId));
    if (stored == null || stored.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(stored) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LayoutTemplateDto.fromJson)
        .toList();
  }

  Future<void> persistTemplates(
    String collectionId,
    List<LayoutTemplateDto> templates,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
        templates.map((dto) => dto.toJson()).toList(growable: false));
    await prefs.setString(_collectionKey(collectionId), payload);
  }

  Future<void> removeCollection(String collectionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_collectionKey(collectionId));
  }
}
