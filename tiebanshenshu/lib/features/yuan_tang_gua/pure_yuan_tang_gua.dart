import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:json_annotation/json_annotation.dart';

import '../six_yao_gua/pure_six_yao_gua.dart';
import '../six_yao_gua/enum_6_shou.dart';
import 'yuan_tang_calculator.dart';

part 'pure_yuan_tang_gua.g.dart';

/// 元堂卦的“纯数据”模型，结构对齐 PureSixYaoGua：
/// - 保留 `gua`、`topGua`、`bottomGua`
/// - 提供 `yaoList`（自下而上：初→上），包含阴阳与地支列表、元堂标记
/// - 暴露与六爻一致的派生属性与便捷方法（binary、互卦、错卦、综卦、单爻变卦等）
@JsonSerializable()
class YuanTangYao extends GuaYao {
  final List<DiZhi>? yangTangZhiList; // 该爻对应的地支列表（元堂卦可多支）
  bool isYuanTang; // 是否为元堂爻

  YuanTangYao({
    required super.order,
    required super.yinYang,
    this.isYuanTang = false,
    this.yangTangZhiList,
  });

  /// 拷贝并更新当前爻（对齐 GuaYao.copyWith 签名，并保留元堂扩展字段）
  @override
  GuaYao copyWith({
    EnumYaoOrder? order,
    YinYang? yinYang,
    TianGan? naJia,
    DiZhi? naZhi,
    LiuQin? liuQin,
    Enum6Shou? sixShou,
    bool? isShiYao,
    bool? isYingYao,
  }) {
    final next = YuanTangYao(
      order: order ?? this.order,
      yinYang: yinYang ?? this.yinYang,
      yangTangZhiList: this.yangTangZhiList,
      isYuanTang: this.isYuanTang,
    );
    // 继承字段拷贝（保持与父类一致的行为）
    next.naJia = naJia ?? this.naJia;
    next.naZhi = naZhi ?? this.naZhi;
    next.sixShou = sixShou ?? this.sixShou;
    next.liuQin = liuQin ?? this.liuQin;
    next.isShiYao = isShiYao ?? this.isShiYao;
    next.isYingYao = isYingYao ?? this.isYingYao;
    return next;
  }

  /// 元堂扩展字段友好更新（不参与 override，避免签名冲突）
  YuanTangYao copyWithYuanTang({
    EnumYaoOrder? order,
    List<DiZhi>? yangTangZhiList,
    bool? isYuanTang,
    YinYang? yinYang,
    TianGan? naJia,
    DiZhi? naZhi,
    LiuQin? liuQin,
    bool? isShiYao,
    bool? isYingYao,
  }) {
    final next = YuanTangYao(
      order: this.order,
      yinYang: yinYang ?? this.yinYang,
      yangTangZhiList: yangTangZhiList ?? this.yangTangZhiList,
      isYuanTang: isYuanTang ?? this.isYuanTang,
    );
    next.naJia = naJia ?? this.naJia;
    next.naZhi = naZhi ?? this.naZhi;
    next.liuQin = liuQin ?? this.liuQin;
    next.isShiYao = isShiYao ?? this.isShiYao;
    next.isYingYao = isYingYao ?? this.isYingYao;
    return next;
  }

  @override
  String toString() {
    final diZhiStr = yangTangZhiList?.map((e) => e.name).join('、') ?? '';
    return 'YuanTangYao(yinYang: ${yinYang.name}, diZhi: [$diZhiStr], isYT: $isYuanTang)';
  }

  factory YuanTangYao.fromJson(Map<String, dynamic> json) =>
      _$YuanTangYaoFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangYaoToJson(this);

  @override
  List<Object?> get props => [
    isYuanTang,
    order,
    yinYang,
    naJia,
    naZhi,
    liuQin,
    isShiYao,
    isYingYao,
  ];
}

@JsonSerializable()
class PureYuanTangGua extends PureSixYaoGua {
  /// 元堂爻位（0..5, 0=初，5=上）
  // final int yuantangYaoIndex;
  final EnumYaoOrder yuanTangYao;

  /// 提供 YuanTangYao 类型化访问（底→顶）
  List<YuanTangYao> get yuanTangYaoList => super.yaoList.cast<YuanTangYao>();

  PureYuanTangGua({
    required Enum64Gua gua,
    required List<YuanTangYao> yaoList,
    required this.yuanTangYao,
  }) : super(gua: gua, yaoList: yaoList);

  /// 地支列表（上→下 / 下→上）
  List<List<DiZhi>> get topBottomDiZhiList =>
      yuanTangYaoList.reversed.map((e) => e.yangTangZhiList ?? []).toList();
  List<List<DiZhi>> get bottomTopDiZhiList =>
      yuanTangYaoList.map((e) => e.yangTangZhiList ?? []).toList();

  // 综卦、错卦、互卦、变爻等逻辑继承自 PureSixYaoGua

  PureYuanTangGua copyWithYuanTang({
    Enum64Gua? gua,
    List<YuanTangYao>? yaoList,
    EnumYaoOrder? yuanTangYao,
  }) {
    return PureYuanTangGua(
      gua: gua ?? this.gua,
      yaoList: yaoList ?? yuanTangYaoList,
      yuanTangYao: yuanTangYao ?? this.yuanTangYao,
    );
  }

  /// 获取爻位标签：0->初、1->二、...、5->上
  static String getYaoPositionLabel(int indexFromBottomZeroBased) {
    switch (indexFromBottomZeroBased) {
      case 0:
        return '初';
      case 1:
        return '二';
      case 2:
        return '三';
      case 3:
        return '四';
      case 4:
        return '五';
      case 5:
        return '上';
      default:
        throw ArgumentError('爻位索引越界，应为 0..5，当前: $indexFromBottomZeroBased');
    }
  }

  /// 由64卦构建（自下而上），并标注元堂爻
  factory PureYuanTangGua.from64Gua(Enum64Gua gua, EnumYaoOrder yuanTangYao) {
    List<YuanTangYao> yaoList = [];
    for (var i = 0; i < gua.bottomTopBinaryList.length; i++) {
      yaoList.add(
        YuanTangYao(
          yinYang: gua.bottomTopBinaryList[i] == 1 ? YinYang.YANG : YinYang.YIN,
          yangTangZhiList: [],
          isYuanTang: false,
          order: EnumYaoOrder.fromIndex(i),
        ),
      );
    }
    yaoList[yuanTangYao.indexAtYaoList].isYuanTang = true;

    return PureYuanTangGua(
      gua: gua,
      yaoList: yaoList,
      yuanTangYao: yuanTangYao,
    );
  }

  factory PureYuanTangGua.fromJson(Map<String, dynamic> json) =>
      _$PureYuanTangGuaFromJson(json);
  Map<String, dynamic> toJson() => _$PureYuanTangGuaToJson(this);
}

/// 元堂卦大运期间数据结构
///
/// 用于保存单个大运期间的详细信息
///
@JsonSerializable()
class YuanTangDaYunPeriod {
  final EnumYaoOrder order;

  /// 阴阳性（"阳" / "阴"）
  final YinYang yinYang;

  /// 年数（阳爻9年，阴爻6年）
  int get years => yinYang == YinYang.YANG ? 9 : 6;

  /// 起始年龄
  final int startAge;

  /// 结束年龄
  int get endAge => startAge + years - 1;

  /// 该爻配置的地支列表
  final List<DiZhi>? diZhiList;

  YuanTangDaYunPeriod({
    required this.order,
    required this.yinYang,
    required this.startAge,
    required this.diZhiList,
  });

  /// 年龄区间字符串（如 "1-6"）
  String get ageRange => '$startAge-$endAge';

  /// 复制并更新
  YuanTangDaYunPeriod copyWith({
    EnumYaoOrder? order,
    YinYang? yinYang,
    int? startAge,
    List<DiZhi>? diZhiList,
  }) {
    return YuanTangDaYunPeriod(
      order: order ?? this.order,
      yinYang: yinYang ?? this.yinYang,
      startAge: startAge ?? this.startAge,
      diZhiList: diZhiList ?? this.diZhiList,
    );
  }

  @override
  String toString() {
    final diZhiStr = diZhiList?.isEmpty ?? true ? '未配' : diZhiList!.join('、');
    return '${order.name}($yinYang-${years}年): $ageRange岁 [$diZhiStr]';
  }

  factory YuanTangDaYunPeriod.fromJson(Map<String, dynamic> json) =>
      _$YuanTangDaYunPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangDaYunPeriodToJson(this);
}

/// 元堂卦流年卦数据结构
///
/// 用于保存单个流年的详细信息
@JsonSerializable()
class YuanTangLiuYearGua {
  /// 虚岁年龄
  final int age;

  /// 在大运中的年份索引(0-8或0-5)
  final int yearIndex;

  /// 流年卦象(如"震坤")
  final Enum64Gua gua;

  /// 卦象来源("先天卦"/"后天卦")
  final String guaSource;

  /// 所属大运期
  final YuanTangDaYunPeriod dayunPeriod;

  /// 本年变换的爻位(-1表示未变换,如阳爻大运阳年起算的第1年)
  EnumYaoOrder changedYao;

  /// 上一年的卦象(第1年为null)
  final Enum64Gua? previousGua;

  YuanTangLiuYearGua({
    required this.age,
    required this.yearIndex,
    required this.gua,
    required this.guaSource,
    required this.dayunPeriod,
    required this.changedYao,
    this.previousGua,
  });

  /// 获取爻位标签
  String get yaoLabel {
    return changedYao.name;
  }

  /// 是否为大运首年
  bool get isFirstYearOfDayun => yearIndex == 0;

  /// 获取爻位标签(辅助方法)
  static String _getYaoPositionLabel(int index) {
    switch (index) {
      case 0:
        return '初';
      case 1:
        return '二';
      case 2:
        return '三';
      case 3:
        return '四';
      case 4:
        return '五';
      case 5:
        return '上';
      default:
        return '未知';
    }
  }

  /// 复制并更新
  YuanTangLiuYearGua copyWith({
    int? age,
    int? yearIndex,
    Enum64Gua? gua,
    String? guaSource,
    YuanTangDaYunPeriod? dayunPeriod,
    EnumYaoOrder? changedYao,
    Enum64Gua? previousGua,
  }) {
    return YuanTangLiuYearGua(
      age: age ?? this.age,
      yearIndex: yearIndex ?? this.yearIndex,
      gua: gua ?? this.gua,
      guaSource: guaSource ?? this.guaSource,
      dayunPeriod: dayunPeriod ?? this.dayunPeriod,
      changedYao: changedYao ?? this.changedYao,
      previousGua: previousGua ?? this.previousGua,
    );
  }

  @override
  String toString() {
    return '$age岁: $gua (${guaSource}卦, 变${yaoLabel}爻)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangLiuYearGua &&
        other.age == age &&
        other.yearIndex == yearIndex &&
        other.gua == gua &&
        other.guaSource == guaSource &&
        other.changedYao == changedYao &&
        other.previousGua == previousGua;
  }

  @override
  int get hashCode {
    return age.hashCode ^
        yearIndex.hashCode ^
        gua.hashCode ^
        guaSource.hashCode ^
        changedYao.hashCode ^
        (previousGua?.hashCode ?? 0);
  }

  factory YuanTangLiuYearGua.fromJson(Map<String, dynamic> json) =>
      _$YuanTangLiuYearGuaFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangLiuYearGuaToJson(this);
}

@JsonSerializable()
class YuanTangLiuMonthGua {
  /// 月份(1-12)
  final int month;

  /// 月份阴阳
  final bool isYangMonth;

  /// 流月卦象
  final Enum64Gua gua;

  /// 所属年龄
  final int age;

  /// 本月变换的爻位
  final EnumYaoOrder changedYaoIndex;

  /// 源卦(阴月取自对应阳月卦, 阳月取自上一个阳月卦或流年卦)
  final Enum64Gua? sourceGua;

  /// 应爻位置(仅阴月有效)
  final EnumYaoOrder? yingYaoIndex;

  const YuanTangLiuMonthGua({
    required this.month,
    required this.isYangMonth,
    required this.gua,
    required this.age,
    required this.changedYaoIndex,
    this.sourceGua,
    this.yingYaoIndex,
  });

  /// 获取爻位标签
  String get yaoLabel => _getYaoPositionLabel(changedYaoIndex);

  /// 获取月份类型标签
  String get monthTypeLabel => isYangMonth ? '阳月' : '阴月';

  /// 获取变化描述
  String get changeDescription {
    if (isYangMonth) {
      return '变${yaoLabel}爻';
    } else {
      final yingYaoLabel = _getYaoPositionLabel(yingYaoIndex!);
      return '由${month - 1}月卦应爻变换(变${yingYaoLabel}爻)';
    }
  }

  /// 获取爻位标签(辅助方法)
  static String _getYaoPositionLabel(EnumYaoOrder yao) {
    return yao.name;
  }

  /// 复制并更新
  YuanTangLiuMonthGua copyWith({
    int? month,
    bool? isYangMonth,
    Enum64Gua? gua,
    int? age,
    EnumYaoOrder? changedYaoIndex,
    Enum64Gua? sourceGua,
    int? yingYaoIndex,
  }) {
    return YuanTangLiuMonthGua(
      month: month ?? this.month,
      isYangMonth: isYangMonth ?? this.isYangMonth,
      gua: gua ?? this.gua,
      age: age ?? this.age,
      changedYaoIndex: changedYaoIndex ?? this.changedYaoIndex,
      sourceGua: sourceGua ?? this.sourceGua,
      yingYaoIndex: yingYaoIndex != null
          ? EnumYaoOrder.fromIndex(yingYaoIndex)
          : this.yingYaoIndex,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'isYangMonth': isYangMonth,
      'gua': gua,
      'age': age,
      'changedYaoIndex': changedYaoIndex,
      'sourceGua': sourceGua,
      'yingYaoIndex': yingYaoIndex,
    };
  }

  @override
  String toString() {
    return '$month月($monthTypeLabel): $gua - $changeDescription';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangLiuMonthGua &&
        other.month == month &&
        other.isYangMonth == isYangMonth &&
        other.gua == gua &&
        other.age == age &&
        other.changedYaoIndex == changedYaoIndex &&
        other.sourceGua == sourceGua &&
        other.yingYaoIndex == yingYaoIndex;
  }

  @override
  int get hashCode {
    return month.hashCode ^
        isYangMonth.hashCode ^
        gua.hashCode ^
        age.hashCode ^
        changedYaoIndex.hashCode ^
        (sourceGua?.hashCode ?? 0) ^
        (yingYaoIndex?.hashCode ?? 0);
  }

  factory YuanTangLiuMonthGua.fromJson(Map<String, dynamic> json) =>
      _$YuanTangLiuMonthGuaFromJson(json);

  Map<String, dynamic> toJson() => _$YuanTangLiuMonthGuaToJson(this);
}

// =====================
// 扩展：大运→流年、流年→流月
// =====================

extension YuanTangDaYunPeriodExt on YuanTangDaYunPeriod {
  /// 计算本大运期内的所有流年卦
  /// - [baseGua]: 基础卦（先天/后天）
  /// - [guaSource]: 卦象来源标识（如"先天卦"/"后天卦"）
  /// - [eightChars]: 八字，用于计算大运起始年的干支
  ///
  /// 说明：大运起始年干支 = 出生年干支 + (startAge - 1) 年的60甲子推移
  List<YuanTangLiuYearGua> calculateLiuYears({
    required Enum64Gua baseGua,
    required String guaSource,
    required EightChars eightChars,
  }) {
    final birthJiaZi = eightChars.year;
    final offset = startAge - 1;
    final daYunStartJiaZi = JiaZi.getByNumber(
      ((birthJiaZi.number - 1 + offset) % 60) + 1,
    );

    return YuanTangCalculator.calculateLiuYearForDayun(
      this,
      baseGua,
      guaSource,
      daYunStartJiaZi,
    );
  }
}

extension YuanTangLiuYearGuaExt on YuanTangLiuYearGua {
  /// 计算该流年对应的12个流月卦
  /// - [yuantangYaoIndex]: 元堂爻位置（0-5）
  /// - [isNextYaoStart]: 正月起始是否取“元堂后一爻”（默认 false=前一爻）
  List<YuanTangLiuMonthGua> calculateLiuMonths({
    required int yuantangYaoIndex,
    bool isNextYaoStart = false,
  }) {
    return YuanTangCalculator.calculateLiuMonthForAge(
      age,
      gua,
      yuantangYaoIndex,
      isNextYaoStart,
    );
  }
}
