import 'package:common/database/app_database.dart' as db;
import 'package:common/datamodel/divination_type_data_model.dart';
import 'package:common/datamodel/seeker_model.dart';
import 'package:common/datamodel/timing_divination_model.dart';
import 'package:common/models/divination_info_model.dart';
import 'package:common/module.dart';
import 'package:common/viewmodels/divination_meta_info.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:uuid/v7.dart';

import '../database/app_database.dart';
import '../datamodel/divination_request_info_datamodel.dart';

class DevEnterPageViewModel extends ChangeNotifier {
  // 获取当前位置
  QuestionMetaInfo? questionMetaInfo;
  DivinationType? currentType;

  late final db.AppDatabase appDatabase;

  DevEnterPageViewModel({required this.appDatabase});

  final ValueNotifier<
          List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>
      selectableCardListNotifier =
      ValueNotifier<List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>(
          null);

  DivinationDatetimeModel? _divinationDatetimeModel;
  DateTimeType datetimeType = DateTimeType.solar;
  // final ValueNotifier<DivinationType> selectedDivinationTypeNotifier =
  // ValueNotifier(DivinationType.destiny);

  ValueNotifier<Gender> genderNotifier = ValueNotifier(Gender.male);

  ValueNotifier<String?> username = ValueNotifier(null);
  ValueNotifier<String?> nickname = ValueNotifier(null);
  ValueNotifier<String?> question = ValueNotifier(null);
  ValueNotifier<String?> detail = ValueNotifier(null);
  ValueNotifier<JiaZi?> yearJiaZi = ValueNotifier(null);

  final ValueNotifier<List<DivinationTypeDataModel>?>
      divinationTypesListNotifier = ValueNotifier(null);
  final ValueNotifier<DivinationTypeDataModel?> selectedDivinaionTypeNotifier =
      ValueNotifier(null);
  @override
  void dispose() {
    // selectedDivinationTypeNotifier.dispose();
    genderNotifier.dispose();
    username.dispose();
    nickname.dispose();
    question.dispose();
    detail.dispose();
    yearJiaZi.dispose();

    selectedDivinaionTypeNotifier.dispose();
    divinationTypesListNotifier.dispose();
    super.dispose();
  }

  void initState() {
    loadDivinationTypes();
  }

  loadDivinationTypes() async {
    final List<DivinationTypeDataModel> divinationTypes =
        await appDatabase.divinationTypesDao.listAvailable();
    divinationTypesListNotifier.value = divinationTypes;
    selectedDivinaionTypeNotifier.value = divinationTypes.first;
  }

  // void selecteDivinationType(DivinationType divinationType) {
  //   selectedDivinationTypeNotifier.value = divinationType;
  // }

  void selectDivinationType(DivinationTypeDataModel divinationType) {
    selectedDivinaionTypeNotifier.value = divinationType;
  }

  // Divination Card Widget
  // void divinationTypeChanged(DivinationType newType) {
  //   if (selectedDivinationTypeNotifier.value != newType) {
  //     selectedDivinationTypeNotifier.value = newType;
  //   }
  // }
  void selectDivinationDatetime(
      DivinationDatetimeModel? divinationDatetimeModel) {
    _divinationDatetimeModel = divinationDatetimeModel;
  }

  void updateDatetimeType(DateTimeType newDatetimeType) {
    if (datetimeType != newDatetimeType) {
      datetimeType = newDatetimeType;
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

  // Future<Tuple2<DivinationDataModel, TimingDivinationModel>>
  Future<DivinationInfoModel> create() async {
    DivinationRequestInfoDataModel divination = generateDivination();
    DivinationsCompanion divinationsCompanion =
        generateDivinationCompanion(divination);

    if (selectedDivinaionTypeNotifier.value!.name ==
        DivinationType.destiny.name) {
      SeekersCompanion seeker = generateSeekerBirthDateTime(divination.uuid);

      await appDatabase.transaction(() async {
        await appDatabase.divinationsDao.insertDivination(divinationsCompanion);
        await appDatabase.seekersDao.insertSeeker(seeker);
      });

      var res = await Future.wait([
        appDatabase.divinationsDao.getDivinationByUuid(divination.uuid),
        appDatabase.seekersDao.getSeekerByUuid(seeker.uuid.value)
      ]);

      // print("~~~~~~~~");
      // print((res[1]! as SeekerModel)?.location?.toJson());
      // print("~~~~~~~~");
      return DivinationInfoModel(
          divination: res[0]! as DivinationRequestInfoDataModel,
          divinationDatetime: res[1]! as SeekerModel);
    } else {
      TimingDivinationsCompanion timing =
          generateDivinationDatetime(divination.uuid);

      await appDatabase.transaction(() async {
        await appDatabase.divinationsDao.insertDivination(divinationsCompanion);
        await appDatabase.timingDivinationsDao.insertTimingDivination(timing);
      });
      var res = await Future.wait([
        appDatabase.divinationsDao.getDivinationByUuid(divination.uuid),
        appDatabase.timingDivinationsDao
            .getTimingDivinationByUuid(timing.uuid.value)
      ]);
      return DivinationInfoModel(
          divination: res[0]! as DivinationRequestInfoDataModel,
          divinationDatetime: res[1]! as TimingDivinationModel);
    }
  }

  DivinationRequestInfoDataModel generateDivination() {
    // check value is all there
    DateTime now = DateTime.now();
    DivinationRequestInfoDataModel divinationDataModel =
        DivinationRequestInfoDataModel(
            uuid: const UuidV7().generate(),
            createdAt: now,
            lastUpdatedAt: now,
            deletedAt: null,
            divinationTypeUuid: selectedDivinaionTypeNotifier.value!.uuid,
            fateYear: yearJiaZi.value?.toString(),
            question: question.value,
            detail: question.value,
            ownerSeekerUuid: null,
            gender: genderNotifier.value,
            seekerName: username.value ?? nickname.value,
            tinyPredict: null,
            directlyPredict: null);
    return divinationDataModel;
  }

  DivinationsCompanion generateDivinationCompanion(
      DivinationRequestInfoDataModel divinationDataModel) {
    return DivinationsCompanion(
        uuid: Value(divinationDataModel.uuid),
        createdAt: Value(divinationDataModel.createdAt),
        lastUpdatedAt: Value(divinationDataModel.lastUpdatedAt!),
        deletedAt: Value(divinationDataModel.deletedAt),
        divinationTypeUuid: Value(divinationDataModel.divinationTypeUuid),
        fateYear: Value(divinationDataModel.fateYear),
        question: Value(divinationDataModel.question),
        detail: Value(divinationDataModel.detail),
        ownerSeekerUuid: Value(divinationDataModel.ownerSeekerUuid),
        gender: Value(divinationDataModel.gender),
        seekerName: Value(divinationDataModel.seekerName),
        tinyPredict: Value(divinationDataModel.tinyPredict),
        directlyPredict: Value(divinationDataModel.directlyPredict));
    // appDatabase.divinationsDao.insertDivination(companion);
  }

  SeekersCompanion generateSeekerBirthDateTime(String divinationUuid) {
    DateTime now = DateTime.now();

    // print("~~~~~~~~");
    // print(_divinationDatetimeModel?.location?.toJson());
    // print("~~~~~~~~");
    return SeekersCompanion(
      uuid: Value(const UuidV7().generate()),
      createdAt: Value(now),
      lastUpdatedAt: Value(now),
      divinationUuid: Value(divinationUuid),
      gender: Value(genderNotifier.value),
      deletedAt: const Value(null),
      timingType: Value(datetimeType),
      yearGanZhi: Value(_divinationDatetimeModel!.yearJiaZi),
      monthGanZhi: Value(_divinationDatetimeModel!.monthJiaZi),
      dayGanZhi: Value(_divinationDatetimeModel!.dayJiaZi),
      timeGanZhi: Value(_divinationDatetimeModel!.timeJiaZi),
      lunarMonth: Value(_divinationDatetimeModel!.lunarMonth),
      lunarDay: Value(_divinationDatetimeModel!.lunarDay),
      isLeapMonth: Value(_divinationDatetimeModel!.isLeapMonth),
      location: Value(_divinationDatetimeModel!.observer.location),
      datetime: Value(_divinationDatetimeModel!.datetime),
      timingInfoListJson: Value([_divinationDatetimeModel!]),
      timingInfoUuid: Value(_divinationDatetimeModel!.uuid),
    );
    // appDatabase.seekersDao.insertSeeker(companion);
  }

  TimingDivinationsCompanion generateDivinationDatetime(String divinationUuid) {
    DateTime now = DateTime.now();
    return TimingDivinationsCompanion(
      uuid: Value(const UuidV7().generate()),
      createdAt: Value(now),
      lastUpdatedAt: Value(now),
      deletedAt: const Value(null),
      divinationUuid: Value(divinationUuid),
      timingType: Value(datetimeType),
      datetime: Value(_divinationDatetimeModel!.datetime),
      isManual: Value(_divinationDatetimeModel!.observer.isManualCalibration),
      yearGanZhi: Value(_divinationDatetimeModel!.yearJiaZi),
      monthGanZhi: Value(_divinationDatetimeModel!.monthJiaZi),
      dayGanZhi: Value(_divinationDatetimeModel!.dayJiaZi),
      timeGanZhi: Value(_divinationDatetimeModel!.timeJiaZi),
      lunarMonth: Value(_divinationDatetimeModel!.lunarMonth),
      lunarDay: Value(_divinationDatetimeModel!.lunarDay),
      isLeapMonth: Value(_divinationDatetimeModel!.isLeapMonth),
      location: Value(_divinationDatetimeModel!.observer.location),
      timingInfoUuid: Value(_divinationDatetimeModel!.uuid),
      timingInfoListJson: Value([_divinationDatetimeModel!]),
    );
    // appDatabase.timingDivinationsDao.insertTimingDivination(companion);
  }
}
