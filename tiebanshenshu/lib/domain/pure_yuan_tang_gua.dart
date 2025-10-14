import 'package:common/enums.dart';

import 'pure_six_yao_gua.dart';

/// 元堂卦的“纯数据”模型，结构对齐 PureSixYaoGua：
/// - 保留 `gua`、`topGua`、`bottomGua`
/// - 提供 `yaoList`（自下而上：初→上），包含阴阳与地支列表、元堂标记
/// - 暴露与六爻一致的派生属性与便捷方法（binary、互卦、错卦、综卦、单爻变卦等）
class YuanTangYao {
  final YinYang yinYang;
  final List<DiZhi> diZhiList; // 该爻对应的地支列表（元堂卦可多支）
  final bool isYuanTang; // 是否为元堂爻

  const YuanTangYao({
    required this.yinYang,
    required this.diZhiList,
    required this.isYuanTang,
  });

  YuanTangYao copyWith({
    YinYang? yinYang,
    List<DiZhi>? diZhiList,
    bool? isYuanTang,
  }) {
    return YuanTangYao(
      yinYang: yinYang ?? this.yinYang,
      diZhiList: diZhiList ?? this.diZhiList,
      isYuanTang: isYuanTang ?? this.isYuanTang,
    );
  }

  @override
  String toString() {
    final diZhiStr = diZhiList.map((e) => e.name).join('、');
    return 'YuanTangYao(yinYang: ${yinYang == YinYang.YANG ? '阳' : '阴'}, diZhi: [$diZhiStr], isYT: $isYuanTang)';
  }
}

class PureYuanTangGua {
  final Gua64Enum gua;
  final Enum8Gua topGua;
  final Enum8Gua bottomGua;

  /// 自下而上（初→上）
  final List<YuanTangYao> yaoList;

  /// 元堂爻位（0..5, 0=初，5=上）
  final int yuantangYaoIndex;

  const PureYuanTangGua({
    required this.gua,
    required this.topGua,
    required this.bottomGua,
    required this.yaoList,
    required this.yuantangYaoIndex,
  });

  /// 上爻→下爻视角
  List<YuanTangYao> get topBottomYaoList => yaoList.reversed.toList();

  /// 阴阳二进制（自下而上）
  String get binStr =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? '0' : '1').join('');
  List<int> get binaryList =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? 0 : 1).toList();

  /// 地支列表（上→下 / 下→上）
  List<List<DiZhi>> get bottomTopDiZhiList =>
      topBottomYaoList.map((e) => e.diZhiList).toList();
  List<List<DiZhi>> get topBottomDiZhiList =>
      bottomTopDiZhiList.reversed.toList();

  /// 综卦：六爻倒置
  Gua64Enum get zong {
    final newBinaryList = binaryList.reversed.toList();
    return Gua64Enum.fromBinaryList(newBinaryList);
  }

  /// 错卦：阴阳全翻转
  Gua64Enum get cuo {
    final newBinaryList = binaryList.map((e) => e == 0 ? 1 : 0).toList();
    return Gua64Enum.fromBinaryList(newBinaryList);
  }

  /// 后天卦：对元堂爻进行爻变后，上下卦互换
  /// 说明：此为通用规则实现（爻变 + 互换上下卦）。
  /// 若需至尊卦在九五/上六的按月阴阳互换特例，可在上层根据月份扩展。
  Gua64Enum get hou {
    // 自下而上二进制拷贝并在元堂位执行爻变
    final changed = List<int>.from(binaryList);
    changed[yuantangYaoIndex] = changed[yuantangYaoIndex] == 0 ? 1 : 0;

    // 拆分上下卦（自下而上：0..2为下卦，3..5为上卦）
    final lowerBinStr = changed.sublist(0, 3).join('');
    final upperBinStr = changed.sublist(3, 6).join('');

    final oldLower = Enum8Gua.fromBottomTopBinaryStr(lowerBinStr);
    final oldUpper = Enum8Gua.fromBottomTopBinaryStr(upperBinStr);

    // 上下卦互换得到后天卦
    return Gua64Enum.getBy8Gua(oldLower, oldUpper);
  }

  /// 互卦：取2,3,4 与 3,4,5 形成新上下卦
  Gua64Enum get hu {
    final downBinStr = binaryList.sublist(1, 4).join('');
    final upBinStr = binaryList.sublist(2, 5).join('');
    final downGua = Enum8Gua.fromBottomTopBinaryStr(downBinStr);
    final upGua = Enum8Gua.fromBottomTopBinaryStr(upBinStr);
    return Gua64Enum.getBy8Gua(upGua, downGua);
  }

  /// 单爻变卦：按自下而上编号（1..6）进行阴阳翻转
  Gua64Enum bianYaoByOrder(int yaoOrder) {
    if (yaoOrder < 1 || yaoOrder > 6) {
      throw ArgumentError('变爻编号越界，应为 1..6，当前: $yaoOrder');
    }
    final indexFromBottomZeroBased = yaoOrder - 1;
    final newBinary = List<int>.from(binaryList);
    newBinary[indexFromBottomZeroBased] =
        newBinary[indexFromBottomZeroBased] == 0 ? 1 : 0;
    return Gua64Enum.fromBinaryList(newBinary);
  }

  /// 变卦候选映射（含互卦 + 变初..变上）
  Map<String, Gua64Enum> changedVariantsWithLabels() {
    final variants = <String, Gua64Enum>{};
    variants['互卦'] = hu;
    for (int i = 0; i < 6; i++) {
      final label = getYaoPositionLabel(i);
      variants['变${label}爻'] = bianYaoByOrder(i + 1);
    }
    return variants;
  }

  PureYuanTangGua copyWith({
    Gua64Enum? gua,
    Enum8Gua? topGua,
    Enum8Gua? bottomGua,
    List<YuanTangYao>? yaoList,
    int? yuantangYaoIndex,
  }) {
    return PureYuanTangGua(
      gua: gua ?? this.gua,
      topGua: topGua ?? this.topGua,
      bottomGua: bottomGua ?? this.bottomGua,
      yaoList: yaoList ?? this.yaoList,
      yuantangYaoIndex: yuantangYaoIndex ?? this.yuantangYaoIndex,
    );
  }

  /// 由64卦 + 地支字符串列表构建（自下而上），并标注元堂爻
  factory PureYuanTangGua.fromStrings({
    required Gua64Enum gua,
    required List<List<String>> zhiListBottomToTop,
    required int yuantangYaoIndex,
  }) {
    final top = gua.top;
    final bottom = gua.bottom;
    final base = PureSixYaoGua.by8Gua(top, bottom);

    if (zhiListBottomToTop.length != 6) {
      throw ArgumentError('地支列表长度必须为6');
    }

    final yaoList = <YuanTangYao>[];
    for (int i = 0; i < 6; i++) {
      final yinYang = base.yaoList[i].yinYang;
      final diZhiList = zhiListBottomToTop[i]
          .map((e) => DiZhi.values.firstWhere((d) => d.name == e))
          .toList();
      yaoList.add(
        YuanTangYao(
          yinYang: yinYang,
          diZhiList: diZhiList,
          isYuanTang: i == yuantangYaoIndex,
        ),
      );
    }

    return PureYuanTangGua(
      gua: gua,
      topGua: top,
      bottomGua: bottom,
      yaoList: yaoList,
      yuantangYaoIndex: yuantangYaoIndex,
    );
  }

  /// 由64卦 + 地支枚举列表构建（自下而上），并标注元堂爻
  factory PureYuanTangGua.fromEnums({
    required Gua64Enum gua,
    required List<List<DiZhi>> zhiListBottomToTop,
    required int yuantangYaoIndex,
  }) {
    final top = gua.top;
    final bottom = gua.bottom;
    final base = PureSixYaoGua.by8Gua(top, bottom);

    if (zhiListBottomToTop.length != 6) {
      throw ArgumentError('地支列表长度必须为6');
    }

    final yaoList = <YuanTangYao>[];
    for (int i = 0; i < 6; i++) {
      final yinYang = base.yaoList[i].yinYang;
      final diZhiList = zhiListBottomToTop[i];
      yaoList.add(
        YuanTangYao(
          yinYang: yinYang,
          diZhiList: diZhiList,
          isYuanTang: i == yuantangYaoIndex,
        ),
      );
    }

    return PureYuanTangGua(
      gua: gua,
      topGua: top,
      bottomGua: bottom,
      yaoList: yaoList,
      yuantangYaoIndex: yuantangYaoIndex,
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
}