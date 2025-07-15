import 'package:drift/drift.dart';

/// Table for storing Ju mappings based on day JiaZi, time DiZhi, and YinYang.
@DataClassName('JuMappingEntryDb')
class JuMappings extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get timeDiZhiName => text()();
  TextColumn get yinYangValue => text()(); // Stores "yang" or "yin"
  IntColumn get juNumber => integer()();

  @override
  Set<Column> get primaryKey => {dayJiaZiName, timeDiZhiName, yinYangValue};
}