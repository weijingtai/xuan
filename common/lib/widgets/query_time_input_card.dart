import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/common_logger.dart';
import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/sp_timezone_datamodel.dart';
import 'package:common/widgets/city_picker_bottom_sheet.dart';
import 'package:common/widgets/eight_chars_input_card.dart';
import 'package:common/widgets/eight_chars_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
// import 'package:timezone_dropdown/timezone_dropdown.dart';
// import 'package:timezone/data/latest.dart' as tz;

import '../enums/enum_gender.dart';
import '../helpers/solar_lunar_datetime_helper.dart';
import '../models/query_datetime.dart';
import 'eight_chars_selection_card.dart';
import 'gan_zhi_picker_alert_dialog.dart';
import 'responseive_datetime_dialog.dart';

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

enum PageType {
  datetime(0),
  chineseTraditional(1),
  eightChars(2);

  final int pageIndex;
  const PageType(this.pageIndex);
  // get by pageIndex
  static PageType getFromPageIndex(int index) {
    switch (index) {
      case 0:
        return datetime;
      case 1:
        return chineseTraditional;
      case 2:
        return eightChars;
      default:
        return datetime;
    }
  }
}

class QueryTimeInputCard extends StatefulWidget {
  // final String defaultTimeZone;
  final PageType defaultPageType;
  final AppFeatureModule appFeatureModule;
  final ValueNotifier<List<MapEntry<EnumDatetimeType,QueryDatetimeModel>>?> selectableCardsNotifier;
  const QueryTimeInputCard(
      {super.key,
      // required this.defaultTimeZone,
      required this.defaultPageType,
        required this.selectableCardsNotifier,
      this.appFeatureModule = AppFeatureModule.Golabel});

  @override
  State<QueryTimeInputCard> createState() => _QueryTimeInputCardState();
}

class _QueryTimeInputCardState extends State<QueryTimeInputCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey isDSTShakeMeKey = GlobalKey<ShakeWidgetState>();
  late AnimationController _controller;

  late PageController _pageController;

  late TextEditingController _nameController;

  late final ValueNotifier<PageType> _tabSelectNotifier;

  late final ValueNotifier<String?> _inputNameNotifier;
  late final ValueNotifier<Gender> _inputGenderNotifier;

  late final ValueNotifier<DateTime?> _selectedBirthTimeNotifier;
  late final ValueNotifier<DateTime?> _DSTBirthTimeNotifier;

  late final ValueNotifier<bool> showTimezoneAtTitleNotifier = ValueNotifier(false);

  late final ValueNotifier<bool> _isAutoHandleDSTNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> _isDefaultTimezoneNotifier = ValueNotifier(false);
  late final ValueNotifier<String?> _timezoneNotifier = ValueNotifier<String?>(null);
  // late final ValueNotifier<String?> _lastTimezoneNotifier = ValueNotifier<String?>("America/Los_Angeles");
  late final ValueNotifier<String?> _localTimezoneNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<SPTimezoneDataModel?> _spTimezoneDataModelNotifier = ValueNotifier<SPTimezoneDataModel?>(null);

  late final ValueNotifier<bool> _isDSTNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<Location?> _locationNotifier;

  final CommonLogger _commonLogger = CommonLogger();
  Logger get l => _commonLogger.logger;
  // late TabController _tabController;
  late final ValueNotifier<Coordinates?> _coordinatesValueNotifier;

  DateFormat timeFormat = DateFormat("HH:mm");
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

  @override
  void initState() {
    super.initState();
    String queryUuid = Uuid().v4();
    _nameController = TextEditingController();
    _controller = AnimationController(vsync: this);
    _tabSelectNotifier = ValueNotifier<PageType>(widget.defaultPageType);
    _tabSelectNotifier.addListener(() {
      _pageController.animateToPage(_tabSelectNotifier.value.pageIndex,
          duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      // _pageController.jumpToPage(_tabSelectNotifier.value.pageIndex);
    });
    _inputNameNotifier = ValueNotifier<String?>(null);
    _inputGenderNotifier = ValueNotifier<Gender>(Gender.male);
    _pageController =
        PageController(initialPage: _tabSelectNotifier.value.pageIndex);

    // _removeDSTTimeNotifier = ValueNotifier(false);

    // 监听事件、以及时区变化，实时验算是否为夏令时时间
    _DSTBirthTimeNotifier = ValueNotifier(null);
    _selectedBirthTimeNotifier = ValueNotifier(null)
      ..addListener(() {
        if (_selectedBirthTimeNotifier.value != null && _timezoneNotifier.value != null) {
          checkDST(_selectedBirthTimeNotifier.value!, _timezoneNotifier.value!);
        }
        setNormalAndDSTSelectableCards(queryUuid);
      });

    _spTimezoneDataModelNotifier.addListener((){
      final timezoneDataModel = _spTimezoneDataModelNotifier.value;
      _timezoneNotifier.value = timezoneDataModel?.timezoneStr ?? _localTimezoneNotifier.value;
      _isAutoHandleDSTNotifier.value = timezoneDataModel?.isAutoHandleDST ?? false;
      _isDefaultTimezoneNotifier.value = timezoneDataModel?.isDefaultTimezone ?? false;
    });
    _timezoneNotifier.addListener(() {
      if (_timezoneNotifier.value != null){
        if (_selectedBirthTimeNotifier.value != null) {
          checkDST(_selectedBirthTimeNotifier.value!, _timezoneNotifier.value!);
        }
        // 检查是否需要勾选“isDefaultTimeZone”
        final _spTimezoneDataModel = _spTimezoneDataModelNotifier.value;
        if (_spTimezoneDataModel != null && (_spTimezoneDataModel.isDefaultTimezone == true)){
          _isDefaultTimezoneNotifier.value = _spTimezoneDataModel.timezoneStr == _timezoneNotifier.value;
        }

      }
    });
    loadTimezoneDataModelFromShared().then((timezoneDataModel){
      if (timezoneDataModel !=null){
        l.d(timezoneDataModel.toJson());
        _spTimezoneDataModelNotifier.value = timezoneDataModel;
      }

    });
    // 获取本地时区时间
    l.i("get local timezone as selectedTimezone");
    FlutterTimezone.getLocalTimezone()
        .then((timezoneName){
      if (_timezoneNotifier.value == null){
        _timezoneNotifier.value = timezoneName;
      }
      _localTimezoneNotifier.value = timezoneName;
    });

    _isAutoHandleDSTNotifier.addListener((){

      if (_isAutoHandleDSTNotifier.value){
        // 检查是否需要将用户选择的时间转换为非DST时间
        if (_selectedBirthTimeNotifier.value != null && _timezoneNotifier.value != null){
          handleDSTTime(_selectedBirthTimeNotifier.value!, _timezoneNotifier.value!);
        }
      }else{
        // 不再处理DST时，检查是否需要将用户选择的时间转换为非DST时间
        unhandleDSTTime();

      }

    });
    _locationNotifier = ValueNotifier(null)..addListener((){
      if (_locationNotifier.value !=null){
        setMeanSolarAndTrueSolarSelectableCards(queryUuid,false);
      }
    });
    _coordinatesValueNotifier = ValueNotifier(null)..addListener((){
      if (_coordinatesValueNotifier.value != null){
        l.i("手动校准经纬为 ${_coordinatesValueNotifier.value}");
        setMeanSolarAndTrueSolarSelectableCards(queryUuid,true);
      }
    });
    // _tabController = TabController(length: 3, vsync: this);
  }
  void setNormalAndDSTSelectableCards(String queryUuid){
    if (_selectedBirthTimeNotifier.value != null && _timezoneNotifier.value != null){
      // if (widget.selectableCardsNotifier.value?.isNotEmpty ?? false){
      // }
      widget.selectableCardsNotifier.value = [];
      String timezoneStr = _timezoneNotifier.value!;
      DateTime selectedBirthTime = _selectedBirthTimeNotifier.value!;
      // check is summary DST
      final tzSelectedBirthTime = tz.TZDateTime.from(selectedBirthTime, tz.getLocation(timezoneStr));
      final isDST = tzSelectedBirthTime.timeZone.isDst;
      final QueryDatetimeModel normalQueryDateTime = SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(queryUuid,selectedBirthTime,timezoneStr, isDST);

      if (isDST){
        // 当前为 DST 时间
        // 将 selectedBirthTime 转换为非DST时间
        DateTime nonDSTDateTime = selectedBirthTime.subtract(Duration(hours: 1));
        QueryDatetimeModel removeDSTQueryDateTime = SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(queryUuid,nonDSTDateTime, timezoneStr, -1);
        widget.selectableCardsNotifier.value!.add(MapEntry(EnumDatetimeType.removeDST, removeDSTQueryDateTime));
      }
      widget.selectableCardsNotifier.value!.add(MapEntry(EnumDatetimeType.standard, normalQueryDateTime));


    }
    if (_selectedBirthTimeNotifier.value == null && (widget.selectableCardsNotifier.value?.isNotEmpty ?? false)){
     widget.selectableCardsNotifier.value = [];
    }
  }


  void setMeanSolarAndTrueSolarSelectableCards(String queryUuid,bool isToManual){
    if (_locationNotifier.value != null){
      EnumDatetimeType meanType = EnumDatetimeType.meanSolar;
      EnumDatetimeType trueType = EnumDatetimeType.trueSolar;
      final Location location = _locationNotifier.value!;
      l.i("set meanSolar datetime");
      // 如果存在前一个 location 的八字，则先移除
      if ((widget.selectableCardsNotifier.value?.isNotEmpty ?? false )){
        if (widget.selectableCardsNotifier.value!.map((e)=>e.key).contains(meanType)){
          l.i("there is a ${meanType.name} datetime in selectable card list, remove it before add new");
          widget.selectableCardsNotifier.value!.removeWhere((element) => element.key == trueType);
        }
        if (widget.selectableCardsNotifier.value!.map((e)=>e.key).contains(trueType)){
          l.i("there is a ${trueType.name} datetime in selectable card list, remove it before add new");
          widget.selectableCardsNotifier.value!.removeWhere((element) => element.key == trueType);
        }
        
      }

      if (_selectedBirthTimeNotifier.value != null && _timezoneNotifier.value != null){
        final tzDateTime = tz.TZDateTime.from(_selectedBirthTimeNotifier.value!, tz.getLocation(_timezoneNotifier.value!));
        print("selectedBirthTime: ${_selectedBirthTimeNotifier.value}");
        print("tzDateTime: ${tzDateTime}");
        final meanSolarDateTime = SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(queryUuid,tzDateTime, location);
        final trueSolarDateTime = SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(queryUuid,meanSolarDateTime.datetime,_timezoneNotifier.value!, isToManual?_coordinatesValueNotifier.value!:location.coordinates);
        l.i("add new ${isToManual?"manualMeanSolar":"meanSolar"} to selectable card");
        l.t(meanSolarDateTime);
        l.i("add new ${isToManual?"manualTrueSolar":"trueSolar"} to selectable card");
        l.t(trueSolarDateTime);

        List<MapEntry<EnumDatetimeType, QueryDatetimeModel>> clonedEntries = widget.selectableCardsNotifier.value!.map((e)=>e).toList();
        widget.selectableCardsNotifier.value = clonedEntries..addAll([
          MapEntry(meanType, isToManual?meanSolarDateTime.clone(isManual:true):meanSolarDateTime),
          MapEntry(trueType, isToManual?trueSolarDateTime.clone(isManual:true):trueSolarDateTime)]);
        // widget.selectableCardsNotifier.value!..add(MapEntry(EnumDatetimeType.meanSolar, meanSolarDateTime));
      }

    }

  }
  Future<SPTimezoneDataModel?> loadTimezoneDataModelFromShared([AppFeatureModule appFeatureModule=AppFeatureModule.Golabel]) async{
    l.i("get ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} from SharedPreference");
    final sp = await SharedPreferences.getInstance();
    var result = sp.getString("${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey}");
    if (result == null){
      l.i("there is not ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} in SharedPreference");
      return null;
    }
    l.i("get ${appFeatureModule.spPrefix}${SPTimezoneDataModel.SharedPreferencesBaseKey} from SharedPreference success. [$result]");
    l.t(result);

    return SPTimezoneDataModel.fromJson(jsonDecode(result));
  }
  // 返回isDefaultTimezone 结果
  Future<bool> saveTimezoneDataModel(SPTimezoneDataModel timezoneDataModel) async{
    l.i("save ${timezoneDataModel.spKey} to SharedPreference");
    final sp = await SharedPreferences.getInstance();
    bool result = await sp.setString(timezoneDataModel.spKey, jsonEncode(timezoneDataModel.toJson()));
    if (result){
      l.i("save ${timezoneDataModel.spKey} success.");
    }else{
      l.e("save ${timezoneDataModel.spKey} failed.");
    }
    return timezoneDataModel.isDefaultTimezone ?? false;
  }
  Map<EnumDatetimeType, QueryDatetimeModel> _mapper = {};
  void calculateEightChars(String queryUuid,DateTime? datetime){
    if (datetime != null){
      if (_isDSTNotifier.value){
        l.i("出生时间为夏令时时间，根据夏令时时间计算 八字等信息, 同时给出移除夏令时后的时间");
        final dstDateTime = SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(queryUuid,datetime,_timezoneNotifier.value!,true);
        final removedDSTDateTime = SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(queryUuid,datetime,_timezoneNotifier.value!,-1);
        _mapper[EnumDatetimeType.removeDST] = removedDSTDateTime;
        _mapper[EnumDatetimeType.standard] = dstDateTime;
      }else{
        l.i("当前为非“夏令时”,");
        final normalDateTimeInfo = SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(queryUuid,datetime,_timezoneNotifier.value!,false);
        _mapper[EnumDatetimeType.standard] = normalDateTimeInfo;
      }
      calculateEightCharByLocation(queryUuid,datetime,_timezoneNotifier.value!);

    }

  }
  void calculateEightCharByLocation(String queryUuid,DateTime datetime,String timezoneStr){
    // 检查用户是否选择了“出生地”，如果选择出生地

    if (_locationNotifier.value != null){
      final tz.TZDateTime result = tz.TZDateTime.from(datetime, tz.getLocation(timezoneStr));
      final meanDateTimeInfo = SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(queryUuid,result,_locationNotifier.value!);
      _mapper[EnumDatetimeType.meanSolar] = meanDateTimeInfo;
      if (_locationNotifier.value!.area != null){
        final normalDateTimeInfo = SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(queryUuid,meanDateTimeInfo.datetime,timezoneStr,_locationNotifier.value!.area!.coordinates);
        _mapper[EnumDatetimeType.trueSolar] = normalDateTimeInfo;
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _inputNameNotifier.dispose();
    _inputGenderNotifier.dispose();
    _pageController.dispose();
    _DSTBirthTimeNotifier.dispose();
    _isDefaultTimezoneNotifier.dispose();

    _spTimezoneDataModelNotifier.dispose();

    _isAutoHandleDSTNotifier.dispose();
    _timezoneNotifier.dispose();
    // _lastTimezoneNotifier.dispose();
    _selectedBirthTimeNotifier.dispose();
    _locationNotifier.dispose();
    _isDSTNotifier.dispose();
    _localTimezoneNotifier.dispose();
    showTimezoneAtTitleNotifier.dispose();
    _coordinatesValueNotifier.dispose();

    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 512,
      height: 512 + 128,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(2, 2),
              color: Colors.black45.withAlpha(100),
            )
          ]),
      child: _mainContainer(),
    );
  }

  Widget _mainContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 512 - 48,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 200, height: 42, child: _buildNameInput()),
              _buildGenderSelector(),
            ],
          ),
        ),
        SizedBox(
          width: 512 - 48,
          height: 480,
          child: timeTab(512 - 48),
          ),
        // SizedBox(height: 24),
      ],
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
                  _tabSelectNotifier.value = PageType.getFromPageIndex(index);
                },
                containerHeight: 48,
                containerWight: width,
                indents: 4,
                // containerColor: const Color(0xffe4e5eb),
                slidersColors: const [Color(0xfff7f5f7)],
                containerBoxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 4,
                  )
                ],
                children: [
                  Text(
                    "时间",
                    style: tabIndex != PageType.datetime
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(),
                  ),
                  Text(
                    "农历",
                    style: tabIndex != PageType.chineseTraditional
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(),
                  ),
                  Text(
                    "八字",
                    style: tabIndex != PageType.eightChars
                        ? _getSwitcherInactivatedStyle()
                        : _getSwitcherActivatedStyle(),
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
  TextStyle locationTextStyle = const TextStyle(
      height:1,fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600,fontFamily: "NotoSansSC");
  TextStyle lngLatTextStyle =
  const TextStyle(fontSize: 14, color: Colors.grey,fontFamily: "NotoSansSC");

  TextStyle titleTextStyle =
  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: Colors.black87,fontFamily: "NotoSansSC");
  TextStyle warningSubtitleTextStyle =
  TextStyle(color: Colors.amber[900]!.withAlpha(180), fontSize: 14,fontFamily: "NotoSansSC");


  Widget _buildTimeSelectionContent() {
    return Container(
        alignment: Alignment.topCenter,
        // color: Colors.blue,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  alignment: Alignment.topCenter,
                  // color: Colors.blue.withAlpha(100),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: timezoneSelectionContent()
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  alignment: Alignment.topCenter,
                  // color: Colors.blue.withAlpha(100),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: selectDateTimeButton(),
              ),

              ValueListenableBuilder<Location?>(
                    valueListenable: _locationNotifier,
                builder: (ctx,location,_) {
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    child:location != null ?buildCityArea(location):SizedBox(),
                  );
                }
              ),

              ElevatedButton(
                  onPressed: () async {
                    // 显示城市选择器底部弹窗
                    final Location? selectedLocation =
                    await showCityPickerBottomSheet(
                      context: context,
                      initLocation: Location.defualtLocation,
                    );
                    // 处理选择结果
                    if (selectedLocation != null) {
                      // print(selectedLocation.toJson());
                      _locationNotifier.value = selectedLocation;
                    }
                  },
                  child: const Text("选择地区")),
              IconButton(
                  onPressed: toLngLatSelectPage,
                  icon: Icon(Icons.map_rounded)),


              // ValueListenableBuilder<Location?>(
              //     valueListenable: _locationNotifier,
              //     builder: (ctx, location, child) {
              //       return ExpansionTile(
              //         subtitle: RichText(
              //             text: TextSpan(children: [
              //               location == null
              //                   ? TextSpan(
              //                   text: "需出生地", style: warningSubtitleTextStyle)
              //                   : TextSpan(
              //                   style: const TextStyle(color: Colors.black54,fontFamily: "NotoSansSC"),
              //                   text: location.province.name,
              //                   children: [
              //                     TextSpan(text: " · ${location.city.name}"),
              //                     if (location.area != null)
              //                       TextSpan(
              //                           text: " · ${location.area!.name}"),
              //                   ]),
              //             ])),
              //         title: RichText(
              //             text: TextSpan(
              //                 text: "平太阳时 ",
              //                 style: titleTextStyle,
              //                 children: [
              //                   WidgetSpan(
              //                       alignment: PlaceholderAlignment.top,
              //                       child: Tooltip(
              //                         message: "根据出生地经度进一步精确计算时间",
              //                         child: InkWell(
              //                           onTap: () {
              //                             helpTooltipTapped(
              //                                 EnumDatetimeType.meanSolar);
              //                           },
              //                           child: const Icon(Icons.help,
              //                               size: 12, color: Colors.grey),
              //                         ),
              //                       ))
              //                 ])),
              //         children: <Widget>[
              //           Container(
              //             padding: EdgeInsets.symmetric(
              //                 vertical: 16, horizontal: 24),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: [
              //                 location != null
              //                     ? Row(
              //                   children: [
              //                     Text(
              //                       location.province.name,
              //                       style: locationTextStyle,
              //                     ),
              //                     Text(
              //                       " · ",
              //                       style: locationTextStyle,
              //                     ),
              //                     Text(
              //                       location.city.name,
              //                       style: locationTextStyle,
              //                     ),
              //                     if (location.area != null)
              //                       Text(
              //                         " · ",
              //                         style: locationTextStyle,
              //                       ),
              //                     if (location.area != null)
              //                       Text(
              //                         location.area!.name,
              //                         style: locationTextStyle,
              //                       ),
              //                     IconButton(
              //                         onPressed: toLngLatSelectPage,
              //                         icon: Icon(Icons.map_rounded))
              //                   ],
              //                 )
              //                     : Text("请选择出生地", style: locationTextStyle),
              //                 Row(children: [
              //                   Text(
              //                     "经度：${location == null ? "??.??????" : location.area?.latitude ?? location.city.latitude}",
              //                     style: lngLatTextStyle,
              //                   ),
              //                   const SizedBox(width: 12),
              //                   Text(
              //                     "纬度：${location == null ? "??.??????" : location.area?.longitude ?? location.city.longitude}",
              //                     style: lngLatTextStyle,
              //                   ),
              //                 ])
              //               ],
              //             ),
              //           ),
              //           ElevatedButton(
              //               onPressed: () async {
              //                 // 显示城市选择器底部弹窗
              //                 final Location? selectedLocation =
              //                 await showCityPickerBottomSheet(
              //                   context: context,
              //                   initLocation: Location.defualtLocation,
              //                 );
              //                 // 处理选择结果
              //                 if (selectedLocation != null) {
              //                   // print(selectedLocation.toJson());
              //                   _locationNotifier.value = selectedLocation;
              //                 }
              //               },
              //               child: const Text("选择地区")),
              //         ],
              //       );
              //     }),
              // ExpansionTile(
              //   subtitle: RichText(
              //       text: TextSpan(
              //           text: "需经纬度", style: warningSubtitleTextStyle)),
              //   title: RichText(
              //       text: TextSpan(
              //           text: "真太阳时 ",
              //           style: titleTextStyle,
              //           children: [
              //             WidgetSpan(
              //                 alignment: PlaceholderAlignment.top,
              //                 child: Tooltip(
              //                   message:
              //                   "标准时间是指一个国家或地区统一采用的基于时区划分的本地时间，通常以格林尼治时间（GMT）或协调世界时（UTC）为基准。\n如：北京时间(UTC+8,东八区)",
              //                   child: InkWell(
              //                     onTap: () {
              //                       helpTooltipTapped(EnumDatetimeType.meanSolar);
              //                     },
              //                     child: const Icon(Icons.help,
              //                         size: 12, color: Colors.grey),
              //                   ),
              //                 ))
              //           ])),
              //   children: <Widget>[
              //     // IconButton(
              //     //     onPressed: toLngLatSelectPage,
              //     //     icon: Icon(Icons.map_rounded))
              //   ],
              // ),

            ],
          ),
        ));
  }
  Widget buildCityArea(Location location){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              location.province.name,
              style: locationTextStyle,
            ),
            Text(
              " · ",
              style: locationTextStyle,
            ),
            Text(
              location.city.name,
              style: locationTextStyle,
            ),
            if (location.area != null)
              Text(
                " · ",
                style: locationTextStyle,
              ),
            if (location.area != null)
              Text(
                location.area!.name,
                style: locationTextStyle,
              ),
            IconButton(
                onPressed: toLngLatSelectPage,
                icon: Icon(Icons.map_rounded))
          ],
        ),
        Text.rich(
          TextSpan(
            style: lngLatTextStyle.copyWith(color: Colors.black87),
            children: [
              TextSpan(
                  text:"${location.lowestGeoLocation.coordinates.longitude}, ${location.lowestGeoLocation.coordinates.latitude}"
              )
            ]
          ),
        ),
        Text.rich(
          TextSpan(text:"(行政中心坐标)",style: lngLatTextStyle.copyWith(color: Colors.black45)),
        )
      ]
    );
  }
  @deprecated
  Widget _timeSelectionContent() {
    return Container(
        alignment: Alignment.topCenter,
        // color: Colors.blue,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExpansionTile(
                initiallyExpanded: showTimezoneAtTitleNotifier.value,
                onExpansionChanged: (expanded){
                  showTimezoneAtTitleNotifier.value = !expanded;
                },
                subtitle: ValueListenableBuilder(
                    valueListenable: _isAutoHandleDSTNotifier,
                    builder: (context, isAutoHandleDST, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRect(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                                      // 上下滑动动画：新组件从上方进入，旧组件从下方退出
                                                      return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0.0, -1.0), // 从上方开始（y轴方向）
                                end: Offset.zero,          // 移动到中心
                              ).animate(animation),
                              child: child,
                                                      );
                                },
                                child: isAutoHandleDST
                                    ? Text(
                                  key: ValueKey("isAutoRemoveDST"),
                                    "移除",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87,fontFamily: "NotoSansSC"))
                                    :Text(
                                    key: ValueKey("isNotAutoRemoveDST"),
                                    "保留",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87,fontFamily: "NotoSansSC")),
                              ),
                            ),
                          ),
                          // SizedBox(width: 4,),
                          Text("夏令时", style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.normal,fontFamily: "NotoSansSC")),
                          Tooltip(
                            message:
                            "在每年夏季，人为调快1小时(相对于时区标准时间)，以达到充分利用光照的目的。\n如：1986-1991(中国)，1918至今（美国）",
                            child: InkWell(
                              onTap: () {
                                helpTooltipTapped(EnumDatetimeType.meanSolar);
                              },
                              child: const Icon(Icons.help,
                                  size: 12, color: Colors.grey),
                            ),
                          )
                        ],
                      );
                    }
                ),
                title:ValueListenableBuilder(
                    valueListenable: _isDefaultTimezoneNotifier,
                    builder: (context,isDefaultTimeZone,_) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: showTimezoneAtTitleNotifier,
                        builder: (ctx, showTimezoneAtTitle, _) {
                          if (!showTimezoneAtTitle){
                            return RichText(text: TextSpan(text:"选择时区 ",style: titleTextStyle));
                          }
                          return ValueListenableBuilder(valueListenable: _timezoneNotifier, builder: (ctx,timezoneStr,_){
                            return RichText(text: TextSpan(text:"选择时区 ",style: titleTextStyle,children: [
                              TextSpan(text: timezoneStr,style: locationTextStyle),
                              if (isDefaultTimeZone)
                                TextSpan(text: "（默认）",style: titleTextStyle.copyWith(color: Colors.black45)),
                            ]));
                          });
                        }
                      );
                    }
                ),
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    alignment: Alignment.topCenter,
                    // color: Colors.blue.withAlpha(100),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: timezoneSelectionContent()
                  )
                ],

                ),
              ExpansionTile(
                initiallyExpanded: true,
                subtitle: RichText(
                  text: TextSpan(
                      text: "请注意",
                      style: const TextStyle(color: Colors.grey, fontSize: 14,fontFamily: "NotoSansSC"),
                      children: [
                        const TextSpan(
                            text: "夏令时 ",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,fontFamily: "NotoSansSC")),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.top,
                            child: Tooltip(
                              message:
                                  "在每年夏季，人为调快1小时(相对于时区标准时间)，以达到充分利用光照的目的。\n如：1986-1991(中国)，1918至今（美国）",
                              child: InkWell(
                                onTap: () {
                                  helpTooltipTapped(EnumDatetimeType.meanSolar);
                                },
                                child: const Icon(Icons.help,
                                    size: 12, color: Colors.grey),
                              ),
                            )
                        ),
                      ]),
                ),
                title: RichText(
                    text: TextSpan(
                        text: "标准时间 ",
                        style: titleTextStyle,
                        children: [
                      WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Tooltip(
                            message:
                                "标准时间是指一个国家或地区统一采用的基于时区划分的本地时间，通常以格林尼治时间（GMT）或协调世界时（UTC）为基准。\n如：北京时间(UTC+8,东八区)",
                            child: InkWell(
                              onTap: () {
                                helpTooltipTapped(EnumDatetimeType.meanSolar);
                              },
                              child: const Icon(Icons.help,
                                  size: 12, color: Colors.grey),
                            ),
                          ))
                    ])),
                children: [
                  selectDateTimeButton(),
                ],
              ),
              ValueListenableBuilder<Location?>(
                  valueListenable: _locationNotifier,
                  builder: (ctx, location, child) {
                    return ExpansionTile(
                      subtitle: RichText(
                          text: TextSpan(children: [
                        location == null
                            ? TextSpan(
                                text: "需出生地", style: warningSubtitleTextStyle)
                            : TextSpan(
                                style: const TextStyle(color: Colors.black54,fontFamily: "NotoSansSC"),
                                text: location.province.name,
                                children: [
                                    TextSpan(text: " · ${location.city.name}"),
                                    if (location.area != null)
                                      TextSpan(
                                          text: " · ${location.area!.name}"),
                                  ]),
                      ])),
                      title: RichText(
                          text: TextSpan(
                              text: "平太阳时 ",
                              style: titleTextStyle,
                              children: [
                            WidgetSpan(
                                alignment: PlaceholderAlignment.top,
                                child: Tooltip(
                                  message: "根据出生地经度进一步精确计算时间",
                                  child: InkWell(
                                    onTap: () {
                                      helpTooltipTapped(
                                          EnumDatetimeType.meanSolar);
                                    },
                                    child: const Icon(Icons.help,
                                        size: 12, color: Colors.grey),
                                  ),
                                ))
                          ])),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              location != null
                                  ? Row(
                                      children: [
                                        Text(
                                          location.province.name,
                                          style: locationTextStyle,
                                        ),
                                        Text(
                                          " · ",
                                          style: locationTextStyle,
                                        ),
                                        Text(
                                          location.city.name,
                                          style: locationTextStyle,
                                        ),
                                        if (location.area != null)
                                          Text(
                                            " · ",
                                            style: locationTextStyle,
                                          ),
                                        if (location.area != null)
                                          Text(
                                            location.area!.name,
                                            style: locationTextStyle,
                                          ),
                                        IconButton(
                                            onPressed: toLngLatSelectPage,
                                            icon: Icon(Icons.map_rounded))
                                      ],
                                    )
                                  : Text("请选择出生地", style: locationTextStyle),
                              Row(children: [
                                Text(
                                  "经度：${location == null ? "??.??????" : location.area?.latitude ?? location.city.latitude}",
                                  style: lngLatTextStyle,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "纬度：${location == null ? "??.??????" : location.area?.longitude ?? location.city.longitude}",
                                  style: lngLatTextStyle,
                                ),
                              ])
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              // 显示城市选择器底部弹窗
                              final Location? selectedLocation =
                                  await showCityPickerBottomSheet(
                                context: context,
                                initLocation: Location.defualtLocation,
                              );
                              // 处理选择结果
                              if (selectedLocation != null) {
                                // print(selectedLocation.toJson());
                                _locationNotifier.value = selectedLocation;
                              }
                            },
                            child: const Text("选择地区")),
                      ],
                    );
                  }),
              ExpansionTile(
                subtitle: RichText(
                    text: TextSpan(
                        text: "需经纬度", style: warningSubtitleTextStyle)),
                title: RichText(
                    text: TextSpan(
                        text: "真太阳时 ",
                        style: titleTextStyle,
                        children: [
                      WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Tooltip(
                            message:
                                "标准时间是指一个国家或地区统一采用的基于时区划分的本地时间，通常以格林尼治时间（GMT）或协调世界时（UTC）为基准。\n如：北京时间(UTC+8,东八区)",
                            child: InkWell(
                              onTap: () {
                                helpTooltipTapped(EnumDatetimeType.meanSolar);
                              },
                              child: const Icon(Icons.help,
                                  size: 12, color: Colors.grey),
                            ),
                          ))
                    ])),
                children: <Widget>[
                  IconButton(
                      onPressed: toLngLatSelectPage,
                      icon: Icon(Icons.map_rounded))
                ],
              ),


              // SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //   child:Row(
              //   children: List.generate(10, (item)=>buildEightCharCard(item,1))
              //   )

              // )
            ],
          ),
        ));
  }

  Widget _buildNameInput() {
    return ValueListenableBuilder(
        valueListenable: _inputNameNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: _nameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                labelText: "命主姓名"),
            onChanged: (value) {
              _inputNameNotifier.value = value;
            },
          );
        });
  }

  Widget _buildGenderSelector() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _inputGenderNotifier,
        builder: (ctx, configType, _) {
          return SlideSwitcher(
            initialIndex: configType.index,
            onSelect: (index) {
              if (index != configType.index) {
                _inputGenderNotifier.value = Gender.values[index];
              }
            },
            containerHeight: 42,
            containerWight: 100,
            indents: 4,
            containerColor: Colors.black12.withAlpha(50),
            slidersColors: const [Color(0xfff7f5f7)],
            containerBoxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 2,
                spreadRadius: 4,
              )
            ],
            children: [
              Text(
                "男",
                style: configType != Gender.male
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(),
              ),
              Text(
                "女",
                style: configType != Gender.female
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(),
              ),
            ],
          );
        },
      ),
    );
  }


  void toLngLatSelectPage() {
    if (_locationNotifier.value != null) {
      Navigator.pushNamed(context, '/common/maps',
          arguments: {"seekerCoordinate":_coordinatesValueNotifier.value,"location": _locationNotifier.value,"myCoordinate":Coordinates(longitude: 114.46091714063846,latitude: 38.04295413918599)}).then((val){
            if (val!= null) {
              _coordinatesValueNotifier.value = val! as Coordinates;
            }
      });
    } else {
      InteractiveToast.pop(
        context,
        title: const Text("为了便于后续操作请先选择出生地"),
        toastSetting: const PopupToastSetting(
          animationDuration: Duration(seconds: 2),
          displayDuration: Duration(seconds: 20),
          toastAlignment: Alignment.bottomCenter,
        ),
      );
    }
  }
  Widget timezoneSelectionContent(){
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              // height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<String?>(
                      valueListenable: _timezoneNotifier,
                      builder: (ctx,timezonStr,_) {
                        return ValueListenableBuilder(
                            valueListenable: _isDefaultTimezoneNotifier,
                            builder: (ctx,isDefaultTimezone,_){
                              return Checkbox(
                                  value: isDefaultTimezone,
                                  onChanged:onIsDefaultTimezoneChanged
                              );
                            });
                      }
                  ),
                  SizedBox(width: 2,),
                  Text("默认",style: TextStyle(fontSize: 12,color: Colors.grey),),
                ],
              ),
            ),
            Column(
                children: [
                  ValueListenableBuilder<SPTimezoneDataModel?>(
                      valueListenable: _spTimezoneDataModelNotifier,
                      builder: (ctx,spTimezoneDataModel,_) {
                        return ValueListenableBuilder<String?>(
                            valueListenable: _localTimezoneNotifier,
                            builder: (ctx,localTimezone,_) {
                              String? defaultTimezone = spTimezoneDataModel?.isDefaultTimezone != null ? spTimezoneDataModel?.timezoneStr: null;
                              return ValueListenableBuilder<String?>(
                                  valueListenable: _timezoneNotifier,
                                  builder: (context, timezoneStr, _) {
                                    return Container(
                                      // height: 50,
                                      width: 240,
                                      child: DropdownButton<String?>(
                                          isExpanded: true,
                                          menuWidth: 240,
                                          value: timezoneStr,
                                          items: tz.timeZoneDatabase.locations.keys
                                              .map((String value) {

                                            return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text.rich(TextSpan(
                                                    style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black54,height: 1),
                                                    children: [
                                                      TextSpan(text: value,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                                      if (localTimezone == value ||defaultTimezone ==value)
                                                        TextSpan(text: " (",),
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

                                                      if (localTimezone == value ||defaultTimezone ==value)
                                                        TextSpan(text: ")")
                                                    ]
                                                ),
                                                ));
                                          }).toList(),
                                          onChanged: onTimezoneSelected
                                      ),
                                    );
                                  });
                            }
                        );
                      }
                  ),
                  Container(
                    height: 18,
                    width: 256,
                    alignment: Alignment.topCenter,
                    // color: Colors.greenAccent.withAlpha(20),
                    child: ValueListenableBuilder<SPTimezoneDataModel?>(
                      valueListenable: _spTimezoneDataModelNotifier,
                      builder: (context, spTimezoneDataModel, _) {
                        return ValueListenableBuilder<String?>(
                            valueListenable: _localTimezoneNotifier,
                            builder: (ctx, localTimezoneStr, _) {
                              return ValueListenableBuilder<String?>(
                                  valueListenable: _timezoneNotifier,
                                  builder: (ctx,selectedTimezoneStr,_){
                                    //  当默认时区是存在的，且当前选择的时区不是默认时区是显示默认时区
                                    if (_spTimezoneDataModelNotifier.value?.isDefaultTimezone ?? false){
                                      List<TextSpan> textSpans = [];
                                      if (_timezoneNotifier.value != _spTimezoneDataModelNotifier.value?.timezoneStr){
                                        textSpans = [
                                          const TextSpan(text: "默认时区: "),
                                          TextSpan(text: _spTimezoneDataModelNotifier.value?.timezoneStr!,style: TextStyle(color: Theme.of(ctx).primaryColor))
                                        ];
                                      }
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 24),
                                        child: TextButton(
                                            onPressed: (){
                                              if (_spTimezoneDataModelNotifier.value?.isDefaultTimezone?? false){
                                                // && _spTimezoneDataModelNotifier.value?.timezoneStr != null){
                                                _timezoneNotifier.value = _spTimezoneDataModelNotifier.value?.timezoneStr;
                                              }
                                            },
                                            child: Text.rich(
                                              TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.grey,height: 1,fontFamily: "NotoSansSC"),
                                                  children: textSpans
                                              ),
                                            )),
                                      );
                                    }else{
                                      List<TextSpan> textSpans = [];
                                      if (_localTimezoneNotifier.value != selectedTimezoneStr){
                                        textSpans = [
                                          const TextSpan(text: "本地时区: "),
                                          TextSpan(text: localTimezoneStr,style: TextStyle(color: Colors.black87))
                                        ];
                                      }
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 24),
                                        child: TextButton(
                                            onPressed: (){
                                              if (_timezoneNotifier.value != localTimezoneStr){
                                                _timezoneNotifier.value = localTimezoneStr;
                                              }
                                            },
                                            child: Text.rich(
                                              TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.grey,height: 1,fontFamily: "NotoSansSC"),
                                                  children: textSpans
                                              ),
                                            )),
                                      );
                                    }

                                  });
                            }
                        );
                      },
                    ),
                  ),
                ]
            ),
            Tooltip(
              message:"开启后当时间为“夏令时”，则自动调整回自然时间",
              child: Container(
                // width: 42 + 24,
                // height: 32 + 24,
                // color: Colors.amberAccent.withAlpha(100),
                child: ValueListenableBuilder(
                    valueListenable: _isDSTNotifier,
                    builder: (context, isDST, _) {
                      return ValueListenableBuilder(
                        valueListenable: _isAutoHandleDSTNotifier,
                        builder: (ctx, isANSI, _) {
                          // 当前时区不是夏令时switch 设为不可用
                          return Column(
                            children: [
                              Transform.scale(
                                  scale: 1,
                                  child: Switch(
                                      value: isANSI,
                                      onChanged: onAutoHandleTimezoneChanged)),
                              Text(
                                "移除夏令时",
                                style: TextStyle(
                                    height: 1,
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      );
                    }),
              ),
            ),


          ],
        ),
      ),
    );

  }
  void onTimezoneSelected(String? newValue) async{

    // 当 _spTimezoneDataModelNotifier.value != null 是，
    // 需要检测新选的值是否与 _spTimezoneDataModelNotifier.value?.timezoneStr
    // 如果不同，且_isDefaultTimezoneNotifier.value == true，则需要在UI上取消 _isDefaultTimezone
    if (_spTimezoneDataModelNotifier.value != null){
      final currentSPTZDataModel = _spTimezoneDataModelNotifier.value!;
      if (currentSPTZDataModel.timezoneStr != newValue && (currentSPTZDataModel.isDefaultTimezone ?? false)){
        _isDefaultTimezoneNotifier.value = false;
      }
    }
    _timezoneNotifier.value = newValue;
  }
  void onIsDefaultTimezoneChanged(bool? newValue) async {
      // _isDefaultTimezoneNotifier.value = newValue ?? false
      bool isDefault = newValue ?? false;
      SPTimezoneDataModel toSavedTimezoneDataModel;
      if (_spTimezoneDataModelNotifier.value == null){
        toSavedTimezoneDataModel = SPTimezoneDataModel(
            appFeatureModule: widget.appFeatureModule,
            timezoneStr: _timezoneNotifier.value,
            isAutoHandleDST: _isAutoHandleDSTNotifier.value,
            isDefaultTimezone: isDefault
        );
      }else{
        toSavedTimezoneDataModel = _spTimezoneDataModelNotifier.value!.copyWith(timezoneStr:_timezoneNotifier.value,isDefaultTimezone: isDefault);
      }
      await saveTimezoneDataModel(toSavedTimezoneDataModel);
      _spTimezoneDataModelNotifier.value = await loadTimezoneDataModelFromShared(widget.appFeatureModule);

  }
  void onAutoHandleTimezoneChanged(bool? newValue) async {
    // _isDefaultTimezoneNotifier.value = newValue ?? false
    bool isAutoHandle = newValue ?? false;
    SPTimezoneDataModel toSavedTimezoneDataModel;
    if (_spTimezoneDataModelNotifier.value == null){
      toSavedTimezoneDataModel = SPTimezoneDataModel(
          appFeatureModule: widget.appFeatureModule,
          timezoneStr: _timezoneNotifier.value,
          isAutoHandleDST: isAutoHandle,
          isDefaultTimezone: _isDefaultTimezoneNotifier.value
      );
    }else{
      toSavedTimezoneDataModel = _spTimezoneDataModelNotifier.value!.copyWith(timezoneStr:_timezoneNotifier.value,isAutoHandleDST: isAutoHandle);
    }
    await saveTimezoneDataModel(toSavedTimezoneDataModel);
    _spTimezoneDataModelNotifier.value = await loadTimezoneDataModelFromShared(widget.appFeatureModule);
    // if (_selectedBirthTimeNotifier.value != null){

    // }
    // if (isAutoHandle){
    //   if (_selectedBirthTimeNotifier.value != null && _timezoneNotifier.value != null){
    //     handleDSTTime(_selectedBirthTimeNotifier.value!,_timezoneNotifier.value!);
    //   }
    // }else{
    //   unhandleDSTTime();
    // }
  }

  // DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  Widget selectDateTimeButton() {
    Duration duration = Duration(milliseconds: 400);
    double largeFontSize = 28;
    double smallFontSize = 16;
    return ValueListenableBuilder(
        valueListenable: _selectedBirthTimeNotifier,
        builder: (ctx, dateTime, _) {
          return ValueListenableBuilder(
              valueListenable: _DSTBirthTimeNotifier,
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
                    AnimatedContainer(
                        duration: duration,
                        height: dateTime == null ? 0 : 64,
                        alignment: Alignment.center,
                        // color: Colors.blueAccent.withAlpha(50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                        AnimatedContainer(
                          duration: duration,
                          height: dstTime==null?0:18,
                          width: 240,
                          // color: Colors.redAccent.withAlpha(100),
                          child: dstTime == null
                              ? SizedBox()
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 16*2,),
                              Text.rich(
                                  TextSpan(
                                      text:"${dateTimeFormat.format(dstTime)} ",
                                      style: TextStyle(
                                          height: 1.0,
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration
                                              .lineThrough),
                                      children: [
                                        TextSpan(text:"夏令时",style: TextStyle(fontSize: 13))
                                      ]
                                  )
                              ),
                            ],
                          ),
                        ),
                            // SizedBox(height: 4,),
                            if (dateTime != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42,
                                    alignment: Alignment.center,
                                  ),
                                  AnimatedDefaultTextStyle(
                                      child: Text(dateTimeFormat.format(dateTime)),
                                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87,fontSize: dstTime == null?36:34),
                                      duration: duration),

                                  // Text(dateTimeFormat.format(dateTime),
                                  //   style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87,fontSize: 36),),
                                  SizedBox(
                                    width: 42,
                                    height: 28,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ValueListenableBuilder<bool>(
                                          valueListenable: _isDSTNotifier,
                                          builder: (context, isDST, _) {
                                            return AnimatedSwitcher(
                                              duration: duration,
                                              transitionBuilder: (Widget child, Animation<double> animation) {
                                                final offsetAnimation = Tween<Offset>(
                                                  begin: const Offset(0.0, -1.0),
                                                  end: Offset.zero,
                                                ).animate(CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut,
                                                ));
                                                final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: FadeTransition(
                                                    opacity: opacityAnimation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: isDST
                                                  ? Text(
                                                "夏令时",
                                                key: ValueKey(isDST),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                                  : SizedBox.shrink(key: ValueKey(isDST)),
                                            );
                                          },
                                        ),
                                        Expanded(child: SizedBox())
                                      ],
                                    ),
                                  )
                                ],
                              ),
                          ],
                        )),
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
                            initialDate: _selectedBirthTimeNotifier.value
                          );
                          if (result != null) {
                            handleDSTTime(result,_timezoneNotifier.value!);
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
                                style:
                                TextStyle(color: Colors.white),
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
            }
          );
        });
  }
  void handleDSTTime(DateTime? result,String timezoneStr){
    if (result != null){
      l.i("handle datetime from DST to normal");
      final tzDateTime = tz.TZDateTime.from(result, tz.getLocation(timezoneStr));
      // final isDST = SolarTimeCalculator.checkIsDST(result, timezoneStr);
      if (tzDateTime.timeZone.isDst){
        l.d("current datetime is DST");

        if (_isAutoHandleDSTNotifier.value ?? false){
          DateTime dstDateTime = result;
          DateTime removedDSTDateTime = dstDateTime.subtract(Duration(hours: 1));
          _selectedBirthTimeNotifier.value = removedDSTDateTime;
          _DSTBirthTimeNotifier.value = result;  // 保留DST，并显示在UI上
          _isDSTNotifier.value = false;
        }else{
          _selectedBirthTimeNotifier.value = result;
          _isDSTNotifier.value = true;
        }
      }else{
        l.d("current datetime is not DST");
        _selectedBirthTimeNotifier.value = result;
        _isDSTNotifier.value = false;
      }
    }

  }
  void unhandleDSTTime(){

    l.i("convert normal back to DST");
    // 确保当前时间是DST
    if (_DSTBirthTimeNotifier.value != null){
      l.t("set _selectedBirthTimeNotifier.value to _DSTBirthTimeNotifier.value");
      _selectedBirthTimeNotifier.value = _DSTBirthTimeNotifier.value;
      l.t("set _DSTBirthTimeNotifier.value to null");
      _DSTBirthTimeNotifier.value = null;
      l.t("set _isDSTNotifier.value to true");
      _isDSTNotifier.value = true;
    }else{
      l.e("current datetime is not DST, can not back to DST");
    }
  }

  void removeDSTTime(bool doRemove) {
    if (_isDSTNotifier.value && _selectedBirthTimeNotifier.value != null) {
      if (doRemove && _DSTBirthTimeNotifier.value == null) {
        DateTime dstDateTime = _selectedBirthTimeNotifier.value!;
        DateTime removedDSTDateTime = dstDateTime.subtract(Duration(hours: 1));
        _selectedBirthTimeNotifier.value = removedDSTDateTime;
        _DSTBirthTimeNotifier.value = dstDateTime;
      } else {
        _selectedBirthTimeNotifier.value = _DSTBirthTimeNotifier.value;
        _DSTBirthTimeNotifier.value = null;
      }
    }
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
        fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black87,fontFamily: "NotoSansSC"
        // color: AppTheme.secondaryText,
        );
  }

  /// 获取滑块激活状态的文本样式
  TextStyle _getSwitcherActivatedStyle() {
    return const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey,fontFamily: "NotoSansSC"
        // color: AppTheme.primaryColor,
        );
  }

  void checkDST(DateTime datetime, String timezone) {
    /// 是否为夏令时
    final isDST = SolarTimeCalculator.checkIsDST(datetime, timezone);
    if (isDST) {
      if (isDSTShakeMeKey.currentState != null &&
          isDSTShakeMeKey.currentState is ShakeWidgetState) {
        (isDSTShakeMeKey.currentState as ShakeWidgetState).shake();
      }
    }
    if (isDST != _isDSTNotifier.value) {
      _isDSTNotifier.value = isDST;
    }
  }
}
