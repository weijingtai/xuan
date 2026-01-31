import 'dart:convert';

import 'package:common/datamodel/location.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/sp_location_datamodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';

import '../common_logger.dart';
import '../helpers/solar_time_calculator.dart';
import '../models/sp_timezone_datamodel.dart';

enum TimezoneType {
  defaultTimezone,
  localTimezone,
  globalCountryTimezoneChanged,
  myLocationTimeZone;
}

class TimezoneLocationViewModel extends ChangeNotifier {
  AppFeatureModule appFeatureModule;
  Logger l = Logger();

  late final ValueNotifier<DateTime?> selectedTimeNotifier;
  final ValueNotifier<DateTime?> selectedDSTTimeNotifer = ValueNotifier(null);
  TimezoneLocationViewModel(
      {required this.appFeatureModule, DateTime? selectedTime}) {
    selectedTimeNotifier = ValueNotifier(selectedTime);
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  onDispose() {
    // dispose alll ValueNotifier
    selectedDSTTimeNotifer.dispose();
    selectedTimeNotifier.dispose();
    selectedLocationNotifier.dispose();
    defaultTimezoneNotifier.dispose();
    isDSTNotifier.dispose();
    locationListNotifier.dispose();
    myLocationNotifier.dispose();
    displayDefaultTimezoneNotifier.dispose();
    rememberLocationNotifier.dispose();
    myLocationIsDefaultNotifier.dispose();
    isSeerLocationNotifier.dispose();
    timezoneNotifier.dispose();
    isDefaultTimezoneNotifier.dispose();
    isAutoHandleDSTNotifier.dispose();
    selectedLocationNotifier.dispose();
  }

  set selectedDatetime(newDatetime) {
    selectedTimeNotifier.value = newDatetime;
    if (newDatetime != null) {
      checkDST();
    }
    //  setNormalAndDSTSelectableCards(queryUuid);
  }

  DateTime? get selectedDatetime => selectedTimeNotifier.value;

  String? localTimezone;

  SPTimezoneDataModel? _timezoneDataModel;
  final ValueNotifier<String?> defaultTimezoneNotifier = ValueNotifier(null);
  set timezoneDataModel(SPTimezoneDataModel? newDataModel) {
    isAutoHandleDSTNotifier.value = newDataModel?.isAutoHandleDST ?? false;
    isDefaultTimezoneNotifier.value = newDataModel?.isDefaultTimezone ?? false;

    if (isDefaultTimezoneNotifier.value) {
      timezoneNotifier.value = newDataModel?.timezoneStr ?? localTimezone;
      defaultTimezoneNotifier.value = timezoneNotifier.value;
    } else {
      timezoneNotifier.value = localTimezone;
      defaultTimezoneNotifier.value = null;
    }
    _timezoneDataModel = newDataModel;
  }

  SPMyLocationDataModel? _myLocationDataModel;
  set myLocationDataModel(SPMyLocationDataModel? newDataModel) {
    _myLocationDataModel = newDataModel;
    myLocationNotifier.value = newDataModel?.location;
    myLocationIsDefaultNotifier.value = newDataModel?.isDefault ?? false;
    isSeerLocationNotifier.value = myLocationIsDefaultNotifier.value;
    if (isSeerLocationNotifier.value &&
        selectedLocationNotifier.value != null) {
      selectedLocationNotifier.value = null;
    }
  }

  final ValueNotifier<Tuple2<TimezoneType, String>?>
      displayDefaultTimezoneNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isDSTNotifier = ValueNotifier(false);
  final ValueNotifier<List<Location>> locationListNotifier = ValueNotifier([]);

  final ValueNotifier<Location?> myLocationNotifier =
      ValueNotifier<Location?>(null);

  final ValueNotifier<bool> rememberLocationNotifier = ValueNotifier(false);
  final ValueNotifier<bool> myLocationIsDefaultNotifier = ValueNotifier(false);

  final ValueNotifier<bool> isSeerLocationNotifier = ValueNotifier(false);

  final ValueNotifier<String?> timezoneNotifier = ValueNotifier(null);
  String? get timezone => timezoneNotifier.value;
  final ValueNotifier<bool> isDefaultTimezoneNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isAutoHandleDSTNotifier = ValueNotifier(false);

  final ValueNotifier<Location?> selectedLocationNotifier = ValueNotifier(null);

  set timezone(String? newTimezoneStr) {
    if (newTimezoneStr == timezoneNotifier.value) {
      return;
    }
    if (newTimezoneStr == null) {
      selectedDatetime = null;
    }
    if (selectedDatetime != null) {
      // selectedDatetime!
      final shangHaiTZTime = tz.TZDateTime(
          tz.getLocation(timezoneNotifier.value!),
          selectedDatetime!.year,
          selectedDatetime!.month,
          selectedDatetime!.day,
          selectedDatetime!.hour,
          selectedDatetime!.minute,
          selectedDatetime!.second,
          selectedDatetime!.millisecond);
      final losAngelesTime =
          tz.TZDateTime.from(shangHaiTZTime, tz.getLocation(newTimezoneStr!));

      // final outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss zzz');
      // print(losAngelesTime.toDateTime());
      selectedDatetime = losAngelesTime.toDateTime();
    }
    timezoneNotifier.value = newTimezoneStr;
    checkDST();
  }

  load() async {
    final List<Object?> result = await Future.wait([
      loadLocalTimezone(),
      loadTimezoneDataModelFromShared(),
      loadMyLocation(),
    ]);
    localTimezone = result[0] as String;
    timezoneDataModel =
        result[1] != null ? result[1] as SPTimezoneDataModel? : null;
    myLocationDataModel =
        result[2] != null ? result[2] as SPMyLocationDataModel? : null;

    // print(
    // "${myLocationNotifier.value?.address != null} ${(_timezoneDataModel?.timezoneStr != null)} ${(_timezoneDataModel?.isDefaultTimezone ?? false)}");
    if (myLocationNotifier.value?.address != null &&
        (_timezoneDataModel?.timezoneStr != null) &&
        (_timezoneDataModel?.isDefaultTimezone ?? false)) {
      // print(
      // "${_timezoneDataModel!.timezoneStr} ${myLocationNotifier.value!.address!.timezone}");
      if (_timezoneDataModel!.timezoneStr !=
          myLocationNotifier.value!.address!.timezone) {
        displayDefaultTimezoneNotifier.value = Tuple2(
            TimezoneType.myLocationTimeZone,
            myLocationNotifier.value!.address!.timezone);
        // timezone = myLocationNotifier.value!.address!.timezone;
      } else {
        displayDefaultTimezoneNotifier.value = null;
      }
    }
  }

  Future<String> loadLocalTimezone() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    return timezoneInfo.identifier;
  }

  Future<SPLocationDataModel?> loadLocation() async {
    l.i("get ${appFeatureModule.spPrefix}${SPLocationDataModel.SharedPreferencesBaseKey} from SharedPreference");
    final sp = await SharedPreferences.getInstance();
    var resultStr = sp.getString(
        "${appFeatureModule.spPrefix}${SPLocationDataModel.SharedPreferencesBaseKey}");
    if (resultStr == null) {
      l.i("there is not ${appFeatureModule.spPrefix}${SPLocationDataModel.SharedPreferencesBaseKey} in SharedPreference");
      return null;
    }
    l.i("get ${appFeatureModule.spPrefix}${SPLocationDataModel.SharedPreferencesBaseKey} from SharedPreference success. [$resultStr]");
    l.t(resultStr);

    SPLocationDataModel? spLocationDataModel;

    spLocationDataModel = SPLocationDataModel.fromJson(jsonDecode(resultStr));

    return spLocationDataModel;
  }

  Future<SPMyLocationDataModel?> loadMyLocation() async {
    l.i("get ${appFeatureModule.spPrefix}${SPMyLocationDataModel.SharedPreferencesBaseKey} from SharedPreference");
    final sp = await SharedPreferences.getInstance();
    var resultStr = sp.getString(
        "${appFeatureModule.spPrefix}${SPMyLocationDataModel.SharedPreferencesBaseKey}");
    if (resultStr == null) {
      l.i("there is not ${appFeatureModule.spPrefix}${SPMyLocationDataModel.SharedPreferencesBaseKey} in SharedPreference");
      return null;
    }
    l.i("get ${appFeatureModule.spPrefix}${SPMyLocationDataModel.SharedPreferencesBaseKey} from SharedPreference success. [$resultStr]");
    l.t(resultStr);
    SPMyLocationDataModel? spMyLocationDataModel;
    spMyLocationDataModel =
        SPMyLocationDataModel.fromJson(jsonDecode(resultStr));

    return spMyLocationDataModel;
  }

  Future<void> updateMyLocation(Location? newLocation) async {
    if (newLocation == null && _myLocationDataModel == null) {
      l.d("新选择的我的地点为null，同时已存储的我的位置也是null，本次为空调用");
      return;
    }

    SPMyLocationDataModel? toSaved;
    l.i("进行新地点的存储");
    if (_myLocationDataModel == null) {
      l.d("本地没有已存储的“我的位置”.");
      l.t(newLocation?.address?.toJson());
      toSaved = SPMyLocationDataModel(
          appFeatureModule: appFeatureModule,
          location: newLocation,
          isDefault: false);
    } else {
      if (newLocation == null) {
        l.d("本地有已经存储的“我的位置”，但newLocation为null，用户清除“我的位置”");
        toSaved = null;
      } else {
        Location? previousLocation = _myLocationDataModel?.location;

        // print(
        // "${previousLocation?.toJson()} ----------- ${previousLocation?.address.toJson()}");
        if (previousLocation != null && previousLocation.address != null) {
          Address previousAddress = previousLocation.address!;
          Address newLocationAddress = newLocation.address!;

          // print("${previousAddress} --- ${newLocationAddress}");
          if (previousAddress == newLocationAddress) {
            if (previousLocation.preciseCoordinates !=
                newLocation.preciseCoordinates) {
              l.d("精确坐标变更，进行更新");
              toSaved = _myLocationDataModel!.copyWith(location: newLocation);
            } else {
              l.d("新选择的我的位置与已存储的“我的位置”相同，本次调用不进行存储");
              return;
            }
          } else {
            toSaved = SPMyLocationDataModel(
                appFeatureModule: appFeatureModule,
                location: newLocation,
                isDefault: false);
          }
        } else {
          l.d("本地有已经存储的“我的位置”，进行更新");
          toSaved = _myLocationDataModel!.copyWith(location: newLocation);
        }
      }
    }
    if (toSaved == null) {
      l.d("新选择的我的位置为null，进行删除");
      await removeMyLocationDataModel(_myLocationDataModel!);
    } else {
      l.d("新选择的我的位置不为null，进行存储");
      await saveMyLocationDataModel(toSaved);
    }
    myLocationDataModel = await loadMyLocation();
  }

  Future<SPTimezoneDataModel?> loadTimezoneDataModelFromShared() async {
    l.i("get ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} from SharedPreference");
    final sp = await SharedPreferences.getInstance();
    var result = sp.getString(
        "${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey}");
    if (result == null) {
      l.i("there is not ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} in SharedPreference");
      return null;
    }
    l.i("get ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} from SharedPreference success. [$result]");
    l.t(result);

    return SPTimezoneDataModel.fromJson(jsonDecode(result));
  }

  Future<void> setMyLocationAsDefault(bool isDefault) async {
    // print(_myLocationDataModel?.toJson());
    // print(myLocationNotifier.value?.toJson());
    if (_myLocationDataModel == null) {
      l.d("当前没有“我的位置”，本次调用不进行处理");
      return;
    }
    if (_myLocationDataModel!.isDefault == isDefault) {
      l.d("当前“我的位置”的默认状态与本次设置的一致，本次调用不进行处理");
      return;
    }
    l.d("当前“我的位置”的默认状态与本次设置的不一致，进行更新");
    SPMyLocationDataModel toSaved = _myLocationDataModel!.copyWith(
        isDefault: isDefault,
        appFeatureModule: appFeatureModule,
        location: _myLocationDataModel!.location);
    await saveMyLocationDataModel(toSaved);
    myLocationDataModel = await loadMyLocation();
  }

  void updateTimezone(String? newValue) async {
    // 当 _timezoneDataModel != null 是，
    // 需要检测新选的值是否与 _timezoneDataModel?.timezoneStr
    // 如果不同，且_isDefaultTimezoneNotifier.value == true，则需要在UI上取消 _isDefaultTimezone
    if (newValue != null &&
        (_timezoneDataModel?.isDefaultTimezone ?? false) &&
        _timezoneDataModel?.timezoneStr == newValue) {
      isDefaultTimezoneNotifier.value = true;
    } else {
      isDefaultTimezoneNotifier.value = false;
    }
    if (newValue != null && timezoneNotifier.value != newValue) {
      if (_timezoneDataModel?.timezoneStr != null) {
        // 新选择的时区是否与存储的默认时区一致
        if ((_timezoneDataModel!.isDefaultTimezone ?? false) &&
            _timezoneDataModel!.timezoneStr != newValue) {
          // 当与默认时区不一致时，将默认时区显示
          displayDefaultTimezoneNotifier.value = Tuple2(
              TimezoneType.defaultTimezone, _timezoneDataModel!.timezoneStr!);
        } else {
          displayDefaultTimezoneNotifier.value = null;
        }
      } else {
        if (localTimezone != null && newValue != localTimezone) {
          displayDefaultTimezoneNotifier.value =
              Tuple2(TimezoneType.localTimezone, timezoneNotifier.value!);
        } else {
          displayDefaultTimezoneNotifier.value = null;
        }
      }
    }

    if (newValue != null && isSeerLocationNotifier.value) {
      // 检查“我的位置”当前是否被勾选, 如果有需要比对两个时区是否一致
      if (myLocationNotifier.value!.address!.timezone != newValue) {
        // 需要提醒用户时区不一致
        displayDefaultTimezoneNotifier.value = Tuple2(
            TimezoneType.myLocationTimeZone,
            myLocationNotifier.value!.address!.timezone!);
      }
    }

    timezone = newValue;
  }

  void onIsDefaultTimezoneChanged(bool? newValue) async {
    // _isDefaultTimezoneNotifier.value = newValue ?? false
    bool isDefault = newValue ?? false;
    SPTimezoneDataModel toSavedTimezoneDataModel;
    if (_timezoneDataModel == null) {
      toSavedTimezoneDataModel = SPTimezoneDataModel(
          appFeatureModule: appFeatureModule,
          timezoneStr: timezoneNotifier.value,
          isAutoHandleDST: isAutoHandleDSTNotifier.value,
          isDefaultTimezone: isDefault);
    } else {
      toSavedTimezoneDataModel = _timezoneDataModel!.copyWith(
          timezoneStr: timezoneNotifier.value, isDefaultTimezone: isDefault);
      if (isDefault &&
          displayDefaultTimezoneNotifier.value != null &&
          _timezoneDataModel?.timezoneStr != null &&
          timezoneNotifier.value != _timezoneDataModel!.timezoneStr) {
        displayDefaultTimezoneNotifier.value = null;
      }
    }
    await saveTimezoneDataModel(toSavedTimezoneDataModel);
    // _timezoneDataModel = await loadTimezoneDataModelFromShared(;
    final loadResult = await loadTimezoneDataModelFromShared();
    timezoneDataModel = loadResult;
  }

  void onAutoHandleTimezoneChanged(bool? newValue) async {
    // _isDefaultTimezoneNotifier.value = newValue ?? false
    bool isAutoHandle = newValue ?? false;
    if (!isAutoHandle) {
      unhandleDSTTime();
    }
    SPTimezoneDataModel toSavedTimezoneDataModel;
    if (_timezoneDataModel == null) {
      toSavedTimezoneDataModel = SPTimezoneDataModel(
          appFeatureModule: appFeatureModule,
          timezoneStr: timezoneNotifier.value,
          isAutoHandleDST: isAutoHandle,
          isDefaultTimezone: isDefaultTimezoneNotifier.value);
    } else {
      toSavedTimezoneDataModel = _timezoneDataModel!.copyWith(
          timezoneStr: timezoneNotifier.value, isAutoHandleDST: isAutoHandle);
    }
    await saveTimezoneDataModel(toSavedTimezoneDataModel);
    final loadResult = await loadTimezoneDataModelFromShared();

    timezoneDataModel = loadResult;
  }

  void usingSeersLocation(bool isSeerLocation) async {
    if (isSeerLocation && selectedLocationNotifier.value != null) {
      selectedLocationNotifier.value = null;
    }
    isSeerLocationNotifier.value = isSeerLocation;
    // 如果我的位置与当前选择的位置不同时 提示用户修改
    if (isSeerLocation &&
        timezone != null &&
        timezone != myLocationNotifier.value!.address!.timezone) {
      displayDefaultTimezoneNotifier.value = Tuple2(
          TimezoneType.myLocationTimeZone,
          myLocationNotifier.value!.address!.timezone!);
    }
  }

  void selectLocation(Location newLocation) {
    selectedLocationNotifier.value = newLocation;
    // 取消 我的位置
    isSeerLocationNotifier.value = false;
    if (newLocation.address != null) {
      // if (newLocation.address!.countryId != 45 &&
      // newLocation.address!.regionId != 9) {
      l.d("新被选择的地点时区与当前时区不一致，触发 globalCountryTimezoneChanged");
      if (newLocation.address!.timezone != timezone) {
        displayDefaultTimezoneNotifier.value = Tuple2(
            TimezoneType.globalCountryTimezoneChanged,
            newLocation.address!.timezone!);
      }
    }
  }

  // 返回isDefaultTimezone 结果
  Future<void> saveTimezoneDataModel(
      SPTimezoneDataModel timezoneDataModel) async {
    l.i("save ${timezoneDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();
    bool result = await sp.setString(
        timezoneDataModel.spKey, jsonEncode(timezoneDataModel.toJson()));
    if (result) {
      l.i("save ${timezoneDataModel.spKey} success.");
    } else {
      l.e("save ${timezoneDataModel.spKey} failed.");
    }
  }

  Future<void> saveLocationDataModel(
      SPLocationDataModel locationDataModel) async {
    l.i("save ${locationDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();
    bool result = await sp.setString(
        locationDataModel.spKey, jsonEncode(locationDataModel.toJson()));
    if (result) {
      l.i("save ${locationDataModel.spKey} success.");
    } else {
      l.e("save ${locationDataModel.spKey} failed.");
    }
  }

  Future<void> saveMyLocationDataModel(
      SPMyLocationDataModel myLocationDataModel) async {
    l.i("save ${myLocationDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();
    bool result = await sp.setString(
        myLocationDataModel.spKey, jsonEncode(myLocationDataModel.toJson()));
    if (result) {
      l.i("save ${myLocationDataModel.spKey} success.");
    } else {
      l.e("save ${myLocationDataModel.spKey} failed.");
    }
  }

  Future<void> removeMyLocationDataModel(
      SPMyLocationDataModel myLocationDataModel) async {
    l.i("save ${myLocationDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();
    // bool result = await sp.setStr(
    // myLocationDataModel.spKey, jsonEncode(myLocationDataModel.toJson()));
    bool result = await sp.remove(myLocationDataModel.spKey);
    if (result) {
      l.i("remove ${myLocationDataModel.spKey} success.");
    } else {
      l.e("remove ${myLocationDataModel.spKey} failed.");
    }
    _myLocationDataModel = await loadMyLocation();
  }

  void addLocation(Location? newLocation) {
    // print(newLocation?.toJson());
    if (newLocation == null) {
      l.d("新选择的地点为null，本次不进行添加");
      return;
    }

    if (locationListNotifier.value.isNotEmpty) {
      if (locationListNotifier.value.any((t) => t == newLocation)) {
        l.d("新选择的地点已经存在，本次不进行添加");
        return; // 已经存在，不添加到 lis;
      }
    }
    final tmpClone =
        locationListNotifier.value.map((e) => e).toList(growable: true);
    locationListNotifier.value = tmpClone..add(newLocation);

    // print("------ ${locationListNotifier.value.length}");
  }

  void updateLocation(Location oldLocation, Location? newLocation) {
    if (newLocation == null) {
      l.d("新选择的地点为null，本次不进行更新");
      return;
    }
    if (locationListNotifier.value.isEmpty) {
      l.d("当前没有地点，本次不进行更新");
      return;
    }
    if (locationListNotifier.value.any((t) => t == newLocation)) {
      l.d("新选择的地点已经存在，本次不进行更新");
      return; // 已经存在，不添加到 lis;
    }
    // for (int i = -1; i < locationListNotifier.value.length; i++) {
    //   if (locationListNotifier.value[i].address == oldLocation.address) {
    //     locationListNotifier.value[i] = newLocation;
    //     break;
    //   }
    // }
    final index = locationListNotifier.value.indexOf(oldLocation);
    if (index == -1) {
      l.d("当前没有旧地点，本次不进行更新");
      return;
    }
    // Location oldLocation = locationListNotifier.value
    //     .where((t) => t.address == newLocation.address)
    //     .first;

    locationListNotifier.value[index] = newLocation;
    final clonedList =
        locationListNotifier.value.map((e) => e).toList(growable: true);
    locationListNotifier.value = clonedList;
    if (selectedLocationNotifier.value == oldLocation) {
      selectedLocationNotifier.value = newLocation;
    }
  }

  // 检查给定时间以及时区是否为夏令时时间
  // 如果是夏令时，将_isDSTNotifier.value 设置为 true
  void checkDST() {
    if (selectedDatetime != null && timezone != null) {
      /// 是否为夏令时
      final isDST =
          SolarTimeCalculator.checkIsDST(selectedDatetime!, timezone!);
      // print("------ ${isDST}");
      if (isAutoHandleDSTNotifier.value) {
        handleDSTDatetime();
      } else {
        isDSTNotifier.value = isDST;
      }
    }
  }

  void handleDSTDatetime() {
    selectedDSTTimeNotifer.value = selectedDatetime;
    selectedTimeNotifier.value =
        selectedDatetime!.subtract(const Duration(hours: 1));
  }

  void updateDatetime(DateTime? newDatetime) {
    selectedDatetime = newDatetime;
  }

  void unhandleDSTTime() {
    l.i("convert normal back to DST");
    if (selectedDSTTimeNotifer.value != null &&
        selectedTimeNotifier.value != null) {
      selectedDatetime = selectedDSTTimeNotifer.value;
      // _selectedTimeNotifier.value = _selectedDSTTimeNotifer.value;
      selectedDSTTimeNotifer.value = null;
    }
    // // 确保当前时间是DST
    // if (_DSTBirthTimeNotifier.value != null) {
    //   // l.t("set _selectedBirthTimeNotifier.value to _DSTBirthTimeNotifier.value");
    //   // _selectedBirthTimeNotifier.value = _DSTBirthTimeNotifier.value;
    //   l.t("set _DSTBirthTimeNotifier.value to null");
    //   _DSTBirthTimeNotifier.value = null;
    //   l.t("set _isDSTNotifier.value to true");
    //   _timezoneLocationViewModel!.isDSTNotifier.value = true;
    // } else {
    //   l.e("current datetime is not DST, can not back to DST");
    // }
  }
}
