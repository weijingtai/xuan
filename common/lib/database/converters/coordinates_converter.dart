// 天干地支组合存储适配器
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../datamodel/location.dart';

class CoordinatesConverter extends TypeConverter<Coordinates, String> {
  const CoordinatesConverter();
  @override
  Coordinates fromSql(String fromDb) =>
      Coordinates.fromJson(jsonDecode(fromDb));
  @override
  String toSql(Coordinates value) => jsonEncode(value.toJson());
}
