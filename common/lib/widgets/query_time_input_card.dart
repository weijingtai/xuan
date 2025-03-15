import 'package:auto_size_text/auto_size_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/city_picker_bottom_sheet.dart';
import 'package:common/widgets/eight_chars_input_card.dart';
import 'package:common/widgets/eight_chars_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:intl/intl.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

import '../enums/enum_gender.dart';
import '../models/query_datetime.dart';
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
  final String defaultTimeZone;
  final PageType defaultPageType;
  const QueryTimeInputCard(
      {super.key,
      required this.defaultTimeZone,
      required this.defaultPageType});

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

  late final ValueNotifier<bool> _removeDSTTimeNotifier;

  late final ValueNotifier<bool> _isDSTNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<String> _timezoneNotifier;
  late final ValueNotifier<Location?> _locationNotifier;

  // late TabController _tabController;

  @override
  void initState() {
    super.initState();
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

    _removeDSTTimeNotifier = ValueNotifier(false);
    // 监听事件、以及时区变化，实时验算是否为夏令时时间
    _DSTBirthTimeNotifier = ValueNotifier(null);
    _selectedBirthTimeNotifier = ValueNotifier(null)
      ..addListener(() {
        if (_selectedBirthTimeNotifier.value != null) {
          checkDST(_selectedBirthTimeNotifier.value!, _timezoneNotifier.value);
        }
      });
    _timezoneNotifier = ValueNotifier(widget.defaultTimeZone)
      ..addListener(() {
        if (_selectedBirthTimeNotifier.value != null) {
          checkDST(_selectedBirthTimeNotifier.value!, _timezoneNotifier.value);
        }
      });

    _locationNotifier = ValueNotifier(null);
    // _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _inputNameNotifier.dispose();
    _inputGenderNotifier.dispose();
    _pageController.dispose();
    _DSTBirthTimeNotifier.dispose();

    _removeDSTTimeNotifier.dispose();
    _selectedBirthTimeNotifier.dispose();
    _timezoneNotifier.dispose();
    _locationNotifier.dispose();
    _isDSTNotifier.dispose();

    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 512,
      height: 512 + 256,
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
          height: 512,
          child: timeTab(512 - 48),
        )
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
                  // if (index != tabIndex.index) {
                  // _inputGenderNotifier.value = Gender.values[index];
                  // }
                  _tabSelectNotifier.value = PageType.getFromPageIndex(index);
                },
                containerHeight: 48,
                containerWight: width,
                indents: 4,
                containerColor: const Color(0xffe4e5eb),
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

              // return Container(
              //   color: Colors.grey[200],
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: <Widget>[
              //       GestureDetector(
              //         onTap: () {
              //           _tabSelectNotifier.value = PageType.datetime;
              //         },
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text(
              //             '时间',
              //             style: TextStyle(
              //               fontWeight: tabIndex == PageType.datetime
              //                   ? FontWeight.bold
              //                   : FontWeight.normal,
              //             ),
              //           ),
              //         ),
              //       ),
              //       GestureDetector(
              //         onTap: () {
              //           _tabSelectNotifier.value = PageType.chineseTraditional;
              //         },
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text(
              //             '农历',
              //             style: TextStyle(
              //               fontWeight: tabIndex == PageType.chineseTraditional
              //                   ? FontWeight.bold
              //                   : FontWeight.normal,
              //             ),
              //           ),
              //         ),
              //       ),
              //       GestureDetector(
              //         onTap: () {
              //           _tabSelectNotifier.value = PageType.eightChars;
              //         },
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text(
              //             '八字',
              //             style: TextStyle(
              //               fontWeight: tabIndex == 2
              //                   ? FontWeight.bold
              //                   : FontWeight.normal,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // );
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
              _timeSelectionContent(),
              const Center(child: Text('Content of Tab 2')),
              _eightCharsPage()
              // EightCharsInput(
              //     initEightChars: EightChars(
              //         year: JiaZi.YI_SI,
              //         month: JiaZi.JI_MAO,
              //         day: JiaZi.GUI_WEI,
              //         time: JiaZi.JI_WEI)),
              // const Center(child: Text('Content of Tab 3')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eightCharsPage() {
    return EightCharsInput(
      initEightChars: null,
    );
  }

  Widget _timeSelectionContent() {
    TextStyle locationTextStyle = const TextStyle(
        fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600);
    TextStyle lngLatTextStyle =
        const TextStyle(fontSize: 14, color: Colors.grey);

    TextStyle titleTextStyle =
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
    TextStyle warningSubtitleTextStyle =
        TextStyle(color: Colors.amber[900]!.withAlpha(180), fontSize: 14);

    return Container(
        alignment: Alignment.topCenter,
        // color: Colors.blue,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                subtitle: RichText(
                  text: TextSpan(
                      text: "请注意",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        const TextSpan(
                            text: "夏令时 ",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent)),
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
                            )),
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
                                style: const TextStyle(color: Colors.black54),
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
            ],
          ),
        ));
  }

  void toLngLatSelectPage() {
    if (_locationNotifier.value != null) {
      Navigator.pushNamed(context, '/common/maps',
          arguments: {"location": _locationNotifier.value});
    } else {
      InteractiveToast.pop(
        context,
        title: const Text("为了便于后续操作请先选择出生地"),
        // trailing: trailingWidget(),
        // leading: leadingWidget(),
        toastSetting: const PopupToastSetting(
          animationDuration: Duration(seconds: 2),
          displayDuration: Duration(seconds: 20),
          toastAlignment: Alignment.bottomCenter,
        ),
      );
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  Widget selectDateTimeButton() {
    Duration duration = Duration(milliseconds: 400);
    double largeFontSize = 32;
    double smallFontSize = 16;
    return ValueListenableBuilder(
        valueListenable: _selectedBirthTimeNotifier,
        builder: (ctx, dateTime, _) {
          return Container(
            margin: EdgeInsets.all(18),
            alignment: Alignment.topCenter,
            width: 512,
            height: 200,
            color: Colors.blue.withAlpha(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                    duration: duration,
                    alignment: dateTime == null
                        ? Alignment.bottomCenter
                        : Alignment.topLeft,
                    color: Colors.red.withAlpha(10),
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      child: Text("请选择命主生辰"),
                      style: dateTime == null
                          ? TextStyle(fontSize: largeFontSize)
                          : TextStyle(fontSize: smallFontSize),
                    )),
                AnimatedContainer(
                    duration: duration,
                    height: dateTime == null ? 16 : 80,
                    color: Colors.amber.withAlpha(10),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                            ),
                            if (dateTime != null)
                              Text(
                                dateFormat.format(dateTime),
                                style: TextStyle(
                                    height: 1.0,
                                    color: Colors.black87,
                                    fontSize: largeFontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                            Container(
                              width: 64,
                              color: Colors.grey.withAlpha(20),
                              alignment: Alignment.bottomCenter,
                              child: ValueListenableBuilder(
                                  valueListenable: _isDSTNotifier,
                                  builder: (ctx, isDST, _) {
                                    if (dateTime == null || !isDST) {
                                      return const SizedBox();
                                    }
                                    return ValueListenableBuilder(
                                        valueListenable: _removeDSTTimeNotifier,
                                        builder: (context, removed, _) {
                                          return Text(
                                            removed ? "" : " 夏令时",
                                            style: TextStyle(
                                                height: 1.0,
                                                fontSize: smallFontSize,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          );
                                        });
                                  }),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                            valueListenable: _removeDSTTimeNotifier,
                            builder: (ctx, removeDST, _) {
                              return ValueListenableBuilder(
                                  valueListenable: _DSTBirthTimeNotifier,
                                  builder: (ctx, dstTime, _) {
                                    return Container(
                                      height: 16,
                                      child: dstTime == null
                                          ? SizedBox()
                                          : Text(
                                              "${dateFormat.format(dstTime)} （夏令时）",
                                              style: TextStyle(
                                                  height: 1.0,
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                    );
                                  });
                            }),
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42 + 24,
                      height: 24,
                      // color: Colors.amberAccent.withAlpha(100),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      padding: EdgeInsets.all(4),
                      alignment: dateTime == null
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () async {
                          final result = await showBoardDateTimePicker(
                            context: context,
                            pickerType: DateTimePickerType.datetime,
                          );
                          if (result != null) {
                            _selectedBirthTimeNotifier.value = result;
                            if (_DSTBirthTimeNotifier.value != null) {
                              _DSTBirthTimeNotifier.value = null;
                              if (_removeDSTTimeNotifier.value) {
                                _removeDSTTimeNotifier.value = false;
                              }
                            }
                          }
                        },
                        child: AnimatedContainer(
                            duration: duration,
                            width: dateTime == null ? 256 : 128,
                            height: dateTime == null ? 56 : 32,
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
                                    TextStyle(height: 1.0, color: Colors.white),
                              ),
                              style: dateTime == null
                                  ? TextStyle(fontSize: largeFontSize)
                                  : TextStyle(fontSize: smallFontSize),
                            )),
                      ),
                    ),
                    Container(
                      width: 42 + 24,
                      height: 32 + 24,
                      // color: Colors.amberAccent.withAlpha(100),
                      child: ValueListenableBuilder(
                          valueListenable: _isDSTNotifier,
                          builder: (context, isDST, _) {
                            if (!isDST) {
                              return SizedBox();
                            }
                            return ValueListenableBuilder(
                              valueListenable: _removeDSTTimeNotifier,
                              builder: (ctx, isANSI, _) {
                                return Column(
                                  children: [
                                    Transform.scale(
                                        scale: .9,
                                        child: Switch(
                                            value: isANSI,
                                            onChanged: (boolVal) {
                                              _removeDSTTimeNotifier.value =
                                                  boolVal;
                                              removeDSTTime(boolVal);
                                            })),
                                    Text(
                                      "移除夏令时",
                                      style: TextStyle(
                                          height: 1,
                                          fontSize: 12,
                                          color: Colors.black87),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    )
                  ],
                )
              ],
            ),
          );
        });
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

  // tz.TZDateTime convertToStandardTime(tz.TZDateTime dateTime) {
  //   final location = dateTime.location;
  //   final currentTimeZone = location.timeZone(dateTime.millisecondsSinceEpoch);

  //   // // 获取该时区全年的标准时间偏移量（非夏令时）
  //   // location.
  //   // final standardOffset = location
  //   //     .lookupTimeZone(dateTime.millisecondsSinceEpoch)
  //   //     .timeZone
  //   //     .offset;
  //   print(currentTimeZone.offset);
  //   print(dateTime.timeZoneOffset.inMilliseconds);
  //   tz.TZDateTime newTZDat = dateTime.add(Duration(days: 20));
  //   int standardOffset = 0;
  //   for (int i = 0; i < 100; i++) {
  //     if (!location.timeZone(newTZDat.microsecondsSinceEpoch).isDst) {
  //       // standardOffset = location
  //       //     .lookupTimeZone(newTZDat.millisecondsSinceEpoch)
  //       //     .timeZone
  //       //     .offset;
  //       print(
  //           "想给定日期之前查找 不是DST的，得到当时的 offset 这个时间是standered offset ${newTZDat.timeZoneOffset.inMilliseconds}");
  //       // 找到后一定要跳出
  //       break;
  //     }
  //     newTZDat = newTZDat.add(Duration(days: 20));
  //   }

  //   // if (currentTimeZone.isDst) {
  //   //   final adjustment = currentTimeZone.offset - standardOffset;
  //   //   return dateTime.subtract(Duration(seconds: adjustment));
  //   // }
  //   return dateTime;
  // }

  // DateTime convertToStandardTime(DateTime dateTime, String timeZone) {
  //   print(dateTime);
  //   print(dateTime.toUtc().toIso8601String());

  //   final location = tz.getLocation(timeZone);
  //   final tzDateTime = tz.TZDateTime.from(dateTime, location);
  //   print(tzDateTime.toUtc().to);
  //   // 获取标准偏移量（假设1月1日处于标准时间）
  //   final nonDstTime = tz.TZDateTime(location, tzDateTime.year, 1, 1, 0);
  //   final standardOffset =
  //       location.timeZone(nonDstTime.microsecondsSinceEpoch).offset;

  //   // 获取当前时间的时区信息
  //   final currentTimeZone =
  //       location.timeZone(tzDateTime.microsecondsSinceEpoch);
  //   final adjustment = currentTimeZone.offset - standardOffset;
  //   final standardTZDateTime =
  //       tzDateTime.subtract(Duration(seconds: adjustment));
  //   return standardTZDateTime.toLocal();
  // }

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
            containerColor: const Color(0xffe4e5eb),
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

  void helpTooltipTapped(EnumDatetimeType datetimeType) {
    switch (datetimeType) {
      case EnumDatetimeType.standard:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.standard]!);
      case EnumDatetimeType.IANA:
        throw UnimplementedError();
      case EnumDatetimeType.meanSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.meanSolar]!);
      case EnumDatetimeType.trueSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.trueSolar]!);
    }
  }

  /// 获取滑块未激活状态的文本样式
  TextStyle _getSwitcherInactivatedStyle() {
    return const TextStyle(
        fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey
        // color: AppTheme.secondaryText,
        );
  }

  /// 获取滑块激活状态的文本样式
  TextStyle _getSwitcherActivatedStyle() {
    return const TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87
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
