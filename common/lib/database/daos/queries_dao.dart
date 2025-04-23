import 'package:drift/drift.dart';
import '../app_database.dart' as app;
import '../app_database.dart';
import '../tables.dart' as table;

part 'queries_dao.g.dart';
@DriftAccessor(tables: [table.Queries])
class QueriesDao extends DatabaseAccessor<app.AppDatabase> with _$QueriesDaoMixin {
  QueriesDao(app.AppDatabase db) : super(db);

  // 获取所有查询记录的流
  Stream<List<app.Query>> getAllQueriesStream() {
    return select(queries).watch();
  }

  // 根据 UUID 获取单个查询记录
  Future<app.Query?> getQueryByUuid(String uuid) async {
    return (select(queries)..where((q) => q.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入查询记录
  Future<int> insertQuery(app.QueriesCompanion query) {
    return into(queries).insert(query);
  }

  // 更新查询记录
  Future<bool> updateQuery(app.QueriesCompanion query) {
    return update(queries).replace(query);
  }

  // 删除查询记录
  Future<int> deleteQuery(app.Query query) {
    return (delete(queries)..where((q) => q.uuid.equals(query.uuid))).go();
  }
}
    