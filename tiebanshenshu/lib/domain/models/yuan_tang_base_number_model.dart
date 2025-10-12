/// 元堂卦取数法基础数模型
///
/// 保存元堂卦取数法的完整计算过程和中间结果
library;

import '../../domain/four_zhu.dart';
import '../../constant/constants.dart' as constants;
import 'base_number_model.dart';

/// 元堂爻详情模型
///
/// 用于保存单个爻的详细信息
class YuanTangYaoDetail {
  /// 爻位（0-5，对应初、二、三、四、五、上）
  final int position;

  /// 爻位标签（"初" / "二" / "三" / "四" / "五" / "上"）
  final String positionLabel;

  /// 阴阳性（"阳" / "阴"）
  final String yinYang;

  /// 配上的地支列表（可能有多个地支）
  final List<String> diZhiList;

  /// 是否为元堂爻
  final bool isYuanTangYao;

  const YuanTangYaoDetail({
    required this.position,
    required this.positionLabel,
    required this.yinYang,
    required this.diZhiList,
    required this.isYuanTangYao,
  });

  /// 复制并更新
  YuanTangYaoDetail copyWith({
    int? position,
    String? positionLabel,
    String? yinYang,
    List<String>? diZhiList,
    bool? isYuanTangYao,
  }) {
    return YuanTangYaoDetail(
      position: position ?? this.position,
      positionLabel: positionLabel ?? this.positionLabel,
      yinYang: yinYang ?? this.yinYang,
      diZhiList: diZhiList ?? this.diZhiList,
      isYuanTangYao: isYuanTangYao ?? this.isYuanTangYao,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'positionLabel': positionLabel,
      'yinYang': yinYang,
      'diZhiList': diZhiList,
      'isYuanTangYao': isYuanTangYao,
    };
  }

  @override
  String toString() {
    final diZhiStr = diZhiList.isEmpty ? '未配' : diZhiList.join('、');
    final yuanTangMark = isYuanTangYao ? '★' : '';
    return '$yuanTangMark$positionLabel爻($yinYang): $diZhiStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangYaoDetail &&
        other.position == position &&
        other.positionLabel == positionLabel &&
        other.yinYang == yinYang &&
        _listEquals(other.diZhiList, diZhiList) &&
        other.isYuanTangYao == isYuanTangYao;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        positionLabel.hashCode ^
        yinYang.hashCode ^
        diZhiList.hashCode ^
        isYuanTangYao.hashCode;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 元堂卦大运期间数据结构
///
/// 用于保存单个大运期间的详细信息
class YuanTangDayunPeriod {
  /// 爻位（0-5，对应初、二、三、四、五、上）
  final int yaoPosition;

  /// 爻位标签（"初" / "二" / "三" / "四" / "五" / "上"）
  final String yaoLabel;

  /// 阴阳性（"阳" / "阴"）
  final String yinYang;

  /// 年数（阳爻9年，阴爻6年）
  final int years;

  /// 起始年龄
  final int startAge;

  /// 结束年龄
  final int endAge;

  /// 该爻配置的地支列表
  final List<String> diZhiList;

  const YuanTangDayunPeriod({
    required this.yaoPosition,
    required this.yaoLabel,
    required this.yinYang,
    required this.years,
    required this.startAge,
    required this.endAge,
    required this.diZhiList,
  });

  /// 年龄区间字符串（如 "1-6"）
  String get ageRange => '$startAge-$endAge';

  /// 复制并更新
  YuanTangDayunPeriod copyWith({
    int? yaoPosition,
    String? yaoLabel,
    String? yinYang,
    int? years,
    int? startAge,
    int? endAge,
    List<String>? diZhiList,
  }) {
    return YuanTangDayunPeriod(
      yaoPosition: yaoPosition ?? this.yaoPosition,
      yaoLabel: yaoLabel ?? this.yaoLabel,
      yinYang: yinYang ?? this.yinYang,
      years: years ?? this.years,
      startAge: startAge ?? this.startAge,
      endAge: endAge ?? this.endAge,
      diZhiList: diZhiList ?? this.diZhiList,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'yaoPosition': yaoPosition,
      'yaoLabel': yaoLabel,
      'yinYang': yinYang,
      'years': years,
      'startAge': startAge,
      'endAge': endAge,
      'diZhiList': diZhiList,
    };
  }

  @override
  String toString() {
    final diZhiStr = diZhiList.isEmpty ? '未配' : diZhiList.join('、');
    return '$yaoLabel爻($yinYang-${years}年): $ageRange岁 [$diZhiStr]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangDayunPeriod &&
        other.yaoPosition == yaoPosition &&
        other.yaoLabel == yaoLabel &&
        other.yinYang == yinYang &&
        other.years == years &&
        other.startAge == startAge &&
        other.endAge == endAge &&
        _listEquals(other.diZhiList, diZhiList);
  }

  @override
  int get hashCode {
    return yaoPosition.hashCode ^
        yaoLabel.hashCode ^
        yinYang.hashCode ^
        years.hashCode ^
        startAge.hashCode ^
        endAge.hashCode ^
        diZhiList.hashCode;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 元堂卦基础数模型
///
/// 继承自BaseNumberModel，包含元堂卦取数法的完整计算过程信息
class YuanTangBaseNumberModel extends BaseNumberModel {
  // ========== 输入参数 ==========
  /// 四柱信息
  final FourZhu fourZhu;

  /// 性别（"男" / "女"）
  final String gender;

  /// 三元（"上" / "中" / "下"）
  final String threeYuan;

  /// 出生节气（"夏至" / "冬至"）
  final String birthAfterZhi;

  // ========== 步骤1：生成天地卦 ==========
  /// 四柱天干数列表 [年干数, 月干数, 日干数, 时干数]
  final List<int> ganNumList;

  /// 四柱地支数列表（每个地支配两个数）[[年支数1,年支数2], [月支数1,月支数2], ...]
  final List<List<int>> zhiNumList;

  /// 奇数总和
  final int oddNumTotal;

  /// 偶数总和
  final int evenNumTotal;

  /// 天数（奇数和处理后，模25）
  final int tianGuaNum;

  /// 地数（偶数和处理后，模30）
  final int diGuaNum;

  /// 天卦名称
  final String tianGua;

  /// 地卦名称
  final String diGua;

  /// 是否使用三元五宫（天数或地数为5时）
  final bool usedThreeYuanWuGong;

  // ========== 步骤2：生成上下卦（先天卦） ==========
  /// 年份阴阳（"阳" / "阴"）
  final String yearYinYang;

  /// 上卦（先天卦上部）
  final String upperGua;

  /// 下卦（先天卦下部）
  final String lowerGua;

  /// 先天卦（上卦+下卦）
  final String xiantianGua;

  /// 先天卦后天数（上卦后天数）
  final int xiantianUpperGuaNumber;

  /// 先天卦后天数（下卦后天数）
  final int xiantianLowerGuaNumber;

  // ========== 步骤3：元堂装卦（先天卦） ==========
  /// 时柱干支
  final String timeGanzhi;

  /// 时辰阴阳（"阳" / "阴"）
  final String timeYinYang;

  /// 卦中阳爻总数
  final int totalYangYao;

  /// 卦中阴爻总数
  final int totalYinYao;

  /// 六爻地支列表（从下到上：初、二、三、四、五、上）
  final List<List<String>> zhiList;

  /// 元堂爻索引（0-5）
  final int yuantangYaoIndex;

  /// 元堂爻位标签
  final String yuantangYaoLabel;

  // ========== 步骤4：生成后天卦 ==========
  /// 后天卦（元堂爻爻变后，上下卦互换）
  final String houtianGua;

  /// 后天卦后天数（上卦后天数）
  final int houtianUpperGuaNumber;

  /// 后天卦后天数（下卦后天数）
  final int houtianLowerGuaNumber;

  // ========== 步骤4.5：后天卦元堂装卦 ==========
  /// 后天卦六爻地支列表（从下到上：初、二、三、四、五、上）
  final List<List<String>> houtianZhiList;

  /// 后天卦元堂爻索引（0-5）
  final int houtianYuantangYaoIndex;

  /// 后天卦元堂爻位标签
  final String houtianYuantangYaoLabel;

  // ========== 步骤5：互卦 ==========
  /// 先天卦互卦
  final String xiantianGuaHu;

  /// 后天卦互卦
  final String houtianGuaHu;

  // ========== 步骤6：大运计算 ==========
  /// 先天卦大运起始年龄
  final int xiantianDayunStartAge;

  /// 先天卦大运列表（6个期间）
  final List<YuanTangDayunPeriod> xiantianDayunList;

  /// 后天卦大运起始年龄
  final int houtianDayunStartAge;

  /// 后天卦大运列表（6个期间）
  final List<YuanTangDayunPeriod> houtianDayunList;

  // ========== 最终条文编号（不同方法） ==========
  /// 先天卦加则法条文编号
  final int tiaowenNumberJiazeXiantiangua;

  /// 后天卦加则法条文编号
  final int tiaowenNumberJiazeHoutiangua;

  /// 先天卦纳甲太玄数条文编号
  final int tiaowenNumberNajiaTaixuanXiantiangua;

  /// 后天卦纳甲太玄数条文编号
  final int tiaowenNumberNajiaTaixuanHoutiangua;

  /// 先天卦本互条文编号
  final int tiaowenNumberXiantianBenhu;

  /// 后天卦本互条文编号
  final int tiaowenNumberHoutianBenhu;

  /// 先天卦互取数列表
  final List<int> tiaowenNumberListXiantianGuahu;

  /// 后天卦互取数列表
  final List<int> tiaowenNumberListHoutianGuahu;

  const YuanTangBaseNumberModel({
    // 继承自BaseNumberModel的字段
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    // 输入参数
    required this.fourZhu,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    // 步骤1：生成天地卦
    required this.ganNumList,
    required this.zhiNumList,
    required this.oddNumTotal,
    required this.evenNumTotal,
    required this.tianGuaNum,
    required this.diGuaNum,
    required this.tianGua,
    required this.diGua,
    required this.usedThreeYuanWuGong,
    // 步骤2：生成上下卦
    required this.yearYinYang,
    required this.upperGua,
    required this.lowerGua,
    required this.xiantianGua,
    required this.xiantianUpperGuaNumber,
    required this.xiantianLowerGuaNumber,
    // 步骤3：元堂装卦（先天卦）
    required this.timeGanzhi,
    required this.timeYinYang,
    required this.totalYangYao,
    required this.totalYinYao,
    required this.zhiList,
    required this.yuantangYaoIndex,
    required this.yuantangYaoLabel,
    // 步骤4：生成后天卦
    required this.houtianGua,
    required this.houtianUpperGuaNumber,
    required this.houtianLowerGuaNumber,
    // 步骤4.5：后天卦元堂装卦
    required this.houtianZhiList,
    required this.houtianYuantangYaoIndex,
    required this.houtianYuantangYaoLabel,
    // 步骤5：互卦
    required this.xiantianGuaHu,
    required this.houtianGuaHu,
    // 步骤6：大运计算
    required this.xiantianDayunStartAge,
    required this.xiantianDayunList,
    required this.houtianDayunStartAge,
    required this.houtianDayunList,
    // 最终条文编号
    required this.tiaowenNumberJiazeXiantiangua,
    required this.tiaowenNumberJiazeHoutiangua,
    required this.tiaowenNumberNajiaTaixuanXiantiangua,
    required this.tiaowenNumberNajiaTaixuanHoutiangua,
    required this.tiaowenNumberXiantianBenhu,
    required this.tiaowenNumberHoutianBenhu,
    required this.tiaowenNumberListXiantianGuahu,
    required this.tiaowenNumberListHoutianGuahu,
  });

  /// 创建工厂方法
  factory YuanTangBaseNumberModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required FourZhu fourZhu,
    required String gender,
    required String threeYuan,
    required String birthAfterZhi,
    required List<int> ganNumList,
    required List<List<int>> zhiNumList,
    required int oddNumTotal,
    required int evenNumTotal,
    required int tianGuaNum,
    required int diGuaNum,
    required String tianGua,
    required String diGua,
    required bool usedThreeYuanWuGong,
    required String yearYinYang,
    required String upperGua,
    required String lowerGua,
    required String xiantianGua,
    required int xiantianUpperGuaNumber,
    required int xiantianLowerGuaNumber,
    required String timeGanzhi,
    required String timeYinYang,
    required int totalYangYao,
    required int totalYinYao,
    required List<List<String>> zhiList,
    required int yuantangYaoIndex,
    required String yuantangYaoLabel,
    required String houtianGua,
    required int houtianUpperGuaNumber,
    required int houtianLowerGuaNumber,
    required List<List<String>> houtianZhiList,
    required int houtianYuantangYaoIndex,
    required String houtianYuantangYaoLabel,
    required String xiantianGuaHu,
    required String houtianGuaHu,
    required int xiantianDayunStartAge,
    required List<YuanTangDayunPeriod> xiantianDayunList,
    required int houtianDayunStartAge,
    required List<YuanTangDayunPeriod> houtianDayunList,
    required int tiaowenNumberJiazeXiantiangua,
    required int tiaowenNumberJiazeHoutiangua,
    required int tiaowenNumberNajiaTaixuanXiantiangua,
    required int tiaowenNumberNajiaTaixuanHoutiangua,
    required int tiaowenNumberXiantianBenhu,
    required int tiaowenNumberHoutianBenhu,
    required List<int> tiaowenNumberListXiantianGuahu,
    required List<int> tiaowenNumberListHoutianGuahu,
  }) {
    return YuanTangBaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      fourZhu: fourZhu,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      ganNumList: ganNumList,
      zhiNumList: zhiNumList,
      oddNumTotal: oddNumTotal,
      evenNumTotal: evenNumTotal,
      tianGuaNum: tianGuaNum,
      diGuaNum: diGuaNum,
      tianGua: tianGua,
      diGua: diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong,
      yearYinYang: yearYinYang,
      upperGua: upperGua,
      lowerGua: lowerGua,
      xiantianGua: xiantianGua,
      xiantianUpperGuaNumber: xiantianUpperGuaNumber,
      xiantianLowerGuaNumber: xiantianLowerGuaNumber,
      timeGanzhi: timeGanzhi,
      timeYinYang: timeYinYang,
      totalYangYao: totalYangYao,
      totalYinYao: totalYinYao,
      zhiList: zhiList,
      yuantangYaoIndex: yuantangYaoIndex,
      yuantangYaoLabel: yuantangYaoLabel,
      houtianGua: houtianGua,
      houtianUpperGuaNumber: houtianUpperGuaNumber,
      houtianLowerGuaNumber: houtianLowerGuaNumber,
      houtianZhiList: houtianZhiList,
      houtianYuantangYaoIndex: houtianYuantangYaoIndex,
      houtianYuantangYaoLabel: houtianYuantangYaoLabel,
      xiantianGuaHu: xiantianGuaHu,
      houtianGuaHu: houtianGuaHu,
      xiantianDayunStartAge: xiantianDayunStartAge,
      xiantianDayunList: xiantianDayunList,
      houtianDayunStartAge: houtianDayunStartAge,
      houtianDayunList: houtianDayunList,
      tiaowenNumberJiazeXiantiangua: tiaowenNumberJiazeXiantiangua,
      tiaowenNumberJiazeHoutiangua: tiaowenNumberJiazeHoutiangua,
      tiaowenNumberNajiaTaixuanXiantiangua:
          tiaowenNumberNajiaTaixuanXiantiangua,
      tiaowenNumberNajiaTaixuanHoutiangua:
          tiaowenNumberNajiaTaixuanHoutiangua,
      tiaowenNumberXiantianBenhu: tiaowenNumberXiantianBenhu,
      tiaowenNumberHoutianBenhu: tiaowenNumberHoutianBenhu,
      tiaowenNumberListXiantianGuahu: tiaowenNumberListXiantianGuahu,
      tiaowenNumberListHoutianGuahu: tiaowenNumberListHoutianGuahu,
    );
  }

  /// 获取六爻详情列表（用于UI展示）
  List<YuanTangYaoDetail> get yaoDetails {
    final details = <YuanTangYaoDetail>[];
    final binaryList = _guaToBinaryList(xiantianGua);

    for (int i = 0; i < 6; i++) {
      final positionLabel = _getYaoPositionLabel(i);
      final yinYang = binaryList[i] == 1 ? '阳' : '阴';
      final diZhiList = zhiList[i];
      final isYuanTangYao = (i == yuantangYaoIndex);

      details.add(YuanTangYaoDetail(
        position: i,
        positionLabel: positionLabel,
        yinYang: yinYang,
        diZhiList: diZhiList,
        isYuanTangYao: isYuanTangYao,
      ));
    }

    return details;
  }

  /// 获取爻位标签
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

  /// 将卦名转换为二进制列表
  List<int> _guaToBinaryList(String gua) {
    if (gua.length != 2) return [0, 0, 0, 0, 0, 0];

    final upper = gua[0];
    final lower = gua[1];

    final upperBinary = constants.guaBinaryMapper[upper] ?? [0, 0, 0];
    final lowerBinary = constants.guaBinaryMapper[lower] ?? [0, 0, 0];

    return [...upperBinary, ...lowerBinary];
  }

  /// 上卦显示文本（带后天数）
  String get upperGuaDisplayText => '$upperGua($xiantianUpperGuaNumber)';

  /// 下卦显示文本（带后天数）
  String get lowerGuaDisplayText => '$lowerGua($xiantianLowerGuaNumber)';

  /// 后天卦上卦显示文本
  String get houtianUpperGuaDisplayText {
    final houtianUpperGua = houtianGua.isNotEmpty ? houtianGua[0] : '';
    return '$houtianUpperGua($houtianUpperGuaNumber)';
  }

  /// 后天卦下卦显示文本
  String get houtianLowerGuaDisplayText {
    final houtianLowerGua = houtianGua.length > 1 ? houtianGua[1] : '';
    return '$houtianLowerGua($houtianLowerGuaNumber)';
  }

  /// 天地卦生成说明
  String get tianDiGuaFormula {
    return '奇数和$oddNumTotal → 天数$tianGuaNum → 天卦$tianGua\n'
        '偶数和$evenNumTotal → 地数$diGuaNum → 地卦$diGua';
  }

  /// 复制并更新
  @override
  YuanTangBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    FourZhu? fourZhu,
    String? gender,
    String? threeYuan,
    String? birthAfterZhi,
    List<int>? ganNumList,
    List<List<int>>? zhiNumList,
    int? oddNumTotal,
    int? evenNumTotal,
    int? tianGuaNum,
    int? diGuaNum,
    String? tianGua,
    String? diGua,
    bool? usedThreeYuanWuGong,
    String? yearYinYang,
    String? upperGua,
    String? lowerGua,
    String? xiantianGua,
    int? xiantianUpperGuaNumber,
    int? xiantianLowerGuaNumber,
    String? timeGanzhi,
    String? timeYinYang,
    int? totalYangYao,
    int? totalYinYao,
    List<List<String>>? zhiList,
    int? yuantangYaoIndex,
    String? yuantangYaoLabel,
    String? houtianGua,
    int? houtianUpperGuaNumber,
    int? houtianLowerGuaNumber,
    List<List<String>>? houtianZhiList,
    int? houtianYuantangYaoIndex,
    String? houtianYuantangYaoLabel,
    String? xiantianGuaHu,
    String? houtianGuaHu,
    int? xiantianDayunStartAge,
    List<YuanTangDayunPeriod>? xiantianDayunList,
    int? houtianDayunStartAge,
    List<YuanTangDayunPeriod>? houtianDayunList,
    int? tiaowenNumberJiazeXiantiangua,
    int? tiaowenNumberJiazeHoutiangua,
    int? tiaowenNumberNajiaTaixuanXiantiangua,
    int? tiaowenNumberNajiaTaixuanHoutiangua,
    int? tiaowenNumberXiantianBenhu,
    int? tiaowenNumberHoutianBenhu,
    List<int>? tiaowenNumberListXiantianGuahu,
    List<int>? tiaowenNumberListHoutianGuahu,
  }) {
    return YuanTangBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      fourZhu: fourZhu ?? this.fourZhu,
      gender: gender ?? this.gender,
      threeYuan: threeYuan ?? this.threeYuan,
      birthAfterZhi: birthAfterZhi ?? this.birthAfterZhi,
      ganNumList: ganNumList ?? this.ganNumList,
      zhiNumList: zhiNumList ?? this.zhiNumList,
      oddNumTotal: oddNumTotal ?? this.oddNumTotal,
      evenNumTotal: evenNumTotal ?? this.evenNumTotal,
      tianGuaNum: tianGuaNum ?? this.tianGuaNum,
      diGuaNum: diGuaNum ?? this.diGuaNum,
      tianGua: tianGua ?? this.tianGua,
      diGua: diGua ?? this.diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong ?? this.usedThreeYuanWuGong,
      yearYinYang: yearYinYang ?? this.yearYinYang,
      upperGua: upperGua ?? this.upperGua,
      lowerGua: lowerGua ?? this.lowerGua,
      xiantianGua: xiantianGua ?? this.xiantianGua,
      xiantianUpperGuaNumber:
          xiantianUpperGuaNumber ?? this.xiantianUpperGuaNumber,
      xiantianLowerGuaNumber:
          xiantianLowerGuaNumber ?? this.xiantianLowerGuaNumber,
      timeGanzhi: timeGanzhi ?? this.timeGanzhi,
      timeYinYang: timeYinYang ?? this.timeYinYang,
      totalYangYao: totalYangYao ?? this.totalYangYao,
      totalYinYao: totalYinYao ?? this.totalYinYao,
      zhiList: zhiList ?? this.zhiList,
      yuantangYaoIndex: yuantangYaoIndex ?? this.yuantangYaoIndex,
      yuantangYaoLabel: yuantangYaoLabel ?? this.yuantangYaoLabel,
      houtianGua: houtianGua ?? this.houtianGua,
      houtianUpperGuaNumber:
          houtianUpperGuaNumber ?? this.houtianUpperGuaNumber,
      houtianLowerGuaNumber:
          houtianLowerGuaNumber ?? this.houtianLowerGuaNumber,
      houtianZhiList: houtianZhiList ?? this.houtianZhiList,
      houtianYuantangYaoIndex:
          houtianYuantangYaoIndex ?? this.houtianYuantangYaoIndex,
      houtianYuantangYaoLabel:
          houtianYuantangYaoLabel ?? this.houtianYuantangYaoLabel,
      xiantianGuaHu: xiantianGuaHu ?? this.xiantianGuaHu,
      houtianGuaHu: houtianGuaHu ?? this.houtianGuaHu,
      xiantianDayunStartAge:
          xiantianDayunStartAge ?? this.xiantianDayunStartAge,
      xiantianDayunList: xiantianDayunList ?? this.xiantianDayunList,
      houtianDayunStartAge:
          houtianDayunStartAge ?? this.houtianDayunStartAge,
      houtianDayunList: houtianDayunList ?? this.houtianDayunList,
      tiaowenNumberJiazeXiantiangua:
          tiaowenNumberJiazeXiantiangua ?? this.tiaowenNumberJiazeXiantiangua,
      tiaowenNumberJiazeHoutiangua:
          tiaowenNumberJiazeHoutiangua ?? this.tiaowenNumberJiazeHoutiangua,
      tiaowenNumberNajiaTaixuanXiantiangua:
          tiaowenNumberNajiaTaixuanXiantiangua ??
              this.tiaowenNumberNajiaTaixuanXiantiangua,
      tiaowenNumberNajiaTaixuanHoutiangua:
          tiaowenNumberNajiaTaixuanHoutiangua ??
              this.tiaowenNumberNajiaTaixuanHoutiangua,
      tiaowenNumberXiantianBenhu:
          tiaowenNumberXiantianBenhu ?? this.tiaowenNumberXiantianBenhu,
      tiaowenNumberHoutianBenhu:
          tiaowenNumberHoutianBenhu ?? this.tiaowenNumberHoutianBenhu,
      tiaowenNumberListXiantianGuahu: tiaowenNumberListXiantianGuahu ??
          this.tiaowenNumberListXiantianGuahu,
      tiaowenNumberListHoutianGuahu:
          tiaowenNumberListHoutianGuahu ?? this.tiaowenNumberListHoutianGuahu,
    );
  }

  /// 转换为Map
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'gender': gender,
      'threeYuan': threeYuan,
      'birthAfterZhi': birthAfterZhi,
      'ganNumList': ganNumList,
      'zhiNumList': zhiNumList,
      'oddNumTotal': oddNumTotal,
      'evenNumTotal': evenNumTotal,
      'tianGuaNum': tianGuaNum,
      'diGuaNum': diGuaNum,
      'tianGua': tianGua,
      'diGua': diGua,
      'usedThreeYuanWuGong': usedThreeYuanWuGong,
      'yearYinYang': yearYinYang,
      'upperGua': upperGua,
      'lowerGua': lowerGua,
      'xiantianGua': xiantianGua,
      'xiantianUpperGuaNumber': xiantianUpperGuaNumber,
      'xiantianLowerGuaNumber': xiantianLowerGuaNumber,
      'timeGanzhi': timeGanzhi,
      'timeYinYang': timeYinYang,
      'totalYangYao': totalYangYao,
      'totalYinYao': totalYinYao,
      'zhiList': zhiList,
      'yuantangYaoIndex': yuantangYaoIndex,
      'yuantangYaoLabel': yuantangYaoLabel,
      'houtianGua': houtianGua,
      'houtianUpperGuaNumber': houtianUpperGuaNumber,
      'houtianLowerGuaNumber': houtianLowerGuaNumber,
      'houtianZhiList': houtianZhiList,
      'houtianYuantangYaoIndex': houtianYuantangYaoIndex,
      'houtianYuantangYaoLabel': houtianYuantangYaoLabel,
      'xiantianGuaHu': xiantianGuaHu,
      'houtianGuaHu': houtianGuaHu,
      'xiantianDayunStartAge': xiantianDayunStartAge,
      'xiantianDayunList':
          xiantianDayunList.map((p) => p.toMap()).toList(),
      'houtianDayunStartAge': houtianDayunStartAge,
      'houtianDayunList':
          houtianDayunList.map((p) => p.toMap()).toList(),
      'tiaowenNumberJiazeXiantiangua': tiaowenNumberJiazeXiantiangua,
      'tiaowenNumberJiazeHoutiangua': tiaowenNumberJiazeHoutiangua,
      'tiaowenNumberNajiaTaixuanXiantiangua':
          tiaowenNumberNajiaTaixuanXiantiangua,
      'tiaowenNumberNajiaTaixuanHoutiangua':
          tiaowenNumberNajiaTaixuanHoutiangua,
      'tiaowenNumberXiantianBenhu': tiaowenNumberXiantianBenhu,
      'tiaowenNumberHoutianBenhu': tiaowenNumberHoutianBenhu,
      'tiaowenNumberListXiantianGuahu': tiaowenNumberListXiantianGuahu,
      'tiaowenNumberListHoutianGuahu': tiaowenNumberListHoutianGuahu,
    };
  }

  @override
  String toString() {
    return 'YuanTangBaseNumberModel('
        'baseNumber: $baseNumber, '
        'name: $name, '
        'gender: $gender, '
        'threeYuan: $threeYuan, '
        'xiantianGua: $xiantianGua, '
        'houtianGua: $houtianGua, '
        'yuantangYaoIndex: $yuantangYaoIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangBaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.xiantianGua == xiantianGua &&
        other.houtianGua == houtianGua &&
        other.yuantangYaoIndex == yuantangYaoIndex;
  }

  @override
  int get hashCode {
    return baseNumber.hashCode ^
        name.hashCode ^
        gender.hashCode ^
        threeYuan.hashCode ^
        xiantianGua.hashCode ^
        houtianGua.hashCode ^
        yuantangYaoIndex.hashCode;
  }
}
