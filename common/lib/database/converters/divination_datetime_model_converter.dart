// 天干地支组合存储适配器
import 'dart:convert';

import 'package:common/models/divination_datetime.dart';
import 'package:drift/drift.dart';

class DivinationDatetimeModelConverter
    extends TypeConverter<List<DivinationDatetimeModel>, String> {
  const DivinationDatetimeModelConverter();
  @override
  List<DivinationDatetimeModel> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList
        .map((json) =>
            DivinationDatetimeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<DivinationDatetimeModel> value) =>
      jsonEncode(value.map((e) => e.toJson()).toList());
}
