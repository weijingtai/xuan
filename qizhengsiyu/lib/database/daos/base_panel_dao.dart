import 'package:drift/drift.dart';
import '../../models/base_panel_model.dart';
import '../app_database.dart';
import '../tables/base_panel_table.dart';
import 'package:uuid/uuid.dart';

part 'base_panel_dao.g.dart';

@DriftAccessor(tables: [BasePanelTable])
class BasePanelDao extends DatabaseAccessor<App74Database>
    with _$BasePanelDaoMixin {
  final App74Database db;
  BasePanelDao(this.db) : super(db);

  SimpleSelectStatement<$BasePanelTableTable, BasePanelModel> _baseSelect() =>
      select(db.basePanelTable);

  /// 获取所有未删除的面板
  Future<List<BasePanelModel>> getAllBasePanels() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  /// 根据UUID获取面板
  Future<BasePanelModel?> getBasePanelByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// 根据占卜UUID获取面板
  Future<List<BasePanelModel>> getBasePanelsByDivinationUuid(
      String divinationUuid) {
    return (_baseSelect()
          ..where((t) =>
              t.divinationUuid.equals(divinationUuid) & t.deletedAt.isNull()))
        .get();
  }

  /// 根据求测人UUID获取面板
  Future<List<BasePanelModel>> getBasePanelsBySeekerUuid(String seekerUuid) {
    return (_baseSelect()
          ..where(
              (t) => t.seekerUuid.equals(seekerUuid) & t.deletedAt.isNull()))
        .get();
  }

  /// 插入新的面板记录
  Future<String> insertBasePanel(BasePanelTableCompanion companion) async {
    await into(db.basePanelTable).insert(companion);
    return companion.uuid.value;
  }

  /// 更新面板记录
  Future<bool> updateBasePanel(BasePanelTableCompanion companion) {
    return update(db.basePanelTable).replace(companion);
  }

  /// 软删除面板
  Future<int> softDeleteBasePanel(String uuid) {
    return (update(db.basePanelTable)..where((t) => t.uuid.equals(uuid)))
        .write(BasePanelTableCompanion(deletedAt: Value(DateTime.now())));
  }

  /// 根据时间范围查询面板
  Future<List<BasePanelModel>> getBasePanelsByDateRange(
      DateTime startDate, DateTime endDate) {
    return (_baseSelect()
          ..where((t) =>
              t.createdAt.isBetweenValues(startDate, endDate) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
