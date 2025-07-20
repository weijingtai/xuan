import 'package:common/models/divination_datetime.dart';
import 'package:qizhengsiyu/models/base_panel_model.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/panel_config.dart';

class QiZhengSiYuPanEntity {
  String uuid;
  DateTime createdAt;
  DateTime lastUpdatedAt;
  DateTime? deletedAt;

  String divinationRequestInfoUuid;

  DivinationDatetimeModel divinationDatetimeModel;
  BasePanelConfig panelConfig;
  BasePanelModel panelModel;
  QiZhengSiYuPanEntity({
    required this.uuid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.deletedAt,
    required this.divinationRequestInfoUuid,
    required this.panelConfig,
    required this.panelModel,
    required this.divinationDatetimeModel,
  });

  QiZhengSiYuPanEntity copyWith({
    String? uuid,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    DateTime? deletedAt,
    String? divinationRequestInfoUuid,
    DivinationDatetimeModel? divinationDatetimeModel,
    BasePanelConfig? panelConfig,
    BasePanelModel? panelModel,
  }) {
    return QiZhengSiYuPanEntity(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationRequestInfoUuid:
          divinationRequestInfoUuid ?? this.divinationRequestInfoUuid,
      divinationDatetimeModel:
          divinationDatetimeModel ?? this.divinationDatetimeModel,
      panelConfig: panelConfig ?? this.panelConfig,
      panelModel: panelModel ?? this.panelModel,
    );
  }
}
