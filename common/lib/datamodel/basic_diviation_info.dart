import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../models/eight_chars.dart';

part 'basic_diviation_info.g.dart';

@JsonSerializable()
class DivinationPerson {
  final String? name;
  final Gender gender;
  final JiaZi yearMingJiaZi;

  final DateTime? birthDateTime;
  final EightChars? baZi;
  DivinationPerson({
    this.name,
    required this.gender,
    required this.yearMingJiaZi,
    this.birthDateTime,
    this.baZi,
  });

  factory DivinationPerson.fromJson(Map<String, dynamic> json) =>
      _$DivinationPersonFromJson(json);
  Map<String, dynamic> toJson() => _$DivinationPersonToJson(this);
}

@JsonSerializable()
class BasicDivination {
  final String question;
  final String? details;
  final DateTime divinationAt;
  final DivinationPerson? divinationPerson;

  BasicDivination({
    required this.question,
    required this.divinationAt,
    this.details,
    this.divinationPerson,
  });

  factory BasicDivination.fromJson(Map<String, dynamic> json) =>
      _$BasicDivinationFromJson(json);
  Map<String, dynamic> toJson() => _$BasicDivinationToJson(this);
}
