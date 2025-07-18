import 'package:drift/drift.dart';
import '../../models/base_panel_model.dart';

@UseRowClass(BasePanelModel)
class BasePanelTable extends Table {
  @override
  String get tableName => "t_base_panels";

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 存储序列化的BasePanelModel JSON数据
  TextColumn get panelData => text().named('panel_data')();

  // 关联信息
  TextColumn get divinationUuid => text().nullable().named('divination_uuid')();
  TextColumn get seekerUuid => text().nullable().named('seeker_uuid')();

  // 计算时的配置信息
  TextColumn get panelConfigJson => text().named('panel_config_json')();
  TextColumn get observerPositionJson =>
      text().named('observer_position_json')();

  @override
  Set<Column> get primaryKey => {uuid};
}
