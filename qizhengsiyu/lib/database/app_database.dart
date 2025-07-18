import 'dart:io';
import 'package:common/enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../dataset/star_position_status_model.dart';
import '../enums/enum_star_position_status.dart';
import 'tables/base_panel_table.dart';
import 'daos/base_panel_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [StarPositionStatusTable, BasePanelTable],
  daos: [BasePanelDao],
)
class App74Database extends _$AppDatabase {
  App74Database() : super(_openConnection());

  @override
  int get schemaVersion => 1; // 增加版本号

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 数据库升级逻辑
        if (from < 2) {
          // 添加新的BasePanelTable
          await m.createTable(basePanelTable);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
