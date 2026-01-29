import 'package:common/datamodel/location.dart' as my;
import 'package:common/models/chinese_date_info.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:timezone/timezone.dart' as tz;
import 'calculation_strategy_config.dart';
import 'input_info_params.dart';
import 'processors/dst_processor.dart';
import 'processors/solar_time_processor.dart';
import 'processors/timezone_processor.dart';
import 'zi_strategy_store.dart';

/// 出生时间计算参数类
/// 封装所有计算所需的基础参数
class DateTimeDetailsCalculationParams {
  /// 原始输入时间
  final DateTime inputDateTime;

  /// 时区字符串，如 "Asia/Shanghai"
  final String timezoneStr;

  /// 出生地点（可选，用于平太阳时计算）
  final my.Location? location;

  /// 精确坐标（可选，用于真太阳时计算）
  final my.Coordinates? coordinates;

  const DateTimeDetailsCalculationParams({
    required this.inputDateTime,
    required this.timezoneStr,
    this.location,
    this.coordinates,
  });

  /// 验证参数有效性
  void validate() {
    // 验证时区
    if (!TimezoneProcessor.isValidTimezone(timezoneStr)) {
      throw ArgumentError('无效的时区字符串: $timezoneStr');
    }

    // 验证日期范围（1900-2100年）
    if (inputDateTime.year < 1900 || inputDateTime.year > 2100) {
      throw ArgumentError('日期超出支持范围 (1900-2100): ${inputDateTime.year}');
    }

    // 验证坐标
    if (coordinates != null) {
      if (coordinates!.latitude < -90 || coordinates!.latitude > 90) {
        throw ArgumentError('纬度超出范围 (-90 to 90): ${coordinates!.latitude}');
      }
      if (coordinates!.longitude < -180 || coordinates!.longitude > 180) {
        throw ArgumentError('经度超出范围 (-180 to 180): ${coordinates!.longitude}');
      }
    }
  }

  /// 检查是否具有高精度坐标（小数点后五位）
  bool get hasHighPrecisionCoordinates {
    final coords = coordinates ?? location?.coordinates;
    if (coords == null) return false;

    // 检查纬度和经度是否都有小数点后五位精度
    final latStr = coords.latitude.toString();
    final lngStr = coords.longitude.toString();

    final latDecimalIndex = latStr.indexOf('.');
    final lngDecimalIndex = lngStr.indexOf('.');

    if (latDecimalIndex == -1 || lngDecimalIndex == -1) return false;

    final latDecimals = latStr.substring(latDecimalIndex + 1).length;
    final lngDecimals = lngStr.substring(lngDecimalIndex + 1).length;

    return latDecimals >= 5 && lngDecimals >= 5;
  }

  /// 是否需要计算平太阳时
  bool get needsMeanSolarTime => location != null;

  /// 是否需要计算真太阳时
  bool get needsTrueSolarTime => hasHighPrecisionCoordinates;

  @override
  String toString() {
    return 'BirthCalculationParams(inputDateTime: $inputDateTime, timezoneStr: $timezoneStr, location: $location, coordinates: $coordinates)';
  }
}

/// 出生时间详情束计算类
/// 负责计算 DateTimeDetailsBundle 的所有时间相关数据
class DateTimeDetailsBundleCalculation {
  /// 主计算方法 - 专业版本
  ///
  /// [params] 计算参数，包含输入时间、时区、地点和坐标信息
  /// [config] 计算配置，包含各种策略参数
  static Future<DateTimeDetailsBundle> calculate({
    required DateTimeDetailsCalculationParams params,
    CalculationStrategyConfig config = CalculationStrategyConfig.defaultConfig,
  }) async {
    // 验证输入参数
    params.validate();

    try {
      // 使用全局运行期策略覆盖配置中的子时策略（开发阶段默认行为）
      config = config.copyWith(ziStrategy: ZiStrategyStore.current);
      // 1. 基础时区处理 - 获取UTC时间和ChineseDateInfo
      final timezoneData = await TimezoneProcessor.process(
        inputDateTime: params.inputDateTime,
        timezoneStr: params.timezoneStr,
      );

      // 2. 检查是否为夏令时，只有在DST时才进行DSTProcessor处理
      DSTProcessResult? dstData;
      final location_tz = tz.getLocation(params.timezoneStr);
      final tzDateTime = tz.TZDateTime.from(params.inputDateTime, location_tz);
      if (tzDateTime.timeZone.isDst) {
        dstData = await DSTProcessor.process(
          standardDateTime: timezoneData.standardDateTime,
          timezoneStr: params.timezoneStr,
          ziStrategy: config.ziStrategy,
        );
      }

      // 3. 太阳时计算 - 根据输入参数条件化处理
      SolarTimeProcessResult? solarTimeData;

      if (params.needsMeanSolarTime || params.needsTrueSolarTime) {
        solarTimeData = await SolarTimeProcessor.process(
          standardDateTime: timezoneData.standardDateTime,
          timezoneStr: params.timezoneStr,
          location: params.needsMeanSolarTime ? params.location : null,
          coordinates: params.needsTrueSolarTime
              ? (params.coordinates ?? params.location?.coordinates)
              : null,
          ziStrategy: config.ziStrategy,
          calculateTrueSolarTime: params.needsTrueSolarTime,
          calculateMeanSolarTime: params.needsMeanSolarTime,
        );
      }

      // 4. 构建最终对象
      return DateTimeDetailsBundle.internal(
        calculationConfig: config,
        meanSolarDatetime: solarTimeData?.meanSolarDatetime,
        meanSolarChineseInfo: solarTimeData?.meanSolarChineseInfo,
        trueSolarDatetime: solarTimeData?.trueSolarDatetime,
        trueSolarChineseInfo: solarTimeData?.trueSolarChineseInfo,
        standeredDatetime: timezoneData.standardDateTime,
        standeredChineseInfo: timezoneData.chineseInfo,
        utcDatetime: timezoneData.utcDateTime,
        timezoneStr: params.timezoneStr,
      );
    } catch (e) {
      throw BirthDateTimeCalculationException(
        '计算出生时间详情时发生错误: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 构建计算元数据
  static CalculationMetadata _buildCalculationMetadata(
    TimezoneProcessResult timezoneData,
    DSTProcessResult? dstData,
    SolarTimeProcessResult? solarTimeData,
  ) {
    return CalculationMetadata(
      calculationTime: DateTime.now(),
      timezoneInfo: timezoneData.getSummary(),
      dstInfo: dstData?.getSummary() ?? {'isDST': false, 'processed': false},
      solarTimeInfo: solarTimeData?.getSummary() ?? {'processed': false},
      version: '1.0.0', // 专业版本
    );
  }
}

/// 计算异常类
class BirthDateTimeCalculationException implements Exception {
  final String message;
  final dynamic originalError;

  BirthDateTimeCalculationException(this.message, {this.originalError});

  @override
  String toString() => 'BirthDateTimeCalculationException: $message';
}

/// 计算元数据
class CalculationMetadata {
  final DateTime calculationTime;
  final Map<String, dynamic> timezoneInfo;
  final Map<String, dynamic> dstInfo;
  final Map<String, dynamic> solarTimeInfo;
  final String version;

  CalculationMetadata({
    required this.calculationTime,
    required this.timezoneInfo,
    required this.dstInfo,
    required this.solarTimeInfo,
    required this.version,
  });
}
