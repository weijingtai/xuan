import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sub_query_types_dao.g.dart';
@DriftAccessor(tables: [SubQueryTypes])
class SubQueryTypesDao extends DatabaseAccessor<AppDatabase> with _$SubQueryTypesDaoMixin {
  SubQueryTypesDao(AppDatabase db) : super(db);

  // 获取所有子查询类型记录的流
  Stream<List<SubQueryType>> getAllSubQueryTypesStream() {
    return select(subQueryTypes).watch();
  }

  // 根据 UUID 获取单个子查询类型记录
  Future<SubQueryType?> getSubQueryTypeByUuid(String uuid) {
    return (select(subQueryTypes)..where((sqt) => sqt.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入子查询类型记录
  Future<int> insertSubQueryType(SubQueryTypesCompanion subQueryType) {
    return into(subQueryTypes).insert(subQueryType);
  }

  // 更新子查询类型记录
  Future<bool> updateSubQueryType(SubQueryTypesCompanion subQueryType) {
    return update(subQueryTypes).replace(subQueryType);
  }

  // 删除子查询类型记录
  Future<int> deleteSubQueryType(SubQueryType subQueryType) {
    return (delete(subQueryTypes)..where((sqt) => sqt.uuid.equals(subQueryType.uuid))).go();
  }
}
    