// 位置坐标转换器（网页3中地理数据处理模式）
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../datamodel/location.dart';

class LocationConverter extends TypeConverter<Location, String> {
  const LocationConverter();

  @override
  Location fromSql(String fromDb) {
    return Location.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(Location value) {
    return jsonEncode(value.toJson());
  }
}
