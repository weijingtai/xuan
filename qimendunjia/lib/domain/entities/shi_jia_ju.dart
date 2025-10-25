import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_three_yuan.dart';
import 'base_entity.dart';

/// 时家局实体（纯业务对象）
///
/// 表示奇门遁甲的局数计算结果，包含完整的起局信息
class ShiJiaJu extends Equatable implements Entity {
  @override
  final String id;

  /// 起盘时间
  final DateTime panDateTime;

  /// 局数 (1-9)
  final int juNumber;

  /// 符头甲子
  final JiaZi fuTouJiaZi;

  /// 阴阳遁
  final YinYang yinYangDun;

  /// 当前节气
  final TwentyFourJieQi jieQiAt;

  /// 当前节气开始时间
  final DateTime jieQiStartAt;

  /// 下一节气
  final TwentyFourJieQi jieQiEnd;

  /// 下一节气开始时间
  final DateTime jieQiEndAt;

  /// 三元（上中下）
  final EnumThreeYuan atThreeYuan;

  /// 四柱八字
  final String fourZhuEightChar;

  /// 盘局节气（置润法专用）
  final TwentyFourJieQi? panJuJieQi;

  /// 盘局天数（置润法专用）
  final int? juDayNumber;

  ShiJiaJu({
    required this.id,
    required this.panDateTime,
    required this.juNumber,
    required this.fuTouJiaZi,
    required this.yinYangDun,
    required this.jieQiAt,
    required this.jieQiStartAt,
    required this.jieQiEnd,
    required this.jieQiEndAt,
    required this.atThreeYuan,
    required this.fourZhuEightChar,
    this.panJuJieQi,
    this.juDayNumber,
  });

  @override
  List<Object?> get props => [
        id,
        panDateTime,
        juNumber,
        fuTouJiaZi,
        yinYangDun,
        jieQiAt,
        jieQiStartAt,
        jieQiEnd,
        jieQiEndAt,
        atThreeYuan,
        fourZhuEightChar,
        panJuJieQi,
        juDayNumber,
      ];

  /// 复制并修改部分属性
  ShiJiaJu copyWith({
    String? id,
    DateTime? panDateTime,
    int? juNumber,
    JiaZi? fuTouJiaZi,
    YinYang? yinYangDun,
    TwentyFourJieQi? jieQiAt,
    DateTime? jieQiStartAt,
    TwentyFourJieQi? jieQiEnd,
    DateTime? jieQiEndAt,
    EnumThreeYuan? atThreeYuan,
    String? fourZhuEightChar,
    TwentyFourJieQi? panJuJieQi,
    int? juDayNumber,
  }) {
    return ShiJiaJu(
      id: id ?? this.id,
      panDateTime: panDateTime ?? this.panDateTime,
      juNumber: juNumber ?? this.juNumber,
      fuTouJiaZi: fuTouJiaZi ?? this.fuTouJiaZi,
      yinYangDun: yinYangDun ?? this.yinYangDun,
      jieQiAt: jieQiAt ?? this.jieQiAt,
      jieQiStartAt: jieQiStartAt ?? this.jieQiStartAt,
      jieQiEnd: jieQiEnd ?? this.jieQiEnd,
      jieQiEndAt: jieQiEndAt ?? this.jieQiEndAt,
      atThreeYuan: atThreeYuan ?? this.atThreeYuan,
      fourZhuEightChar: fourZhuEightChar ?? this.fourZhuEightChar,
      panJuJieQi: panJuJieQi ?? this.panJuJieQi,
      juDayNumber: juDayNumber ?? this.juDayNumber,
    );
  }

  /// 是否阳遁
  bool get isYangDun => yinYangDun.isYang;

  /// 是否阴遁
  bool get isYinDun => yinYangDun.isYin;

  /// 获取局数描述
  String get juDescription => '${yinYangDun.name}$juNumber局';

  /// 获取节气区间描述
  String get jieQiRange =>
      '${jieQiAt.name}（${_formatDate(jieQiStartAt)} - ${_formatDate(jieQiEndAt)}）';

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
