/// 八卦加则UI模型
///
/// 用于UI层展示八卦加则计算结果的数据结构
library;

import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/ba_gua_jia_ze_base_number_model.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 八卦加则UI模型
///
/// 包含八卦加则计算结果的所有UI展示所需信息
class BaGuaJiaZeUIModel {
  /// 柱名："年柱" / "月柱" / "日柱" / "时柱"
  final String pillarName;

  /// 干支名称，如"甲子"
  final String ganZhi;

  /// 算法方法："爻序法" / "纳甲法"
  final String method;

  /// 条文编号（基础数）
  final int tiaoWenNumber;

  /// 条文内容（如果有）
  final String? tiaoWenContent;

  /// 条文年龄信息（如果有）
  final String? tiaoWenAgeInfo;

  // 计算过程信息
  /// 上卦名称，如"乾卦"
  final String upperGua;

  /// 下卦名称，如"坤卦"
  final String lowerGua;

  /// 上卦后天数
  final int upperGuaNumber;

  /// 下卦后天数
  final int lowerGuaNumber;

  /// 六爻地支总和
  final int yaoSum;

  /// 计算公式，如"6000 + 270 - 2 = 6268"
  final String formula;

  /// 六爻详情列表
  final List<YaoUIModel> yaoList;

  const BaGuaJiaZeUIModel({
    required this.pillarName,
    required this.ganZhi,
    required this.method,
    required this.tiaoWenNumber,
    this.tiaoWenContent,
    this.tiaoWenAgeInfo,
    required this.upperGua,
    required this.lowerGua,
    required this.upperGuaNumber,
    required this.lowerGuaNumber,
    required this.yaoSum,
    required this.formula,
    required this.yaoList,
  });

  /// 从Domain模型创建UI模型
  ///
  /// [baseNumberModel] BaseNumberTiaoWenListModel实例
  factory BaGuaJiaZeUIModel.fromDomain(
    BaseNumberTiaoWenListModel baseNumberModel,
  ) {
    // 从BaseNumberTiaoWenListModel中提取BaGuaJiaZeBaseNumberModel的特定信息
    // 由于BaseNumberTiaoWenListModel包含的是BaseNumberModel，
    // 我们需要通过sourceData来获取详细信息

    // 获取条文内容
    String? tiaoWenContent;
    String? tiaoWenAgeInfo;
    if (baseNumberModel.tiaoWenDataList.isNotEmpty) {
      final tiaoWen = baseNumberModel.tiaoWenDataList.first;
      tiaoWenContent = tiaoWen.content1;

      // 格式化年龄信息
      if (tiaoWen.ageSet1 != null && tiaoWen.ageSet1!.isNotEmpty) {
        tiaoWenAgeInfo = tiaoWen.ageSet1!.join(', ');
        if (tiaoWen.ageSet2 != null && tiaoWen.ageSet2!.isNotEmpty) {
          tiaoWenAgeInfo += ' / ${tiaoWen.ageSet2!.join(', ')}';
        }
      }
    }

    // 从name中解析柱名和方法
    final nameParts = baseNumberModel.name.split('-');
    final pillarName = nameParts.isNotEmpty ? nameParts[0] : '未知';
    final method = nameParts.length > 1 ? nameParts[1] : '未知方法';

    // 从description中解析干支和卦象信息
    // 格式示例："年柱甲子爻序法计算：上卦乾(6)，下卦坤(2)，六爻总和270"
    final description = baseNumberModel.description;

    // 提取干支（在柱名之后，方法之前）
    String ganZhi = '';
    final ganZhiMatch = RegExp(r'$pillarName(\S+)$method').firstMatch(description);
    if (ganZhiMatch != null) {
      ganZhi = ganZhiMatch.group(1) ?? '';
    } else {
      // 简化提取：取柱名后的两个字符
      final pillarIndex = description.indexOf(pillarName);
      if (pillarIndex >= 0 && pillarIndex + pillarName.length + 2 <= description.length) {
        ganZhi = description.substring(
          pillarIndex + pillarName.length,
          pillarIndex + pillarName.length + 2,
        );
      }
    }

    // 提取上卦信息
    String upperGua = '';
    int upperGuaNumber = 0;
    final upperGuaMatch = RegExp(r'上卦(\S+)\((\d+)\)').firstMatch(description);
    if (upperGuaMatch != null) {
      upperGua = upperGuaMatch.group(1) ?? '';
      upperGuaNumber = int.tryParse(upperGuaMatch.group(2) ?? '0') ?? 0;
    }

    // 提取下卦信息
    String lowerGua = '';
    int lowerGuaNumber = 0;
    final lowerGuaMatch = RegExp(r'下卦(\S+)\((\d+)\)').firstMatch(description);
    if (lowerGuaMatch != null) {
      lowerGua = lowerGuaMatch.group(1) ?? '';
      lowerGuaNumber = int.tryParse(lowerGuaMatch.group(2) ?? '0') ?? 0;
    }

    // 提取六爻总和
    int yaoSum = 0;
    final yaoSumMatch = RegExp(r'六爻总和(\d+)').firstMatch(description);
    if (yaoSumMatch != null) {
      yaoSum = int.tryParse(yaoSumMatch.group(1) ?? '0') ?? 0;
    } else {
      // 备选：总和(\d+)
      final sumMatch = RegExp(r'总和(\d+)').firstMatch(description);
      if (sumMatch != null) {
        yaoSum = int.tryParse(sumMatch.group(1) ?? '0') ?? 0;
      }
    }

    // 生成公式
    final formula = '${upperGuaNumber}000 + $yaoSum - $lowerGuaNumber = ${baseNumberModel.baseNumber}';

    // 创建空的六爻列表（实际数据需要从BaGuaJiaZeBaseNumberModel获取）
    // 由于我们只有BaseNumberTiaoWenListModel，无法直接访问PureSixYaoGua
    // 这里提供占位符，实际使用时需要传入完整的BaGuaJiaZeBaseNumberModel
    final yaoList = <YaoUIModel>[];

    return BaGuaJiaZeUIModel(
      pillarName: pillarName,
      ganZhi: ganZhi,
      method: method,
      tiaoWenNumber: baseNumberModel.baseNumber,
      tiaoWenContent: tiaoWenContent,
      tiaoWenAgeInfo: tiaoWenAgeInfo,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber,
      yaoSum: yaoSum,
      formula: formula,
      yaoList: yaoList,
    );
  }

  /// 从BaGuaJiaZeBaseNumberModel直接创建UI模型（包含完整六爻信息）
  ///
  /// [baseNumberModel] BaGuaJiaZeBaseNumberModel实例
  /// [tiaoWenData] 可选的条文数据
  factory BaGuaJiaZeUIModel.fromBaGuaJiaZeModel(
    BaGuaJiaZeBaseNumberModel baseNumberModel, {
    TiaoWenDataModel? tiaoWenData,
  }) {
    // 获取条文内容
    String? tiaoWenContent;
    String? tiaoWenAgeInfo;
    if (tiaoWenData != null) {
      tiaoWenContent = tiaoWenData.content1;

      // 格式化年龄信息
      if (tiaoWenData.ageSet1 != null && tiaoWenData.ageSet1!.isNotEmpty) {
        tiaoWenAgeInfo = tiaoWenData.ageSet1!.join(', ');
        if (tiaoWenData.ageSet2 != null && tiaoWenData.ageSet2!.isNotEmpty) {
          tiaoWenAgeInfo += ' / ${tiaoWenData.ageSet2!.join(', ')}';
        }
      }
    }

    // 转换六爻详情
    final yaoList = baseNumberModel.yaoDetails
        .map((yaoDetail) => YaoUIModel(
              position: yaoDetail.position,
              positionLabel: yaoDetail.positionLabel,
              yinYang: yaoDetail.yinYang,
              diZhi: yaoDetail.diZhi,
              number: yaoDetail.number,
            ))
        .toList();

    return BaGuaJiaZeUIModel(
      pillarName: baseNumberModel.pillarName,
      ganZhi: baseNumberModel.ganZhiDisplayText,
      method: baseNumberModel.method,
      tiaoWenNumber: baseNumberModel.baseNumber,
      tiaoWenContent: tiaoWenContent,
      tiaoWenAgeInfo: tiaoWenAgeInfo,
      upperGua: baseNumberModel.upperGua.name,
      lowerGua: baseNumberModel.lowerGua.name,
      upperGuaNumber: baseNumberModel.upperGuaNumber,
      lowerGuaNumber: baseNumberModel.lowerGuaNumber,
      yaoSum: baseNumberModel.yaoSum,
      formula: baseNumberModel.formula,
      yaoList: yaoList,
    );
  }

  /// 获取上卦显示文本
  String get upperGuaDisplayText => '$upperGua($upperGuaNumber)';

  /// 获取下卦显示文本
  String get lowerGuaDisplayText => '$lowerGua($lowerGuaNumber)';

  /// 获取完整标题
  String get fullTitle => '$pillarName $ganZhi - $method';

  /// 获取条文显示文本
  String get tiaoWenDisplayText =>
      tiaoWenContent ?? '条文编号: $tiaoWenNumber (无条文内容)';

  /// 是否有条文内容
  bool get hasTiaoWenContent => tiaoWenContent != null;

  /// 是否有六爻详情
  bool get hasYaoDetails => yaoList.isNotEmpty;

  @override
  String toString() {
    return 'BaGuaJiaZeUIModel('
        'pillarName: $pillarName, '
        'ganZhi: $ganZhi, '
        'method: $method, '
        'tiaoWenNumber: $tiaoWenNumber, '
        'formula: $formula'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaGuaJiaZeUIModel &&
        other.pillarName == pillarName &&
        other.ganZhi == ganZhi &&
        other.method == method &&
        other.tiaoWenNumber == tiaoWenNumber;
  }

  @override
  int get hashCode {
    return pillarName.hashCode ^
        ganZhi.hashCode ^
        method.hashCode ^
        tiaoWenNumber.hashCode;
  }
}

/// 六爻UI模型
///
/// 用于UI层展示单个爻的信息
class YaoUIModel {
  /// 爻位（0-5，从下到上：初爻、二爻、三爻、四爻、五爻、上爻）
  final int position;

  /// 爻位标签："初" / "二" / "三" / "四" / "五" / "上"
  final String positionLabel;

  /// 阴阳性："阳" / "阴"
  final String yinYang;

  /// 地支名称
  final String diZhi;

  /// 地支对应的数字
  final int number;

  const YaoUIModel({
    required this.position,
    required this.positionLabel,
    required this.yinYang,
    required this.diZhi,
    required this.number,
  });

  /// 获取完整显示文本
  String get displayText => '$positionLabel爻($yinYang): $diZhi($number)';

  /// 获取简短显示文本
  String get shortDisplayText => '$positionLabel: $diZhi';

  @override
  String toString() {
    return 'YaoUIModel(position: $position, $displayText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YaoUIModel &&
        other.position == position &&
        other.diZhi == diZhi &&
        other.yinYang == yinYang;
  }

  @override
  int get hashCode {
    return position.hashCode ^ diZhi.hashCode ^ yinYang.hashCode;
  }
}
