import 'package:common/enums.dart';
import 'package:common/shared/enums/enum_di_zhi.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiebanshenshu/domain/pure_six_yao_gua.dart';

import '../constant/constants.dart' as Constants;
import '../utils/tiao_wen_calculator.dart';
import '../utils/utils.dart' as Utils;

part 'six_yao_gua.g.dart';

/// 六爻卦类
///
/// 用于表示完整的六爻卦象信息，包括卦名、爻位、干支、六亲等
///
@JsonSerializable()
class SixYaoGua {
  /// 本卦名 如：履、遁等
  final String benName;

  /// 卦象名 如："天泽" "天山"
  final String objectName;

  /// 八经卦名 如："乾兑" "乾艮"
  final String guaName;

  /// 世爻所在的爻位，从上爻->初爻 index:0->5
  final int shiYaoIndex;

  /// 应爻所在的爻位，从上爻->初爻 index:0->5
  final int yingYaoIndex;

  /// 卦所在的宫如 "坤宫" "乾宫"
  final String guaGong;

  /// 卦在宫内的编号名称如："五世" "二世"
  final String gongGuaName;

  /// 装订的六亲，从上爻->初爻 index:0->5
  final List<LiuQin> liuqinList;

  /// 装订的干支，从上爻->初爻 index:0->5
  final List<String> topBottomGanZhiList;
  List<String> get bottomTopGanZhiList {
    return List.generate(
      6,
      (i) => "${bottomTopGanList[i].name}${bottomTopZhiList[i].name}",
    );
  }

  List<TianGan> bottomTopGanList;
  List<TianGan> get topBottomGanList => bottomTopGanList.reversed.toList();
  List<DiZhi> bottomTopZhiList;
  List<DiZhi> get topBottomZhiList => bottomTopZhiList.reversed.toList();

  /// 卦的二进制编码，从上爻->初爻 index:0->5
  final List<int> binaryList;

  SixYaoGua({
    required this.benName,
    required this.objectName,
    required this.guaName,
    required this.shiYaoIndex,
    required this.yingYaoIndex,
    required this.guaGong,
    required this.gongGuaName,
    required this.liuqinList,
    required this.topBottomGanZhiList,
    required this.binaryList,
    required this.bottomTopGanList,
    required this.bottomTopZhiList,
  });

  @override
  String toString() {
    final List<String> resultList = [];
    for (int i = 0; i < 6; i++) {
      final int yaoBinary = binaryList[i];
      final String yaoYinYang = yaoBinary != 1
          ? Constants.yinYao
          : Constants.yangYao;
      String eachYaoStr =
          '${topBottomGanZhiList[i]} $yaoYinYang ${liuqinList[i]}';

      if (shiYaoIndex == i) {
        eachYaoStr += ' 世';
      } else if (yingYaoIndex == i) {
        eachYaoStr += ' 应';
      }
      resultList.add(eachYaoStr);
    }
    return resultList.join('\n');
  }

  /// 获取六亲爻位
  ///
  /// 警告：当有多个相同的六亲时，返回离"世爻"最近的一个
  ///
  /// 参数:
  ///   [targetName] 目标六亲名称
  ///
  /// 返回:
  ///   int 六亲爻位，-1 为未找到
  int getSixQinYaoIndex(String targetName) {
    int targetYaoIndex = -1;
    final List<int> targetYaoIndexList = [];

    for (int i = 0; i < 6; i++) {
      if (liuqinList[i] == targetName) {
        targetYaoIndexList.add(i);
      }
    }

    if (targetYaoIndexList.isEmpty) {
      return -1;
    }

    targetYaoIndex = targetYaoIndexList[0];

    if (targetYaoIndexList.length > 1) {
      // 当有多个父母爻时，计算每个父母爻与世爻的距离
      final List<int> distances = [];
      for (final int parentIndex in targetYaoIndexList) {
        final int distance = (parentIndex - shiYaoIndex).abs();
        distances.add(distance);
      }
      // 取距离世爻最近的父母爻索引
      final int minDistance = distances.reduce((a, b) => a < b ? a : b);
      final int minIndex = distances.indexOf(minDistance);
      targetYaoIndex = targetYaoIndexList[minIndex];
    }

    return targetYaoIndex;
  }

  /// 获取所有地支数字之和
  int get allZhiSum {
    int sum = 0;
    for (int i = 0; i < topBottomGanZhiList.length; i++) {
      final String zhi = topBottomGanZhiList[i].substring(
        topBottomGanZhiList[i].length - 1,
      );
      sum += Constants.dizhiNumberMapper[zhi] ?? 0;
    }
    return sum;
  }

  /// 通过加则法获取条文数
  int getTiaowenNumberByJiaze() {
    // 4. 计算条文
    final int tiaowenBaseNumber = TiaowenCalculator.calculateTiaowen(
      Enum8Gua.fromValue(guaName[0]),
      Enum8Gua.fromValue(guaName[1]),
      allZhiSum,
    );
    return tiaowenBaseNumber;
  }

  /// 根据干支生成完整的SixYaoGua数据类
  ///
  /// 参数:
  ///   [ganzhi] 干支字符串，如 "甲子"
  ///   [ganzhi2GuaFunc] 干支到卦象的转换函数
  ///
  /// 返回:
  ///   SixYaoGua 完整的六爻卦象数据类
  static SixYaoGua generateFromGanzhi(
    String ganzhi,
    String Function(String) ganzhi2GuaFunc,
  ) {
    // 1. 根据干支获得对应的卦象
    final String guaName = ganzhi2GuaFunc(ganzhi);
    return generateFromGua(guaName);
  }

  /// 根据卦名生成SixYaoGua
  ///
  /// 参数:
  ///   [guaName] 卦名字符串
  ///
  /// 返回:
  ///   SixYaoGua 完整的六爻卦象数据类
  static SixYaoGua generateFromGua(String guaName) {
    // 1. 获取本卦名（需要根据guaName查找对应的卦名）
    final String guaObjectName =
        Constants.guaName2ObjectName[guaName[0]]! +
        Constants.guaName2ObjectName[guaName[guaName.length - 1]]!;
    final String benName = Utils.getPureGuaNameByObject(
      guaObjectName[0],
      guaObjectName[guaObjectName.length - 1],
    );

    // 2. 拆分成二进制表示（从上而下，阳爻为1，阴爻为0）
    final Gua64Enum gua = Gua64Enum.getBy8Gua(
      Enum8Gua.fromValue(guaName[0]),
      Enum8Gua.fromValue(guaName[1]),
    );
    final List<int> binaryGua = Utils.guaToBinaryList(gua);

    // 3. 纳甲装卦 - 获取天干和地支
    final List<String> ganTop2BottomList = Utils.najiaGanZhuangGua(gua);
    final List<String> zhiTop2BottomList = Utils.najiaZhuangGua(gua);

    // 4. 构建每一爻的干支组合
    final List<String> yaoGanzhiList = [];
    for (int i = 0; i < binaryGua.length; i++) {
      final String yaoGanzhi = '${ganTop2BottomList[i]}${zhiTop2BottomList[i]}';
      yaoGanzhiList.add(yaoGanzhi);
    }

    // 5. 装六亲
    final List<LiuQin> liuqinList = Utils.liuqinZhuanggua(
      guaName,
      yaoGanzhiList,
    ).map((e) => LiuQin.getLiuQinBySingleName(e[0])).toList();

    // 6. 获取卦宫
    final String guaGong = Utils.getGuagongByBenname(benName);

    // 7. 获取八序（宫内编号）
    final String gongGuaName = Utils.getEightOrderByGuaname(benName);

    // 10. 计算世爻和应爻位置（根据八序确定）
    // 这里需要根据具体的世应规则来计算，暂时设置为默认值
    const int shiYaoIndex = 0; // 需要根据实际规则计算
    const int yingYaoIndex = 3; // 需要根据实际规则计算
    final List<TianGan> bottomTopGanList = yaoGanzhiList
        .map((e) => TianGan.getFromValue(e[0])!)
        .toList()
        .reversed
        .toList();
    final List<DiZhi> bottomTopZhiList = yaoGanzhiList
        .map((e) => DiZhi.getFromValue(e[1])!)
        .toList()
        .reversed
        .toList();

    // 11. 创建SixYaoGua实例
    return SixYaoGua(
      benName: benName,
      objectName: guaObjectName,
      guaName: guaName,
      shiYaoIndex: shiYaoIndex,
      yingYaoIndex: yingYaoIndex,
      guaGong: guaGong,
      gongGuaName: gongGuaName,
      liuqinList: liuqinList,
      topBottomGanZhiList: yaoGanzhiList,
      bottomTopGanList: bottomTopGanList,
      bottomTopZhiList: bottomTopZhiList,
      binaryList: binaryGua,
    );
  }

  /// 使用特殊天干函数生成SixYaoGua
  ///
  /// 同 generateFromGua，但是装卦时使用指定的天干：
  /// 如，传统的六爻装卦为"乾金甲子外壬午"，根据卦所处的内外位置配天干（generateFromGua）中使用的，
  /// 但也存在诸如《铁板神数·太玄取数一》中根据年柱阴阳，以及卦本身阴阳（四阳卦：乾震坎艮）确定
  /// 乾卦在阳年则取'壬'，阴年取'甲'，坤卦在阳年取'癸'，阴年取'乙'
  ///
  /// 参数:
  ///   [guaName] 卦名，如："乾艮" "坤坎"之类
  ///   [specialGanFunc] 特殊天干函数
  ///
  /// 返回:
  ///   SixYaoGua SixYaoGua实例
  static SixYaoGua generateFromGuaBySpecial(
    String guaName,
    List<String> Function(String) specialGanFunc,
  ) {
    // 1. 获取本卦名（需要根据guaName查找对应的卦名）
    final String guaObjectName =
        Constants.guaName2ObjectName[guaName[0]]! +
        Constants.guaName2ObjectName[guaName[guaName.length - 1]]!;
    final String benName = Utils.getPureGuaNameByObject(
      guaObjectName[0],
      guaObjectName[guaObjectName.length - 1],
    );

    // 2. 拆分成二进制表示（从上而下，阳爻为1，阴爻为0）
    Gua64Enum gua = Gua64Enum.getBy8Gua(
      Enum8Gua.fromValue(guaName[0]),
      Enum8Gua.fromValue(guaName[1]),
    );
    final List<int> binaryGua = Utils.guaToBinaryList(gua);

    // 3. 纳甲装卦 - 获取天干和地支
    final List<TianGan> ganTop2BottomList = specialGanFunc(
      guaName,
    ).map((e) => TianGan.getFromValue(e[0])!).toList();
    final List<DiZhi> zhiTop2BottomList = specialGanFunc(
      guaName,
    ).map((e) => DiZhi.getFromValue(e[1])!).toList();

    // 4. 构建每一爻的干支组合
    final List<String> yaoGanzhiList = [];
    for (int i = 0; i < binaryGua.length; i++) {
      final String yaoGanzhi = '${ganTop2BottomList[i]}${zhiTop2BottomList[i]}';
      yaoGanzhiList.add(yaoGanzhi);
    }

    // 5. 装六亲
    final List<LiuQin> liuqinList = Utils.liuqinZhuanggua(
      guaName,
      yaoGanzhiList,
    ).map((e) => LiuQin.getLiuQinBySingleName(e[0])).toList();

    // 6. 获取卦宫
    final String guaGong = Utils.getGuagongByBenname(benName);

    // 7. 获取八序（宫内编号）
    final String gongGuaName = Utils.getEightOrderByGuaname(benName);

    // 10. 计算世爻和应爻位置（根据八序确定）
    // 这里需要根据具体的世应规则来计算，暂时设置为默认值
    const int shiYaoIndex = 0; // 需要根据实际规则计算
    const int yingYaoIndex = 3; // 需要根据实际规则计算

    // 11. 创建SixYaoGua实例
    return SixYaoGua(
      benName: benName,
      objectName: guaObjectName,
      guaName: guaName,
      shiYaoIndex: shiYaoIndex,
      yingYaoIndex: yingYaoIndex,
      guaGong: guaGong,
      gongGuaName: gongGuaName,
      liuqinList: liuqinList,
      topBottomGanZhiList: yaoGanzhiList,
      binaryList: binaryGua,
      bottomTopGanList: ganTop2BottomList.reversed.toList(),
      bottomTopZhiList: zhiTop2BottomList.reversed.toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SixYaoGua &&
        other.benName == benName &&
        other.objectName == objectName &&
        other.guaName == guaName &&
        other.shiYaoIndex == shiYaoIndex &&
        other.yingYaoIndex == yingYaoIndex &&
        other.guaGong == guaGong &&
        other.gongGuaName == gongGuaName &&
        _listEquals(other.liuqinList, liuqinList) &&
        _listEquals(other.topBottomGanZhiList, topBottomGanZhiList) &&
        _listEquals(other.binaryList, binaryList);
  }

  @override
  int get hashCode {
    return Object.hash(
      benName,
      objectName,
      guaName,
      shiYaoIndex,
      yingYaoIndex,
      guaGong,
      gongGuaName,
      Object.hashAll(liuqinList),
      Object.hashAll(topBottomGanZhiList),
      Object.hashAll(binaryList),
    );
  }

  /// 辅助方法：比较两个列表是否相等
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 从JSON字符串创建SixYaoGua实例
  factory SixYaoGua.fromJson(Map<String, dynamic> json) =>
      _$SixYaoGuaFromJson(json);

  /// 将SixYaoGua实例转换为JSON字符串
  Map<String, dynamic> toJson() => _$SixYaoGuaToJson(this);

  // SixYaoGua yinYangNaJiaGan(
  //   YinYang yinYang,
  //   Map<Enum8Gua, List<TianGan>> yangGuaMapper,
  //   Map<Enum8Gua, List<TianGan>> yinGuaMapper,
  // ) {
  //   // 根据 给定的yinYang 确定纳甲
  //   if (yinYang.isYang) {
  //     bottomTopGanList = yangGuaMapper[Enum8Gua.getFromValue(benName[0])]!;
  //   } else {
  //     bottomTopGanList = yinGuaMapper[Enum8Gua.getFromValue(benName[0])]!;
  //   }
  // }

  /// 根据双经卦名进行纳甲，安装“天干”。
  /// 返回一个从上爻到初爻的6元素天干列表。
  SixYaoGua sixYaoNaJiaGan(
    Map<Enum8Gua, List<TianGan>> uponGuaMapper,
    Map<Enum8Gua, List<TianGan>> underGuaMapper,
  ) {
    // // 上卦天干映射表
    // Map<String, List<String>> uponGuaMapper = {
    //   "乾": ["壬", "壬", "壬"],
    //   "兑": ["丁", "丁", "丁"],
    //   "离": ["己", "己", "己"],
    //   "震": ["庚", "庚", "庚"],
    //   "巽": ["辛", "辛", "辛"],
    //   "坎": ["戊", "戊", "戊"],
    //   "艮": ["丙", "丙", "丙"],
    //   "坤": ["癸", "癸", "癸"],
    // };

    // // 下卦天干映射表
    // final Map<String, List<String>> underGuaMapper = {
    //   "乾": ["甲", "甲", "甲"],
    //   "兑": ["丁", "丁", "丁"],
    //   "离": ["己", "己", "己"],
    //   "震": ["庚", "庚", "庚"],
    //   "巽": ["辛", "辛", "辛"],
    //   "坎": ["戊", "戊", "戊"],
    //   "艮": ["丙", "丙", "丙"],
    //   "坤": ["乙", "乙", "乙"],
    // };

    final uponGua = guaName.substring(0, 1);
    final underGua = guaName.substring(1, 2);

    // 将上卦和下卦的天干合并成一个数组，从上爻到下爻
    final uponGan = uponGuaMapper[uponGua]!;
    final underGan = underGuaMapper[underGua]!;
    final bottomToUpList = [...uponGan, ...underGan].reversed.toList();
    bottomTopGanList = bottomToUpList;
    return this;

    // return [...uponGan, ...underGan];
  }

  /// 返回一个从上爻到初爻的6元素地支列表。
  SixYaoGua sixYaoNaZhi(
    Map<Enum8Gua, List<DiZhi>> uponGuaMapper,
    Map<Enum8Gua, List<DiZhi>> underGuaMapper,
  ) {
    final uponGua = guaName.substring(0, 1);
    final underGua = guaName.substring(1, 2);

    // 将上卦和下卦的地支字符串合并成一个数组，从上爻到下爻
    final uponZhi = uponGuaMapper[uponGua]!;
    final underZhi = underGuaMapper[underGua]!;
    bottomTopZhiList = [...underZhi, ...uponZhi];

    return this;
  }
}
