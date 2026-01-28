import 'package:common/enums/nine_star.dart';
import 'package:json_annotation/json_annotation.dart';

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

final Map<YuanYunOrder, String> _yuanYunOrderMap = {
  YuanYunOrder.upper: '上元',
  YuanYunOrder.middle: '中元',
  YuanYunOrder.lower: '下元',
};

final Map<NineYun, String> _nineYunMap = {
  NineYun.first: '一运',
  NineYun.second: '二运',
  NineYun.third: '三运',
  NineYun.fourth: '四运',
  NineYun.fifth: '五运',
  NineYun.sixth: '六运',
  NineYun.seventh: '七运',
  NineYun.eighth: '八运',
  NineYun.ninth: '九运',
};

// YuanYunOrder _yuanYunOrderFromJson(Object? json) => _yuanYunOrderMap.entries
//     .singleWhere(
//       (e) => e.value == json,
//       orElse: () => throw ArgumentError('Invalid YuanYunOrder value: $json'),
//     )
//     .key;

// Object? _yuanYunOrderToJson(YuanYunOrder value) => _yuanYunOrderMap[value];

// NineYun _nineYunFromJson(Object? json) => _nineYunMap.entries
//     .singleWhere(
//       (e) => e.value == json,
//       orElse: () => throw ArgumentError('Invalid NineYun value: $json'),
//     )
//     .key;

// Object? _nineYunToJson(NineYun value) => _nineYunMap[value];
