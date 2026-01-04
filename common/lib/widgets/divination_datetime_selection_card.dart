import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;

import '../datamodel/location.dart';
import '../models/sp_timezone_datamodel.dart';
import 'city_picker_bottom_sheet.dart';

enum DivinationDatetimeSelectionCard {
  datetime(pageIndex: 0),
  lunar(pageIndex: 1),
  ganZhi(pageIndex: 2);

  final int pageIndex;
  const DivinationDatetimeSelectionCard({required this.pageIndex});
}

@Deprecated("")
class DivinationDatetimeSelectionCardWidget extends StatefulWidget {
  late DateFormat timeFormat;
  late DateFormat dateFormat;
  late DateFormat dateTimeFormat;

  // late DateFormat timeFormat = DateFormat("HH:mm");
  // late DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  // late DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

  DivinationDatetimeSelectionCardWidget({
    Key? key,
    required this.timeFormat,
    required this.dateFormat,
    required this.dateTimeFormat,
  }) : super(key: key);

  @override
  State<DivinationDatetimeSelectionCardWidget> createState() =>
      _DivinationDatetimeSelectionCardWidgetState();
}

class _DivinationDatetimeSelectionCardWidgetState
    extends State<DivinationDatetimeSelectionCardWidget> {
  late final Logger l = Logger();
  TextStyle locationTextStyle = const TextStyle(
      height: 1,
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      fontFamily: "NotoSansSC-Regular");
    TextStyle lngLatTextStyle = const TextStyle(
        fontSize: 14, color: Colors.grey, fontFamily: "NotoSansSC-Regular");

  final ValueNotifier<SPTimezoneDataModel?> _spTimezoneDataModelNotifier =
      ValueNotifier<SPTimezoneDataModel?>(null);
  late final ValueNotifier<Address?> _addressNotifier;
  late final ValueNotifier<Coordinates?> _coordinatesValueNotifier;

  final ValueNotifier<DivinationDatetimeSelectionCard>
      _selectedTabBarButtonNotifier =
      ValueNotifier(DivinationDatetimeSelectionCard.datetime);
  final PageController _pageController = PageController();

  late final ValueNotifier<String?> _timezoneNotifier =
      ValueNotifier<String?>(null);
  late final ValueNotifier<DateTime?> _selectedBirthTimeNotifier;

  late final ValueNotifier<bool> _isAutoHandleDSTNotifier =
      ValueNotifier(false);
  late final ValueNotifier<bool> _isDSTNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<DateTime?> _DSTBirthTimeNotifier;
  late final ValueNotifier<String?> _localTimezoneNotifier =
      ValueNotifier<String?>(null);
  late final ValueNotifier<bool> _isDefaultTimezoneNotifier =
      ValueNotifier(false);

  double smallRadius = 8;
  double largeRadius = 24;

  @override
  void dispose() {
    super.dispose();
    _selectedTabBarButtonNotifier.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              valueListenable: _selectedTabBarButtonNotifier,
              builder: (ctx, selectedTabBarButton, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: DivinationDatetimeSelectionCard.values
                      .map((e) => _buildTabBarButton(
                          e, smallRadius, selectedTabBarButton))
                      .toList(),
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _selectedTabBarButtonNotifier,
            builder: (ctx, selectedTabBarButton, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: contentWidth - (contentPadding * 2),
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
                    _selectedTabBarButtonNotifier.value = index == 0
                        ? DivinationDatetimeSelectionCard.datetime
                        : DivinationDatetimeSelectionCard.lunar;
                  },
                  children: [
                    _buildDatetime(),
                    _buildLunar(),
                    _buildGanZhi(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarButton(DivinationDatetimeSelectionCard type,
      double smallRadius, DivinationDatetimeSelectionCard selected) {
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
              _selectedTabBarButtonNotifier.value = type;
              _pageController.animateToPage(
                type == DivinationDatetimeSelectionCard.datetime ? 0 : 1,
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
              );
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

  String _getTabBarButtonText(DivinationDatetimeSelectionCard type) {
    switch (type) {
      case DivinationDatetimeSelectionCard.datetime:
        return "时间";
      case DivinationDatetimeSelectionCard.lunar:
        return "农历";
      case DivinationDatetimeSelectionCard.ganZhi:
        return "八字";
    }
  }

  Widget _buildDatetime() {
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
                  child: timezoneSelectionContent()),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                alignment: Alignment.topCenter,
                // color: Colors.blue.withAlpha(100),
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: selectDateTimeButton(),
              ),
              ValueListenableBuilder<Address?>(
                  valueListenable: _addressNotifier,
                  builder: (ctx, location, _) {
                    return Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: location != null
                          ? buildCityArea(location)
                          : SizedBox(),
                    );
                  }),
              ElevatedButton(
                  onPressed: () async {
                    // 显示城市选择器底部弹窗
                    final Address? newSelectedLocation;
                    if (_addressNotifier.value != null) {
                      // 显示城市选择器底部弹窗
                      newSelectedLocation = await showCityPickerBottomSheet(
                        context: context,
                        initAddress: _addressNotifier.value!,
                        myLocationNotifier: ValueNotifier(null),
                      );
                    } else {
                      newSelectedLocation = await showCityPickerBottomSheet(
                        context: context,
                        initAddress: Address.defualtAddress,
                        myLocationNotifier: ValueNotifier(null),
                      );
                    }

                    // 处理选择结果
                    if (newSelectedLocation != null) {
                      // print(selectedLocation.toJson());
                      _addressNotifier.value = newSelectedLocation;
                    }
                  },
                  child: const Text("选择地区")),
              IconButton(
                  onPressed: toLngLatSelectPage, icon: Icon(Icons.map_rounded)),
            ],
          ),
        ));
  }

  Widget _buildLunar() {
    return Placeholder();
  }

  Widget _buildGanZhi() {
    return Placeholder();
  }

  void toLngLatSelectPage() {
    if (_addressNotifier.value != null) {
      Navigator.pushNamed(context, '/common/maps', arguments: {
        "seekerCoordinate": _coordinatesValueNotifier.value,
        "location": _addressNotifier.value,
        "myCoordinate": Coordinates(
            longitude: 114.46091714063846, latitude: 38.04295413918599)
      }).then((val) {
        if (val != null) {
          _coordinatesValueNotifier.value = val! as Coordinates;
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

  Widget timezoneSelectionContent() {
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
            SizedBox(
              // height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<String?>(
                      valueListenable: _timezoneNotifier,
                      builder: (ctx, timezonStr, _) {
                        return ValueListenableBuilder(
                            valueListenable: _isDefaultTimezoneNotifier,
                            builder: (ctx, isDefaultTimezone, _) {
                              return Checkbox(
                                  value: isDefaultTimezone,
                                  onChanged: onIsDefaultTimezoneChanged);
                            });
                      }),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    "默认",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(children: [
              ValueListenableBuilder<SPTimezoneDataModel?>(
                  valueListenable: _spTimezoneDataModelNotifier,
                  builder: (ctx, spTimezoneDataModel, _) {
                    return ValueListenableBuilder<String?>(
                        valueListenable: _localTimezoneNotifier,
                        builder: (ctx, localTimezone, _) {
                          String? defaultTimezone =
                              spTimezoneDataModel?.isDefaultTimezone != null
                                  ? spTimezoneDataModel?.timezoneStr
                                  : null;
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
                                            child: Text.rich(
                                              TextSpan(
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black54,
                                                      height: 1),
                                                  children: [
                                                    TextSpan(
                                                        text: value,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .black87)),
                                                    if (localTimezone ==
                                                            value ||
                                                        defaultTimezone ==
                                                            value)
                                                      TextSpan(
                                                        text: " (",
                                                      ),
                                                    if (localTimezone == value)
                                                      TextSpan(
                                                        text: "本地",
                                                      ),
                                                    if (localTimezone ==
                                                            value &&
                                                        defaultTimezone ==
                                                            value)
                                                      TextSpan(text: "/"),
                                                    if (defaultTimezone ==
                                                        value)
                                                      TextSpan(
                                                        text: "默认",
                                                      ),
                                                    if (localTimezone ==
                                                            value ||
                                                        defaultTimezone ==
                                                            value)
                                                      TextSpan(text: ")")
                                                  ]),
                                            ));
                                      }).toList(),
                                      onChanged: onTimezoneSelected),
                                );
                              });
                        });
                  }),
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
                              builder: (ctx, selectedTimezoneStr, _) {
                                //  当默认时区是存在的，且当前选择的时区不是默认时区是显示默认时区
                                if (_spTimezoneDataModelNotifier
                                        .value?.isDefaultTimezone ??
                                    false) {
                                  List<TextSpan> textSpans = [];
                                  if (_timezoneNotifier.value !=
                                      _spTimezoneDataModelNotifier
                                          .value?.timezoneStr) {
                                    textSpans = [
                                      const TextSpan(text: "默认时区: "),
                                      TextSpan(
                                          text: _spTimezoneDataModelNotifier
                                              .value?.timezoneStr!,
                                          style: TextStyle(
                                              color:
                                                  Theme.of(ctx).primaryColor))
                                    ];
                                  }
                                  return Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    child: TextButton(
                                        onPressed: () {
                                          if (_spTimezoneDataModelNotifier
                                                  .value?.isDefaultTimezone ??
                                              false) {
                                            // && _spTimezoneDataModelNotifier.value?.timezoneStr != null){
                                            _timezoneNotifier.value =
                                                _spTimezoneDataModelNotifier
                                                    .value?.timezoneStr;
                                          }
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  height: 1,
                                                  fontFamily: "NotoSansSC"),
                                              children: textSpans),
                                        )),
                                  );
                                } else {
                                  List<TextSpan> textSpans = [];
                                  if (_localTimezoneNotifier.value !=
                                      selectedTimezoneStr) {
                                    textSpans = [
                                      const TextSpan(text: "本地时区: "),
                                      TextSpan(
                                          text: localTimezoneStr,
                                          style:
                                              TextStyle(color: Colors.black87))
                                    ];
                                  }
                                  return Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    child: TextButton(
                                        onPressed: () {
                                          if (_timezoneNotifier.value !=
                                              localTimezoneStr) {
                                            _timezoneNotifier.value =
                                                localTimezoneStr;
                                          }
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  height: 1,
                                                  fontFamily: "NotoSansSC"),
                                              children: textSpans),
                                        )),
                                  );
                                }
                              });
                        });
                  },
                ),
              ),
            ]),
            Tooltip(
              message: "开启后当时间为“夏令时”，则自动调整回自然时间",
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

  Widget buildCityArea(Address location) {
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
              if (location.city != null)
                Text(
                  " · ",
                  style: locationTextStyle,
                ),
              if (location.city != null)
                Text(
                  location.city!.name,
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
                  onPressed: toLngLatSelectPage, icon: Icon(Icons.map_rounded))
            ],
          ),
          Text.rich(
            TextSpan(
                style: lngLatTextStyle.copyWith(color: Colors.black87),
                children: [
                  TextSpan(
                      text:
                          "${location.lowestGeoLocation.coordinates.longitude}, ${location.lowestGeoLocation.coordinates.latitude}")
                ]),
          ),
          Text.rich(
            TextSpan(
                text: "(行政中心坐标)",
                style: lngLatTextStyle.copyWith(color: Colors.black45)),
          )
        ]);
  }

  void handleDSTTime(DateTime? result, String timezoneStr) {
    if (result != null) {
      l.i("handle datetime from DST to normal");
      final tzDateTime =
          tz.TZDateTime.from(result, tz.getLocation(timezoneStr));
      // final isDST = SolarTimeCalculator.checkIsDST(result, timezoneStr);
      if (tzDateTime.timeZone.isDst) {
        l.d("current datetime is DST");

        if (_isAutoHandleDSTNotifier.value ?? false) {
          DateTime dstDateTime = result;
          DateTime removedDSTDateTime =
              dstDateTime.subtract(Duration(hours: 1));
          _selectedBirthTimeNotifier.value = removedDSTDateTime;
          _DSTBirthTimeNotifier.value = result; // 保留DST，并显示在UI上
          _isDSTNotifier.value = false;
        } else {
          _selectedBirthTimeNotifier.value = result;
          _isDSTNotifier.value = true;
        }
      } else {
        l.d("current datetime is not DST");
        _selectedBirthTimeNotifier.value = result;
        _isDSTNotifier.value = false;
      }
    }
  }

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
                                height: dstTime == null ? 0 : 18,
                                width: 240,
                                // color: Colors.redAccent.withAlpha(100),
                                child: dstTime == null
                                    ? SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16 * 2,
                                          ),
                                          Text.rich(TextSpan(
                                              text:
                                                  "${widget.dateTimeFormat.format(dstTime)} ",
                                              style: TextStyle(height: 1.0, color: Colors.black87, fontSize: 16, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough),
                                              children: [
                                                TextSpan(
                                                    text: "夏令时",
                                                    style:
                                                        TextStyle(fontSize: 13))
                                              ])),
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
                                        child: Text(widget.dateTimeFormat
                                            .format(dateTime)),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize:
                                                dstTime == null ? 36 : 34),
                                        duration: duration),

                                    // Text(dateTimeFormat.format(dateTime),
                                    //   style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87,fontSize: 36),),
                                    SizedBox(
                                      width: 42,
                                      height: 28,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ValueListenableBuilder<bool>(
                                            valueListenable: _isDSTNotifier,
                                            builder: (context, isDST, _) {
                                              return AnimatedSwitcher(
                                                duration: duration,
                                                transitionBuilder:
                                                    (Widget child,
                                                        Animation<double>
                                                            animation) {
                                                  final offsetAnimation =
                                                      Tween<Offset>(
                                                    begin:
                                                        const Offset(0.0, -1.0),
                                                    end: Offset.zero,
                                                  ).animate(CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeInOut,
                                                  ));
                                                  final opacityAnimation =
                                                      Tween<double>(
                                                              begin: 0.0,
                                                              end: 1.0)
                                                          .animate(animation);
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : SizedBox.shrink(
                                                        key: ValueKey(isDST)),
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
                                initialDate: _selectedBirthTimeNotifier.value);
                            if (result != null) {
                              handleDSTTime(result, _timezoneNotifier.value!);
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

  void onIsDefaultTimezoneChanged(bool? newValue) async {
    // _isDefaultTimezoneNotifier.value = newValue ?? false
    bool isDefault = newValue ?? false;
    SPTimezoneDataModel toSavedTimezoneDataModel;
    if (_spTimezoneDataModelNotifier.value == null) {
      // toSavedTimezoneDataModel = SPTimezoneDataModel(
      // appFeatureModule: appFeatureModule,
      // timezoneStr: _timezoneNotifier.value,
      // isAutoHandleDST: _isAutoHandleDSTNotifier.value,
      // isDefaultTimezone: isDefault);
    } else {
      toSavedTimezoneDataModel = _spTimezoneDataModelNotifier.value!.copyWith(
          timezoneStr: _timezoneNotifier.value, isDefaultTimezone: isDefault);
    }
    // await saveTimezoneDataModel(toSavedTimezoneDataModel);
    // _spTimezoneDataModelNotifier.value =
    // await loadTimezoneDataModelFromShared(appFeatureModule);
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

  void onTimezoneSelected(String? newValue) async {
    // 当 _spTimezoneDataModelNotifier.value != null 是，
    // 需要检测新选的值是否与 _spTimezoneDataModelNotifier.value?.timezoneStr
    // 如果不同，且_isDefaultTimezoneNotifier.value == true，则需要在UI上取消 _isDefaultTimezone
    if (_spTimezoneDataModelNotifier.value != null) {
      final currentSPTZDataModel = _spTimezoneDataModelNotifier.value!;
      if (currentSPTZDataModel.timezoneStr != newValue &&
          (currentSPTZDataModel.isDefaultTimezone ?? false)) {
        _isDefaultTimezoneNotifier.value = false;
      }
    }
    _timezoneNotifier.value = newValue;
  }

  void onAutoHandleTimezoneChanged(bool? newValue) async {
    // _isDefaultTimezoneNotifier.value = newValue ?? false
    bool isAutoHandle = newValue ?? false;
    SPTimezoneDataModel toSavedTimezoneDataModel;
    // if (_spTimezoneDataModelNotifier.value == null) {
    //   toSavedTimezoneDataModel = SPTimezoneDataModel(
    //       appFeatureModule: appFeatureModule,
    //       timezoneStr: _timezoneNotifier.value,
    //       isAutoHandleDST: isAutoHandle,
    //       isDefaultTimezone: _isDefaultTimezoneNotifier.value);
    // } else {
    //   toSavedTimezoneDataModel = _spTimezoneDataModelNotifier.value!.copyWith(
    //       timezoneStr: _timezoneNotifier.value, isAutoHandleDST: isAutoHandle);
    // }
    // await saveTimezoneDataModel(toSavedTimezoneDataModel);
    // _spTimezoneDataModelNotifier.value =
    //     await loadTimezoneDataModelFromShared(appFeatureModule);
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
}
