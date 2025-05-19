import 'package:drift/drift.dart';

import '../world_info_database.dart';

part 'city_dao.g.dart';

@DriftAccessor(tables: [Cities])
class CityDao extends DatabaseAccessor<WorldInfoDatabase> with _$CityDaoMixin {
  final WorldInfoDatabase db;

  CityDao(this.db) : super(db);

  // 查询所有城市
  Future<List<CityDataModel>> getAllCities() => select(cities).get();

  // 根据ID查询城市
  Future<CityDataModel?> getCityById(int id) =>
      (select(cities)..where((c) => c.id.equals(id))).getSingleOrNull();

  // 根据州/省ID查询城市
  Future<List<CityDataModel>> getCitiesByStateId(int stateId) =>
      (select(cities)..where((c) => c.stateId.equals(stateId))).get();

  // 根据国家ID查询城市
  Future<List<CityDataModel>> getCitiesByCountryId(int countryId) =>
      (select(cities)..where((c) => c.countryId.equals(countryId))).get();

  // 获取实时城市流
  Stream<List<CityDataModel>> watchAllCities() => select(cities).watch();

  // 根据ID获取实时城市流
  Stream<CityDataModel?> watchCityById(int id) =>
      (select(cities)..where((c) => c.id.equals(id))).watchSingleOrNull();

  // 根据州/省ID获取实时城市流
  Stream<List<CityDataModel>> watchCitiesByStateId(int stateId) =>
      (select(cities)..where((c) => c.stateId.equals(stateId))).watch();

  // 根据国家ID获取实时城市流
  Stream<List<CityDataModel>> watchCitiesByCountryId(int countryId) =>
      (select(cities)..where((c) => c.countryId.equals(countryId))).watch();
}
