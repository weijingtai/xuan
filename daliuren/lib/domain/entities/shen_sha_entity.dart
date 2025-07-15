import 'package:common/enums.dart';

/// 神煞基础实体类
abstract class ShenShaEntity {
  final String name;
  final JiXiongEnum jiXiong;
  final List<String> descriptionList;
  final String type;
  final Map<String, String> locationMapper;
  final List<String> locationDescriptionList;
  final List<String>? otherNameList;

  const ShenShaEntity({
    required this.name,
    required this.jiXiong,
    required this.descriptionList,
    required this.type,
    required this.locationMapper,
    required this.locationDescriptionList,
    this.otherNameList,
  });

  /// 工厂方法，根据JSON创建对应的神煞实体
  factory ShenShaEntity.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case '干煞':
        return TianGanShenShaEntity.fromJson(json);
      case '年煞':
        return YearShenShaEntity.fromJson(json);
      case '月煞':
        return MonthShenShaEntity.fromJson(json);
      case '支煞':
        return DiZhiShenShaEntity.fromJson(json);
      case '季煞':
        return JiShenShaEntity.fromJson(json);
      case '旬煞':
        return XunShenShaEntity.fromJson(json);
      default:
        throw ArgumentError('Unknown shen sha type: $type');
    }
  }
}

/// 天干神煞实体
class TianGanShenShaEntity extends ShenShaEntity {
  const TianGanShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory TianGanShenShaEntity.fromJson(Map<String, dynamic> json) {
    return TianGanShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据天干获取神煞位置
  DiZhi? getLocationByTianGan(TianGan tianGan) {
    final locationStr = locationMapper[tianGan.name];
    if (locationStr == null) return null;

    try {
      return DiZhi.values.firstWhere((zhi) => zhi.name == locationStr);
    } catch (e) {
      return null;
    }
  }
}

/// 年支神煞实体
class YearShenShaEntity extends ShenShaEntity {
  const YearShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory YearShenShaEntity.fromJson(Map<String, dynamic> json) {
    return YearShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据年支获取神煞位置
  DiZhi? getLocationByYearZhi(DiZhi yearZhi) {
    final locationStr = locationMapper[yearZhi.name];
    if (locationStr == null) return null;

    try {
      return DiZhi.values.firstWhere((zhi) => zhi.name == locationStr);
    } catch (e) {
      return null;
    }
  }
}

/// 月支神煞实体
class MonthShenShaEntity extends ShenShaEntity {
  const MonthShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory MonthShenShaEntity.fromJson(Map<String, dynamic> json) {
    return MonthShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据月支获取神煞位置
  DiZhi? getLocationByMonthZhi(DiZhi monthZhi) {
    final locationStr = locationMapper[monthZhi.name];
    if (locationStr == null) return null;

    try {
      return DiZhi.values.firstWhere((zhi) => zhi.name == locationStr);
    } catch (e) {
      return null;
    }
  }
}

/// 地支神煞实体
class DiZhiShenShaEntity extends ShenShaEntity {
  const DiZhiShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory DiZhiShenShaEntity.fromJson(Map<String, dynamic> json) {
    return DiZhiShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据地支获取神煞位置
  DiZhi? getLocationByDiZhi(DiZhi diZhi) {
    final locationStr = locationMapper[diZhi.name];
    if (locationStr == null) return null;

    try {
      return DiZhi.values.firstWhere((zhi) => zhi.name == locationStr);
    } catch (e) {
      return null;
    }
  }
}

/// 神煞计算结果
class ShenShaResult {
  final ShenShaEntity shenSha;
  final DiZhi location;

  const ShenShaResult({
    required this.shenSha,
    required this.location,
  });

  @override
  String toString() {
    return '${shenSha.name}(${shenSha.jiXiong.name}) at ${location.name}';
  }
}

/// 季煞实体
class JiShenShaEntity extends ShenShaEntity {
  const JiShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory JiShenShaEntity.fromJson(Map<String, dynamic> json) {
    return JiShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据季节获取神煞位置
  DiZhi? getLocationBySeason(String season) {
    final locationStr = locationMapper[season];
    if (locationStr != null) {
      return DiZhi.getFromValue(locationStr);
    }
    return null;
  }
}

/// 旬煞实体
class XunShenShaEntity extends ShenShaEntity {
  const XunShenShaEntity({
    required super.name,
    required super.jiXiong,
    required super.descriptionList,
    required super.type,
    required super.locationMapper,
    required super.locationDescriptionList,
    super.otherNameList,
  });

  factory XunShenShaEntity.fromJson(Map<String, dynamic> json) {
    return XunShenShaEntity(
      name: json['name'] as String,
      jiXiong: JiXiongEnum.fromName(json['jiXiong'] as String? ?? '平'),
      descriptionList: List<String>.from(json['descriptionList'] ?? []),
      type: json['type'] as String,
      locationMapper: Map<String, String>.from(json['locationMapper'] ?? {}),
      locationDescriptionList:
          List<String>.from(json['locationDescriptionList'] ?? []),
      otherNameList: json['otherNameList'] != null
          ? List<String>.from(json['otherNameList'])
          : null,
    );
  }

  /// 根据旬首获取神煞位置
  DiZhi? getLocationByXunShou(String xunShou) {
    final locationStr = locationMapper[xunShou];
    if (locationStr == null) return null;

    try {
      return DiZhi.values.firstWhere((zhi) => zhi.name == locationStr);
    } catch (e) {
      return null;
    }
  }

  /// 根据旬获取神煞位置
  DiZhi? getLocationByXun(String xunKey) {
    final locationStr = locationMapper[xunKey];
    if (locationStr != null) {
      return DiZhi.getFromValue(locationStr);
    }
    return null;
  }
}
