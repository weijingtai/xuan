import 'package:common/shared/enums/nine_star.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enum_three_yuan.g.dart';

@JsonEnum()
enum YuanYunOrder {
  /// 上元
  @JsonValue('上元')
  upper('上元'),

  /// 中元
  @JsonValue('中元')
  middle('中元'),

  /// 下元
  @JsonValue('下元')
  lower('下元');

  final String name;
  const YuanYunOrder(this.name);
}

@JsonEnum()
enum YuanYunType {
  /// 元
  @JsonValue('元')
  yuan('元', 60),

  /// 运
  @JsonValue('运')
  yun('运', 20);

  final String name;
  final int totalYears;
  const YuanYunType(this.name, this.totalYears);
}

@JsonEnum()
enum NineYun {
  @JsonValue('一运')
  first(1, '一运', NineStarEnum.first),
  @JsonValue('二运')
  second(2, '二运', NineStarEnum.second),
  @JsonValue('三运')
  third(3, '三运', NineStarEnum.third),
  @JsonValue('四运')
  fourth(4, '四运', NineStarEnum.fourth),
  @JsonValue('五运')
  fifth(5, '五运', NineStarEnum.fifth),
  @JsonValue('六运')
  sixth(6, '六运', NineStarEnum.sixth),
  @JsonValue('七运')
  seventh(7, '七运', NineStarEnum.seventh),
  @JsonValue('八运')
  eighth(8, '八运', NineStarEnum.eighth),
  @JsonValue('九运')
  ninth(9, '九运', NineStarEnum.ninth);

  final int order;
  final String name;
  final NineStarEnum star;
  const NineYun(this.order, this.name, this.star);
}

// --- 辅助函数：Enum 转换 ---
// 这些辅助函数用于将字符串和 Enum 值相互转换，并被 EachYuanInfo 和 EachYunInfo 调用。

YuanYunOrder _yuanYunOrderFromJson(Object? json) =>
    _$YuanYunOrderEnumMap.entries
        .singleWhere(
          (e) => e.value == json,
          orElse: () =>
              throw ArgumentError('Invalid YuanYunOrder value: $json'),
        )
        .key;

Object? _yuanYunOrderToJson(YuanYunOrder value) => _$YuanYunOrderEnumMap[value];

NineYun _nineYunFromJson(Object? json) => _$NineYunEnumMap.entries
    .singleWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Invalid NineYun value: $json'),
    )
    .key;

Object? _nineYunToJson(NineYun value) => _$NineYunEnumMap[value];

// --- 泛型类 ---
@JsonSerializable(genericArgumentFactories: true)
class EachYuanYunInfo {
  final YuanYunType type;

  final int startYear;
  final int endYear;
  final String version;

  const EachYuanYunInfo({
    required this.type,
    required this.startYear,
    required this.endYear,
    this.version = "1",
  });

  factory EachYuanYunInfo.fromJson(Map<String, dynamic> json) =>
      _$EachYuanYunInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EachYuanYunInfoToJson(this);
}

// --- 具体的子类 ---

@JsonSerializable()
class EachYuanInfo extends EachYuanYunInfo {
  YuanYunOrder name;
  EachYuanInfo({
    required super.type,
    required this.name,
    required super.startYear,
    required super.endYear,
    super.version = "1",
  });

  factory EachYuanInfo.fromJson(Map<String, dynamic> json) =>
      _$EachYuanInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EachYuanInfoToJson(this);
}

@JsonSerializable()
class EachYunInfo extends EachYuanYunInfo {
  final NineYun name;
  const EachYunInfo({
    required super.type,
    required this.name,
    required super.startYear,
    required super.endYear,
    super.version = "1",
  });

  factory EachYunInfo.fromJson(Map<String, dynamic> json) =>
      _$EachYunInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EachYunInfoToJson(this);
}

/// 三元九运信息数据类
/// 存储给定年份所在的三元九运信息，以及所在三元九运的开始与结束年份
@JsonSerializable()
class ThreeYuanNineYunInfo {
  /// 目标年份
  final int targetYear;

  final EachYuanInfo yuanInfo;
  final EachYunInfo yunInfo;

  /// 当前大三元的开始年份
  final int currentCycleStartYear;

  /// 当前大三元的结束年份
  final int currentCycleEndYear;

  final String version;

  const ThreeYuanNineYunInfo({
    required this.targetYear,
    required this.yuanInfo,
    required this.yunInfo,
    required this.currentCycleStartYear,
    required this.currentCycleEndYear,
    this.version = "1",
  });

  factory ThreeYuanNineYunInfo.fromJson(Map<String, dynamic> json) =>
      _$ThreeYuanNineYunInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ThreeYuanNineYunInfoToJson(this);

  /// 根据年份计算三元九运信息
  /// 以1864年为基准点，每运20年，每元60年，每个大三元180年
  factory ThreeYuanNineYunInfo.fromYear(int year) {
    // 计算相对于1864年的年份偏移
    int yearOffset = year - 1864;

    // 使用数学取模运算确保结果在0-179范围内
    int yearInCycle = yearOffset % 180;
    if (yearInCycle < 0) {
      yearInCycle += 180;
    }

    // 计算是第几运（0-8，对应一运到九运）
    int yunIndex = yearInCycle ~/ 20;
    yunIndex = yunIndex.clamp(0, 8);

    // 计算三元
    YuanYunOrder yuanName;
    if (yunIndex < 3) {
      yuanName = YuanYunOrder.upper; // 上元：一、二、三运
    } else if (yunIndex < 6) {
      yuanName = YuanYunOrder.middle; // 中元：四、五、六运
    } else {
      yuanName = YuanYunOrder.lower; // 下元：七、八、九运
    }

    // 计算九运
    NineYun nineYun = NineYun.values[yunIndex];

    // 计算当前180年周期的起始年份
    int cycleStartYear = 1864 + (yearOffset ~/ 180) * 180;
    if (yearOffset < 0) {
      cycleStartYear = 1864 + ((yearOffset - 179) ~/ 180) * 180;
    }

    // 计算各个时间范围
    int currentYunStartYear = cycleStartYear + yunIndex * 20;
    int currentYunEndYear = currentYunStartYear + 19;

    int yuanStartIndex = (yunIndex ~/ 3) * 3;
    int currentYuanStartYear = cycleStartYear + yuanStartIndex * 20;
    int currentYuanEndYear = currentYuanStartYear + 59;

    int currentCycleStartYear = cycleStartYear;
    int currentCycleEndYear = cycleStartYear + 179;

    // 创建元信息
    EachYuanInfo yuanInfo = EachYuanInfo(
      type: YuanYunType.yuan,
      name: yuanName,
      startYear: currentYuanStartYear,
      endYear: currentYuanEndYear,
    );

    // 创建运信息
    EachYunInfo yunInfo = EachYunInfo(
      type: YuanYunType.yun,
      name: nineYun,
      startYear: currentYunStartYear,
      endYear: currentYunEndYear,
    );

    return ThreeYuanNineYunInfo(
      targetYear: year,
      yuanInfo: yuanInfo,
      yunInfo: yunInfo,
      currentCycleStartYear: currentCycleStartYear,
      currentCycleEndYear: currentCycleEndYear,
    );
  }
}
