import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';

part 'gong_constellation_mapping.g.dart';

/// 天体对象类，用于表示宫位或星宿
/// [E] 可以是 [EnumTwelveGong] 或 [Enum28Constellations]
/// [name] 天体名称
/// [absStartContinuous] 连续的绝对起始角度 (可能 > totalDegree)
/// [absEndContinuous] 连续的绝对结束角度 (absStart + width)
/// [width] 天体宽度(度数)
class CelestialObject<E> {
  E name;
  double absStartContinuous; // 连续的绝对起始角度 (可能 > totalDegree)
  double absEndContinuous; // 连续的绝对结束角度 (absStart + width)
  double width;
  CelestialObject(
      this.name, this.absStartContinuous, this.absEndContinuous, this.width);

  @override
  String toString() {
    String nameStr = name is EnumTwelveGong
        ? (name as EnumTwelveGong).name
        : name is Enum28Constellations
            ? (name as Enum28Constellations).name
            : name.toString();
    return '$nameStr: [${absStartContinuous.toStringAsFixed(2)}°, ${absEndContinuous.toStringAsFixed(2)}°) width ${width.toStringAsFixed(2)}°';
  }
}

/// 星宿在宫位中的分段信息
/// [palaceName] 宫位名称
/// [startInPalaceDeg] 在宫位中的起始度数
/// [endInPalaceDeg] 在宫位中的结束度数
/// [startInConstellationDeg] 在星宿中的起始度数
/// [endInConstellationDeg] 在星宿中的结束度数
/// [segmentLengthDeg] 分段长度(度数)
/// [crossesPalaceAtConstellationDeg] 星宿跨越宫位的度数点(如果跨越)
@JsonSerializable()
class ConstellationSegment extends Equatable {
  EnumTwelveGong palaceName; // 替换为EnumTwelveGong
  double startInPalaceDeg;
  double endInPalaceDeg;
  double startInConstellationDeg;
  double endInConstellationDeg;
  double segmentLengthDeg;
  double? crossesPalaceAtConstellationDeg;

  ConstellationSegment({
    required this.palaceName,
    required this.startInPalaceDeg,
    required this.endInPalaceDeg,
    required this.startInConstellationDeg,
    required this.endInConstellationDeg,
    required this.segmentLengthDeg,
    this.crossesPalaceAtConstellationDeg,
  });

  @override
  String toString() {
    String base =
        '  - In ${palaceName.name}: [${startInPalaceDeg.toStringAsFixed(2)}°-${endInPalaceDeg.toStringAsFixed(2)}°)] '
        ' (Constellation segment: [${startInConstellationDeg.toStringAsFixed(2)}°-${endInConstellationDeg.toStringAsFixed(2)}°]) '
        'Length: ${segmentLengthDeg.toStringAsFixed(2)}°';
    if (crossesPalaceAtConstellationDeg != null) {
      base +=
          ' -> Crosses into next palace at ${crossesPalaceAtConstellationDeg!.toStringAsFixed(2)}° of constellation.';
    }
    return base;
  }

  @override
  List<Object?> get props => [
        palaceName,
        startInPalaceDeg,
        endInPalaceDeg,
        startInConstellationDeg,
        endInConstellationDeg,
        segmentLengthDeg,
        crossesPalaceAtConstellationDeg,
      ];

  factory ConstellationSegment.fromJson(Map<String, dynamic> json) =>
      _$ConstellationSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$ConstellationSegmentToJson(this);
}

/// 星宿映射到宫位的结果
/// [constellationName] 星宿名称
/// [absStartDeg] 绝对起始度数
/// [absEndDeg] 绝对结束度数
/// [totalWidthDeg] 总宽度(度数)
/// [segments] 在各宫位中的分段信息列表
@JsonSerializable()
class ConstellationMappingResult extends Equatable {
  Enum28Constellations constellationName; // 替换为Enum28Constellations
  double absStartDeg;
  double absEndDeg;
  double totalWidthDeg;
  List<ConstellationSegment> segments;

  ConstellationMappingResult({
    required this.constellationName,
    required this.absStartDeg,
    required this.absEndDeg,
    required this.totalWidthDeg,
    required this.segments,
  });

  @override
  String toString() {
    return 'Constellation: ${constellationName.name} (Abs: [${absStartDeg.toStringAsFixed(2)}°-${absEndDeg.toStringAsFixed(2)}°), Width: ${totalWidthDeg.toStringAsFixed(2)}°)\n'
        '${segments.map((s) => s.toString()).join('\n')}';
  }

  @override
  List<Object?> get props => [
        constellationName,
        absStartDeg,
        absEndDeg,
        totalWidthDeg,
        segments,
      ];

  factory ConstellationMappingResult.fromJson(Map<String, dynamic> json) =>
      _$ConstellationMappingResultFromJson(json);
  Map<String, dynamic> toJson() => _$ConstellationMappingResultToJson(this);
}

/// 宫位中的星宿分段信息
/// [constellationName] 星宿名称
/// [startInConstellationDeg] 在星宿中的起始度数
/// [endInConstellationDeg] 在星宿中的结束度数
/// [startInPalaceDeg] 在宫位中的起始度数
/// [endInPalaceDeg] 在宫位中的结束度数
/// [segmentLengthDeg] 分段长度(度数)
/// [absStartDeg] 在周天中的绝对起始度数
/// [absEndDeg] 在周天中的绝对结束度数
@JsonSerializable()
class PalaceConstellationSegment extends Equatable {
  Enum28Constellations constellationName;

  // double totalDeg;

  double startInConstellationDeg;
  double endInConstellationDeg;
  double startInPalaceDeg;
  double endInPalaceDeg;
  double segmentLengthDeg;
  double absStartDeg;
  double absEndDeg;

  PalaceConstellationSegment({
    required this.constellationName,
    // required this.totalDeg,
    required this.startInConstellationDeg,
    required this.endInConstellationDeg,
    required this.startInPalaceDeg,
    required this.endInPalaceDeg,
    required this.segmentLengthDeg,
    required this.absStartDeg,
    required this.absEndDeg,
  });

  @override
  String toString() {
    return '  - Constellation ${constellationName.name}: '
        'In Palace [${startInPalaceDeg.toStringAsFixed(2)}°-${endInPalaceDeg.toStringAsFixed(2)}°] '
        '(Constellation segment: [${startInConstellationDeg.toStringAsFixed(2)}°-${endInConstellationDeg.toStringAsFixed(2)}°]) '
        'Abs: [${absStartDeg.toStringAsFixed(2)}°-${absEndDeg.toStringAsFixed(2)}°] '
        'Length: ${segmentLengthDeg.toStringAsFixed(2)}°';
  }

  @override
  List<Object?> get props => [
        constellationName,
        startInConstellationDeg,
        endInConstellationDeg,
        startInPalaceDeg,
        endInPalaceDeg,
        segmentLengthDeg,
        absStartDeg,
        absEndDeg,
      ];

  factory PalaceConstellationSegment.fromJson(Map<String, dynamic> json) =>
      _$PalaceConstellationSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceConstellationSegmentToJson(this);
}

/// 宫位映射到星宿的结果
/// [palaceName] 宫位名称
/// [totalWidthDeg] 宫位总度数
/// [absStartDeg] 宫位在周天中的绝对起始度数
/// [absEndDeg] 宫位在周天中的绝对结束度数
/// [constellationSegments] 宫位中包含的星宿分段信息列表
@JsonSerializable()
class PalaceMappingResult extends Equatable {
  EnumTwelveGong palaceName;
  double totalWidthDeg;
  double absStartDeg;
  double absEndDeg;

  // 逆时针，顺周天星宿顺序，奎娄胃昴....
  List<PalaceConstellationSegment> constellationSegments;

  // 顺时针，逆周天星宿 昴胃娄奎
  List<PalaceConstellationSegment> get reversedOrder =>
      constellationSegments.reversed.toList();

  PalaceMappingResult({
    required this.palaceName,
    required this.totalWidthDeg,
    required this.absStartDeg,
    required this.absEndDeg,
    required this.constellationSegments,
  });

  @override
  String toString() {
    return 'Palace: ${palaceName.name} '
        '(Abs: [${absStartDeg.toStringAsFixed(2)}°-${absEndDeg.toStringAsFixed(2)}°], '
        'Width: ${totalWidthDeg.toStringAsFixed(2)}°)\n'
        '${constellationSegments.map((s) => s.toString()).join('\n')}';
  }

  @override
  List<Object?> get props => [
        palaceName,
        totalWidthDeg,
        absStartDeg,
        absEndDeg,
        constellationSegments,
      ];

  factory PalaceMappingResult.fromJson(Map<String, dynamic> json) =>
      _$PalaceMappingResultFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceMappingResultToJson(this);
}
