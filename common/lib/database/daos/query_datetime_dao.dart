import 'package:drift/drift.dart';
import '../../models/query_datetime.dart';
import '../app_database.dart';
import '../tables.dart';

part 'query_datetime_dao.g.dart';
@DriftAccessor(tables: [QueryDatetime])
class QueryDatetimeDao extends DatabaseAccessor<AppDatabase> with _$QueryDatetimeDaoMixin {
  QueryDatetimeDao(AppDatabase db) : super(db);

  // 获取所有查询日期时间记录的流
  Stream<List<QueryDatetimeModel>> getAllQueryDatetimeStream() {
    return select(queryDatetime).watch();
  }

  // 根据 UUID 获取单个查询日期时间记录
  Future<QueryDatetimeModel?> getQueryDatetimeByUuid(String uuid) {
    return (select(queryDatetime)..where((qd) => qd.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入查询日期时间记录
  Future<int> insertQueryDatetime(QueryDatetimeCompanion queryDatetimeC) {
    return into(queryDatetime).insert(queryDatetimeC);
  }

  // 更新查询日期时间记录
  Future<bool> updateQueryDatetime(QueryDatetimeCompanion queryDatetimeC) {
    return update(queryDatetime).replace(queryDatetimeC);
  }

  // 删除查询日期时间记录
  Future<int> deleteQueryDatetime(QueryDatetimeCompanion queryDatetimeC) {
    return (delete(queryDatetime)..where((qd) => qd.uuid.equals(queryDatetimeC.uuid.value))).go();
  }
}
    