// 位置坐标转换器（网页3中地理数据处理模式）
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../datamodel/location.dart';

class NullableLocationConverter extends TypeConverter<Location?, String?> {
  const NullableLocationConverter();

  @override
  Location? fromSql(String? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return Location.fromJson(jsonDecode(fromDb));
  }

  @override
  String? toSql(Location? value) {
    if (value == null) {
      return null;
    }
    return jsonEncode(value.toJson());
  }
}
