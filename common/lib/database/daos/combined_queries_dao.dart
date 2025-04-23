import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'combined_queries_dao.g.dart';

@DriftAccessor(tables: [CombinedQueries])
class CombinedQueriesDao extends DatabaseAccessor<AppDatabase> with _$CombinedQueriesDaoMixin {
  CombinedQueriesDao(AppDatabase db) : super(db);

  // 获取所有组合查询记录的流
  Stream<List<CombinedQuery>> getAllCombinedQueriesStream() {
    return select(combinedQueries).watch();
  }

  // 根据 UUID 获取单个组合查询记录
  Future<CombinedQuery?> getCombinedQueryByUuid(String uuid) {
    return (select(combinedQueries)..where((cq) => cq.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入组合查询记录
  Future<int> insertCombinedQuery(CombinedQueriesCompanion combinedQuery) {
    return into(combinedQueries).insert(combinedQuery);
  }

  // 更新组合查询记录
  Future<bool> updateCombinedQuery(CombinedQueriesCompanion combinedQuery) {
    return update(combinedQueries).replace(combinedQuery);
  }

  // 删除组合查询记录
  Future<int> deleteCombinedQuery(CombinedQuery combinedQuery) {
    return (delete(combinedQueries)..where((cq) => cq.uuid.equals(combinedQuery.uuid))).go();
  }
}
    