import 'dart:convert';
import 'package:drift/drift.dart';

/// TypeConverter for Map<String, String> to/from JSON string.
class MapStringStringConverter extends TypeConverter<Map<String, String>, String> {
  const MapStringStringConverter();

  @override
  Map<String, String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return <String, String>{};
    try {
      final decoded = json.decode(fromDb);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      return <String, String>{};
    } catch (e) {
      return <String, String>{};
    }
  }

  @override
  String toSql(Map<String, String> value) {
    return json.encode(value);
  }
}