import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'query_sub_query_type_mapper_dao.g.dart';

// 生成的 DAO 类
@DriftAccessor(tables: [QuerySubQueryTypeMapper])
class QuerySubQueryTypeMapperDao extends DatabaseAccessor<AppDatabase> with _$QuerySubQueryTypeMapperDaoMixin {
  QuerySubQueryTypeMapperDao(AppDatabase db) : super(db);

  // 获取所有映射记录的流
  Stream<List<QuerySubQueryTypeMapperData>> getAllMappersStream() {
    return select(querySubQueryTypeMapper).watch();
  }

  // 根据 ID 获取单个映射记录
  Future<QuerySubQueryTypeMapperData?> getMapperById(int id) {
    return (select(querySubQueryTypeMapper)..where((mapper) => mapper.id.equals(id))).getSingleOrNull();
  }

  // 根据 queryUuid 获取映射记录列表
  Future<List<QuerySubQueryTypeMapperData>> getMappersByQueryUuid(String queryUuid) {
    return (select(querySubQueryTypeMapper)..where((mapper) => mapper.queryUuid.equals(queryUuid))).get();
  }

  // 根据 subTypeUuid 获取映射记录列表
  Future<List<QuerySubQueryTypeMapperData>> getMappersBySubTypeUuid(String subTypeUuid) {
    return (select(querySubQueryTypeMapper)..where((mapper) => mapper.subTypeUuid.equals(subTypeUuid))).get();
  }

  // 插入映射记录
  Future<int> insertMapper(QuerySubQueryTypeMapperCompanion mapper) {
    return into(querySubQueryTypeMapper).insert(mapper);
  }

  // 更新映射记录
  Future<bool> updateMapper(QuerySubQueryTypeMapperCompanion mapper) {
    return update(querySubQueryTypeMapper).replace(mapper);
  }

  // 删除映射记录
  Future<int> deleteMapper(QuerySubQueryTypeMapperData mapper) {
    return (delete(querySubQueryTypeMapper)..where((m) => m.id.equals(mapper.id))).go();
  }
}