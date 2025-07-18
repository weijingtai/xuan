import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/base_panel_dao.dart';
import '../database/tables/base_panel_table.dart';
import '../models/base_panel_model.dart';
import '../models/panel_config.dart';
import '../models/observer_position.dart';

class SaveCalculatedPanelUseCase {
  final BasePanelDao _basePanelDao;
  final Uuid _uuid = const Uuid();

  SaveCalculatedPanelUseCase(this._basePanelDao);

  /// 保存计算得到的基础面板模型到本地数据库
  ///
  /// [basicPanelModel] 计算得到的基础面板模型
  /// [panelConfig] 面板配置信息
  /// [observerPosition] 观测者位置信息
  /// [divinationUuid] 可选的占卜UUID
  /// [seekerUuid] 可选的求测人UUID
  ///
  /// 返回保存的记录UUID
  Future<String> execute({
    required BasePanelModel basicPanelModel,
    required PanelConfig panelConfig,
    required ObserverPosition observerPosition,
    String? divinationUuid,
    String? seekerUuid,
  }) async {
    try {
      final uuid = _uuid.v4();
      final now = DateTime.now();

      // 序列化数据
      final panelDataJson = jsonEncode(basicPanelModel.toJson());
      final panelConfigJson = jsonEncode(panelConfig.toJson());
      final observerPositionJson = jsonEncode(observerPosition.toJson());

      // 创建数据库记录
      final companion = BasePanelTableCompanion(
        uuid: Value(uuid),
        createdAt: Value(now),
        lastUpdatedAt: Value(now),
        panelData: Value(panelDataJson),
        panelConfigJson: Value(panelConfigJson),
        observerPositionJson: Value(observerPositionJson),
        divinationUuid: Value(divinationUuid),
        seekerUuid: Value(seekerUuid),
      );

      // 保存到数据库
      await _basePanelDao.insertBasePanel(companion);

      return uuid;
    } catch (e) {
      throw SavePanelException('保存面板数据失败: $e');
    }
  }

  /// 更新已存在的面板记录
  Future<bool> updatePanel({
    required String uuid,
    required BasePanelModel basicPanelModel,
    required PanelConfig panelConfig,
    required ObserverPosition observerPosition,
    String? divinationUuid,
    String? seekerUuid,
  }) async {
    try {
      final now = DateTime.now();

      // 序列化数据
      final panelDataJson = jsonEncode(basicPanelModel.toJson());
      final panelConfigJson = jsonEncode(panelConfig.toJson());
      final observerPositionJson = jsonEncode(observerPosition.toJson());

      // 创建更新记录
      final companion = BasePanelTableCompanion(
        uuid: Value(uuid),
        lastUpdatedAt: Value(now),
        panelData: Value(panelDataJson),
        panelConfigJson: Value(panelConfigJson),
        observerPositionJson: Value(observerPositionJson),
        divinationUuid: Value(divinationUuid),
        seekerUuid: Value(seekerUuid),
      );

      // 更新数据库
      return await _basePanelDao.updateBasePanel(companion);
    } catch (e) {
      throw SavePanelException('更新面板数据失败: $e');
    }
  }

  /// 根据UUID获取面板数据
  Future<SavedPanelData?> getPanelByUuid(String uuid) async {
    try {
      final record = await _basePanelDao.getBasePanelByUuid(uuid);
      if (record == null) return null;

      return _convertToSavedPanelData(record);
    } catch (e) {
      throw SavePanelException('获取面板数据失败: $e');
    }
  }

  /// 获取所有面板数据
  Future<List<SavedPanelData>> getAllPanels() async {
    try {
      final records = await _basePanelDao.getAllBasePanels();
      return records.map(_convertToSavedPanelData).toList();
    } catch (e) {
      throw SavePanelException('获取面板列表失败: $e');
    }
  }

  /// 根据占卜UUID获取面板数据
  Future<List<SavedPanelData>> getPanelsByDivinationUuid(
      String divinationUuid) async {
    try {
      final records =
          await _basePanelDao.getBasePanelsByDivinationUuid(divinationUuid);
      return records.map(_convertToSavedPanelData).toList();
    } catch (e) {
      throw SavePanelException('根据占卜UUID获取面板数据失败: $e');
    }
  }

  /// 删除面板数据
  Future<int> deletePanel(String uuid) async {
    try {
      return await _basePanelDao.softDeleteBasePanel(uuid);
    } catch (e) {
      throw SavePanelException('删除面板数据失败: $e');
    }
  }

  /// 转换数据库记录为业务模型
  SavedPanelData _convertToSavedPanelData(BasePanelModel record) {
    final panelData = BasePanelModel.fromJson(jsonDecode(record.panelData));
    final panelConfig =
        PanelConfig.fromJson(jsonDecode(record.panelConfigJson));
    final observerPosition =
        ObserverPosition.fromJson(jsonDecode(record.observerPositionJson));

    return SavedPanelData(
      uuid: record.uuid,
      createdAt: record.createdAt,
      lastUpdatedAt: record.lastUpdatedAt,
      basicPanelModel: panelData,
      panelConfig: panelConfig,
      observerPosition: observerPosition,
      divinationUuid: record.divinationUuid,
      seekerUuid: record.seekerUuid,
    );
  }
}

/// 保存的面板数据模型
class SavedPanelData {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final BasePanelModel basicPanelModel;
  final PanelConfig panelConfig;
  final ObserverPosition observerPosition;
  final String? divinationUuid;
  final String? seekerUuid;

  SavedPanelData({
    required this.uuid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.basicPanelModel,
    required this.panelConfig,
    required this.observerPosition,
    this.divinationUuid,
    this.seekerUuid,
  });
}

/// 保存面板异常
class SavePanelException implements Exception {
  final String message;
  SavePanelException(this.message);

  @override
  String toString() => 'SavePanelException: $message';
}
