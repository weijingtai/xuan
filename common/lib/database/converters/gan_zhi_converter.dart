// 天干地支组合存储适配器
import 'package:drift/drift.dart';

import 'package:common/enums.dart';

class GanZhiConverter extends TypeConverter<JiaZi, String> {
  const GanZhiConverter();
  @override
  JiaZi fromSql(String fromDb) =>
      JiaZi.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(JiaZi value) => value.name;
}
