import 'dart:convert';
import 'dart:math';

import 'package:common/datamodel/base_divination_datetime_datamodel.dart';
import 'package:common/datamodel/datetime_divination_datamodel.dart';
import 'package:common/datamodel/location.dart';
import 'package:common/datamodel/observer_datamodel.dart';
import 'package:common/enums.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/module.dart';
import 'package:flutter/foundation.dart'; // 使用 @visibleForTesting
import 'package:flutter/material.dart'; // ChangeNotifier 仍然需要
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/v7.dart';

import '../../data/datasources/local/shen_sha_local_data_source.dart';
import '../../data/repositories/shen_sha_repository_impl.dart';
import '../../domain/entities/models/base_panel_model.dart';
import '../../domain/entities/models/body_life_model.dart';
import '../../domain/entities/models/di_zhi_shen_sha.dart';
import '../../domain/entities/models/hua_yao.dart';
import '../../domain/entities/models/observer_position.dart';
import '../../domain/entities/models/panel_config.dart';
import '../../domain/entities/models/passage_year_panel_model.dart';
import '../../domain/entities/models/star_angle_speed.dart';
import '../../domain/entities/models/star_enter_info.dart';
import '../../domain/entities/models/star_position_raw_data.dart';
import '../../domain/entities/models/stars_angle.dart';
import '../../domain/entities/models/zhou_tian_model.dart';
import '../../domain/managers/hua_yao_manager.dart';
import '../../domain/managers/shen_sha_manager.dart';
import '../../domain/managers/zhou_tian_model_manager.dart';
import '../../domain/services/generate_base_panel_service.dart';
import '../../domain/usecases/calculate_fate_dong_wei_usecase.dart';
import '../../domain/engines/calculation_engine_factory.dart';
import '../../domain/usecases/save_calculated_panel_usecase.dart';
import '../models/ui_star_model.dart';
import 'StarsResolver.dart';

/// 七政四余星盘计算和数据管理的 ViewModel。
/// 负责加载必要数据、根据观测位置和时间计算星体位置，
/// 生成星盘详细信息和 UI 显示数据，并管理状态通知 UI 更新。
class BeautyPageViewModel extends ChangeNotifier {
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;
  final ZhouTianModelManager zhouTianModelManager;

  final SaveCalculatedPanelUseCase saveCalculatedPanelUseCase;
  final CalculateFateDongWeiUseCase calculateFateDongWeiUseCase;

  static const double _uiSafetyAnglePadding = 2.0;
  ObserverDataModel? observer;

  static final tz.TZDateTime _ziQiBaseShangHaiTime =
      tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);

  static const double _ziQiAnglePerDay = 0.0352;

  static const double _ziQiAnglePerMinute = _ziQiAnglePerDay / (24 * 60);

  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  final ValueNotifier<List<UIStarModel>?> uiBasicLifeStarsNotifier =
      ValueNotifier<List<UIStarModel>?>(null);

  final ValueNotifier<BasePanelModel?> uiBasePanelNotifier =
      ValueNotifier<BasePanelModel?>(null);
  final ValueNotifier<ZhouTianModel?> zhouTianModelNotifier = ValueNotifier(null);
  final ValueNotifier<PassageYearPanelModel?> uiDaXianPanelNotifier =
      ValueNotifier<PassageYearPanelModel?>(null);

  final ValueNotifier<ObserverPosition?> baseObserverPositionNotifier =
      ValueNotifier<ObserverPosition?>(null);

  final ValueNotifier<CalculateFateDongWeiResult?> dongWeiFateResultNotifier =
      ValueNotifier(null);

  List<UIStarModel> _uiFateLifeStars = [];
  List<UIStarModel> get uiFateLifeStars => _uiFateLifeStars;

  final ValueNotifier<List<UIStarModel>?> uiFateLifeStarsNotifier =
      ValueNotifier<List<UIStarModel>?>(null);

  Map<EnumStars, FiveStarWalkingInfo>? _daXianMapper;
  Map<EnumStars, FiveStarWalkingInfo>? get daXianMapper => _daXianMapper;

  double _baseMiniSafetyAngle = 5;

  double _fateMiniSafetyAngle = 7;

  DivinationInfoModel? _divinationInfoModel;

  ObserverPosition? lifeObserver;

  ObserverPosition? fateObserver;

  late final GenerateBasePanelService _generateBasePanelService;

  BeautyPageViewModel({
    required this.saveCalculatedPanelUseCase,
    required this.calculateFateDongWeiUseCase,
    required this.shenShaManager,
    required this.huaYaoManager,
    required this.zhouTianModelManager,
  });

  // MARK: - Safety Angle Calculation

  /// 计算本命盘 UI 绘制时星体所需的最小安全角度。
  /// [starBodyRadius]: 星体图标的半径。
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小。
  /// [basicLifeStarCenterCircleSize]: 本命盘中心圆的大小。
  void calculateBasicStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double basicLifeStarCenterCircleSize) {
    _baseMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        basicLifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    // 增加额外的填充以优化 UI 外观
    _baseMiniSafetyAngle =
        _baseMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Base Safety Angle Calculated: $_baseMiniSafetyAngle");
  }

  /// 计算行限盘 UI 绘制时星体所需的最小安全角度。
  /// [starBodyRadius]: 星体图标的半径。
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小。
  /// [lifeStarCenterCircleSize]: 行限盘中心圆的大小。
  void calculateFateStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double lifeStarCenterCircleSize) {
    _fateMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        lifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    // 增加额外的填充以优化 UI 外观
    _fateMiniSafetyAngle =
        _fateMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Fate Safety Angle Calculated: $_fateMiniSafetyAngle");
  }

  @override
  void dispose() {
    uiFateLifeStarsNotifier.dispose();
    uiBasicLifeStarsNotifier.dispose();

    uiBasePanelNotifier.dispose();
    uiDaXianPanelNotifier.dispose();
    baseObserverPositionNotifier.dispose();
    zhouTianModelNotifier.dispose();
    dongWeiFateResultNotifier.dispose();
    super.dispose();
  }

  // MARK: - State Management

  /// 重置 ViewModel 的所有计算结果和状态。
  void reset() {
    // _basicLifeStarsAngle = null;
    // _fateLifeStarsAngle = null;
    // _fateLifePanelStarsInfo = null;
    // _basicLifePanelStarsInfo = null;
    // _observerPosition = null;
    _daXianMapper = null;
    _uiBasicLifeStars = [];
    _uiFateLifeStars = [];
    uiFateLifeStarsNotifier.value = null;
    uiBasicLifeStarsNotifier.value = null;
    uiDaXianPanelNotifier.value = null;
    uiBasePanelNotifier.value = null;
    baseObserverPositionNotifier.value = null;
    _baseMiniSafetyAngle = 0;
    _fateMiniSafetyAngle = 0;

    debugPrint("ViewModel state reset.");
    notifyListeners(); // 通知 UI 状态已清空
  }

  // MARK: - Calculation

  BasePanelConfig panelConfig = BasePanelConfig.defaultBasicPanelConfig();
  FatePanelConfig fatePanelConfig = FatePanelConfig.defaultFatePanelConfig();

  /// 根据观测者位置和时间计算星盘数据。
  /// 这是触发所有计算的主入口。
  /// [observerPosition]: 包含出生信息、行限时间、经纬度、时区等观测者信息。
  Future<void> calculate(BasePanelConfig config, ObserverPosition observerPosition) async {
    // 1. Create the engine based on the configuration
    final engine = CalculationEngineFactory.create(config);

    // 2. Get the system definition and star positions from the engine
    final zhouTianModel = await engine.getSystemDefinition(config);
    final starPositions = await engine.calculateStarPositions(observerPosition.dateTime, observerPosition, config);

    // 3. Update the notifiers with the core data
    zhouTianModelNotifier.value = zhouTianModel;

    // 4. Adapt the engine's output to the format expected by the post-processing service
    final starAngleMapper = _transformStarPositions(starPositions, config);

    // 5. Instantiate and call the post-processing service
    _generateBasePanelService = GenerateBasePanelService(
      panelConfig: config,
      observerPosition: observerPosition,
      shenShaManager: shenShaManager,
      huaYaoManager: huaYaoManager,
    );

    final basicPanelModel = await _generateBasePanelService.calculate(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );

    // 6. Update the rest of the UI notifiers
    uiBasePanelNotifier.value = basicPanelModel;
    uiBasicLifeStarsNotifier.value = _calculateUIStarsFromMapper(
        basicPanelModel.starAngleMapper, _baseMiniSafetyAngle, zhouTianModel);

    await calculateDongWeiFateFromCurrentPanel();

    // ... other post-calculation logic like calculateDongWeiFate, saveCalculatedPanelUseCase etc.
    debugPrint("ViewModel calculation complete. Listeners notified.");
  }

  /// Transforms the raw data from the calculation engine into the map format required by other services.
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


  Future<void> calculateDaXian(DateTime fateLifeTime) async {
    final fateObserver = generateFateObserverPosition(fateLifeTime);

    // 1. Create the engine based on the configuration
    final engine = CalculationEngineFactory.create(panelConfig); // Assuming base panel's config for DaXian

    // 2. Get the system definition and star positions for the DaXian date
    final zhouTianModel = await engine.getSystemDefinition(panelConfig);
    final starPositions = await engine.calculateStarPositions(fateObserver.dateTime, fateObserver, panelConfig);

    // 3. Adapt the engine's output
    final starAngleMapper = _transformStarPositions(starPositions, panelConfig);

    try {
      PassageYearPanelModel fatePanelModel = await _generateBasePanelService
          .calculateDaXia(uiBasePanelNotifier.value!, fateObserver,
          zhouTianModel: zhouTianModel,
          starAngleMapper: starAngleMapper,
        );

      _uiFateLifeStars = _calculateUIStarsFromMapper(
          fatePanelModel.starAngleMapper,
          _fateMiniSafetyAngle, zhouTianModel); // Pass zhouTianModel

      uiFateLifeStarsNotifier.value = _uiFateLifeStars;
      uiDaXianPanelNotifier.value = fatePanelModel;
      debugPrint("Fate panel calculated. ${_uiFateLifeStars.length}");
    } catch (e) {
      debugPrint("Error calculating fate panel: $e");
      _uiFateLifeStars = [];
      uiFateLifeStarsNotifier.value = null;
    }
  }

  /// 使用 BasePanelModel 中的 StarAngleSpeed 映射计算 UI 星体列表。
  /// 这个方法用于将服务计算的结果转换为 UI 需要的格式。
  /// [starsAngleMapper]: 星体到 StarAngleSpeed 信息的映射。
  /// [miniSafetyAngle]: UI 绘制时星体所需的最小安全角度。
  /// 返回: 适用于 UI 绘制的 UIStarModel 列表。
  List<UIStarModel> _calculateUIStarsFromMapper(
      Map<EnumStars, StarAngleSpeed> starsAngleMapper, double miniSafetyAngle, ZhouTianModel zhouTianModel) {
    // 定义星体及其在 UI 调整位置时的优先级。
    // 优先级越高，越不容易被移动。
    List<UIStarModel> unadjustedStarList = starsAngleMapper.entries.map((entry) {
      final star = entry.key;
      final starAngle = entry.value;
      // Normalize the angle from the native system to a 360-degree system for UI drawing
      final normalizedAngle = (starAngle.angle / zhouTianModel.totalDegree) * 360.0;

      return UIStarModel(
        star: star,
        originalAngle: normalizedAngle,
        priority: _getStarPriority(star), // Helper function to get priority
        rangeAngleEachSide: miniSafetyAngle,
      );
    }).toList();

    // 移除角度为0的星体 (可能表示该星体未计算或不存在于mapper中)
    unadjustedStarList.removeWhere((starModel) =>
        starModel.originalAngle == 0 &&
        starsAngleMapper[starModel.star] == null);

    // 使用 StarsResolver 计算调整后的 UI 位置
    return StarsResolver.resolveUIStars(unadjustedStarList);
  }

  int _getStarPriority(EnumStars star) {
    if (star == EnumStars.Sun) return 4;
    if (star == EnumStars.Moon) return 3;
    if (star.isFiveStar) return 2;
    return 1; // Auxiliary stars
  }

  // MARK: - Utility Methods

  /// 检查一个角度是否落在另一个角度范围内。
  /// 能处理范围跨越 0/360 度边界的情况。
  /// [theStartDegree]: 范围的起始角度。
  /// [theEndDegree]: 范围的结束角度。
  /// [doTestDegree]: 需要测试的角度。
  /// 返回: 如果测试角度在范围内则为 true，否则为 false。
  @visibleForTesting // 标记为测试可见，因为它可能是内部辅助方法但逻辑复杂
  static bool isInDegreeRange(
      double theStartDegree, double theEndDegree, double doTestDegree) {
    // 将所有角度规范化到 [0, 360) 范围
    double normalizeAngle(double angle) {
      angle = angle % 360;
      if (angle < 0) {
        angle += 360;
      }
      return angle;
    }

    double startDegree = normalizeAngle(theStartDegree);
    double endDegree = normalizeAngle(theEndDegree);
    double testedDegree = normalizeAngle(doTestDegree);

    // 如果起始角度等于结束角度，表示范围覆盖整个圆，除了起始点本身（取决于包含性）
    // 当前逻辑抛出错误，保留原逻辑，但需注意这种情况可能需要特殊处理
    if (startDegree == endDegree) {
      // 通常表示一个点或整个圆。在角度范围判断中，相等可能表示空范围或整个圆。
      // 根据原代码逻辑，此处认为无效范围。
      debugPrint(
          "isInDegreeRange called with startDegree == endDegree ($startDegree). This might be an edge case or invalid input.");
      return false; // 或者根据具体需求判断是否为整个圆
      // throw ArgumentError("startDegree == endDegree is not a valid range for simple check.");
    }

    if (startDegree < endDegree) {
      // 正常范围，例如 30 到 60 度
      return testedDegree >= startDegree && testedDegree <= endDegree;
    } else {
      // 跨越 0/360 边界的范围，例如 330 到 30 度
      // 测试角度在 [startDegree, 360) 或 [0, endDegree] 范围内
      return testedDegree >= startDegree || testedDegree <= endDegree;
    }
  }

  /// 计算洞微命理信息
  /// [bodyLifeModel]: 身命信息模型
  /// [calculateDaXian]: 是否计算大限，默认为 true
  /// [calculateHundredSix]: 是否计算百六限，默认为 true
  /// [daXianCountingType]: 大限计算类型，默认为现代方法
  /// [hundredSixCountingType]: 百六限计算类型，默认为现代方法
  Future<void> calculateDongWeiFate({
    required BodyLifeModel bodyLifeModel,
  }) async {
    debugPrint("开始计算洞微命理...");

    // 创建计算参数
    final params = CalculateFateDongWeiParams(
      bodyLifeModel: bodyLifeModel,
      countingType: fatePanelConfig.mingCountingType,
    );

    // 执行计算
    final result = await calculateFateDongWeiUseCase.execute(params);
    dongWeiFateResultNotifier.value = result;
  }

  /// 根据当前的基础面板模型计算洞微命理
  /// 这是一个便捷方法，会自动从当前的面板数据中提取身命信息
  Future<void> calculateDongWeiFateFromCurrentPanel() async {
    final basePanelModel = uiBasePanelNotifier.value;
    if (basePanelModel == null) {
      debugPrint("无法计算洞微命理：基础面板模型为空，请先计算星盘");
      return;
    }

    // 从基础面板模型中提取身命信息
    final bodyLifeModel = basePanelModel.bodyLifeModel;
    if (bodyLifeModel == null) {
      debugPrint("无法计算洞微命理：基础面板模型中缺少身命信息");
      return;
    }

    // 执行洞微命理计算
    await calculateDongWeiFate(bodyLifeModel: bodyLifeModel);
  }

  /// 计算紫气在黄道坐标系中的位置。
  /// 这个计算方法基于特定术数规则，非标准天文计算。
  /// [datetime]: 计算紫气位置的时间 (UTC)。
  /// 返回: 紫气在黄道上的角度 (度)。
  double _calculateZiQi(DateTime datetime) {
    // 将目标时间转换为上海时区，以便与基准时间比较
    // 注意：Sweph计算使用UTC时间，但紫气基准是上海时间。
    // 这里假设紫气的运行速度是相对于地球自转的相对速度，因此与本地时间差相关。
    // 如果紫气运行速度是恒定的，与时区无关，则应直接使用UTC时间差。
    // 原代码使用了UTC时间差与上海基准时间比较，这里沿用此逻辑，但需注意其合理性。
    // 更严谨的做法可能是将datetime转换为tz.TZDateTime后再比较
    // 但为了与 Sweph 计算的输入 (UTC DateTime) 一致，且原逻辑使用了UTC时间差，这里保留UTC时间差计算。

    // 假设输入的 datetime 已经是 UTC 时间
    final utcDateTime = datetime;
    // 将上海基准时间转换为 UTC
    final ziQiBaseUtcTime = _ziQiBaseShangHaiTime.toUtc();

    if (utcDateTime.isAtSameMomentAs(ziQiBaseUtcTime)) {
      return 0.0; // 在基准时间点，角度为 0
    }

    // 计算与基准时间的分钟差
    var diffInMinutes = utcDateTime.isBefore(ziQiBaseUtcTime)
        ? ziQiBaseUtcTime.difference(utcDateTime)
        : utcDateTime.difference(ziQiBaseUtcTime);

    // 计算运行角度
    double result = diffInMinutes.inMinutes * _ziQiAnglePerMinute;

    // 如果目标时间早于基准时间，角度应该倒退
    if (utcDateTime.isBefore(ziQiBaseUtcTime)) {
      result = -result;
    }

    // 规范化角度到 [0, 360) 范围
    result = result % 360;
    if (result < 0) {
      result += 360;
    }

    // 保留小数点后两位
    num factor = pow(10, 2);
    result = ((result * factor).round() / factor);

    return result;
  }


  void setLifeObserver(DivinationInfoModel divinationInfoModel) {
    _divinationInfoModel = divinationInfoModel;
    BaseDivinationDatetimeDataModel _tmp =
        divinationInfoModel.divinationDatetime;
    observer = _tmp.timingInfoListJson!
        .firstWhere((t) => t.uuid == _tmp.timingInfoUuid)
        .observer;
    lifeObserver = generateLifeObserverPosition();

    print(json.encode(lifeObserver));
  }

  ObserverPosition generateLifeObserverPosition() {
    DivinationDatetimeModel _datetimeModel = _divinationInfoModel!
        .divinationDatetime.timingInfoListJson!
        .firstWhere((t) =>
            t.uuid == _divinationInfoModel!.divinationDatetime.timingInfoUuid)!;
    Coordinates _coordinates;
    switch (observer!.type) {
      case EnumDatetimeType.standard:
      case EnumDatetimeType.removeDST:
        _coordinates =
            _datetimeModel.observer.location!.address!.province.coordinates!;
        break;
      case EnumDatetimeType.meanSolar:
        _coordinates =
            _datetimeModel.observer.location!.address!.city?.coordinates ??
                _datetimeModel.observer.location!.address!.province.coordinates;
        break;
      case EnumDatetimeType.trueSolar:
        if (_datetimeModel.observer.isManualCalibration) {
          _coordinates = _datetimeModel.observer.location!.preciseCoordinates!;
        } else {
          _coordinates = _datetimeModel.observer.location!.coordinates!;
        }

        break;
    }
    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: _coordinates.latitude,
      longitude: _coordinates.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: observer!.timezoneStr,
      dateTime: _datetimeModel.datetime, // 保存时区信息
      isDayBirth: getDayTimeZhi().contains(_datetimeModel.timeJiaZi.zhi),
      yearGanZhi: _datetimeModel.yearJiaZi,
      monthGanZhi: _datetimeModel.monthJiaZi,
      dayGanZhi: _datetimeModel.dayJiaZi,
      timeGanZhi: _datetimeModel.timeJiaZi,
    );
  }

  ObserverPosition generateFateObserverPosition(DateTime fateDatetime) {
    DivinationDatetimeModel _datetimeModel;
    tz.TZDateTime tzDatetime =
        tz.TZDateTime.from(fateDatetime, tz.getLocation(observer!.timezoneStr));
    final isDST = tzDatetime.timeZone.isDst;
    String queryUuid = UuidV7().toString();
    // Coordinates _coordinates;
    switch (observer!.type) {
      case EnumDatetimeType.standard:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
          queryUuid: queryUuid,
          dateTime: tzDatetime.toDateTime(),
          timezoneStr: observer!.timezoneStr,
          location: observer!.location,
          isDST: isDST,
          isSeersLocation: false,
        );
        break;
      case EnumDatetimeType.removeDST:
        if (isDST) {
          // 处理夏令时的情况
          // 例如，将时间向前调整一个小时
          tzDatetime = tzDatetime.subtract(Duration(hours: 1));
          _datetimeModel =
              SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(
            queryUuid: queryUuid,
            dateTime: tzDatetime.toDateTime(),
            timezoneStr: observer!.timezoneStr,
            location: observer!.location,
            hourAdjusted: -1,
            isSeersLocation: false,
          );
        } else {
          _datetimeModel =
              SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
            queryUuid: queryUuid,
            dateTime: tzDatetime.toDateTime(),
            timezoneStr: observer!.timezoneStr,
            location: observer!.location,
            isDST: isDST,
            isSeersLocation: false,
          );
        }

        break;
      case EnumDatetimeType.meanSolar:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
                queryUuid, tzDatetime, observer!.location!.address!, false);
        break;
      case EnumDatetimeType.trueSolar:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
                queryUuid,
                tzDatetime.toDateTime(),
                observer!.timezoneStr,
                observer!.coordinate!,
                false);
        break;
    }
    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: _datetimeModel.observer.coordinate!.latitude,
      longitude: _datetimeModel.observer.coordinate!.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: observer!.timezoneStr,
      dateTime: _datetimeModel.datetime, // 保存时区信息
      isDayBirth: getDayTimeZhi().contains(_datetimeModel.timeJiaZi.zhi),
      yearGanZhi: _datetimeModel.yearJiaZi,
      monthGanZhi: _datetimeModel.monthJiaZi,
      dayGanZhi: _datetimeModel.dayJiaZi,
      timeGanZhi: _datetimeModel.timeJiaZi,
    );
  }

  /// 将 DivinationInfoModel 转换为 ObserverPosition。
  /// [divinationInfo]: 包含问事时间、地点等信息的数据模型。
  /// 返回: ObserverPosition 对象。
  ObserverPosition convertToObserverPosition(
      DivinationInfoModel divinationInfo) {
    BaseDivinationDatetimeDataModel _tmp = divinationInfo.divinationDatetime;
    observer = _tmp.timingInfoListJson!
        .firstWhere((t) => t.uuid == _tmp.timingInfoUuid)
        .observer;

    // 确保日期时间信息有效
    final dateTime = _tmp.datetime;
    final location = _tmp.location;

    if (location == null ||
        location.coordinates == null ||
        location.address == null) {
      throw ArgumentError(
          "DivinationInfoModel must contain valid datetime, location, coordinates, and timezone.");
    }

    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: location.coordinates!.latitude,
      longitude: location.coordinates!.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: location.address!.timezone,
      dateTime: dateTime, // 保存时区信息
      isDayBirth: getDayTimeZhi()
          .contains(divinationInfo.divinationDatetime.timeGanZhi.diZhi),
      yearGanZhi: divinationInfo.divinationDatetime.yearGanZhi,
      monthGanZhi: divinationInfo.divinationDatetime.monthGanZhi,
      dayGanZhi: divinationInfo.divinationDatetime.dayGanZhi,
      timeGanZhi: divinationInfo.divinationDatetime.timeGanZhi,
    );
  }

  static List<DiZhi> getDayTimeZhi() {
    return [
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN
    ];
  }






  // late final App74Database _database;

  // 在构造函数或初始化方法中初始化
  // void _initializeUseCases() {
  //   _database = App74Database();
  //   _saveCalculatedPanelUseCase =
  //       SaveCalculatedPanelUseCase(_database.basePanelDao);
  // }

  // 修改现有的计算方法
  // Future<void> calculatePanel() async {
  //   try {
  //     basicPanelModel = await _generateBasePanelService.calculate();

  //     // 保存计算结果到数据库
  //     final savedUuid = await _saveCalculatedPanelUseCase.execute(
  //       basicPanelModel: basicPanelModel,
  //       panelConfig: panelConfig, // 需要传入当前的配置
  //       observerPosition: observerPosition, // 需要传入当前的观测位置
  //       divinationUuid: currentDivinationUuid, // 如果有的话
  //       seekerUuid: currentSeekerUuid, // 如果有的话
  //     );

  //     print('面板数据已保存，UUID: $savedUuid');
  //   } catch (e) {
  //     print('保存面板数据失败: $e');
  //     // 处理错误
  //   }
  // }
}
