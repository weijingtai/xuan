import 'package:drift/drift.dart';
import 'package:common/models/divination_datetime.dart';
import '../../converters/panel_model_converter.dart';
import '../../converters/panel_config_converter.dart';
import '../../converters/divination_datetime_converter.dart';
import '../../models/base_panel_model.dart';
import '../../models/panel_config.dart';
import '../../models/pan_entity.dart';

@UseRowClass(QiZhengSiYuPanEntity)
class QizhengsiyuPanTable extends Table {
  @override
  String get tableName => "t_qizhengsiyu_pans";

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 关联信息
  TextColumn get divinationRequestInfoUuid =>
      text().named('divination_request_info_uuid')();

  // 使用converter直接存储复杂对象
  TextColumn get panelConfig =>
      text().map(const PanelConfigConverter()).named('panel_config_json')();

  TextColumn get panelModel =>
      text().map(const BasePanelModelConverter()).named('panel_data_json')();

  TextColumn get divinationDatetimeModel => text()
      .map(const DivinationDatetimeConverter())
      .named('divination_datetime_json')();

  @override
  Set<Column> get primaryKey => {uuid};
}
