import 'package:flutter/material.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';

enum DivinationType {
  destiny(pageIndex: 0, name: "命理"),
  divination(pageIndex: 1, name: "占测");

  final int pageIndex;
  final String name;
  const DivinationType({required this.pageIndex, required this.name});
}

class QuestionMetaInfo {
  String nickname;
  Gender gender;
  String questioin;
  DivinationType type;
  QuestionMetaInfo({
    required this.nickname,
    required this.gender,
    required this.questioin,
    required this.type,
  });
}

class DivinationMetaInfo extends QuestionMetaInfo {
  String? detail;
  JiaZi? yearJiaZi;
  DivinationMetaInfo(
      {required super.nickname,
      required super.gender,
      required super.questioin,
      super.type = DivinationType.divination});
}

class DestinyMetaInfo extends QuestionMetaInfo {
  String? usernmae;

  DestinyMetaInfo(
      {required super.nickname,
      required super.gender,
      required super.questioin,
      super.type = DivinationType.destiny});
}
