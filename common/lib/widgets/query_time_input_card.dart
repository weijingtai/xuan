import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/common_logger.dart';
import 'package:common/models/sp_location_datamodel.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/widgets/city_picker_bottom_sheet.dart';
import 'package:common/widgets/eight_chars_input_card.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
// import 'package:timezone_dropdown/timezone_dropdown.dart';
// import 'package:timezone/data/latest.dart' as tz;

import '../datamodel/location.dart';
import '../enums/enum_datetime_type.dart';
import '../helpers/solar_lunar_datetime_helper.dart';
import '../models/divination_datetime.dart';
import 'responseive_datetime_dialog.dart';
import '../viewmodels/timezone_location_viewmodel.dart';
import 'zi_strategy_settings_card.dart';
import 'jieqi_phenology_settings_card.dart';
import 'package:common/features/datetime_details/jieqi_phenology_store.dart';
import 'package:common/features/datetime_details/zi_strategy_store.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'jieqi_entry_settings_card.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

class QueryTimeInputCard extends StatefulWidget {
  // final String defaultTimeZone;
  final DateTimeType defaultDateTimeType;
  final AppFeatureModule appFeatureModule;
  // final String defaultTimezone;
  final ValueNotifier<
          List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>
      selectableCardsNotifier;
  const QueryTimeInputCard(
      {super.key,
      required this.defaultDateTimeType,
      required this.selectableCardsNotifier,
      this.appFeatureModule = AppFeatureModule.Golabel});

  @override
  State<QueryTimeInputCard> createState() => _QueryTimeInputCardState();
}

class _QueryTimeInputCardState extends State<QueryTimeInputCard>
    with SingleTickerProviderStateMixin {
  TimezoneLocationViewModel get _timezoneLocationViewModel =>
      context.read<TimezoneLocationViewModel>();
  final GlobalKey isDSTShakeMeKey = GlobalKey<ShakeWidgetState>();
  final GlobalKey isGlobalTimezoneChangedShakeMeKey =
      GlobalKey<ShakeWidgetState>();
  late AnimationController _controller;

  late PageController _pageController;

  late TextEditingController _nameController;

  late final ValueNotifier<DateTimeType> _tabSelectNotifier;

  late final ValueNotifier<bool> showTimezoneAtTitleNotifier =
      ValueNotifier(false);

  final ValueNotifier<bool> isEditorNotifier = ValueNotifier(false);
  // late final ValueNotifier<bool> _isSeersLocationNotifier;

  final CommonLogger _commonLogger = CommonLogger();
  Logger get l => _commonLogger.logger;
  // late TabController _tabController;
  // late final ValueNotifier<Coordinates?> _coordinatesValueNotifier;

  DateFormat timeFormat = DateFormat("HH:mm");
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

  final ValueNotifier<bool> _isDivinationQuestionNotifier =
      ValueNotifier<bool>(true);
  final ValueNotifier<String?> _inputQuestionStrValueNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<String?> _inputQuestionDetailValueNotifier =
      ValueNotifier<String?>(null);

  late tz.TZDateTime _tzNow;
  late final ValueNotifier<Tuple2<String, bool>> _nowClockTimeNotifier;
  Timer? _nowClockTimer;
  // late final DateFormat secondsFormat =;
  final DateFormat secondsFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    super.initState();
    _timezoneLocationViewModel.load();
    _nowClockTimeNotifier = ValueNotifier(Tuple2("loading", false));
    String queryUuid = Uuid().v4();
    _nameController = TextEditingController();
    _controller = AnimationController(vsync: this);
    _tabSelectNotifier =
        ValueNotifier<DateTimeType>(widget.defaultDateTimeType);
    _tabSelectNotifier.addListener(() {
      // _pageController.animateToPage(
      //     getPageIndexByDateTimeType(_tabSelectNotifier.value),
      //     duration: const Duration(milliseconds: 800),
      //     curve: Curves.easeInOut);
    });

    _timezoneLocationViewModel.isDefaultTimezoneNotifier.addListener(() {
      showTimezoneAtTitleNotifier.value =
          _timezoneLocationViewModel.isDefaultTimezoneNotifier.value;
    });
    _pageController = PageController(
        initialPage: getPageIndexByDateTimeType(widget.defaultDateTimeType));

    // _removeDSTTimeNotifier = ValueNotifier(false);

    // 监听事件、以及时区变化，实时验算是否为夏令时时间
    // _DSTBirthTimeNotifier = ValueNotifier(null);
    // _selectedBirthTimeNotifier = ValueNotifier(null)
    _timezoneLocationViewModel.selectedTimeNotifier.addListener(() {
      if (_timezoneLocationViewModel.selectedTimeNotifier.value != null) {
        setNormalAndDSTSelectableCards(queryUuid);
        // 当位置已经设置时，需要添加 mean solar 与 true solar
        if (_timezoneLocationViewModel.selectedLocationNotifier.value != null) {
          bool isManual = _timezoneLocationViewModel
                  .selectedLocationNotifier.value!.preciseCoordinates !=
              null;
          setMeanSolarAndTrueSolarSelectableCards(queryUuid, isManual,
              _timezoneLocationViewModel.selectedLocationNotifier.value!);
        } else {
          if (_timezoneLocationViewModel.isSeerLocationNotifier.value &&
              _timezoneLocationViewModel.myLocationNotifier.value != null) {
            bool isManual = _timezoneLocationViewModel
                    .myLocationNotifier.value!.preciseCoordinates !=
                null;
            setMeanSolarAndTrueSolarSelectableCards(queryUuid, isManual,
                _timezoneLocationViewModel.myLocationNotifier.value!);
          }
        }
      } else {
        startNewNowClockTimer();
        removeAllSelectableCards();
      }
    });

    _timezoneLocationViewModel.timezoneNotifier.addListener(() {
      startNewNowClockTimer();
    });

    _timezoneLocationViewModel.selectedLocationNotifier.addListener(() {
      Location? selectedLocation =
          _timezoneLocationViewModel.selectedLocationNotifier.value;
      if (selectedLocation != null) {
        if (_timezoneLocationViewModel
                .selectedLocationNotifier.value!.coordinates !=
            null) {
          l.i("手动校准经纬为 ${_timezoneLocationViewModel.selectedLocationNotifier.value!.coordinates}");
          setMeanSolarAndTrueSolarSelectableCards(
              queryUuid, true, selectedLocation);
        } else {
          l.i("使用官方给定中心");
          setMeanSolarAndTrueSolarSelectableCards(
              queryUuid, false, selectedLocation);
        }
      } else {
        // 当清除地理位置之后，需要已经存在的card
        if (widget.selectableCardsNotifier.value != null) {
          widget.selectableCardsNotifier.value =
              widget.selectableCardsNotifier.value!.where((e) {
            return (e.key == EnumDatetimeType.standard ||
                    e.key == EnumDatetimeType.removeDST) &&
                !e.value.observer.isManualCalibration;
          }).toList();
        }
      }
    });

    _timezoneLocationViewModel.isDSTNotifier.addListener(() {
      if (_timezoneLocationViewModel.isDSTNotifier.value) {
        if (isDSTShakeMeKey.currentState != null &&
            isDSTShakeMeKey.currentState is ShakeWidgetState) {
          (isDSTShakeMeKey.currentState as ShakeWidgetState).shake();
        }
      }
    });
  }

  int getPageIndexByDateTimeType(DateTimeType datetimeType) {
    switch (datetimeType) {
      case DateTimeType.solar:
        return 0;
      case DateTimeType.lunar:
        return 1;
      case DateTimeType.ganZhi:
        return 2;
    }
  }

  DateTimeType getDateTimeTypeByPageIndex(int index) {
    switch (index) {
      case 0:
        return DateTimeType.solar;
      case 1:
        return DateTimeType.lunar;
      case 2:
        return DateTimeType.ganZhi;
    }
    return DateTimeType.solar;
  }

  void stopNowClockTimer() {
    if (_nowClockTimer != null) {
      _nowClockTimer!.cancel();
      _nowClockTimer = null;
    }
  }

  void startNewNowClockTimer() {
    stopNowClockTimer();
    _tzNow = getNowClockTime();
    _nowClockTimeNotifier.value = Tuple2<String, bool>(
        secondsFormat.format(_tzNow.toDateTime()), _tzNow.timeZone.isDst);

    _nowClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nowClockTimer != null && _nowClockTimer!.isActive) {
        // _nowClockTimeNotifier.value = getNowClockTime();
        _tzNow = _tzNow.add(const Duration(seconds: 1));
        _nowClockTimeNotifier.value = Tuple2<String, bool>(
            secondsFormat.format(_tzNow.toDateTime()), _tzNow.timeZone.isDst);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _pageController.dispose();

    showTimezoneAtTitleNotifier.dispose();
    _isDivinationQuestionNotifier.dispose();
    _inputQuestionStrValueNotifier.dispose();
    _inputQuestionDetailValueNotifier.dispose();
    _isExpandedNotifier.dispose();
    isEditorNotifier.dispose();
    _nowClockTimeNotifier.dispose();
    _nowClockTimer?.cancel();

    super.dispose();
  }

  // @return:
  // Tuple2<String,bool> 第一个元素为时间字符串，第二个元素为是否为夏令时
  tz.TZDateTime getNowClockTime() {
    // return Tuple2("ok", true);
    tz.TZDateTime tzNow = tz.TZDateTime.from(DateTime.now(),
        tz.getLocation(context.read<TimezoneLocationViewModel>().timezone!));

    // return Tuple2(secondsFormat.format(tzSelectedBirthTime.toDateTime()),
    //     tzSelectedBirthTime.timeZone.isDst);
    return tzNow;
  }

  void removeAllSelectableCards() {
    l.i("remove all selectableCars");
    widget.selectableCardsNotifier.value = [];
  }

  void setNormalAndDSTSelectableCards(String queryUuid) {
    if (_timezoneLocationViewModel.selectedDatetime != null &&
        _timezoneLocationViewModel.timezoneNotifier.value != null) {
      // if (widget.selectableCardsNotifier.value?.isNotEmpty ?? false){
      // }
      // widget.selectableCardsNotifier.value = [];
      List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>> result = [];

      String timezoneStr = _timezoneLocationViewModel.timezoneNotifier.value!;
      DateTime selectedBirthTime = _timezoneLocationViewModel.selectedDatetime!;
      // check is summary DST
      final tzSelectedBirthTime =
          tz.TZDateTime.from(selectedBirthTime, tz.getLocation(timezoneStr));
      final isDST = tzSelectedBirthTime.timeZone.isDst;
      final DivinationDatetimeModel normalQueryDateTime =
          SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
              queryUuid: queryUuid,
              dateTime: selectedBirthTime,
              timezoneStr: timezoneStr,
              location: context
                      .read<TimezoneLocationViewModel>()
                      .isSeerLocationNotifier
                      .value
                  ? _timezoneLocationViewModel.myLocationNotifier.value
                  : _timezoneLocationViewModel.selectedLocationNotifier.value,
              isDST: isDST,
              isSeersLocation: context
                  .read<TimezoneLocationViewModel>()
                  .isSeerLocationNotifier
                  .value);
      result.add(MapEntry(EnumDatetimeType.standard, normalQueryDateTime));
      if (isDST) {
        // 当前为 DST 时间
        // 将 selectedBirthTime 转换为非DST时间
        DateTime nonDSTDateTime =
            selectedBirthTime.subtract(Duration(hours: 1));
        DivinationDatetimeModel removeDSTQueryDateTime =
            SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(
                queryUuid: queryUuid,
                dateTime: nonDSTDateTime,
                timezoneStr: timezoneStr,
                hourAdjusted: -1,
                location: context
                        .read<TimezoneLocationViewModel>()
                        .isSeerLocationNotifier
                        .value
                    ? _timezoneLocationViewModel.myLocationNotifier.value
                    : _timezoneLocationViewModel.selectedLocationNotifier.value,
                isSeersLocation: context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        result
            .add(MapEntry(EnumDatetimeType.removeDST, removeDSTQueryDateTime));
      }
      widget.selectableCardsNotifier.value = result;
    }
    if (_timezoneLocationViewModel.selectedDatetime == null &&
        (widget.selectableCardsNotifier.value?.isNotEmpty ?? false)) {
      widget.selectableCardsNotifier.value = [];
    }
  }

  void setMeanSolarAndTrueSolarSelectableCards(
      String queryUuid, bool isToManual, Location? location) {
    if (location != null) {
      EnumDatetimeType meanType = EnumDatetimeType.meanSolar;
      EnumDatetimeType trueType = EnumDatetimeType.trueSolar;
      l.i("set meanSolar datetime");
      // 如果存在前一个 location 的八字，则先移除
      if ((widget.selectableCardsNotifier.value?.isNotEmpty ?? false)) {
        if (widget.selectableCardsNotifier.value!
            .map((e) => e.key)
            .contains(meanType)) {
          l.i("there is a ${meanType.name} datetime in selectable card list, remove it before add new");
          widget.selectableCardsNotifier.value!
              .removeWhere((element) => element.key == trueType);
        }
        if (widget.selectableCardsNotifier.value!
            .map((e) => e.key)
            .contains(trueType)) {
          l.i("there is a ${trueType.name} datetime in selectable card list, remove it before add new");
          widget.selectableCardsNotifier.value!
              .removeWhere((element) => element.key == trueType);
        }
      }

      if (_timezoneLocationViewModel.selectedDatetime != null &&
          _timezoneLocationViewModel.timezoneNotifier.value != null) {
        final tzDateTime = tz.TZDateTime.from(
            _timezoneLocationViewModel.selectedDatetime!,
            tz.getLocation(_timezoneLocationViewModel.timezoneNotifier.value!));
        final meanSolarDateTime =
            SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
                queryUuid,
                tzDateTime,
                location.address!,
                context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        var meanTrueSolarList = [
          MapEntry(meanType, meanSolarDateTime),
        ];
        if (location.address?.area != null) {
          final trueSolarDateTime =
              SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
                  queryUuid,
                  _timezoneLocationViewModel.selectedTimeNotifier.value!,
                  _timezoneLocationViewModel.timezoneNotifier.value!,
                  location.address!.city!.coordinates,
                  context
                      .read<TimezoneLocationViewModel>()
                      .isSeerLocationNotifier
                      .value);
          l.i("add new ${isToManual ? "manualTrueSolar" : "trueSolar"} to selectable card");
          meanTrueSolarList.add(MapEntry(trueType, trueSolarDateTime));
        }
        if (location.preciseCoordinates != null) {
          final trueSolarDateTime =
              SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
                  queryUuid,
                  _timezoneLocationViewModel.selectedTimeNotifier.value!,
                  _timezoneLocationViewModel.timezoneNotifier.value!,
                  location.address!.city!.coordinates,
                  context
                      .read<TimezoneLocationViewModel>()
                      .isSeerLocationNotifier
                      .value);
          l.i("add new ${isToManual ? "manualTrueSolar" : "trueSolar"} to selectable card");
          // l.t(trueSolarDateTime);

          meanTrueSolarList.add(MapEntry(
              trueType,
              trueSolarDateTime.clone(
                  observer: trueSolarDateTime.observer
                      .copyWith(isManualCalibration: true))));
        } else {
          l.i("user not provider area OR preciseCoordinates, the True Solar Datetime without meaning.");
        }

        l.i("add new ${isToManual ? "manualMeanSolar" : "meanSolar"} to selectable card");
        l.t(meanSolarDateTime);

        List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>
            clonedEntries =
            widget.selectableCardsNotifier.value!.map((e) => e).toList();
        widget.selectableCardsNotifier.value = clonedEntries
          ..addAll(meanTrueSolarList);
        // widget.selectableCardsNotifier.value!..add(MapEntry(EnumDatetimeType.meanSolar, meanSolarDateTime));
      }
    }
  }

  // 返回isDefaultTimezone 结果
  Future<bool> saveLocationDataModel(
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
    return true;
  }

  Future<bool> removeLocationDataModel(
      SPLocationDataModel locationDataModel) async {
    l.i("save ${locationDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();

    bool result = await sp.remove(locationDataModel.spKey);
    if (result) {
      l.i("remove ${locationDataModel.spKey} success.");
    } else {
      l.e("remove ${locationDataModel.spKey} failed.");
    }
    return true;
  }

  Map<EnumDatetimeType, DivinationDatetimeModel> _mapper = {};
  void calculateEightChars(String queryUuid, DateTime? datetime) {
    if (datetime != null) {
      if (_timezoneLocationViewModel.isDSTNotifier.value) {
        l.i("出生时间为夏令时时间，根据夏令时时间计算 八字等信息, 同时给出移除夏令时后的时间");
        final dstDateTime =
            SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
                queryUuid: queryUuid,
                dateTime: datetime,
                timezoneStr: _timezoneLocationViewModel.timezoneNotifier.value!,
                location: context
                        .read<TimezoneLocationViewModel>()
                        .isSeerLocationNotifier
                        .value
                    ? _timezoneLocationViewModel.myLocationNotifier.value
                    : _timezoneLocationViewModel.selectedLocationNotifier.value,
                isDST: true,
                isSeersLocation: context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        final removedDSTDateTime =
            SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(
                queryUuid: queryUuid,
                dateTime: datetime,
                timezoneStr: _timezoneLocationViewModel.timezoneNotifier.value!,
                hourAdjusted: -1,
                location: context
                        .read<TimezoneLocationViewModel>()
                        .isSeerLocationNotifier
                        .value
                    ? _timezoneLocationViewModel.myLocationNotifier.value
                    : _timezoneLocationViewModel.selectedLocationNotifier.value,
                isSeersLocation: context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        _mapper[EnumDatetimeType.removeDST] = removedDSTDateTime;
        _mapper[EnumDatetimeType.standard] = dstDateTime;
      } else {
        l.i("当前为非夏令时");
        final normalDateTimeInfo =
            SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
                queryUuid: queryUuid,
                dateTime: datetime,
                timezoneStr: _timezoneLocationViewModel.timezoneNotifier.value!,
                isDST: false,
                location: context
                        .read<TimezoneLocationViewModel>()
                        .isSeerLocationNotifier
                        .value
                    ? _timezoneLocationViewModel.myLocationNotifier.value
                    : _timezoneLocationViewModel.selectedLocationNotifier.value,
                isSeersLocation: context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        _mapper[EnumDatetimeType.standard] = normalDateTimeInfo;
      }
      calculateEightCharByLocation(
        queryUuid,
        datetime,
        _timezoneLocationViewModel.timezoneNotifier.value!,
        _timezoneLocationViewModel.selectedLocationNotifier.value,
      );
    }
  }

  void calculateEightCharByLocation(String queryUuid, DateTime datetime,
      String timezoneStr, Location? location) {
    // 检查用户是否选择了"出生地"，如果选择出生地

    if (location != null) {
      final tz.TZDateTime result =
          tz.TZDateTime.from(datetime, tz.getLocation(timezoneStr));
      final meanDateTimeInfo =
          SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
              queryUuid,
              result,
              location.address!,
              context
                  .read<TimezoneLocationViewModel>()
                  .isSeerLocationNotifier
                  .value);
      _mapper[EnumDatetimeType.meanSolar] = meanDateTimeInfo;
      if (location.address!.area != null) {
        final normalDateTimeInfo =
            SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
                queryUuid,
                _timezoneLocationViewModel.selectedTimeNotifier.value!,
                timezoneStr,
                location.coordinates ?? location.address!.city!.coordinates,
                context
                    .read<TimezoneLocationViewModel>()
                    .isSeerLocationNotifier
                    .value);
        _mapper[EnumDatetimeType.trueSolar] = normalDateTimeInfo;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mainContainer();
  }

  Widget _mainContainer() {
    double smallRadius = 8;
    double largeRadius = 24;

    // 获取屏幕尺寸信息
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // 计算合适的尺寸
    final contentWidth = screenWidth > 600 ? 512.0 : screenWidth * 0.9;
    final contentPadding = screenWidth > 600 ? 16.0 : 8.0;

    return Container(
      width: contentWidth,
      padding: EdgeInsets.symmetric(
          horizontal: contentPadding, vertical: contentPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: contentWidth - (contentPadding * 2),
            child: ValueListenableBuilder(
              valueListenable: _tabSelectNotifier,
              builder: (ctx, selectedTabBarButton, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: DateTimeType.values
                      .map((e) => _buildTabBarButton(
                          e, smallRadius, selectedTabBarButton))
                      .toList(),
                );
              },
            ),
          ),
          ValueListenableBuilder<DateTimeType>(
            valueListenable: _tabSelectNotifier,
            builder: (ctx, selectedTabBarButton, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: contentWidth - (contentPadding * 2),
                height: selectedTabBarButton == DateTimeType.solar ? 600 : 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(largeRadius),
                    bottomLeft: Radius.circular(largeRadius),
                    bottomRight: Radius.circular(largeRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      offset: Offset(1, 2),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                child: PageView(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  onPageChanged: (index) {
                    _tabSelectNotifier.value =
                        getDateTimeTypeByPageIndex(index);
                  },
                  children: [
                    Column(
                      children: [
                        Expanded(child: _buildTimeSelectionContent()),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const Center(child: Text('Content of Tab 2')),
                    _eightCharsPage()
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // 将设置卡片移出内层 Card，独立展示
          ZiStrategySettingsCard(
            applyOnChange: false,
            onStrategyChanged: (s) {
              ZiStrategyStore.set(s);
              _timezoneLocationViewModel.selectedTimeNotifier.value =
                  _timezoneLocationViewModel.selectedTimeNotifier.value;
            },
          ),
          JieQiPhenologySettingsCard(
            applyOnChange: false,
            onChanged: (jieQiType, phStrategy) {
              JieQiPhenologyStore.jieQiType = jieQiType;
              JieQiPhenologyStore.phenologyStrategy = phStrategy;
              _timezoneLocationViewModel.selectedTimeNotifier.value =
                  _timezoneLocationViewModel.selectedTimeNotifier.value;
            },
          ),
          JieQiEntrySettingsCard(
            applyOnChange: false,
            onChanged: (p) {
              _timezoneLocationViewModel.selectedTimeNotifier.value =
                  _timezoneLocationViewModel.selectedTimeNotifier.value;
            },
          ),
        ],
      ),
    );
  }

  @deprecated
  Widget _mainContainer2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 512 - 48,
          height: 480,
          child: timeTab(512 - 48),
        ),
        // SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTabBarButton(
      DateTimeType type, double smallRadius, DateTimeType selected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 32,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(smallRadius),
        ),
        boxShadow: selected == type
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        child: Ink(
          child: InkWell(
            splashColor: Colors.blue.withValues(alpha: 0.3),
            highlightColor: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(smallRadius),
              topRight: Radius.circular(smallRadius),
            ),
            onTap: () {
              _pageController.animateToPage(
                getPageIndexByDateTimeType(type),
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
              );
              context.read<DevEnterPageViewModel>().updateDatetimeType(type);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              alignment: Alignment.center,
              child: Text(
                _getTabBarButtonText(type),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              decoration: BoxDecoration(
                color: selected == type ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(smallRadius),
                  topRight: Radius.circular(smallRadius),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget timeTab(double width) {
    return Column(
      children: <Widget>[
        ValueListenableBuilder(
            valueListenable: _tabSelectNotifier,
            builder: (ctx, tabIndex, _) {
              return SlideSwitcher(
                initialIndex: tabIndex.index,
                onSelect: (index) {
                  _tabSelectNotifier.value = getDateTimeTypeByPageIndex(index);
                  // _pageController.animateToPage(
                  //     getPageIndexByDateTimeType(_tabSelectNotifier.value),
                  //     duration: const Duration(milliseconds: 800),
                  //     curve: Curves.easeInOut);
                  _pageController.animateToPage(index,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.bounceIn);
                },
                containerHeight: 48,
                containerWight: width,
                indents: 4,
                // containerColor: const Color(0xffe4e5eb),
                slidersColors: const [Color(0xfff7f5f7)],
                containerBoxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 2,
                    spreadRadius: 4,
                  )
                ],
                children: [
                  Text(
                    _getTabBarButtonText(DateTimeType.solar),
                    style: tabIndex != DateTimeType.solar
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(Colors.blueAccent),
                  ),
                  Text(
                    _getTabBarButtonText(DateTimeType.lunar),
                    style: tabIndex != DateTimeType.lunar
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(Colors.blueAccent),
                  ),
                  Text(
                    _getTabBarButtonText(DateTimeType.ganZhi),
                    style: tabIndex != DateTimeType.ganZhi
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(Colors.blueAccent),
                  ),
                ],
              );
            }),
        SizedBox(height: 24),
        Expanded(
          child: PageView(
            controller: _pageController,
            // onPageChanged: (index) {
            // _tabSelectNotifier.value = PageType.getFromPageIndex(index);
            // },
            children: <Widget>[
              // Center(child: Text('Content of Tab 1')),
              _buildTimeSelectionContent(),
              const Center(child: Text('Content of Tab 2')),
              _eightCharsPage()
            ],
          ),
        ),
        // SizedBox(height: 24),
      ],
    );
  }

  Widget _eightCharsPage() {
    return EightCharsInput(
      initEightChars: null,
    );
  }

  String _getTabBarButtonText(DateTimeType type) {
    switch (type) {
      case DateTimeType.solar:
        return "阳历";
      case DateTimeType.lunar:
        return "农历";
      case DateTimeType.ganZhi:
        return "八字";
    }
  }

  TextStyle locationTextStyle = const TextStyle(
      height: 1,
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      fontFamily: "NotoSansSC-Regular");

  TextStyle lngLatTextStyle = const TextStyle(
      fontSize: 14, color: Colors.grey, fontFamily: "NotoSansSC-Regular");

  TextStyle titleTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.black87,
      fontFamily: "NotoSansSC-Regular");
  TextStyle warningSubtitleTextStyle = TextStyle(
      color: Colors.amber[900]!.withAlpha(180),
      fontSize: 14,
      fontFamily: "NotoSansSC-Regular");

  Widget _buildTimeSelectionContent() {
    return Container(
      alignment: Alignment.center,
      child: CustomScrollView(
        slivers: [
          // timezoneSelectionContent(),
          SliverToBoxAdapter(
            child: buildSetTimezoneContentV1(),
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 12),
          ),
          SliverToBoxAdapter(
            child: buildDateTimeSelectionContent(),
          ),

          SliverPadding(
            padding: EdgeInsets.only(top: 12),
          ),
          SliverToBoxAdapter(
            child: buildLocationSelectionContentWithMine(300),
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder<Location?>(
                valueListenable: context
                    .read<TimezoneLocationViewModel>()
                    .selectedLocationNotifier,
                builder: (ctx, selectedLocation, _) =>
                    buildSelectableLocationList(
                      300,
                      selectedLocation,
                    )),
          ),
          // buildLocationSelectionContent(),
        ],
      ),
    );
  }

  Widget buildSetAtDefaultLocationContent() {
    return Transform.scale(
        scale: 0.8,
        child: InkWell(
          child: Row(
            children: [
              Checkbox(
                  value: false,
                  onChanged: (newVal) async {
                    // await _timezoneLocationViewModel.setAsDefaultLocation();
                    // _timezoneLocationViewModel.setAsDefaultLocation();
                  }),
              Text(
                "记住这个位置",
                style: TextStyle(height: 1, fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ));
  }

  Widget buildSelectMyLocation(double width) {
    return ValueListenableBuilder<Location?>(
        valueListenable:
            context.read<TimezoneLocationViewModel>().myLocationNotifier,
        builder: (ctx, location, child) {
          if (location == null) {
            // 没有“我的位置”, 展示为空
            return SizedBox();
          }
          Address address = location.address!;
          String defaultLocation;
          if (address.countryId == 45 && address.regionId != 9) {
            defaultLocation =
                "${address.countryName}, ${address.province.name}";
          } else {
            defaultLocation = address.province.name;
          }
          if (address.city != null) {
            defaultLocation += ", ${address.city!.name}";
          }
          if (address.area != null) {
            defaultLocation += ", ${address.area!.name}";
          }
          return ValueListenableBuilder<bool>(
              valueListenable:
                  ctx.read<TimezoneLocationViewModel>().isSeerLocationNotifier,
              builder: (ctx, isSeersLocation, _) {
                return ValueListenableBuilder(
                    valueListenable: isEditorNotifier,
                    builder: (ctx, isEditor, _) {
                      return InkWell(
                          onTap: () {
                            context
                                .read<TimezoneLocationViewModel>()
                                .usingSeersLocation(!isSeersLocation);
                            // .value = !isSeersLocation;
                            // _isSeersLocationNotifier.value =!isSeersLocation;
                          },
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              width: width,
                              height: isEditor ? 102 : 42,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSeersLocation
                                      ? Border.all(
                                          color: Colors.black, width: 1)
                                      : Border.all(
                                          color: Colors.grey, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 2,
                                        spreadRadius: 2)
                                  ]),
                              child: ClipRRect(
                                  child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        width: 16,
                                        height: 16,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: isSeersLocation
                                                    ? Colors.black87
                                                    : Colors.grey,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: AnimatedOpacity(
                                          duration: Duration(milliseconds: 200),
                                          opacity: isSeersLocation ? 1 : 0,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: isSeersLocation
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      AnimatedDefaultTextStyle(
                                        child: Text("我的位置"),
                                        style: TextStyle(
                                            fontSize: 14,
                                            height: 1.2,
                                            fontWeight: FontWeight.w600,
                                            color: isSeersLocation
                                                ? Colors.black87
                                                : Colors.grey.shade600),
                                        duration: Duration(milliseconds: 400),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Container(
                                        width: 120,
                                        height: 18,
                                        child: AnimatedDefaultTextStyle(
                                            child: Text(defaultLocation),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                height: 1.2,
                                                color: isEditor
                                                    ? Colors.transparent
                                                    : Colors.black38),
                                            duration:
                                                Duration(milliseconds: 400)),
                                      ),
                                      Expanded(child: SizedBox()),
                                      InkWell(
                                          child: Icon(Icons.edit_document,
                                              size: 14,
                                              color:
                                                  Colors.blueAccent.shade100),
                                          onTap: () {
                                            isEditorNotifier.value = !isEditor;
                                          })
                                    ],
                                  ),
                                  if (isEditor) ...[
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      height: 46,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          AutoSizeText.rich(
                                            minFontSize: 10,
                                            maxFontSize: 16,
                                            TextSpan(
                                                style: TextStyle(
                                                    height: 1,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black87),
                                                text:
                                                    "${location.address!.countryName} > ${location.address!.province.name}",
                                                children: [
                                                  if (location.address!.city !=
                                                      null)
                                                    TextSpan(
                                                        text:
                                                            " > ${location.address!.city!.name}"),
                                                  if (location.address!.area !=
                                                      null)
                                                    TextSpan(
                                                        text:
                                                            " > ${location.address!.area!.name}"),
                                                ]),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    height: 1.2,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        Colors.grey.shade600),
                                                children: [
                                                  location.preciseCoordinates ==
                                                          null
                                                      ? TextSpan(
                                                          text:
                                                              "经纬度: (${location.coordinates!.latitude}, ${location.coordinates!.longitude})",
                                                        )
                                                      : TextSpan(
                                                          text:
                                                              "手动校准: (${location.preciseCoordinates!.latitude.toStringAsFixed(6)}, ${location.preciseCoordinates!.longitude.toStringAsFixed(6)})",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                          )),
                                                ]),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            Address? newSelectedAddress =
                                                await showCityPickerBottomSheet(
                                              context: ctx,
                                              initAddress: location.address!,
                                              myLocationNotifier:
                                                  _timezoneLocationViewModel
                                                      .myLocationNotifier,
                                            );
                                            if (newSelectedAddress == null) {
                                              return;
                                            }
                                            ctx
                                                .read<
                                                    TimezoneLocationViewModel>()
                                                .updateMyLocation(Location(
                                                  address: newSelectedAddress,
                                                ));
                                          },
                                          child: Text(
                                            "修改位置",
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1,
                                              fontWeight: FontWeight.normal,
                                              color: const Color.fromRGBO(
                                                  68, 138, 255, 1),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: SizedBox()),
                                        ValueListenableBuilder(
                                            valueListenable: context
                                                .read<
                                                    TimezoneLocationViewModel>()
                                                .myLocationIsDefaultNotifier,
                                            builder: (ctx, isDefault, _) {
                                              return InkWell(
                                                  onTap: () {
                                                    ctx
                                                        .read<
                                                            TimezoneLocationViewModel>()
                                                        .setMyLocationAsDefault(
                                                            !isDefault);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      FlutterSwitch(
                                                          width: 20,
                                                          height: 12,
                                                          padding: 2,
                                                          toggleSize: 10,
                                                          showOnOff: false,
                                                          value: isDefault,
                                                          onToggle: (newValue) {
                                                            ctx
                                                                .read<
                                                                    TimezoneLocationViewModel>()
                                                                .setMyLocationAsDefault(
                                                                    newValue);
                                                          }),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      AnimatedDefaultTextStyle(
                                                          child: Text("设为默认位置"),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            height: 1,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: isDefault
                                                                ? Colors.black87
                                                                : Colors.grey
                                                                    .shade600,
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  200)),
                                                    ],
                                                  ));
                                            }),
                                        Expanded(child: SizedBox()),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/common/maps',
                                                arguments: {
                                                  "seekerLocation": location,
                                                  "seerLocation": null
                                                }).then((val) {
                                              _timezoneLocationViewModel
                                                  .updateMyLocation(
                                                      location.copyWith(
                                                          preciseCoordinates: val
                                                              as Coordinates));
                                            });
                                          },
                                          child: Text(
                                            (location.preciseCoordinates ==
                                                    null)
                                                ? "地图精准定位"
                                                : "已精准定位",
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                ],
                              ))));
                    });
              });
        });
  }

  Widget buildSelectableLocationList(double width, Location? selectedLocation) {
    return ValueListenableBuilder<List<Location>>(
        valueListenable:
            context.read<TimezoneLocationViewModel>().locationListNotifier,
        builder: (ctx, locationList, child) {
          if (locationList.isEmpty) {
            return SizedBox();
          }
          List<Widget> locationListWidget = [];
          for (var l in locationList) {
            bool isSelected = selectedLocation == l;
            locationListWidget.add(InkWell(
              onTap: () {
                ctx.read<TimezoneLocationViewModel>().selectLocation(l);
              },
              child: Container(
                width: width,
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    // color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            isSelected ? Colors.black87 : Colors.grey.shade600,
                        width: 1),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          spreadRadius: 2)
                    ]),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 16,
                            height: 16,
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: isSelected
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    width: 1),
                                borderRadius: BorderRadius.circular(8)),
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: isSelected ? 1 : 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                        ]),
                    buildSelectableLocation(l)
                  ],
                ),
              ),
            ));
          }

          return Container(child: Column(children: locationListWidget));

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: locationList.length,
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return buildSelectMyLocation(width);
              }
              Location location = locationList[index];
              // return buildLocationItem(location, width);
              return ListTile(
                title: Text(location.address!.province.name),
                subtitle: Text(location.address!.city!.name),
                trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<TimezoneLocationViewModel>()
                          .selectLocation(location);
                    }),
              );
            },
          );
          return SingleChildScrollView(
            // shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              height: 56,
              width: width,
              child: Column(
                children: locationList
                    .map((l) => InkWell(
                          onTap: () {},
                          child: Container(
                            width: width,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade600, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 2,
                                      spreadRadius: 2)
                                ]),
                            child: buildSelectableLocation(l),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        });

    // return Container(
    //   width: width,
    //   height: 48,
    //   alignment: Alignment.topCenter,
    //   color: Colors.red,
    //   child: );
  }

  Widget buildLocationSelectionContentWithMine(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildSelectMyLocation(width),
        SizedBox(
          height: 12,
        ),
        InkWell(
            onTap: () {
              doSelectCity(null);
            },
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(12),
                padding: EdgeInsets.all(6),
                color: Colors.grey,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: width,
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            "点击选择位置",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )),
                    ],
                  )),
            )),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }

  @Deprecated("use buildLocationSelectionContentWithMine")
  Widget buildLocationSelectionContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValueListenableBuilder<Location?>(
            valueListenable:
                _timezoneLocationViewModel.selectedLocationNotifier,
            builder: (ctx, location, child) {
              return Column(
                children: [
                  InkWell(
                      onTap: () => doSelectCity(null),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(12),
                          padding: EdgeInsets.all(6),
                          color: Colors.grey,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Container(
                              width: 260,
                              height: 56,
                              alignment: Alignment.center,
                              child: location == null
                                  ? Text(
                                      "点击选择位置",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    )
                                  : buildSelectableLocation(location),
                            )),
                      )),
                  SizedBox(height: 4),
                  Container(
                      width: 260,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildSetAtDefaultLocationContent(),
                          Expanded(child: SizedBox()),
                          // buildIsMyLocationContent(),
                        ],
                      ))
                ],
              );
            }),
        SizedBox(width: 4),
        Column(
          children: [
            InkWell(
              onTap: () async {},
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                alignment: Alignment.center,
                height: 24,
                width: 48,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          spreadRadius: 4)
                    ]),
                child: Text("选择"),
              ),
            ),
            InkWell(
              onTap: () {
                // handleDSTTime(DateTime.now(), _timezoneNotifier.value!);
                // _timezoneLocationViewModel.updateLocation(null);
                // _locationNotifier.value = null; // clear the location inf
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                alignment: Alignment.center,
                height: 24,
                width: 48,
                decoration: BoxDecoration(
                    // color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          spreadRadius: 4)
                    ]),
                child: Text("清除"),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildSelectableLocation(Location location) {
    double largeFontSize = 24;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                  text:
                      "${location.address!.countryName}, ${location.address!.province.name}",
                  children: [
                    if (location.address!.city != null)
                      TextSpan(
                        text: ", ${location.address!.city!.name}",
                      ),
                    if (location.address!.area != null)
                      TextSpan(
                        text: ", ${location.address!.area!.name}",
                      ),
                  ]),
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1),
            ),
            location.preciseCoordinates == null
                ? Text(
                    "行政中心：${location.coordinates?.latitude.toStringAsFixed(4)}° N, ${location.coordinates?.longitude.toStringAsFixed(4)}° W",
                    style: lngLatTextStyle.copyWith(fontSize: 10),
                  )
                : Text(
                    "手动校准：${location.preciseCoordinates?.latitude.toStringAsFixed(6)}° N, ${location.preciseCoordinates?.longitude.toStringAsFixed(5)}° W",
                    style: lngLatTextStyle.copyWith(
                        fontSize: 10, color: Colors.blueAccent),
                  ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () async {
                    Address? newSelectedAddress =
                        await showCityPickerBottomSheet(
                      context: context,
                      initAddress: location.address!,
                      myLocationNotifier:
                          _timezoneLocationViewModel.myLocationNotifier,
                    );
                    if (newSelectedAddress == null) {
                      return;
                    }
                    context.read<TimezoneLocationViewModel>().updateLocation(
                        location,
                        Location(
                          address: newSelectedAddress,
                        ));
                  },
                  child: Text(
                    "修改位置",
                    style: TextStyle(
                      fontSize: 10,
                      height: 1,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blueAccent,
                    ),
                  )),
              Expanded(child: SizedBox()),
              InkWell(
                  onTap: () {
                    // toLngLatSelectPage(location);
                    Navigator.pushNamed(context, '/common/maps', arguments: {
                      "seekerLocation": location,
                      "seerLocation": context
                          .read<TimezoneLocationViewModel>()
                          .myLocationNotifier
                          .value
                    }).then((val) {
                      _timezoneLocationViewModel.updateLocation(
                          location,
                          location.copyWith(
                              preciseCoordinates: val as Coordinates));
                    });
                  },
                  child: Text(
                    "地图精准定位",
                    style: TextStyle(
                      fontSize: 10,
                      height: 1,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blueAccent,
                    ),
                  ))
            ],
          ),
        )
      ],
    );
  }

  Widget buildCurrentLocation() {
    double largeFontSize = 24;
    return Container(
      height: 56,
      width: 260,
      // color: Colors.amber,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "36.1716° N, 115.1391° W",
                style: lngLatTextStyle.copyWith(fontSize: 10),
              ),
              Text(
                "Clark County, Las Vegas, NV, USA",
                style:
                    TextStyle(fontSize: 16, color: Colors.black54, height: 1),
              ),
            ],
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: "<<点击使用"),
              TextSpan(
                  text: "我的位置", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ">>")
            ]),
            style: TextStyle(
                height: 1,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black87),
          )
        ],
      ),
    );
  }

  Widget buildDateTimeSelectionContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValueListenableBuilder(
            valueListenable: _timezoneLocationViewModel.selectedTimeNotifier,
            builder: (ctx, birthTime, _) {
              return InkWell(
                onTap: () async {
                  if (birthTime == null) {
                    stopNowClockTimer();
                    _timezoneLocationViewModel.updateDatetime(tzNow());
                  } else {
                    final result = await showBoardDateTimePicker(
                        context: context,
                        pickerType: DateTimePickerType.datetime,
                        initialDate:
                            _timezoneLocationViewModel.selectedDatetime!);
                    if (result != null) {
                      _timezoneLocationViewModel.updateDatetime(result);
                      // _selectedBirthTimeNotifier.value = result;
                      // handleDSTTime(result, _timezoneNotifier.value!);
                    }
                  }
                },
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(12),
                    padding: EdgeInsets.all(6),
                    color: Colors.grey,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: birthTime == null
                          ? buildNowClockTime()
                          : buildBirthDatetime(birthTime)),
                ),
              );
            }),
        SizedBox(width: 4),
        Column(
          children: [
            InkWell(
              onTap: () async {
                final result = await showBoardDateTimePicker(
                    context: context,
                    pickerType: DateTimePickerType.datetime,
                    initialDate: _timezoneLocationViewModel.selectedDatetime);
                if (result != null) {
                  // _selectedBirthTimeNotifier.value = result;
                  _timezoneLocationViewModel.updateDatetime(result);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                alignment: Alignment.center,
                height: 24,
                width: 48,
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueGrey.shade300,
                          blurRadius: 4,
                          spreadRadius: 4)
                    ]),
                child: Text("选择"),
              ),
            ),
            ValueListenableBuilder<DateTime?>(
                valueListenable: context
                    .read<TimezoneLocationViewModel>()
                    .selectedTimeNotifier,
                builder: (ctx, selectedTime, _) {
                  return InkWell(
                    onTap: () {
                      if (selectedTime == null) {
                        _timezoneLocationViewModel.updateDatetime(tzNow());
                      } else {
                        _timezoneLocationViewModel.updateDatetime(null);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      alignment: Alignment.center,
                      height: 24,
                      width: 48,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: selectedTime == null
                                  ? Colors.blueGrey
                                  : Colors.redAccent,
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withAlpha(40),
                                blurRadius: 4,
                                spreadRadius: 4)
                          ]),
                      child: selectedTime == null
                          ? Text(
                              "现在",
                              style: TextStyle(color: Colors.blueGrey),
                            )
                          : Text(
                              "取消",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                    ),
                  );
                }),
          ],
        )
      ],
    );
  }

  DateTime tzNow() {
    tz.TZDateTime tzSelectedBirthTime = tz.TZDateTime.from(
        DateTime.now(),
        tz.getLocation(context.read<TimezoneLocationViewModel>().timezone ??
            context.read<TimezoneLocationViewModel>().localTimezone!));
    return tzSelectedBirthTime.toDateTime();
  }

  Widget buildNowClockTime() {
    return Container(
      height: 56,
      width: 260,
      // color: Colors.amber,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: _nowClockTimeNotifier,
            builder: (ctx, currentDateTimeStr, _) {
              return Text.rich(
                TextSpan(text: currentDateTimeStr.item1, children: [
                  if (currentDateTimeStr.item2)
                    TextSpan(
                        text: "夏令时",
                        style: TextStyle(color: Colors.red, fontSize: 12))
                ]),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54),
              );
            },
          ),
          Text(
            "<<点击确认>>",
            style: TextStyle(
                height: 1,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black87),
          )
        ],
      ),
    );
  }

  Widget timezoneSelectionContent() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              alignment: Alignment.center,
              height: 24,
              width: 180,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      spreadRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ]),
              child: ValueListenableBuilder(
                  valueListenable: _timezoneLocationViewModel.timezoneNotifier,
                  builder: (ctx, timezoneStr, _) {
                    return Text(
                      timezoneStr!,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontFamily: "NotoSansSC",
                          shadows: [
                            Shadow(
                              color: Colors.grey.shade100.withAlpha(50),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ]),
                    );
                  })),
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    spreadRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ]),
            child: InkWell(
                onTap: () {
                  // alertSelectTimezone(
                  // _timezoneLocationViewModel.timezoneNotifier.value!);
                },
                child: Icon(
                  Icons.settings,
                  size: 18,
                )),
          )
        ]);
  }

  Widget buildSetTimezoneContentV1() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        alignment: Alignment.topCenter,
        // color: Colors.blue.withAlpha(100),
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            timezoneSelectionContent1(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildSetAsDefaultTimezoneContent(),
                Expanded(child: SizedBox()),
                buildRemoveDSTContent()
              ],
            )
          ],
        ));
  }

  Widget buildTimezoneDropdownList(double totalWidth, String? selectedTimezone,
      String? localTimezone, String? defaultTimezone) {
    return DropdownButton<String?>(
        isExpanded: true,
        menuWidth: totalWidth,
        value: selectedTimezone ?? pleaseSelectTimezoneStr,
        items: ([
          pleaseSelectTimezoneStr,
          ...tz.timeZoneDatabase.locations.keys.toList()
        ]).map((String value) {
          return DropdownMenuItem<String>(
              value: value,
              child: Text.rich(
                TextSpan(
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                        height: 1),
                    children: [
                      TextSpan(
                          text: value,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      if (localTimezone == value || defaultTimezone == value)
                        TextSpan(
                          text: " (",
                        ),
                      if (localTimezone == value)
                        TextSpan(
                          text: "本地",
                        ),
                      if (localTimezone == value && defaultTimezone == value)
                        TextSpan(text: "/"),
                      if (defaultTimezone == value)
                        TextSpan(
                          text: "默认",
                        ),
                      if (localTimezone == value || defaultTimezone == value)
                        TextSpan(text: ")")
                    ]),
              ));
        }).toList(),
        onChanged: _timezoneLocationViewModel.updateTimezone);
  }

  String get pleaseSelectTimezoneStr {
    return "请选择时区";
  }

  void doSelectCity(Location? location) async {
    // 显示城市选择器底部弹窗
    final Address? newSelectedLocation;
    if (location != null) {
      // 显示城市选择器底部弹窗
      newSelectedLocation = await showCityPickerBottomSheet(
        context: context,
        initAddress: location.address!,
        myLocationNotifier: _timezoneLocationViewModel.myLocationNotifier,
      );
    } else {
      newSelectedLocation = await showCityPickerBottomSheet(
          context: context,
          initAddress: Address.defualtAddress,
          myLocationNotifier: _timezoneLocationViewModel.myLocationNotifier);
    }

    // 处理选择结果
    if (newSelectedLocation != null) {
      // print(selectedLocation.toJson());
      _timezoneLocationViewModel.addLocation(Location(
          address: newSelectedLocation,
          isReverseSpeculation: false,
          preciseCoordinates: null));
    }
  }

  Widget buildCityArea(Location location) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                location.address!.province.name,
                style: locationTextStyle,
              ),
              Text(
                " · ",
                style: locationTextStyle,
              ),
              if (location.address!.area != null)
                Text(
                  " · ",
                  style: locationTextStyle,
                ),
              if (location.address!.area != null)
                Text(
                  location.address!.city!.name,
                  style: locationTextStyle,
                ),
              if (location.address!.area != null)
                Text(
                  " · ",
                  style: locationTextStyle,
                ),
              if (location.address!.area != null)
                Text(
                  location.address!.area!.name,
                  style: locationTextStyle,
                ),
              IconButton(
                  onPressed: () => toLngLatSelectPage(null),
                  icon: Icon(Icons.map_rounded))
            ],
          ),
          Text.rich(
            TextSpan(
                style: lngLatTextStyle.copyWith(color: Colors.black87),
                children: [
                  TextSpan(
                      text:
                          "${location.coordinates!.longitude}, ${location.coordinates!.latitude}")
                ]),
          ),
          Text.rich(
            TextSpan(
                text: "(行政中心坐标)",
                style: lngLatTextStyle.copyWith(color: Colors.black45)),
          )
        ]);
  }

  Widget buildSetAsDefaultTimezoneContent() {
    return SizedBox(
      // height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder(
              valueListenable:
                  _timezoneLocationViewModel.isDefaultTimezoneNotifier,
              builder: (ctx, isDefaultTimezone, _) {
                return Checkbox(
                    value: isDefaultTimezone,
                    onChanged:
                        _timezoneLocationViewModel.onIsDefaultTimezoneChanged);
              }),
          SizedBox(
            width: 2,
          ),
          Text(
            "设为默认时区",
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1),
          ),
        ],
      ),
    );
  }

  Widget buildRemoveDSTContent() {
    return Tooltip(
      message: "开启后当时间为“夏令时”，则自动调整回自然时间",
      child: Container(
        child: ValueListenableBuilder(
          valueListenable: _timezoneLocationViewModel.isDSTNotifier,
          builder: (context, isDST, _) {
            return ValueListenableBuilder(
              valueListenable:
                  _timezoneLocationViewModel.isAutoHandleDSTNotifier,
              builder: (ctx, isANSI, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterSwitch(
                        width: 32,
                        height: 16,
                        padding: 2,
                        value: isANSI,
                        toggleSize: 12,
                        showOnOff: false,
                        onToggle: _timezoneLocationViewModel
                            .onAutoHandleTimezoneChanged),
                    SizedBox(
                      width: 4,
                    ),
                    AnimatedDefaultTextStyle(
                      child: Text("自动移除夏令时"),
                      style: TextStyle(
                        height: 1,
                        fontSize: 12,
                        color: isANSI ? Colors.black87 : Colors.grey,
                      ),
                      duration: Duration(milliseconds: 100),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @Deprecated("已废弃")
  void toLngLatSelectPage(Location? location) {
    if (location != null) {
      Navigator.pushNamed(context, '/common/maps', arguments: {
        "seekerCoordinate": context
            .read<TimezoneLocationViewModel>()
            .myLocationNotifier
            .value
            ?.coordinates,
        "location": location.address,
        "myCoordinate": Coordinates(
            longitude: location.coordinates!.longitude,
            latitude: location.coordinates!.latitude)
      }).then((val) {
        if (val != null) {
          _timezoneLocationViewModel.addLocation(
              location.copyWith(preciseCoordinates: val as Coordinates));
        }
      });
    } else {
      InteractiveToast.pop(
        context: context,
        title: const Text("为了便于后续操作请先选择出生地"),
        toastSetting: const PopupToastSetting(
          animationDuration: Duration(seconds: 2),
          displayDuration: Duration(seconds: 20),
          toastAlignment: Alignment.bottomCenter,
        ),
      );
    }
  }

  Widget timezoneSelectionContent1() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              ValueListenableBuilder<String?>(
                  valueListenable: _timezoneLocationViewModel.timezoneNotifier,
                  builder: (context, timezoneStr, _) {
                    return ValueListenableBuilder<String?>(
                        valueListenable:
                            _timezoneLocationViewModel.defaultTimezoneNotifier,
                        builder: (ctx, defaultTimezone, _) {
                          return SizedBox(
                            width: 280,
                            height: 48,
                            child: buildTimezoneDropdownList(
                                256,
                                timezoneStr,
                                _timezoneLocationViewModel.localTimezone,
                                defaultTimezone),
                          );
                        });
                  }),
              Container(
                height: 18,
                width: 280,
                alignment: Alignment.topCenter,
                // color: Colors.greenAccent.withAlpha(20),
                child: ValueListenableBuilder<Tuple2<TimezoneType, String>?>(
                  valueListenable:
                      _timezoneLocationViewModel.displayDefaultTimezoneNotifier,
                  builder: (context, tuple, _) {
                    if (tuple == null) {
                      return SizedBox();
                    }
                    String hintText;
                    Color hintTextColor = Colors.grey;
                    switch (tuple!.item1) {
                      case TimezoneType.defaultTimezone:
                        hintText = "默认时区：";
                        hintTextColor = Colors.grey;
                        break;
                      case TimezoneType.localTimezone:
                        hintText = "本机时区：";
                        hintTextColor = Colors.grey;
                        break;
                      case TimezoneType.globalCountryTimezoneChanged:
                        hintText = "新位置时区：";
                        hintTextColor = Colors.pinkAccent;
                        Future.delayed(Duration(milliseconds: 600), () {
                          (isGlobalTimezoneChangedShakeMeKey.currentState
                                  as ShakeWidgetState)
                              .shake();
                        });
                        break;
                      case TimezoneType.myLocationTimeZone:
                        hintText = "“我的位置”时区：";
                        hintTextColor = Colors.redAccent;
                        Future.delayed(Duration(milliseconds: 600), () {
                          (isGlobalTimezoneChangedShakeMeKey.currentState
                                  as ShakeWidgetState)
                              .shake();
                        });
                        break;
                    }
                    TextStyle hintTextStyle = TextStyle(
                        fontSize: 12,
                        color: hintTextColor,
                        height: 1,
                        fontFamily: "NotoSansSC");
                    String timezoneStr = tuple!.item2;
                    return Container(
                        // padding: EdgeInsets.symmetric(horizontal: 24),
                        child: ShakeMe(
                      // 4. pass the GlobalKey as an argument
                      // 5. configure the animation parameters
                      shakeCount: 3,
                      shakeOffset: 12,
                      shakeDuration: Duration(seconds: 1),
                      key: isGlobalTimezoneChangedShakeMeKey,
                      child: TextButton(
                          onPressed: () {
                            _timezoneLocationViewModel
                                .updateTimezone(timezoneStr);
                          },
                          child: Text.rich(
                            TextSpan(
                                text: hintText,
                                style: hintTextStyle,
                                children: [TextSpan(text: timezoneStr)]),
                          )),
                    ));
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  Widget selectDateTimeButton() {
    Duration duration = Duration(milliseconds: 400);
    double largeFontSize = 28;
    double smallFontSize = 16;
    return ValueListenableBuilder(
        valueListenable: _timezoneLocationViewModel.selectedTimeNotifier,
        builder: (ctx, dateTime, _) {
          return ValueListenableBuilder(
              valueListenable:
                  _timezoneLocationViewModel.selectedDSTTimeNotifer,
              builder: (ctx, dstTime, _) {
                return AnimatedContainer(
                  duration: Duration.zero,
                  margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  alignment: Alignment.topCenter,
                  // color: Colors.blue.withAlpha(100),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  // width: 512,
                  // height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 命主生时 title
                      AnimatedContainer(
                          duration: duration,
                          alignment: dateTime == null
                              ? Alignment.bottomCenter
                              : Alignment.topLeft,
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            child: Text("命主生时"),
                            style: dateTime == null
                                ? TextStyle(
                                    fontSize: smallFontSize,
                                    height: 1.0,
                                    color: Colors.black87)
                                : TextStyle(
                                    fontSize: smallFontSize,
                                    height: 1.0,
                                    color: Colors.black87,
                                  ),
                          )),
                      // 命主生时选择结果
                      ValueListenableBuilder(
                          valueListenable:
                              _timezoneLocationViewModel.isDSTNotifier,
                          builder: (ctx, dst, _) {
                            return birthDatetimeResult(dateTime, dstTime, dst);
                          }),
                      AnimatedContainer(
                        duration: duration,
                        padding: const EdgeInsets.all(4),
                        alignment: dateTime == null
                            ? Alignment.topCenter
                            : Alignment.bottomCenter,
                        // margin: EdgeInsets.only(top: 12),
                        child: InkWell(
                          onTap: () async {
                            final result = await showBoardDateTimePicker(
                                context: context,
                                pickerType: DateTimePickerType.datetime,
                                initialDate: _timezoneLocationViewModel
                                    .selectedDatetime);
                            if (result != null) {
                              // handleDSTTime(
                              //     result,
                              //     _timezoneLocationViewModel
                              //                   .timezoneNotifier.value!);
                            }
                          },
                          child: AnimatedContainer(
                              duration: duration,
                              width: dateTime == null ? 180 : 128,
                              height: dateTime == null ? 48 : 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26.withAlpha(20),
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        spreadRadius: 2)
                                  ]),
                              child: AnimatedDefaultTextStyle(
                                duration: duration,
                                child: Text(
                                  "选择时间",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: dateTime == null
                                    ? TextStyle(fontSize: largeFontSize)
                                    : TextStyle(fontSize: smallFontSize),
                              )),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  Widget buildBirthDatetime(DateTime dateTime) {
    return ValueListenableBuilder(
        valueListenable: _timezoneLocationViewModel.selectedDSTTimeNotifer,
        builder: (ctx, dstTime, _) {
          return ValueListenableBuilder(
              valueListenable: _timezoneLocationViewModel.isDSTNotifier,
              builder: (ctx, dst, _) {
                return birthDatetimeResult(dateTime, dstTime, dst);
              });
        });
  }

  Widget birthDatetimeResult(
      DateTime? dateTime, DateTime? dstTime, bool isDST) {
    Duration duration = Duration(milliseconds: 400);

    double totalHeight = 56;
    double smallHeight = 24;
    double width = 240;
    double largeFontSize = 24;
    double smallFontSize = 12;
    double dstFontSize = 10;
    return AnimatedContainer(
      duration: duration,
      // height: dateTime == null ? 0 : totalHeight,
      height: totalHeight,
      width: width,
      alignment: Alignment.center,
      // color: Colors.red.withAlpha(100),
      // decoration: BoxDecoration(
      //     // color: Colors.white,
      //     // borderRadius: BorderRadius.circular(100),
      //     // border: Border.all(color: Colors.black54, width: 1),
      //     // borderRadius: BorderRadius.circular(12),
      //     boxShadow: [
      //       BoxShadow(
      //           color: Colors.black26.withAlpha(20),
      //           offset: Offset(1, 1),
      //           blurRadius: 2,
      //           spreadRadius: 2)
      //     ]),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: duration,
              alignment:
                  dstTime == null ? Alignment.center : Alignment.bottomCenter,
              height: dstTime == null ? totalHeight : smallHeight,
              width: width,
              child: dateTime == null
                  ? SizedBox()
                  : AnimatedDefaultTextStyle(
                      child: Text.rich(TextSpan(
                          text: dateTimeFormat.format(dateTime),
                          children: [
                            if (isDST)
                              TextSpan(
                                  text: "夏令时",
                                  style: TextStyle(
                                      color: dstTime == null
                                          ? Colors.red
                                          : Colors.black38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: dstFontSize))
                          ])),
                      style: dstTime == null
                          ? TextStyle(
                              fontSize: largeFontSize,
                              color: Colors.black87,
                              height: 1)
                          : TextStyle(
                              fontSize: smallFontSize,
                              color: Colors.black38,
                              height: 1,
                              decoration: TextDecoration.lineThrough),
                      duration: duration),
            ),
            AnimatedContainer(
              duration: duration,
              height: dstTime == null ? 0 : totalHeight - smallHeight,
              width: width,
              alignment: Alignment.topCenter,
              child: dstTime == null
                  ? SizedBox()
                  : AnimatedDefaultTextStyle(
                      child: Text(dateTimeFormat.format(dstTime)),
                      style: TextStyle(
                          fontSize: largeFontSize,
                          color: Colors.black87,
                          height: 1),
                      duration: duration),
            )
          ]),
    );
  }

  void helpTooltipTapped(EnumDatetimeType datetimeType) {
    switch (datetimeType) {
      case EnumDatetimeType.standard:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.standard]!);
        break;
      case EnumDatetimeType.removeDST:
        throw UnimplementedError();
      case EnumDatetimeType.meanSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.meanSolar]!);
        break;
      case EnumDatetimeType.trueSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.trueSolar]!);
        break;
      default:
        throw UnimplementedError();
    }
  }

  /// 获取滑块未激活状态的文本样式
  TextStyle _getSwitcherInactivatedStyle() {
    return const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
        fontFamily: "NotoSansSC"
        // color: AppTheme.secondaryText,
        );
  }

  /// 获取滑块激活状态的文本样式
  TextStyle _getSwitcherActivatedStyle(Color color) {
    return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: "NotoSansSC"
        // color: AppTheme.primaryColor,
        );
  }
}

class QueryDateTimeHeplperModel {
  EnumDatetimeType datetimeType;
  final String shortText;
  final String longText;
  final String warningText;
  final String example;
  final String formula;

  QueryDateTimeHeplperModel(
      {required this.datetimeType,
      required this.shortText,
      required this.longText,
      required this.warningText,
      required this.example,
      required this.formula});

  static Map<EnumDatetimeType, QueryDateTimeHeplperModel> datetimeHelperMapper =
      {
    EnumDatetimeType.standard: QueryDateTimeHeplperModel(
        datetimeType: EnumDatetimeType.standard,
        shortText: "基于时区划分的官方统一时间",
        longText:
            "“标准时间”是一个国家或地区为统一时间管理而采用的法定时间系统，以地球自转为基础，将全球划分为24个时区（每个时区跨度15°经度），每个时区采用与UTC（协调世界时）固定偏移的时间。例如：\n 中国统一使用“北京时间”（UTC+8），美国本土划分为东部时间（UTC-5）、中部时间（UTC-6）等时区。",
        warningText: "标准时间不考虑地方太阳时差异，可能与实际太阳位置存在偏差。如新疆西藏地区处于东六区，但仍使用东八区",
        formula: "标准时间 = UTC + 时区偏移量（如北京为UTC+8）",
        example:
            "如：UTC时间为“2025年3月14日 00:00”，则：\n - 北京时间（UTC+8）为“2025年3月14日 08:00”\n - 纽约时间（UTC-5）为“2025年3月13日 19:00”（冬令时）或“2025年3月13日 20:00”（夏令时）"),
    EnumDatetimeType.meanSolar: QueryDateTimeHeplperModel(
        datetimeType: EnumDatetimeType.meanSolar,
        shortText: "根据出生地的经度进一步精确生时",
        longText:
            "“平太阳时”是基于平均太阳日制定的时间系统，通过将地球公转轨道视为正圆形来消除实际轨道偏心率的影响，结合出生地经度与时区中央经度的差值进行时间修正，形成规则化计时体系，是日常生活使用的标准时间基础。",
        warningText: "精确地出生时间与出生地点，可以极大降低“平太阳时”的误差",
        formula: "平太阳时=标准时间+4×(当地经度−120°）分钟",
        example:
            "如：北京时间(东八区标准时间)为“2025年3月13日 23:15”,新疆乌鲁木齐当地平太阳时为“2025年3月13日 21:05”，时差为2小时10分"),
    EnumDatetimeType.trueSolar: QueryDateTimeHeplperModel(
        datetimeType: EnumDatetimeType.trueSolar,
        shortText: "根据均时差进一步精确生时",
        longText:
            "“真太阳时”是基于太阳在天空中实际位置的时间系统，它考虑了地球公转轨道的椭圆形状和地轴倾斜对太阳运动速度的影响，通过计算“均时差”对“平太阳时”进行修正，以获得更精确的太阳位置时间。\n 是由地球公转轨道椭圆性和地轴倾斜引起的真太阳时与平太阳时的周期性时间偏差，全年波动范围约为 -16分钟至+14分钟。",
        warningText: "精确的出生时间和地点以及均时差的计算，可以极大降低“真太阳时”的误差",
        formula: "真太阳时=平太阳时+均时差",
        example:
            "如：北京时间(东八区标准时间)为“2025年3月13日 23:15”，新疆乌鲁木齐当地平太阳时为“2025年3月13日 21:05”，通过计算得到当日均时差为“-7分26秒”，真太阳时为“2025年3月13日 20:57:34”")
  };
}
