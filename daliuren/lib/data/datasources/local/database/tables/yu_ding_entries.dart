import 'package:drift/drift.dart';
import '../converters/map_string_string_converter.dart';
import '../converters/set_string_converter.dart';

/// Table for storing entries from "御定大六壬" (Yu Ding Da Liu Ren).
@DataClassName('YuDingEntryDb')
class YuDingEntries extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get juName => text()(); // Represents 干上神 (DiZhi on Day Gan)
  IntColumn get juNumber => integer()(); // The Ju number for this entry

  // Complex fields stored as JSON strings using TypeConverters.
  TextColumn get detailsJson =>
      text().map(const MapStringStringConverter())(); // Map<String, String>
  TextColumn get booksJson =>
      text().map(const MapStringStringConverter())(); // Map<String, String>
  TextColumn get bodyJson =>
      text().map(const SetStringConverter())(); // Set<String>

  TextColumn get meaning => text()(); // 课义
  TextColumn get explain => text()(); // 解曰
  TextColumn get predication => text()(); // 断曰

  @override
  Set<Column> get primaryKey =>
      {dayJiaZiName, juName}; // Assumed primary key based on lookup logic
}
