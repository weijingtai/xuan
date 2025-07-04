// 节气信息转换器（结合网页2的时间处理）
import 'dart:convert';

import 'package:drift/drift.dart';
import '../../models/jie_qi_info.dart';

class JieQiInfoConverter extends TypeConverter<JieQiInfo, String> {
  const JieQiInfoConverter();

  @override
  JieQiInfo fromSql(String fromDb) {
    return JieQiInfo.fromJson(jsonDecode(fromDb));
    // final parts = fromDb.split('|');
    // return JieQiInfo(
    //     jieQi: TwentyFourJieQi.fromName(parts[0]),
    //     startAt: DateTime.parse(parts[1]),
    //     endAt: DateTime.parse(parts[2])
    // );
  }

  @override
  String toSql(JieQiInfo value) {
    return jsonEncode(value.toJson());
    // return '${value.jieQi.name}|${value.startAt.toIso8601String()}|${value.endAt.toIso8601String()}';
  }
}
