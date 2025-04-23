import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'seekers_dao.g.dart';
@DriftAccessor(tables: [Seekers])
class SeekersDao extends DatabaseAccessor<AppDatabase> with _$SeekersDaoMixin {
  SeekersDao(AppDatabase db) : super(db);

  // 获取所有求测人记录的流
  Stream<List<Seeker>> getAllSeekersStream() {
    return select(seekers).watch();
  }

  // 根据 UUID 获取单个求测人记录
  Future<Seeker?> getSeekerByUuid(String uuid) {
    return (select(seekers)..where((s) => s.uuid.equals(uuid))).getSingleOrNull();
  }

  // 插入求测人记录
  Future<int> insertSeeker(SeekersCompanion seeker) {
    return into(seekers).insert(seeker);
  }

  // 更新求测人记录
  Future<bool> updateSeeker(SeekersCompanion seeker) {
    return update(seekers).replace(seeker);
  }

  // 删除求测人记录
  Future<int> deleteSeeker(Seeker seeker) {
    return (delete(seekers)..where((s) => s.uuid.equals(seeker.uuid))).go();
  }
}
    