import 'dart:convert';
import 'package:drift/drift.dart';

/// TypeConverter for Set<String> to/from JSON string.
class SetStringConverter extends TypeConverter<Set<String>, String> {
  const SetStringConverter();

  @override
  Set<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return <String>{};
    try {
      final decoded = json.decode(fromDb);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toSet();
      }
      return <String>{};
    } catch (e) {
      return <String>{};
    }
  }

  @override
  String toSql(Set<String> value) {
    return json.encode(value.toList());
  }
}