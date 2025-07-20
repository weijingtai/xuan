import 'dart:io';
import 'package:common/models/divination_datetime.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../converters/divination_datetime_converter.dart';
import '../converters/panel_config_converter.dart';
import '../converters/panel_model_converter.dart';
import '../models/base_panel_model.dart';
import '../models/pan_entity.dart';
import '../models/panel_config.dart';
import 'daos/qizhengsiyu_pan_dao.dart';
import 'tables/qizhengsiyu_pan_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [QizhengsiyuPanTable],
  daos: [QiZhengSiYuPanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'app_74_database',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      print(
                        'Using ${result.chosenImplementation} due to unsupported '
                        'browser features: ${result.missingFeatures}',
                      );
                    }
                  },
                ),
              ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 处理数据库升级逻辑
        if (from < 2) {
          // 示例：添加新字段的迁移
          // await m.addColumn(qizhengsiyuPanTable, qizhengsiyuPanTable.newField);
        }
      },
    );
  }

  // 数据库健康检查
  Future<bool> isDatabaseHealthy() async {
    try {
      await customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取数据库大小
  // Future<int> getDatabaseSize() async {
  //   final dbFolder = await getApplicationDocumentsDirectory();
  //   final file = File(.join(dbFolder.path, 'qizhengsiyu_app.db'));
  //   if (await file.exists()) {
  //     return await file.length();
  //   }
  //   return 0;
  // }
}
