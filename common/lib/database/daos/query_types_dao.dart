import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'query_types_dao.g.dart';
@DriftAccessor(tables: [QueryTypes])
class QueryTypesDao extends DatabaseAccessor<AppDatabase> with _$QueryTypesDaoMixin {
  QueryTypesDao(AppDatabase db) : super(db);

  // 获取所有查询类型记录的流
  Stream<List<QueryType>> getAllQueryTypesStream() {
    return select(queryTypes).watch();
  }

  // 根据 UUID 获取单个查询类型记录
  Future<QueryType?> getQueryTypeByUuid(String uuid) {
    return (select(queryTypes)..where((qt) => qt.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入查询类型记录
  Future<int> insertQueryType(QueryTypesCompanion queryType) {
    return into(queryTypes).insert(queryType);
  }

  // 更新查询类型记录
  Future<bool> updateQueryType(QueryTypesCompanion queryType) {
    return update(queryTypes).replace(queryType);
  }

  // 删除查询类型记录
  Future<int> deleteQueryType(QueryType queryType) {
    return (delete(queryTypes)..where((qt) => qt.uuid.equals(queryType.uuid))).go();
  }
}
    