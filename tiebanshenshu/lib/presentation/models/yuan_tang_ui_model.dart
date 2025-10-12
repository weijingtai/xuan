/// 元堂卦UI模型
///
/// 用于UI层展示元堂卦计算结果的数据结构
library;

import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 元堂卦UI模型
///
/// 包含元堂卦取数法计算结果的所有UI展示所需信息
class YuanTangUIModel {
  // ========== 输入参数 ==========
  /// 性别："男" / "女"
  final String gender;

  /// 三元："上" / "中" / "下"
  final String threeYuan;

  /// 出生节气后："夏至" / "冬至"
  final String birthAfterZhi;

  // ========== 步骤1：天地卦 ==========
  /// 天卦名称
  final String tianGua;

  /// 地卦名称
  final String diGua;

  /// 天地卦生成公式
  final String tianDiGuaFormula;

  /// 是否使用三元五宫
  final bool usedThreeYuanWuGong;

  // ========== 步骤2：上下卦（先天卦） ==========
  /// 先天卦名称（上卦+下卦）
  final String xiantianGua;

  /// 上卦显示文本，如"乾(6)"
  final String upperGuaDisplay;

  /// 下卦显示文本，如"坤(2)"
  final String lowerGuaDisplay;

  /// 年份阴阳
  final String yearYinYang;

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
  final String houtianGua;

  /// 后天卦上卦显示文本
  final String houtianUpperGuaDisplay;

  /// 后天卦下卦显示文本
  final String houtianLowerGuaDisplay;

  // ========== 步骤5：互卦 ==========
  /// 先天卦互卦
  final String xiantianGuaHu;

  /// 后天卦互卦
  final String houtianGuaHu;

  // ========== 条文编号（8种方法） ==========
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
    required this.xiantianGuaHu,
    required this.houtianGuaHu,
    required this.tiaoWenByMethod,
    required this.allTiaoWenNumbers,
    required this.tiaoWenDataList,
  });

  /// 从Domain模型创建UI模型（从BaseNumberTiaoWenListModel）
  ///
  /// 注意：由于BaseNumberTiaoWenListModel不包含完整的YuanTangBaseNumberModel信息，
  /// 此工厂方法只能提取有限的信息。建议使用fromYuanTangModel()直接创建。
  factory YuanTangUIModel.fromDomain(
    BaseNumberTiaoWenListModel baseNumberModel,
  ) {
    // 从description中提取信息
    // 格式示例："元堂卦取数法计算（性别:男，三元:上，节气:夏至）"
    final description = baseNumberModel.description;

    // 提取性别
    final genderMatch = RegExp(r'性别:(\S+)').firstMatch(description);
    final gender = genderMatch?.group(1) ?? '未知';

    // 提取三元
    final threeYuanMatch = RegExp(r'三元:(\S+)').firstMatch(description);
    final threeYuan = threeYuanMatch?.group(1) ?? '未知';

    // 提取节气
    final birthAfterZhiMatch = RegExp(r'节气:(\S+)').firstMatch(description);
    final birthAfterZhi = birthAfterZhiMatch?.group(1) ?? '未知';

    // 由于没有完整的中间结果，这里提供占位符
    return YuanTangUIModel(
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      tianGua: '未知',
      diGua: '未知',
      tianDiGuaFormula: '无法从BaseNumberTiaoWenListModel提取',
      usedThreeYuanWuGong: false,
      xiantianGua: '未知',
      upperGuaDisplay: '未知',
      lowerGuaDisplay: '未知',
      yearYinYang: '未知',
      yuantangYaoLabel: '未知',
      yuantangYaoIndex: -1,
      timeYinYang: '未知',
      yaoList: [],
      houtianGua: '未知',
      houtianUpperGuaDisplay: '未知',
      houtianLowerGuaDisplay: '未知',
      xiantianGuaHu: '未知',
      houtianGuaHu: '未知',
      tiaoWenByMethod: {},
      allTiaoWenNumbers: baseNumberModel.tiaoWenNumbers,
      tiaoWenDataList: baseNumberModel.tiaoWenDataList,
    );
  }

  /// 从YuanTangBaseNumberModel直接创建UI模型（包含完整计算过程）
  ///
  /// [baseNumberModel] YuanTangBaseNumberModel实例
  /// [tiaoWenDataList] 条文数据列表
  factory YuanTangUIModel.fromYuanTangModel(
    YuanTangBaseNumberModel baseNumberModel, {
    List<TiaoWenDataModel>? tiaoWenDataList,
  }) {
    // 转换六爻详情
    final yaoList = baseNumberModel.yaoDetails
        .map((yaoDetail) => YuanTangYaoUIModel(
              position: yaoDetail.position,
              positionLabel: yaoDetail.positionLabel,
              yinYang: yaoDetail.yinYang,
              diZhiList: yaoDetail.diZhiList,
              isYuanTangYao: yaoDetail.isYuanTangYao,
            ))
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
      xiantianGuaHu: baseNumberModel.xiantianGuaHu,
      houtianGuaHu: baseNumberModel.houtianGuaHu,
      tiaoWenByMethod: tiaoWenByMethod,
      allTiaoWenNumbers: allTiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList ?? [],
    );
  }

  /// 是否有条文内容
  bool get hasTiaoWen => tiaoWenDataList.isNotEmpty;

  /// 条文数量
  int get tiaoWenCount => tiaoWenDataList.length;

  /// 唯一条文编号数量
  int get uniqueTiaoWenCount => allTiaoWenNumbers.length;

  /// 获取完整描述
  String get fullDescription =>
      '性别:$gender, 三元:$threeYuan, 节气:$birthAfterZhi';

  /// 获取先天卦显示文本
  String get xiantianGuaDisplayText => '$xiantianGua ($upperGuaDisplay / $lowerGuaDisplay)';

  /// 获取后天卦显示文本
  String get houtianGuaDisplayText =>
      '$houtianGua ($houtianUpperGuaDisplay / $houtianLowerGuaDisplay)';

  /// 是否有六爻详情
  bool get hasYaoDetails => yaoList.isNotEmpty;

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
  String get diZhiDisplayText =>
      diZhiList.isEmpty ? '未配' : diZhiList.join('、');

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
