import 'package:drift/drift.dart';
// import '../converters/heaven_plate_converter.dart';
// import '../converters/earth_plate_converter.dart';
import '../converters/four_class_converter.dart';
import '../converters/three_chuan_converter.dart';

/// Table for storing pre-calculated/preset Liu Ren Pans (e.g., from 甲午庚牛羊 JSONs).
@DataClassName('PresetPanEntryDb')
class PresetPans extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get shiChenName => text()(); // DiZhi name of the ShiChen
  TextColumn get yinYangDun => text()(); // "yang" or "yin"

  TextColumn get juNumberName => text()(); // e.g., "一局"

  // Complex pan structures stored as JSON strings.
  // TextColumn get heavenPlateJson => text().map(const HeavenPlateConverter())();
  // TextColumn get earthPlateJson => text().map(const EarthPlateConverter())();
  TextColumn get fourClassJson => text().map(const FourClassConverter())();
  TextColumn get threeChuanJson => text().map(const ThreeChuanConverter())();

  TextColumn get nineZongMenName => text()(); // Name of the NineZongMen KeTi

  @override
  Set<Column> get primaryKey => {dayJiaZiName, shiChenName, yinYangDun};
}
