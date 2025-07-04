import 'package:drift/drift.dart';

/// Table for storing flags, e.g., whether initial asset data has been loaded.
@DataClassName('DbInitializationFlag')
class DbInitializationFlags extends Table {
  /// The key for the flag, e.g., "isAssetDataLoaded_v1". Using version in key allows for future data reseeding.
  TextColumn get flagKey =>
      text().clientDefault(() => 'isAssetDataLoaded_v1')();

  /// Boolean value of the flag.
  BoolColumn get isSet => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {flagKey};
}