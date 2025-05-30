// 位置坐标转换器（网页3中地理数据处理模式）
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../datamodel/location.dart';

class NullableLocationConverter extends TypeConverter<Location?, String?> {
  const NullableLocationConverter();

  @override
  Location? fromSql(String? fromDb) {
    try {
      if (fromDb == null || fromDb.isEmpty) return null;
      final jsonMap = jsonDecode(fromDb) as Map<String, dynamic>;
      return Location.fromJson(jsonMap);
    } catch (e, stack) {
      debugPrint('JSON 解析失败: $e\n$stack');
      return null; // 返回 null 或抛出特定异常
    }
  }

  @override
  String? toSql(Location? value) {
    if (value == null) {
      return null;
    }

    return jsonEncode(value.toJson());
  }
}
