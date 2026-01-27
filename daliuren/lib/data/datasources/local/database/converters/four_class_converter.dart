import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../models/four_class_data_model.dart';

/// TypeConverter for FourClassDataModel to/from JSON string.
class FourClassConverter extends TypeConverter<FourClassDataModel?, String> {
  const FourClassConverter();

  @override
  FourClassDataModel? fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      // return FourClassDataModel.empty();
      return null;
    }
    try {
      final Map<String, dynamic> json = jsonDecode(fromDb);
      return FourClassDataModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  String toSql(FourClassDataModel? value) {
    if (value == null) {
      return '';
    }
    return jsonEncode(value.toJson());
  }
}
