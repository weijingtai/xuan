import 'package:drift/drift.dart';

import '../world_info_database.dart';

part 'subregion_dao.g.dart';

@DriftAccessor(tables: [Subregions])
class SubregionDao extends DatabaseAccessor<WorldInfoDatabase>
    with _$SubregionDaoMixin {
  final WorldInfoDatabase db;

  SubregionDao(this.db) : super(db);

  // 查询所有子地区
  Future<List<SubregionDataModel>> getAllSubregions() =>
      select(subregions).get();

  // 根据ID查询子地区
  Future<SubregionDataModel?> getSubregionById(int id) =>
      (select(subregions)..where((s) => s.id.equals(id))).getSingleOrNull();

  // 根据地区ID查询子地区
  Future<List<SubregionDataModel>> getSubregionsByRegionId(int regionId) =>
      (select(subregions)..where((s) => s.regionId.equals(regionId))).get();

  // 获取实时子地区流
  Stream<List<SubregionDataModel>> watchAllSubregions() =>
      select(subregions).watch();

  // 根据ID获取实时子地区流
  Stream<SubregionDataModel?> watchSubregionById(int id) =>
      (select(subregions)..where((s) => s.id.equals(id))).watchSingleOrNull();

  // 根据地区ID获取实时子地区流
  Stream<List<SubregionDataModel>> watchSubregionsByRegionId(int regionId) =>
      (select(subregions)..where((s) => s.regionId.equals(regionId))).watch();
}
