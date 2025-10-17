/// 元堂卦UI模型
///
/// 用于UI层展示元堂卦计算结果的数据结构
library;

import 'package:common/enums.dart';

import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 元堂卦UI模型
///
/// 包含元堂卦取数法计算结果的所有UI展示所需信息
class YuanTangUIModel {
  // ========== 输入参数 ==========
  /// 性别："男" / "女"
  final Gender gender;

  /// 三元："上" / "中" / "下"
  final YuanYunOrder threeYuan;

  /// 出生节气后："夏至" / "冬至"
  final TwentyFourJieQi birthAfterZhi;

  // ========== 步骤1：天地卦 ==========
  /// 天卦名称
  final Enum8Gua tianGua;

  /// 地卦名称
  final Enum8Gua diGua;

  /// 天地卦生成公式
  final String tianDiGuaFormula;

  /// 是否使用三元五宫
  final bool usedThreeYuanWuGong;

  // ========== 步骤2：上下卦（先天卦） ==========
  /// 先天卦名称（上卦+下卦）
  final Enum64Gua xiantianGua;

  /// 上卦显示文本，如"乾(6)"
  final String upperGuaDisplay;

  /// 下卦显示文本，如"坤(2)"
  final String lowerGuaDisplay;

  /// 年份阴阳
  final YinYang yearYinYang;

  // ========== 步骤3：元堂装卦 ==========
  /// 元堂爻标签："初" / "二" / "三" / "四" / "五" / "上"
  final String yuantangYaoLabel;

  /// 元堂爻索引（0-5）
  final int yuantangYaoIndex;

  /// 时辰阴阳："阳" / "阴"
  final String timeYinYang;

  /// 六爻详情列表（包含元堂爻标记）
  final List<YuanTangYaoUIModel> yaoList;

  // ========== 步骤4：后天卦 ==========
  /// 后天卦名称（元堂爻爻变后，上下卦互换）
  final Enum64Gua houtianGua;

  /// 后天卦上卦显示文本
  final String houtianUpperGuaDisplay;

  /// 后天卦下卦显示文本
  final String houtianLowerGuaDisplay;

  // ========== 步骤4.5：后天卦元堂装卦 ==========
  /// 后天卦元堂爻标签
  final String houtianYuantangYaoLabel;

  /// 后天卦元堂爻索引（0-5）
  final int houtianYuantangYaoIndex;

  /// 后天卦六爻详情列表
  final List<YuanTangYaoUIModel> houtianYaoList;

  // ========== 步骤5：互卦 ==========
  /// 先天卦互卦
  final Enum64Gua xiantianGuaHu;

  /// 后天卦互卦
  final Enum64Gua houtianGuaHu;

  // ========== 步骤6：大运计算 ==========
  /// 先天卦大运列表
  final List<YuanTangDayunPeriodUI> xiantianDayunList;

  /// 后天卦大运列表
  final List<YuanTangDayunPeriodUI> houtianDayunList;

  // ========== 条文编号扩展 ==========
  /// 先天卦条文编号列表（递加96四次，5个）
  final List<int> xiantianTiaoWenNumbers;

  /// 后天卦条文编号列表（递加96四次，5个）
  final List<int> houtianTiaoWenNumbers;

  /// 先天卦计算公式
  final String xiantianCalculationFormula;

  /// 后天卦计算公式
  final String houtianCalculationFormula;

  // ========== 条文编号（8种方法，已废弃，保留用于兼容） ==========
  /// 条文编号按方法分类
  final Map<String, List<int>> tiaoWenByMethod;

  /// 所有条文编号（去重）
  final List<int> allTiaoWenNumbers;

  /// 条文数据列表
  final List<TiaoWenDataModel> tiaoWenDataList;

  const YuanTangUIModel({
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    required this.tianGua,
    required this.diGua,
    required this.tianDiGuaFormula,
    required this.usedThreeYuanWuGong,
    required this.xiantianGua,
    required this.upperGuaDisplay,
    required this.lowerGuaDisplay,
    required this.yearYinYang,
    required this.yuantangYaoLabel,
    required this.yuantangYaoIndex,
    required this.timeYinYang,
    required this.yaoList,
    required this.houtianGua,
    required this.houtianUpperGuaDisplay,
    required this.houtianLowerGuaDisplay,
    required this.houtianYuantangYaoLabel,
    required this.houtianYuantangYaoIndex,
    required this.houtianYaoList,
    required this.xiantianGuaHu,
    required this.houtianGuaHu,
    required this.xiantianDayunList,
    required this.houtianDayunList,
    required this.xiantianTiaoWenNumbers,
    required this.houtianTiaoWenNumbers,
    required this.xiantianCalculationFormula,
    required this.houtianCalculationFormula,
    required this.tiaoWenByMethod,
    required this.allTiaoWenNumbers,
    required this.tiaoWenDataList,
  });

  /// 从Domain模型创建UI模型（从BaseNumberTiaoWenListModel）
  ///
  /// 注意：由于BaseNumberTiaoWenListModel不包含完整的YuanTangBaseNumberModel信息，
  /// 此工厂方法只能提取有限的信息。建议使用fromYuanTangModel()直接创建。
  // factory YuanTangUIModel.fromDomain(
  //   BaseNumberTiaoWenListModel baseNumberModel,
  // ) {
  //   // 从description中提取信息
  //   // 格式示例："元堂卦取数法计算（性别:男，三元:上，节气:夏至）"
  //   final description = baseNumberModel.description;

  //   // 提取性别
  //   final genderMatch = RegExp(r'性别:(\S+)').firstMatch(description);
  //   final gender = genderMatch?.group(1) ?? '未知';

  //   // 提取三元
  //   final threeYuanMatch = RegExp(r'三元:(\S+)').firstMatch(description);
  //   final threeYuan = threeYuanMatch?.group(1) ?? '未知';

  //   // 提取节气
  //   final birthAfterZhiMatch = RegExp(r'节气:(\S+)').firstMatch(description);
  //   final birthAfterZhi = birthAfterZhiMatch?.group(1) ?? '未知';

  //   // 由于没有完整的中间结果，这里提供占位符
  //   return YuanTangUIModel(
  //     gender: gender,
  //     threeYuan: threeYuan,
  //     birthAfterZhi: birthAfterZhi,
  //     tianGua: '未知',
  //     diGua: '未知',
  //     tianDiGuaFormula: '无法从BaseNumberTiaoWenListModel提取',
  //     usedThreeYuanWuGong: false,
  //     xiantianGua: '未知',
  //     upperGuaDisplay: '未知',
  //     lowerGuaDisplay: '未知',
  //     yearYinYang: '未知',
  //     yuantangYaoLabel: '未知',
  //     yuantangYaoIndex: -1,
  //     timeYinYang: '未知',
  //     yaoList: [],
  //     houtianGua: '未知',
  //     houtianUpperGuaDisplay: '未知',
  //     houtianLowerGuaDisplay: '未知',
  //     houtianYuantangYaoLabel: '未知',
  //     houtianYuantangYaoIndex: -1,
  //     houtianYaoList: [],
  //     xiantianGuaHu: '未知',
  //     houtianGuaHu: '未知',
  //     xiantianDayunList: [],
  //     houtianDayunList: [],
  //     xiantianTiaoWenNumbers: [],
  //     houtianTiaoWenNumbers: [],
  //     xiantianCalculationFormula: '未知',
  //     houtianCalculationFormula: '未知',
  //     tiaoWenByMethod: {},
  //     allTiaoWenNumbers: baseNumberModel.tiaoWenNumbers,
  //     tiaoWenDataList: baseNumberModel.tiaoWenDataList,
  //   );
  // }

  /// 从YuanTangBaseNumberModel直接创建UI模型（包含完整计算过程）
  ///
  /// [baseNumberModel] YuanTangBaseNumberModel实例
  /// [tiaoWenDataList] 条文数据列表
  /// [xiantianTiaoWenNumbers] 先天卦条文编号列表（递加96四次）
  /// [houtianTiaoWenNumbers] 后天卦条文编号列表（递加96四次）
  factory YuanTangUIModel.fromYuanTangModel(
    YuanTangBaseNumberModel baseNumberModel, {
    List<TiaoWenDataModel>? tiaoWenDataList,
    List<int>? xiantianTiaoWenNumbers,
    List<int>? houtianTiaoWenNumbers,
  }) {
    // 转换先天卦六爻详情
    final yaoList = baseNumberModel.yaoDetails
        .map(
          (yaoDetail) => YuanTangYaoUIModel(
            position: yaoDetail.position,
            positionLabel: yaoDetail.positionLabel,
            yinYang: yaoDetail.yinYang,
            diZhiList: yaoDetail.diZhiList,
            isYuanTangYao: yaoDetail.isYuanTangYao,
          ),
        )
        .toList();

    // 转换后天卦六爻详情
    final houtianYaoList = <YuanTangYaoUIModel>[];

    final houtianBinaryList = _guaToBinaryList(baseNumberModel.houtianGua);
    for (int i = 0; i < 6; i++) {
      final positionLabel = _getYaoPositionLabel(i);
      final yinYang = houtianBinaryList[i] == 1 ? '阳' : '阴';
      final diZhiList = baseNumberModel.houtianZhiList[i];
      final isYuanTangYao = (i == baseNumberModel.houtianYuantangYaoIndex);

      houtianYaoList.add(
        YuanTangYaoUIModel(
          position: i,
          positionLabel: positionLabel,
          yinYang: yinYang,
          diZhiList: diZhiList,
          isYuanTangYao: isYuanTangYao,
        ),
      );
    }

    // 转换先天卦大运列表
    final xiantianDayunList = baseNumberModel.xiantianDayunList
        .map((period) => YuanTangDayunPeriodUI.fromDomain(period))
        .toList();

    // 转换后天卦大运列表
    final houtianDayunList = baseNumberModel.houtianDayunList
        .map((period) => YuanTangDayunPeriodUI.fromDomain(period))
        .toList();

    // 按方法分类条文编号
    final tiaoWenByMethod = <String, List<int>>{
      '先天卦加则法': [baseNumberModel.tiaowenNumberJiazeXiantiangua],
      '后天卦加则法': [baseNumberModel.tiaowenNumberJiazeHoutiangua],
      '先天卦纳甲太玄数': [baseNumberModel.tiaowenNumberNajiaTaixuanXiantiangua],
      '后天卦纳甲太玄数': [baseNumberModel.tiaowenNumberNajiaTaixuanHoutiangua],
      '先天卦本互': [baseNumberModel.tiaowenNumberXiantianBenhu],
      '后天卦本互': [baseNumberModel.tiaowenNumberHoutianBenhu],
      '先天卦互取数列表': baseNumberModel.tiaowenNumberListXiantianGuahu,
      '后天卦互取数列表': baseNumberModel.tiaowenNumberListHoutianGuahu,
    };

    // 收集所有条文编号（去重）
    final allTiaoWenNumbers = <int>[
      baseNumberModel.tiaowenNumberJiazeXiantiangua,
      baseNumberModel.tiaowenNumberJiazeHoutiangua,
      baseNumberModel.tiaowenNumberNajiaTaixuanXiantiangua,
      baseNumberModel.tiaowenNumberNajiaTaixuanHoutiangua,
      baseNumberModel.tiaowenNumberXiantianBenhu,
      baseNumberModel.tiaowenNumberHoutianBenhu,
      ...baseNumberModel.tiaowenNumberListXiantianGuahu,
      ...baseNumberModel.tiaowenNumberListHoutianGuahu,
    ].toSet().toList();

    // 如果没有提供条文编号列表，使用基础数构建默认列表
    final finalXiantianTiaoWenNumbers =
        xiantianTiaoWenNumbers ??
        [baseNumberModel.tiaowenNumberJiazeXiantiangua];
    final finalHoutianTiaoWenNumbers =
        houtianTiaoWenNumbers ?? [baseNumberModel.tiaowenNumberJiazeHoutiangua];

    // 构建计算公式
    final xiantianBaseNumber = baseNumberModel.tiaowenNumberJiazeXiantiangua;
    final houtianBaseNumber = baseNumberModel.tiaowenNumberJiazeHoutiangua;
    final xiantianCalculationFormula =
        '先天卦基础数$xiantianBaseNumber + [0, 96, 192, 288, 384]';
    final houtianCalculationFormula =
        '后天卦基础数$houtianBaseNumber + [0, 96, 192, 288, 384]';

    return YuanTangUIModel(
      gender: baseNumberModel.gender,
      threeYuan: baseNumberModel.threeYuan,
      birthAfterZhi: baseNumberModel.birthAfterZhi,
      tianGua: baseNumberModel.tianGua,
      diGua: baseNumberModel.diGua,
      tianDiGuaFormula: baseNumberModel.tianDiGuaFormula,
      usedThreeYuanWuGong: baseNumberModel.usedThreeYuanWuGong,
      xiantianGua: baseNumberModel.xiantianGua,
      upperGuaDisplay: baseNumberModel.upperGuaDisplayText,
      lowerGuaDisplay: baseNumberModel.lowerGuaDisplayText,
      yearYinYang: baseNumberModel.yearYinYang,
      yuantangYaoLabel: baseNumberModel.yuantangYaoLabel,
      yuantangYaoIndex: baseNumberModel.yuantangYaoIndex,
      timeYinYang: baseNumberModel.timeYinYang,
      yaoList: yaoList,
      houtianGua: baseNumberModel.houtianGua,
      houtianUpperGuaDisplay: baseNumberModel.houtianUpperGuaDisplayText,
      houtianLowerGuaDisplay: baseNumberModel.houtianLowerGuaDisplayText,
      houtianYuantangYaoLabel: baseNumberModel.houtianYuantangYaoLabel,
      houtianYuantangYaoIndex: baseNumberModel.houtianYuantangYaoIndex,
      houtianYaoList: houtianYaoList,
      xiantianGuaHu: baseNumberModel.xiantianGuaHu,
      houtianGuaHu: baseNumberModel.houtianGuaHu,
      xiantianDayunList: xiantianDayunList,
      houtianDayunList: houtianDayunList,
      xiantianTiaoWenNumbers: finalXiantianTiaoWenNumbers,
      houtianTiaoWenNumbers: finalHoutianTiaoWenNumbers,
      xiantianCalculationFormula: xiantianCalculationFormula,
      houtianCalculationFormula: houtianCalculationFormula,
      tiaoWenByMethod: tiaoWenByMethod,
      allTiaoWenNumbers: allTiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList ?? [],
    );
  }

  /// 将卦名转换为二进制列表（辅助方法）
  static List<int> _guaToBinaryList(Enum64Gua gua) {
    // 这里需要从constants获取，简化实现
    final guaBinaryMapper = {
      '乾': [1, 1, 1],
      '兑': [0, 1, 1],
      '离': [1, 0, 1],
      '震': [0, 0, 1],
      '巽': [1, 1, 0],
      '坎': [0, 1, 0],
      '艮': [1, 0, 0],
      '坤': [0, 0, 0],
    };

    final upper = gua.top;
    final lower = gua.bottom;

    final upperBinary = guaBinaryMapper[upper] ?? [0, 0, 0];
    final lowerBinary = guaBinaryMapper[lower] ?? [0, 0, 0];

    return [...upperBinary, ...lowerBinary];
  }

  /// 获取爻位标签（辅助方法）
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

  /// 是否有条文内容
  bool get hasTiaoWen => tiaoWenDataList.isNotEmpty;

  /// 条文数量
  int get tiaoWenCount => tiaoWenDataList.length;

  /// 唯一条文编号数量
  int get uniqueTiaoWenCount => allTiaoWenNumbers.length;

  /// 获取完整描述
  String get fullDescription => '性别:$gender, 三元:$threeYuan, 节气:$birthAfterZhi';

  /// 获取先天卦显示文本
  String get xiantianGuaDisplayText =>
      '$xiantianGua ($upperGuaDisplay / $lowerGuaDisplay)';

  /// 获取后天卦显示文本
  String get houtianGuaDisplayText =>
      '$houtianGua ($houtianUpperGuaDisplay / $houtianLowerGuaDisplay)';

  /// 是否有六爻详情
  bool get hasYaoDetails => yaoList.isNotEmpty;

  /// 获取条文编号的来源信息（算法名称列表）
  ///
  /// 一个条文编号可能来自多个算法（如先天卦扩展和后天卦扩展可能有重复）
  List<String> getTiaoWenSources(int tiaoWenNumber) {
    final sources = <String>[];

    // 检查是否在先天卦扩展列表中
    if (xiantianTiaoWenNumbers.contains(tiaoWenNumber)) {
      final index = xiantianTiaoWenNumbers.indexOf(tiaoWenNumber);
      sources.add('先天卦扩展 (${xiantianGua}) - 第${index + 1}个');
    }

    // 检查是否在后天卦扩展列表中
    if (houtianTiaoWenNumbers.contains(tiaoWenNumber)) {
      final index = houtianTiaoWenNumbers.indexOf(tiaoWenNumber);
      sources.add('后天卦扩展 (${houtianGua}) - 第${index + 1}个');
    }

    // 检查是否在8种方法中
    tiaoWenByMethod.forEach((methodName, numbers) {
      if (numbers.contains(tiaoWenNumber)) {
        sources.add(methodName);
      }
    });

    return sources.isEmpty ? ['未知来源'] : sources;
  }

  @override
  String toString() {
    return 'YuanTangUIModel('
        'gender: $gender, '
        'threeYuan: $threeYuan, '
        'birthAfterZhi: $birthAfterZhi, '
        'xiantianGua: $xiantianGua, '
        'houtianGua: $houtianGua, '
        'yuantangYaoLabel: $yuantangYaoLabel'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangUIModel &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.birthAfterZhi == birthAfterZhi &&
        other.xiantianGua == xiantianGua &&
        other.houtianGua == houtianGua;
  }

  @override
  int get hashCode {
    return gender.hashCode ^
        threeYuan.hashCode ^
        birthAfterZhi.hashCode ^
        xiantianGua.hashCode ^
        houtianGua.hashCode;
  }
}

/// 元堂爻UI模型
///
/// 用于UI层展示单个爻的信息（元堂卦特有，可能有多个地支）
class YuanTangYaoUIModel {
  /// 爻位（0-5，从下到上：初爻、二爻、三爻、四爻、五爻、上爻）
  final int position;

  /// 爻位标签："初" / "二" / "三" / "四" / "五" / "上"
  final String positionLabel;

  /// 阴阳性："阳" / "阴"
  final String yinYang;

  /// 配上的地支列表（可能有多个地支）
  final List<String> diZhiList;

  /// 是否为元堂爻
  final bool isYuanTangYao;

  const YuanTangYaoUIModel({
    required this.position,
    required this.positionLabel,
    required this.yinYang,
    required this.diZhiList,
    required this.isYuanTangYao,
  });

  /// 地支显示文本
  String get diZhiDisplayText => diZhiList.isEmpty ? '未配' : diZhiList.join('、');

  /// 获取完整显示文本
  String get displayText {
    final yuanTangMark = isYuanTangYao ? '★' : '';
    return '$yuanTangMark$positionLabel爻($yinYang): $diZhiDisplayText';
  }

  /// 获取简短显示文本
  String get shortDisplayText => '$positionLabel: $diZhiDisplayText';

  @override
  String toString() {
    return 'YuanTangYaoUIModel(position: $position, $displayText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangYaoUIModel &&
        other.position == position &&
        other.yinYang == yinYang &&
        other.isYuanTangYao == isYuanTangYao;
  }

  @override
  int get hashCode {
    return position.hashCode ^ yinYang.hashCode ^ isYuanTangYao.hashCode;
  }
}

/// 元堂卦大运期间UI模型
///
/// 用于UI层展示单个大运期间的信息
class YuanTangDayunPeriodUI {
  /// 爻位标签："初" / "二" / "三" / "四" / "五" / "上"
  final String yaoLabel;

  /// 阴阳性："阳" / "阴"
  final String yinYang;

  /// 年数（阳爻9年，阴爻6年）
  final int years;

  /// 年龄区间，如"1-6"
  final String ageRange;

  /// 该爻配置的地支列表
  final List<String> diZhiList;

  const YuanTangDayunPeriodUI({
    required this.yaoLabel,
    required this.yinYang,
    required this.years,
    required this.ageRange,
    required this.diZhiList,
  });

  /// 从Domain模型转换
  factory YuanTangDayunPeriodUI.fromDomain(YuanTangDayunPeriod period) {
    return YuanTangDayunPeriodUI(
      yaoLabel: period.yaoLabel,
      yinYang: period.yinYang,
      years: period.years,
      ageRange: period.ageRange,
      diZhiList: period.diZhiList,
    );
  }

  /// 地支显示文本
  String get diZhiDisplayText => diZhiList.isEmpty ? '未配' : diZhiList.join('、');

  /// 获取完整显示文本
  String get displayText =>
      '$yaoLabel爻($yinYang-${years}年): $ageRange岁 [$diZhiDisplayText]';

  @override
  String toString() => displayText;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YuanTangDayunPeriodUI &&
        other.yaoLabel == yaoLabel &&
        other.yinYang == yinYang &&
        other.years == years &&
        other.ageRange == ageRange;
  }

  @override
  int get hashCode {
    return yaoLabel.hashCode ^
        yinYang.hashCode ^
        years.hashCode ^
        ageRange.hashCode;
  }
}
