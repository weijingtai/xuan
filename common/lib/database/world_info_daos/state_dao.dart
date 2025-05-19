import 'package:drift/drift.dart';

import '../world_info_database.dart';

part 'state_dao.g.dart';

@DriftAccessor(tables: [States])
class StateDao extends DatabaseAccessor<WorldInfoDatabase>
    with _$StateDaoMixin {
  final WorldInfoDatabase db;

  StateDao(this.db) : super(db);

  // 查询所有州/省
  Future<List<StateDataModel>> getAllStates() => select(states).get();

  // 根据ID查询州/省
  Future<StateDataModel?> getStateById(int id) =>
      (select(states)..where((s) => s.id.equals(id))).getSingleOrNull();

  // 根据国家ID查询州/省
  Future<List<StateDataModel>> getStatesByCountryId(int countryId) =>
      (select(states)..where((s) => s.countryId.equals(countryId))).get();

  // 获取实时州/省流
  Stream<List<StateDataModel>> watchAllStates() => select(states).watch();

  // 根据ID获取实时州/省流
  Stream<StateDataModel?> watchStateById(int id) =>
      (select(states)..where((s) => s.id.equals(id))).watchSingleOrNull();

  // 根据国家ID获取实时州/省流
  Stream<List<StateDataModel>> watchStatesByCountryId(int countryId) =>
      (select(states)..where((s) => s.countryId.equals(countryId))).watch();
}
