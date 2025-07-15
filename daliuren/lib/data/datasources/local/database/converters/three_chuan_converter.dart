import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../models/three_chuan_data_model.dart';

/// TypeConverter for ThreeChuanDataModel to/from JSON string.
class ThreeChuanConverter extends TypeConverter<ThreeChuanDataModel?, String> {
  const ThreeChuanConverter();

  @override
  ThreeChuanDataModel? fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return null;
      // return ThreeChuanDataModel.empty();
    }
    try {
      final Map<String, dynamic> json = jsonDecode(fromDb);
      return ThreeChuanDataModel.fromJson(json);
    } catch (e) {
      return null;
      // return ThreeChuanDataModel.empty();
    }
  }

  @override
  String toSql(ThreeChuanDataModel? value) {
    if (value == null) {
      return '';
    }
    return jsonEncode(value.toJson());
  }
}
