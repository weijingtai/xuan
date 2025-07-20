import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/panel_config.dart';

class PanelConfigConverter extends TypeConverter<PanelConfig, String> {
  const PanelConfigConverter();

  @override
  PanelConfig fromSql(String fromDb) {
    return PanelConfig.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(PanelConfig value) {
    return jsonEncode(value.toJson());
  }
}