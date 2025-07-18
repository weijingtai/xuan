import 'package:json_annotation/json_annotation.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import '../enums/enum_twelve_gong.dart';
import 'base_panel_model.dart';
import 'body_life_model.dart';
import 'hua_yao.dart';
import 'star_angle_speed.dart';
import 'star_enter_info.dart';
import 'stars_angle.dart';
import 'panel_config.dart';
import 'observer_position.dart';

part 'qi_zhen_pan_data_model.g.dart';

/// 七政四余盘数据模型 - 用于Drift数据库存储
@JsonSerializable()
class QiZhenPanDataModel {
  /// 唯一标识符
  final String uuid;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime lastUpdatedAt;

  /// 删除时间（软删除）
  final DateTime? deletedAt;

  /// 面板数据JSON字符串（序列化的BasePanelModel）
  final String panelDataJson;

  /// 面板配置JSON字符串（序列化的PanelConfig）
  final String panelConfigJson;

  /// 观测者位置JSON字符串（序列化的ObserverPosition）
  final String observerPositionJson;

  /// 关联的占卜UUID
  final String? divinationUuid;

  /// 关联的求测人UUID
  final String? seekerUuid;

  /// 盘的标题或名称
  final String? title;

  /// 盘的描述
  // final String? description;

  /// 盘的类型（本命盘、流年盘、合盘等）
  // final String panelType;

  /// 是否为收藏的盘
  // final bool isFavorite;

  /// 标签（用逗号分隔的字符串）
  // final String? tags;

  QiZhenPanDataModel({
    required this.uuid,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.deletedAt,
    required this.panelDataJson,
    required this.panelConfigJson,
    required this.observerPositionJson,
    this.divinationUuid,
    this.seekerUuid,
    this.title,
  });

  factory QiZhenPanDataModel.fromJson(Map<String, dynamic> json) =>
      _$QiZhenPanDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$QiZhenPanDataModelToJson(this);

  /// 从BasePanelModel创建QiZhenPanDataModel
  factory QiZhenPanDataModel.fromBasePanelModel({
    required String uuid,
    required BasePanelModel basePanelModel,
    required PanelConfig panelConfig,
    required ObserverPosition observerPosition,
    String? divinationUuid,
    String? seekerUuid,
    String? title,
    String? description,
    String panelType = '本命盘',
    bool isFavorite = false,
    String? tags,
  }) {
    final now = DateTime.now();
    return QiZhenPanDataModel(
      uuid: uuid,
      createdAt: now,
      lastUpdatedAt: now,
      panelDataJson: jsonEncode(basePanelModel.toJson()),
      panelConfigJson: jsonEncode(panelConfig.toJson()),
      observerPositionJson: jsonEncode(observerPosition.toJson()),
      divinationUuid: divinationUuid,
      seekerUuid: seekerUuid,
      title: title,
      description: description,
      panelType: panelType,
      isFavorite: isFavorite,
      tags: tags,
    );
  }

  /// 获取反序列化的BasePanelModel
  BasePanelModel getBasePanelModel() {
    return BasePanelModel.fromJson(jsonDecode(panelDataJson));
  }

  /// 获取反序列化的PanelConfig
  PanelConfig getPanelConfig() {
    return PanelConfig.fromJson(jsonDecode(panelConfigJson));
  }

  /// 获取反序列化的ObserverPosition
  ObserverPosition getObserverPosition() {
    return ObserverPosition.fromJson(jsonDecode(observerPositionJson));
  }

  /// 获取标签列表
  List<String> getTagsList() {
    if (tags == null || tags!.isEmpty) return [];
    return tags!
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// 设置标签列表
  QiZhenPanDataModel withTags(List<String> tagsList) {
    return copyWith(tags: tagsList.join(','));
  }

  /// 复制并修改部分字段
  QiZhenPanDataModel copyWith({
    String? uuid,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    DateTime? deletedAt,
    String? panelDataJson,
    String? panelConfigJson,
    String? observerPositionJson,
    String? divinationUuid,
    String? seekerUuid,
    String? title,
    String? description,
    String? panelType,
    bool? isFavorite,
    String? tags,
  }) {
    return QiZhenPanDataModel(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      panelDataJson: panelDataJson ?? this.panelDataJson,
      panelConfigJson: panelConfigJson ?? this.panelConfigJson,
      observerPositionJson: observerPositionJson ?? this.observerPositionJson,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      seekerUuid: seekerUuid ?? this.seekerUuid,
      title: title ?? this.title,
      description: description ?? this.description,
      panelType: panelType ?? this.panelType,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  /// 更新最后修改时间
  QiZhenPanDataModel updateLastModified() {
    return copyWith(lastUpdatedAt: DateTime.now());
  }

  /// 软删除
  QiZhenPanDataModel markAsDeleted() {
    return copyWith(deletedAt: DateTime.now());
  }

  /// 恢复删除
  QiZhenPanDataModel restore() {
    return copyWith(deletedAt: null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QiZhenPanDataModel && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'QiZhenPanDataModel(uuid: $uuid, title: $title, panelType: $panelType, createdAt: $createdAt)';
  }
}
