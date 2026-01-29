/// 八卦滚法 UI模型
///
/// 用于UI层展示八卦滚法计算结果和中间过程的数据结构
library;

import 'package:common/enums.dart';
import '../../domain/models/ba_gua_gun_base_number_model.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import 'si_men_fa_ui_model.dart'; // 复用 GuaInfoUIModel 和 GuaThreeNumbersUIModel

/// 八卦滚法 UI模型
///
/// 包含八卦滚法计算结果的所有UI展示所需信息
class BaGuaGunUIModel {
  /// 基本信息
  final String algorithmName;
  final int basicNumber;
  final String basicGuaName;
  final Gender gender;
  final String threeYuan;

  /// 变爻基数
  final int variationBase;

  /// 八个卦的信息（前四卦 + 后四卦）
  final List<GuaInfoUIModel> eightGuaList;

  /// 最终条文列表（48个）
  final List<int> finalTiaowenList;

  /// 条文数据
  final List<TiaoWenDataModel> tiaoWenDataList;

  const BaGuaGunUIModel({
    required this.algorithmName,
    required this.basicNumber,
    required this.basicGuaName,
    required this.gender,
    required this.threeYuan,
    required this.variationBase,
    required this.eightGuaList,
    required this.finalTiaowenList,
    required this.tiaoWenDataList,
  });

  /// 从Domain模型创建UI模型
  factory BaGuaGunUIModel.fromDomain(
    BaGuaGunBaseNumberModel model,
    List<TiaoWenDataModel> tiaoWenDataList,
  ) {
    // 转换八个卦的信息
    final eightGuaList = <GuaInfoUIModel>[];
    final allGuaList = model.eightGuaList;

    for (int i = 0; i < allGuaList.length; i++) {
      final gua = allGuaList[i];
      final guaThreeNumbers = model.guaThreeNumbersList[i];

      eightGuaList.add(GuaInfoUIModel(
        index: i + 1,
        guaName: gua.name,
        guaFullName: gua.fullname,
        threeNumbers: GuaThreeNumbersUIModel(
          xiantianShunxu: guaThreeNumbers.xiantianShunxu,
          xiantianLuoshu: guaThreeNumbers.xiantianLuoshu,
          houtianLuoshu: guaThreeNumbers.houtianLuoshu,
        ),
      ));
    }

    return BaGuaGunUIModel(
      algorithmName: model.name,
      basicNumber: model.basicNumber,
      basicGuaName: model.basicGua.name,
      gender: model.gender,
      threeYuan: _yuanYunOrderToString(model.threeYuan),
      variationBase: model.variationBase,
      eightGuaList: eightGuaList,
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

  /// 获取前四卦
  List<GuaInfoUIModel> get firstFourGua => eightGuaList.take(4).toList();

  /// 获取后四卦
  List<GuaInfoUIModel> get lastFourGua => eightGuaList.skip(4).toList();

  /// 获取条文总数
  int get tiaoWenTotalCount => finalTiaowenList.length;

  /// 获取完整标题
  String get fullTitle => '$algorithmName ($genderDisplayText, $threeYuan)';

  /// 获取计算过程摘要
  String get calculationSummary =>
      '基本卦: $basicGuaName, 基本数: $basicNumber, 变爻基数: $variationBase, '
      '八卦: ${eightGuaList.map((g) => g.guaName).join(', ')}, '
      '条文总数: $tiaoWenTotalCount';

  /// 获取八卦滚法特有的卦象生成流程说明
  String get guaGenerationFlow =>
      '前四卦: 本→变爻交换→互→错\n'
      '后四卦: 变爻交换→互→错→变爻交换';

  /// 获取三基数计算说明
  String get threeNumbersDescription =>
      '每卦计算三基数: a(先天顺序数), b(先天洛书数), c(后天洛书数)\n'
      '每卦生成6个条文: a×100+b, a×100+c, b×100+a, b×100+c, c×100+a, c×100+b';

  @override
  String toString() {
    return 'BaGuaGunUIModel('
        'algorithmName: $algorithmName, '
        'basicNumber: $basicNumber, '
        'gender: $genderDisplayText, '
        'threeYuan: $threeYuan, '
        'eightGuaCount: ${eightGuaList.length}, '
        'tiaoWenCount: $tiaoWenTotalCount'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaGuaGunUIModel &&
        other.algorithmName == algorithmName &&
        other.basicNumber == basicNumber &&
        other.basicGuaName == basicGuaName &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.variationBase == variationBase &&
        _listEquals(other.eightGuaList, eightGuaList) &&
        _listEquals(other.finalTiaowenList, finalTiaowenList) &&
        _listEquals(other.tiaoWenDataList, tiaoWenDataList);
  }

  @override
  int get hashCode =>
      algorithmName.hashCode ^
      basicNumber.hashCode ^
      basicGuaName.hashCode ^
      gender.hashCode ^
      threeYuan.hashCode ^
      variationBase.hashCode ^
      eightGuaList.hashCode ^
      finalTiaowenList.hashCode ^
      tiaoWenDataList.hashCode;

  /// 辅助方法：比较列表
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
