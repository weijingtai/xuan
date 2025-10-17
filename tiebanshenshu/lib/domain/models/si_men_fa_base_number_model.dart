/// 四门法基础数模型
///
/// 保存四门法计算的完整过程和中间结果
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_number_model.dart';
import 'tiao_wen_source_info.dart';

/// 四门法基础数模型
class SiMenFaBaseNumberModel extends BaseNumberModel {
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
  final List<Enum64Gua> fourGuaList;

  /// 中间计算过程
  final List<int> secretNumbers; // 秘数列表
  final List<int> xiantianNumbers; // 先天数列表
  final List<int> finalTiaowenList; // 最终条文列表

  /// 条文来源信息列表
  final List<TiaoWenSourceInfo> tiaoWenSourceList;

  const SiMenFaBaseNumberModel({
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
    required this.fourGuaList,
    required this.secretNumbers,
    required this.xiantianNumbers,
    required this.finalTiaowenList,
    this.tiaoWenSourceList = const [],
  });

  /// 获取四卦的名称列表
  List<String> get fourGuaNames =>
      fourGuaList.map((gua) => gua.toString()).toList();

  /// 获取第一卦（互卦）
  Enum64Gua get firstGua => fourGuaList[0];

  /// 获取第二卦（变爻后）
  Enum64Gua get secondGua => fourGuaList[1];

  /// 获取第三卦（第一卦的互卦）
  Enum64Gua get thirdGua => fourGuaList[2];

  /// 获取第四卦（第二卦的互卦）
  Enum64Gua get fourthGua => fourGuaList[3];

  @override
  SiMenFaBaseNumberModel copyWith({
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
    List<Enum64Gua>? fourGuaList,
    List<int>? secretNumbers,
    List<int>? xiantianNumbers,
    List<int>? finalTiaowenList,
    List<TiaoWenSourceInfo>? tiaoWenSourceList,
  }) {
    return SiMenFaBaseNumberModel(
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
      fourGuaList: fourGuaList ?? this.fourGuaList,
      secretNumbers: secretNumbers ?? this.secretNumbers,
      xiantianNumbers: xiantianNumbers ?? this.xiantianNumbers,
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
      'fourGuaList': fourGuaList.map((g) => g.toString()).toList(),
      'secretNumbers': secretNumbers,
      'xiantianNumbers': xiantianNumbers,
      'finalTiaowenList': finalTiaowenList,
    };
  }

  @override
  String toString() {
    return 'SiMenFaBaseNumberModel('
        'baseNumber: $baseNumber, '
        'name: $name, '
        'gender: $gender, '
        'threeYuan: $threeYuan, '
        'basicGua: $basicGua, '
        'fourGuaCount: ${fourGuaList.length})';
  }
}
