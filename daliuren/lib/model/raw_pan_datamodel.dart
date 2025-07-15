import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'raw_pan_datamodel.g.dart';

/// 四课中的单个项目
@JsonSerializable()
class FourClassItem extends Equatable {
  /// 顺序 (0-3)
  final int order;

  /// 天盘地支
  final DiZhi sky;

  /// 地盘地支
  final DiZhi ground;

  const FourClassItem({
    required this.order,
    required this.sky,
    required this.ground,
  });
  factory FourClassItem.fromJson(Map<String, dynamic> json) =>
      _$FourClassItemFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FourClassItemToJson(this);

  @override
  List<Object?> get props => [
        order,
        sky,
        ground,
      ];
}

/// 三传中的单个项目
///
@JsonSerializable()
class ThreeClassItem extends Equatable {
  /// 顺序 (1-3)
  final int order;

  /// 地支
  final DiZhi diZhi;

  /// 六亲关系
  final LiuQin liuQin;

  const ThreeClassItem({
    required this.order,
    required this.diZhi,
    required this.liuQin,
  });

  factory ThreeClassItem.fromJson(Map<String, dynamic> json) =>
      _$ThreeClassItemFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreeClassItemToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [
        order,
        diZhi,
        liuQin,
      ];
}

/// 大六壬原始盘数据
@JsonSerializable()
class RawPan {
  /// 日干支，如 JiaZi.jiaZi
  final JiaZi day;

  /// 时辰地支，如 DiZhi.yin
  final DiZhi upon;

  /// 局数字符串，如 "一局"
  final String juStr;

  /// 局数，如 1
  final int ju;

  /// 四课数据，包含4个元素
  final List<FourClassItem> four;

  /// 三传数据，包含3个元素
  final List<ThreeClassItem> three;

  /// 宫位映射，12个地支的对应关系
  final Map<DiZhi, DiZhi> gong;

  const RawPan({
    required this.day,
    required this.upon,
    required this.juStr,
    required this.ju,
    required this.four,
    required this.three,
    required this.gong,
  });

  factory RawPan.fromJson(Map<String, dynamic> json) => _$RawPanFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RawPanToJson(this);
}

/// 原始盘数据集合
@JsonSerializable()
class RawPanCollection {
  /// 阳盘数据
  final List<RawPan> yangData;

  /// 阴盘数据
  final List<RawPan> yinData;

  const RawPanCollection({
    required this.yangData,
    required this.yinData,
  });

  factory RawPanCollection.fromJson(Map<String, dynamic> json) =>
      _$RawPanCollectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RawPanCollectionToJson(this);
  @override
  String toString() {
    return 'RawPanCollection(yangData: ${yangData.length} items, yinData: ${yinData.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RawPanCollection &&
        _listEquals(other.yangData, yangData) &&
        _listEquals(other.yinData, yinData);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(yangData),
      Object.hashAll(yinData),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
