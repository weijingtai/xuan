import 'package:drift/drift.dart';

import '../world_info_database.dart';
part 'region_dao.g.dart';

@DriftAccessor(tables: [Regions])
class RegionDao extends DatabaseAccessor<WorldInfoDatabase>
    with _$RegionDaoMixin {
  final WorldInfoDatabase db;

  RegionDao(this.db) : super(db);

  // 查询所有地区
  Future<List<RegionDataModel>> getAllRegions() => select(regions).get();

  // 根据ID查询地区
  Future<RegionDataModel?> getRegionById(int id) =>
      (select(regions)..where((r) => r.id.equals(id))).getSingleOrNull();

  // 获取实时地区流
  Stream<List<RegionDataModel>> watchAllRegions() => select(regions).watch();

  // 根据ID获取实时地区流
  Stream<RegionDataModel?> watchRegionById(int id) =>
      (select(regions)..where((r) => r.id.equals(id))).watchSingleOrNull();
}
