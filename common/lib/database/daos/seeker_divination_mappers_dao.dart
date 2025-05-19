import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'seeker_divination_mappers_dao.g.dart';

@DriftAccessor(tables: [SeekerDivinationMappers])
class SeekerDivinationMappersDao extends DatabaseAccessor<AppDatabase>
    with _$SeekerDivinationMappersDaoMixin {
  final AppDatabase db;
  SeekerDivinationMappersDao(this.db) : super(db);

  SimpleSelectStatement<$SeekerDivinationMappersTable, SeekerDivinationMapper>
      _baseSelect() => select(db.seekerDivinationMappers);

  Future<List<SeekerDivinationMapper>> getAllSeekerDivinationMappers() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<SeekerDivinationMapper?> getSeekerDivinationMapperBySeekerUuid(
      String uuid) {
    return (_baseSelect()
          ..where((t) => t.seekerUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertSeekerDivinationMapper(
      SeekerDivinationMappersCompanion companion) {
    return into(db.seekerDivinationMappers).insert(companion);
  }

  Future<bool> updateSeekerDivinationMapper(
      SeekerDivinationMappersCompanion companion) {
    return update(db.seekerDivinationMappers).replace(companion);
  }

  Future<int> softDeleteSeekerDivinationMapperBySeekerUuid(String uuid) {
    return (update(db.seekerDivinationMappers)
          ..where((t) => t.seekerUuid.equals(uuid)))
        .write(
            SeekerDivinationMappersCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeleteSeekerDivinationMapperByDivinationUuid(String uuid) {
    return (update(db.seekerDivinationMappers)
          ..where((t) => t.divinationUuid.equals(uuid)))
        .write(
            SeekerDivinationMappersCompanion(deletedAt: Value(DateTime.now())));
  }
}
