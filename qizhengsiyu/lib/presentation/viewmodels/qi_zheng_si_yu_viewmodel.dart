import 'package:common/enums/enum_stars.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/data/datasources/local/shen_sha_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/shen_sha_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';

import '../../domain/entities/models/star_angle_speed.dart';

class QiZhengSiYuViewModel extends ChangeNotifier {
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;
  final ZhouTianModelManager zhouTianModelManager;

  QiZhengSiYuViewModel({
    required this.shenShaManager,
    required this.huaYaoManager,
    required this.zhouTianModelManager,
  });

  BasePanelModel? _basicLifePanel;
  BasePanelModel? get basicLifePanel => _basicLifePanel;

  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  // The calculate method now takes the full panel configuration.
  Future<void> calculate(BasePanelConfig config, ObserverPosition observer) async {
    await zhouTianModelManager.load();

    final engine = CalculationEngineFactory.create(config);
    final zhouTianModel = await engine.getSystemDefinition(config);
    final starPositions = await engine.calculateStarPositions(observer.dateTime, observer, config);
    final starAngleMapper = _transformStarPositions(starPositions, config);

    final panelService = GenerateBasePanelService(
      panelConfig: config,
      observerPosition: observer,
      shenShaManager: shenShaManager,
      huaYaoManager: huaYaoManager,
    );

    _basicLifePanel = await panelService.calculate(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );

    // TODO: The following calculation logic needs to be implemented
    // _uiBasicLifeStars =
    //     calculateUIStars(_basicLifePanel.starAngleMapper, _baseMiniSafetyAngle);

    notifyListeners();
  }

  Map<EnumStars, StarAngleSpeed> _transformStarPositions(List<StarPositionRawData> starPositions, BasePanelConfig config) {
    final Map<EnumStars, StarAngleSpeed> mapper = {};
    for (final pos in starPositions) {
      // Find the angle/speed info that matches the current panel configuration
      final matchingInfo = pos.angleRawInfoSet.firstWhere(
        (info) =>
            info.panelSystemType == config.panelSystemType &&
            info.coordinateSystem == config.celestialCoordinateSystem,
        orElse: () => pos.angleRawInfoSet.first, // Fallback to the first available if no exact match
      );
      mapper[pos.starType] = StarAngleSpeed(
        angle: matchingInfo.angle,
        speed: matchingInfo.speed,
      );
    }
    return mapper;
  }
}
