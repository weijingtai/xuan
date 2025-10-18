import 'package:common/enums.dart';
import '../../../constant/constants.dart';
import '../../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../models/liu_qin_type.dart';

/// 纳甲六亲结果
///
/// 包含完整的纳甲装配和六亲关系信息
class NaJiaLiuQinResult {
  /// 装配好纳甲和六亲的六爻卦
  final PureSixYaoGua sixYaoGua;

  /// 世爻位置（0-5，从下往上）
  final int shiYaoIndex;

  /// 应爻位置（0-5，从下往上）
  final int yingYaoIndex;

  /// 宫卦
  final Enum8Gua gongGua;

  /// 宫序（0-7：本卦、一世、二世、三世、四世、五世、游魂、归魂）
  final int gongXu;

  const NaJiaLiuQinResult({
    required this.sixYaoGua,
    required this.shiYaoIndex,
    required this.yingYaoIndex,
    required this.gongGua,
    required this.gongXu,
  });

  /// 获取世爻
  GuaYao get shiYao => sixYaoGua.yaoList[shiYaoIndex];

  /// 获取应爻
  GuaYao get yingYao => sixYaoGua.yaoList[yingYaoIndex];

  @override
  String toString() {
    return '纳甲六亲结果:\n'
        '  卦: ${sixYaoGua.gua.name}\n'
        '  宫: ${gongGua.name}宫 (${gongGuaName[gongXu]})\n'
        '  世爻: ${shiYao.order.name}爻 (${shiYao.ganZhi?.name})\n'
        '  应爻: ${yingYao.order.name}爻 (${yingYao.ganZhi?.name})';
  }
}

/// 纳甲六亲助手类
///
/// 实现六爻卦的纳甲装配和六亲定位功能
class NaJiaLiuQinHelper {
  /// 装配纳甲和六亲
  ///
  /// [gua64] 64卦
  /// [dayGan] 日干（用于定六亲）
  ///
  /// 返回完整的纳甲六亲结果
  static NaJiaLiuQinResult installNaJiaAndLiuQin(
    Enum64Gua gua64,
    TianGan dayGan,
  ) {
    // 1. 创建基础六爻卦
    final sixYaoGua = PureSixYaoGua.by8Gua(gua64.top, gua64.bottom);

    // 2. 确定归宫和宫序
    final gongInfo = _findGongGua(gua64);
    final gongGua = gongInfo['gongGua'] as Enum8Gua;
    final gongXu = gongInfo['gongXu'] as int;

    // 3. 确定世爻和应爻位置
    final shiYaoIndex = shiYao[gongXu]; // 从constants.dart
    final yingYaoIndex = yiYao[gongXu]; // 从constants.dart

    // 4. 装纳甲（天干和地支）
    _installNaJia(sixYaoGua, gongGua);

    // 5. 标记世爻和应爻
    sixYaoGua.yaoList[shiYaoIndex].isShiYao = true;
    sixYaoGua.yaoList[yingYaoIndex].isYingYao = true;

    // 6. 定六亲
    _installLiuQin(sixYaoGua, dayGan);

    return NaJiaLiuQinResult(
      sixYaoGua: sixYaoGua,
      shiYaoIndex: shiYaoIndex,
      yingYaoIndex: yingYaoIndex,
      gongGua: gongGua,
      gongXu: gongXu,
    );
  }

  /// 查找父母爻
  ///
  /// [result] 纳甲六亲结果
  /// [liuQinType] 六亲类型（决定以世爻还是应爻为参考）
  ///
  /// 返回离世爻（或应爻）最近的父母爻
  static GuaYao? findTargetYao(
    NaJiaLiuQinResult result,
    LiuQinType liuQinType,
  ) {
    // 确定参考爻位
    final referenceIndex = liuQinType.isSpouse
        ? result.yingYaoIndex  // 考夫妻以应爻为参考
        : result.shiYaoIndex;  // 其他以世爻为参考

    // 确定目标六亲类型
    final targetLiuQin = _liuQinTypeToEnum(liuQinType);

    // 找出所有符合目标六亲的爻
    final candidates = <int, GuaYao>{};
    for (int i = 0; i < result.sixYaoGua.yaoList.length; i++) {
      final yao = result.sixYaoGua.yaoList[i];
      if (yao.liuQin == targetLiuQin) {
        candidates[i] = yao;
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    // 找出离参考爻最近的一个
    int closestIndex = candidates.keys.first;
    int minDistance = (closestIndex - referenceIndex).abs();

    for (final index in candidates.keys) {
      final distance = (index - referenceIndex).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = index;
      }
    }

    return candidates[closestIndex];
  }

  /// 确定卦属于哪个宫
  static Map<String, dynamic> _findGongGua(Enum64Gua gua64) {
    for (final entry in eightGongGuaListMapper.entries) {
      final gongGua = entry.key;
      final guaList = entry.value;

      for (int i = 0; i < guaList.length; i++) {
        if (guaList[i] == gua64) {
          return {
            'gongGua': gongGua,
            'gongXu': i,
          };
        }
      }
    }

    throw Exception('未找到卦 ${gua64.name} 的归宫信息');
  }

  /// 装纳甲（天干地支）
  static void _installNaJia(PureSixYaoGua sixYaoGua, Enum8Gua gongGua) {
    // 获取内卦和外卦的纳甲配置
    final innerGanList = innerGuaYaoTianGan[sixYaoGua.bottomGua]!;
    final innerZhiList = innerGuaYaoDiZhi[sixYaoGua.bottomGua]!;
    final outerGanList = outerGuaYaoTianGan[sixYaoGua.topGua]!;
    final outerZhiList = outerGuaYaoDiZhi[sixYaoGua.topGua]!;

    // 装配内卦（初、二、三爻）
    for (int i = 0; i < 3; i++) {
      sixYaoGua.yaoList[i].naJia = innerGanList[i];
      sixYaoGua.yaoList[i].naZhi = innerZhiList[i];
    }

    // 装配外卦（四、五、上爻）
    for (int i = 0; i < 3; i++) {
      sixYaoGua.yaoList[i + 3].naJia = outerGanList[i];
      sixYaoGua.yaoList[i + 3].naZhi = outerZhiList[i];
    }
  }

  /// 定六亲
  static void _installLiuQin(PureSixYaoGua sixYaoGua, TianGan dayGan) {
    // 获取日干五行
    final dayGanWuXing = dayGan.fiveXing;

    // 为每个爻定六亲
    for (final yao in sixYaoGua.yaoList) {
      if (yao.naZhi == null) continue;

      // 获取爻支的五行
      final yaoZhiWuXing = yao.naZhi!.fiveXing;

      // 根据五行生克关系确定六亲
      yao.liuQin = fiveXingSixQingMapper[dayGanWuXing]![yaoZhiWuXing];
    }
  }

  /// 将LiuQinType转换为LiuQin枚举
  static LiuQin _liuQinTypeToEnum(LiuQinType type) {
    switch (type) {
      case LiuQinType.father:
      case LiuQinType.mother:
        return LiuQin.FU_MU; // 父母
      case LiuQinType.wife:
      case LiuQinType.husband:
        return LiuQin.QI_CAI; // 妻财（考夫妻）
      case LiuQinType.sibling:
        return LiuQin.XIONG_DI; // 兄弟
      case LiuQinType.son:
      case LiuQinType.daughter:
        return LiuQin.ZI_SUN; // 子孙
    }
  }

  /// 获取爻的地支
  static DiZhi? getYaoZhi(GuaYao yao) {
    return yao.naZhi;
  }

  /// 获取爻的干支
  static JiaZi? getYaoGanZhi(GuaYao yao) {
    return yao.ganZhi;
  }
}
