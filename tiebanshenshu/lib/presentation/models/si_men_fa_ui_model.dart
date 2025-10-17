/// 四门法V2 UI模型
///
/// 用于UI层展示四门法V2计算结果和中间过程的数据结构
library;

import 'package:common/enums.dart';
import '../../domain/models/si_men_fa_base_number_model.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 四门法V2 UI模型
///
/// 包含四门法V2计算结果的所有UI展示所需信息
class SiMenFaUIModel {
  /// 基本信息
  final String algorithmName;
  final int basicNumber;
  final String basicGuaName;
  final Gender gender;
  final String threeYuan;

  /// 变爻基数
  final int variationBase;

  /// 四个卦的信息
  final List<GuaInfoUIModel> fourGuaList;

  /// 秘数列���（四个）
  final List<int> secretNumbers;

  /// 先天数列表（四个）
  final List<int> xiantianNumbers;

  /// 最终条文列表
  final List<int> finalTiaowenList;

  /// 条文数据
  final List<TiaoWenDataModel> tiaoWenDataList;

  const SiMenFaUIModel({
    required this.algorithmName,
    required this.basicNumber,
    required this.basicGuaName,
    required this.gender,
    required this.threeYuan,
    required this.variationBase,
    required this.fourGuaList,
    required this.secretNumbers,
    required this.xiantianNumbers,
    required this.finalTiaowenList,
    required this.tiaoWenDataList,
  });

  /// 从Domain模型创建UI模型
  factory SiMenFaUIModel.fromDomain(
    SiMenFaBaseNumberModel model,
    List<TiaoWenDataModel> tiaoWenDataList,
  ) {
    // 转换四个卦的信息
    final fourGuaList = <GuaInfoUIModel>[];
    for (int i = 0; i < model.fourGuaList.length; i++) {
      final gua = model.fourGuaList[i];
      fourGuaList.add(GuaInfoUIModel(
        index: i + 1,
        guaName: gua.name,
        guaFullName: gua.fullname,
        secretNumber: model.secretNumbers[i],
        xiantianNumber: model.xiantianNumbers[i],
      ));
    }

    return SiMenFaUIModel(
      algorithmName: model.name,
      basicNumber: model.basicNumber,
      basicGuaName: model.basicGua.name,
      gender: model.gender,
      threeYuan: _yuanYunOrderToString(model.threeYuan),
      variationBase: model.variationBase,
      fourGuaList: fourGuaList,
      secretNumbers: model.secretNumbers,
      xiantianNumbers: model.xiantianNumbers,
      finalTiaowenList: model.finalTiaowenList,
      tiaoWenDataList: tiaoWenDataList,
    );
  }

  /// 将YuanYunOrder转换为字符串
  static String _yuanYunOrderToString(YuanYunOrder order) {
    switch (order) {
      case YuanYunOrder.upper:
        return '上元';
      case YuanYunOrder.middle:
        return '中元';
      case YuanYunOrder.lower:
        return '下元';
    }
  }

  /// 获取性别显示文本
  String get genderDisplayText => gender == Gender.male ? '男' : '女';

  /// 获取基本卦显示文本
  String get basicGuaDisplayText => '$basicGuaName (基本数: $basicNumber)';

  /// 获取变爻基数显示文本
  String get variationBaseDisplayText => '变爻基数: $variationBase';

  /// 获取条文总数
  int get tiaoWenTotalCount => finalTiaowenList.length;

  /// 获取完整标题
  String get fullTitle => '$algorithmName ($genderDisplayText, $threeYuan)';

  /// 获取计算过程摘要
  String get calculationSummary =>
      '基本卦: $basicGuaName, 基本数: $basicNumber, 变爻基数: $variationBase, '
      '四卦: ${fourGuaList.map((g) => g.guaName).join(', ')}, '
      '条文总数: $tiaoWenTotalCount';

  @override
  String toString() {
    return 'SiMenFaUIModel('
        'algorithmName: $algorithmName, '
        'basicNumber: $basicNumber, '
        'gender: $genderDisplayText, '
        'threeYuan: $threeYuan, '
        'tiaoWenCount: $tiaoWenTotalCount'
        ')';
  }
}

/// 卦信息UI模型
///
/// 用于展示单个卦的信息
class GuaInfoUIModel {
  /// 卦的索引（1-4 或 1-8）
  final int index;

  /// 卦名（简称）
  final String guaName;

  /// 卦全名
  final String guaFullName;

  /// 秘数（仅四门法）
  final int? secretNumber;

  /// 先天数（仅四门法）
  final int? xiantianNumber;

  /// 三基数（仅八卦滚）
  final GuaThreeNumbersUIModel? threeNumbers;

  const GuaInfoUIModel({
    required this.index,
    required this.guaName,
    required this.guaFullName,
    this.secretNumber,
    this.xiantianNumber,
    this.threeNumbers,
  });

  /// 获取卦的显示文本
  String get displayText => '第$index卦: $guaFullName ($guaName)';

  /// 获取秘数显示文本
  String get secretNumberDisplayText =>
      secretNumber != null ? '秘数: $secretNumber' : '';

  /// 获取先天数显示文本
  String get xiantianNumberDisplayText =>
      xiantianNumber != null ? '先天数: $xiantianNumber' : '';

  /// 获取完整信息
  String get fullInfo {
    final parts = [displayText];
    if (secretNumber != null) parts.add(secretNumberDisplayText);
    if (xiantianNumber != null) parts.add(xiantianNumberDisplayText);
    if (threeNumbers != null) parts.add(threeNumbers!.displayText);
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'GuaInfoUIModel(index: $index, guaName: $guaName)';
  }
}

/// 卦的三基数UI模型（用于八卦滚）
class GuaThreeNumbersUIModel {
  /// a: 先天八卦顺序数
  final int xiantianShunxu;

  /// b: 先天洛书数
  final int xiantianLuoshu;

  /// c: 后天洛书数
  final int houtianLuoshu;

  const GuaThreeNumbersUIModel({
    required this.xiantianShunxu,
    required this.xiantianLuoshu,
    required this.houtianLuoshu,
  });

  /// 获取显示文本
  String get displayText =>
      'a=$xiantianShunxu, b=$xiantianLuoshu, c=$houtianLuoshu';

  /// 获取条文计算公式
  List<String> get tiaoWenFormulas => [
        'a×100+b = ${xiantianShunxu * 100 + xiantianLuoshu}',
        'a×100+c = ${xiantianShunxu * 100 + houtianLuoshu}',
        'b×100+a = ${xiantianLuoshu * 100 + xiantianShunxu}',
        'b×100+c = ${xiantianLuoshu * 100 + houtianLuoshu}',
        'c×100+a = ${houtianLuoshu * 100 + xiantianShunxu}',
        'c×100+b = ${houtianLuoshu * 100 + xiantianLuoshu}',
      ];

  @override
  String toString() {
    return 'GuaThreeNumbersUIModel($displayText)';
  }
}
