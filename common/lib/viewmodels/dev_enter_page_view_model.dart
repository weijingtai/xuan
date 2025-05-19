import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';

import '../enums/enum_gender.dart';
import 'divination_meta_info.dart';

class DevEnterPageViewModel extends ChangeNotifier {
  // 获取当前位置
  QuestionMetaInfo? questionMetaInfo;
  DivinationType? currentType;

  DivinationDatetimeModel? _divinationDatetimeModel;
  final ValueNotifier<DivinationType> selectedDivinationTypeNotifier =
      ValueNotifier(DivinationType.destiny);

  ValueNotifier<Gender> genderNotifier = ValueNotifier(Gender.male);

  ValueNotifier<String?> username = ValueNotifier(null);
  ValueNotifier<String?> nickname = ValueNotifier(null);
  ValueNotifier<String?> question = ValueNotifier(null);
  ValueNotifier<String?> detail = ValueNotifier(null);
  ValueNotifier<JiaZi?> yearJiaZi = ValueNotifier(null);

  @override
  void dispose() {
    selectedDivinationTypeNotifier.dispose();
    genderNotifier.dispose();
    username.dispose();
    nickname.dispose();
    question.dispose();
    detail.dispose();
    yearJiaZi.dispose();
    super.dispose();
  }

  // Divination Card Widget
  void divinationTypeChanged(DivinationType newType) {
    if (selectedDivinationTypeNotifier.value != newType) {
      selectedDivinationTypeNotifier.value = newType;
    }
  }

  void inputUsername(String? newUsername) {
    if (username != newUsername) {
      username.value = newUsername;
    }
  }

  void inputNickname(String? newNickname) {
    if (nickname != newNickname) {
      nickname.value = newNickname;
    }
  }

  void inputYearJiaZi(JiaZi newYearJiaZi) {
    yearJiaZi.value = newYearJiaZi;
  }

  void inputQuestion(String? newQuestion) {
    question.value = newQuestion;
  }

  void inputDetails(String? newDetails) {
    detail.value = newDetails;
  }

  void setDivinationDateTime(DivinationDatetimeModel divinationDateTime) {
    _divinationDatetimeModel = divinationDateTime;
  }
}
