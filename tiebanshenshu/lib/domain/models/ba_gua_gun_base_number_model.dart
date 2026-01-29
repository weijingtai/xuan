/// 八卦滚基础数模型
///
/// 保存八卦滚法计算的完整过程和中间结果
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';
import 'tiao_wen_source_info.dart';

/// 八卦滚基础数模型
class BaGuaGunBaseNumberModel extends BaseNumberModel {
  /// 输入参数
  final EightChars eightChars;
  final Gender gender;
  final YuanYunOrder threeYuan;

  /// 基本卦和基本数
  final Enum64Gua basicGua;
  final int basicNumber;

  /// 变爻基数
  final int variationBase;

  /// 前四卦列表
  final List<Enum64Gua> firstFourGuaList;

  /// 后四卦列表
  final List<Enum64Gua> lastFourGuaList;

  /// 全部八卦
  List<Enum64Gua> get eightGuaList => [...firstFourGuaList, ...lastFourGuaList];

  /// 中间计算过程
  final List<GuaThreeNumbers> guaThreeNumbersList; // 每卦的三基数
  final List<int> finalTiaowenList; // 最终条文列表（8卦 × 6条 = 48条）

  /// 条文来源信息列表
  final List<TiaoWenSourceInfo> tiaoWenSourceList;

  const BaGuaGunBaseNumberModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.basicGua,
    required this.basicNumber,
    required this.variationBase,
    required this.firstFourGuaList,
    required this.lastFourGuaList,
    required this.guaThreeNumbersList,
    required this.finalTiaowenList,
    this.tiaoWenSourceList = const [],
  });

  /// 获取八卦的名称列表
  List<String> get eightGuaNames =>
      eightGuaList.map((gua) => gua.toString()).toList();

  @override
  BaGuaGunBaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    EightChars? eightChars,
    Gender? gender,
    YuanYunOrder? threeYuan,
    Enum64Gua? basicGua,
    int? basicNumber,
    int? variationBase,
    List<Enum64Gua>? firstFourGuaList,
    List<Enum64Gua>? lastFourGuaList,
    List<GuaThreeNumbers>? guaThreeNumbersList,
    List<int>? finalTiaowenList,
    List<TiaoWenSourceInfo>? tiaoWenSourceList,
  }) {
    return BaGuaGunBaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      eightChars: eightChars ?? this.eightChars,
      gender: gender ?? this.gender,
      threeYuan: threeYuan ?? this.threeYuan,
      basicGua: basicGua ?? this.basicGua,
      basicNumber: basicNumber ?? this.basicNumber,
      variationBase: variationBase ?? this.variationBase,
      firstFourGuaList: firstFourGuaList ?? this.firstFourGuaList,
      lastFourGuaList: lastFourGuaList ?? this.lastFourGuaList,
      guaThreeNumbersList: guaThreeNumbersList ?? this.guaThreeNumbersList,
      finalTiaowenList: finalTiaowenList ?? this.finalTiaowenList,
      tiaoWenSourceList: tiaoWenSourceList ?? this.tiaoWenSourceList,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'gender': gender,
      'threeYuan': threeYuan,
      'basicGua': basicGua.toString(),
      'basicNumber': basicNumber,
      'variationBase': variationBase,
      'firstFourGuaList': firstFourGuaList.map((g) => g.toString()).toList(),
      'lastFourGuaList': lastFourGuaList.map((g) => g.toString()).toList(),
      'guaThreeNumbersList': guaThreeNumbersList.map((g) => g.toMap()).toList(),
      'finalTiaowenList': finalTiaowenList,
    };
  }

  @override
  String toString() {
    return 'BaGuaGunBaseNumberModel('
        'baseNumber: $baseNumber, '
        'name: $name, '
        'gender: $gender, '
        'threeYuan: $threeYuan, '
        'basicGua: $basicGua, '
        'eightGuaCount: ${eightGuaList.length})';
  }
}

/// 卦的三个基数
class GuaThreeNumbers {
  final Enum64Gua gua;
  final int xiantianShunxu; // a: 先天八卦顺序数
  final int xiantianLuoshu; // b: 先天洛书数
  final int houtianLuoshu; // c: 后天洛书数

  const GuaThreeNumbers({
    required this.gua,
    required this.xiantianShunxu,
    required this.xiantianLuoshu,
    required this.houtianLuoshu,
  });

  Map<String, dynamic> toMap() {
    return {
      'gua': gua.toString(),
      'xiantianShunxu': xiantianShunxu,
      'xiantianLuoshu': xiantianLuoshu,
      'houtianLuoshu': houtianLuoshu,
    };
  }

  @override
  String toString() {
    return '$gua: a=$xiantianShunxu, b=$xiantianLuoshu, c=$houtianLuoshu';
  }
}
