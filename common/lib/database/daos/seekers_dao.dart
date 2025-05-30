import 'package:drift/drift.dart';
import '../../datamodel/seeker_model.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'seekers_dao.g.dart';

@DriftAccessor(tables: [Seekers])
class SeekersDao extends DatabaseAccessor<AppDatabase> with _$SeekersDaoMixin {
  final AppDatabase db;
  SeekersDao(this.db) : super(db);

  SimpleSelectStatement<$SeekersTable, SeekerModel> _baseSelect() =>
      select(db.seekers);

  Future<List<SeekerModel>> getAllSeekers() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<SeekerModel?> getSeekerByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<SeekerModel>> getSeekersByDivinationUuid(String divinationUuid) {
    return (_baseSelect()
          ..where((t) =>
              t.divinationUuid.equals(divinationUuid) & t.deletedAt.isNull()))
        .get();
  }

  Future<int> insertSeeker(SeekersCompanion companion) {
    return into(db.seekers).insert(companion);
  }

  Future<bool> updateSeeker(SeekersCompanion companion) {
    return update(db.seekers).replace(companion);
  }

  Future<int> softDeleteSeeker(String uuid) {
    return (update(db.seekers)..where((t) => t.uuid.equals(uuid)))
        .write(SeekersCompanion(deletedAt: Value(DateTime.now())));
  }
}
