import 'package:drift/drift.dart';

import '../world_info_database.dart';

part 'country_dao.g.dart';

@DriftAccessor(tables: [Countries])
class CountryDao extends DatabaseAccessor<WorldInfoDatabase>
    with _$CountryDaoMixin {
  final WorldInfoDatabase db;

  CountryDao(this.db) : super(db);

  // 查询所有国家
  Future<List<CountryDataModel>> getAllCountries() => select(countries).get();

  // 根据ID查询国家
  Future<CountryDataModel?> getCountryById(int id) =>
      (select(countries)..where((c) => c.id.equals(id))).getSingleOrNull();

  // 根据ISO2代码查询国家
  Future<CountryDataModel?> getCountryByIso2(String iso2) =>
      (select(countries)..where((c) => c.iso2.equals(iso2))).getSingleOrNull();

  // 获取实时国家流
  Stream<List<CountryDataModel>> watchAllCountries() =>
      select(countries).watch();

  // 根据ID获取实时国家流
  Stream<CountryDataModel?> watchCountryById(int id) =>
      (select(countries)..where((c) => c.id.equals(id))).watchSingleOrNull();

  // 根据ISO2代码获取实时国家流
  Stream<CountryDataModel?> watchCountryByIso2(String iso2) =>
      (select(countries)..where((c) => c.iso2.equals(iso2)))
          .watchSingleOrNull();
}
