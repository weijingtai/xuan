import 'package:auto_size_text/auto_size_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/city_picker_bottom_sheet.dart';
import 'package:common/widgets/eight_chars_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:intl/intl.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';
import '../helpers/solar_lunar_datetime_helper.dart';
import 'gan_zhi_picker_alert_dialog.dart';
import 'responseive_datetime_dialog.dart';

class EightCharsInput extends StatefulWidget {
  final EightChars? initEightChars;
  const EightCharsInput({super.key, required this.initEightChars});

  @override
  State<EightCharsInput> createState() => _EightCharsInputState();
}

class _EightCharsInputState extends State<EightCharsInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final ValueNotifier<JiaZi?> _selectedYearNotifier;
  late final ValueNotifier<JiaZi?> _selectedMonthNotifier;
  late final ValueNotifier<JiaZi?> _selectedDayNotifier;
  late final ValueNotifier<JiaZi?> _selectedTimeNotifier;

  late final ValueNotifier<List<DateTime>?> sameGanZhiAtDateTimeListNotifier =
      ValueNotifier<List<DateTime>?>(null);
  late final ValueNotifier<int?> selectedGanZhiAtDateTimeNotifier =
      ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.initEightChars != null) {
      _selectedYearNotifier = ValueNotifier(widget.initEightChars!.year);
      _selectedMonthNotifier = ValueNotifier(widget.initEightChars!.month);
      _selectedDayNotifier = ValueNotifier(widget.initEightChars!.day);
      _selectedTimeNotifier = ValueNotifier(widget.initEightChars!.time);
      checkEigthCharsDateTime(
          _selectedYearNotifier.value,
          _selectedMonthNotifier.value,
          _selectedDayNotifier.value,
          _selectedTimeNotifier.value);
    } else {
      _selectedYearNotifier = ValueNotifier(null);
      _selectedMonthNotifier = ValueNotifier(null);
      _selectedDayNotifier = ValueNotifier(null);
      _selectedTimeNotifier = ValueNotifier(null);
    }
    _selectedYearNotifier.addListener(() {
      checkEigthCharsDateTime(
          _selectedYearNotifier.value,
          _selectedMonthNotifier.value,
          _selectedDayNotifier.value,
          _selectedTimeNotifier.value);
    });
    _selectedMonthNotifier.addListener(() {
      checkEigthCharsDateTime(
          _selectedYearNotifier.value,
          _selectedMonthNotifier.value,
          _selectedDayNotifier.value,
          _selectedTimeNotifier.value);
    });
    _selectedDayNotifier.addListener(() {
      checkEigthCharsDateTime(
          _selectedYearNotifier.value,
          _selectedMonthNotifier.value,
          _selectedDayNotifier.value,
          _selectedTimeNotifier.value);
    });
    _selectedTimeNotifier.addListener(() {
      checkEigthCharsDateTime(
          _selectedYearNotifier.value,
          _selectedMonthNotifier.value,
          _selectedDayNotifier.value,
          _selectedTimeNotifier.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedYearNotifier.dispose();
    _selectedMonthNotifier.dispose();
    _selectedDayNotifier.dispose();
    _selectedTimeNotifier.dispose();
    sameGanZhiAtDateTimeListNotifier.dispose();
    selectedGanZhiAtDateTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectionButton(_ButtonType.year),
            _selectionButton(_ButtonType.month),
            _selectionButton(_ButtonType.day),
            _selectionButton(_ButtonType.time),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        ValueListenableBuilder(
            valueListenable: sameGanZhiAtDateTimeListNotifier,
            builder: (ctx, dateTimeList, _) {
              final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
              if (dateTimeList == null) {
                return Container(
                  height: 128,
                );
              }
              return Container(
                height: 320,
                width: 320,
                child: ValueListenableBuilder(
                  valueListenable: selectedGanZhiAtDateTimeNotifier,
                  builder: (ctx, selectedIndex, _) {
                    return ListView.builder(
                        itemCount: dateTimeList.length,
                        itemBuilder: (ctx, index) => InkWell(
                              onTap: () {
                                if (selectedGanZhiAtDateTimeNotifier.value !=
                                    index) {
                                  selectedGanZhiAtDateTimeNotifier.value =
                                      index;
                                }
                              },
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 400),
                                opacity: (selectedIndex == null)
                                    ? 0.5
                                    : (selectedIndex != index ? .3 : 1),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black87, width: 2),
                                  ),
                                  child: Text(
                                    dateFormat.format(dateTimeList[index]),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28),
                                  ),
                                ),
                              ),
                            ));
                  },
                ),
              );
            })
      ],
    );
  }

  void checkEigthCharsDateTime(
      JiaZi? year, JiaZi? month, JiaZi? day, JiaZi? time) {
    if (sameGanZhiAtDateTimeListNotifier.value != null) {
      // 当前用户放弃了之前输入的生辰八字，所以清空基于之前八字获取的时间
      if ([year, month, day, time].any((gz) => gz == null)) {
        sameGanZhiAtDateTimeListNotifier.value = null;
        if (selectedGanZhiAtDateTimeNotifier.value != null) {
          // 取消已选择的时间
          selectedGanZhiAtDateTimeNotifier.value = null;
        }
      }
      // print(
      // "${sameGanZhiAtDateTimeListNotifier.value}  ${selectedGanZhiAtDateTimeNotifier.value}");
      return;
    }
    if ([year, month, day, time].any((gz) => gz == null)) {
      return;
    }
    // 八字全部为空时，用户更改了时间 重新计算

    List<DateTime> dateTimeList = SolarLunarDateTimeHelper.eightChars2DateTime(
        EightChars(year: year!, month: month!, day: day!, time: time!));
    if (dateTimeList.isEmpty) {
      InteractiveToast.pop(
        context: context,
        title: const Text("用户输入的八字没有找到对应时间，请查正"),
        trailing: trailingWidget(),
        leading: leadingWidget(),
        toastSetting: const PopupToastSetting(
          animationDuration: Duration(seconds: 1),
          displayDuration: Duration(seconds: 3),
          toastAlignment: Alignment.bottomCenter,
        ),
      );
    }
    if (dateTimeList.length == 1) {
      selectedGanZhiAtDateTimeNotifier.value = 0;
    }
    sameGanZhiAtDateTimeListNotifier.value = dateTimeList;
  }

  Text textWidget(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16),
      );

  Icon trailingWidget() => const Icon(
        Icons.person,
        color: Colors.deepPurple,
      );
  Container leadingWidget() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            spreadRadius: 3,
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        "�",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _selectionButton(
    _ButtonType _bt,
  ) {
    ValueNotifier<JiaZi?> notifier = getValueNotifierByType(_bt);
    String hintText = hintTextMapper[_bt]!;

    return ValueListenableBuilder<JiaZi?>(
        valueListenable: notifier,
        builder: (ctx, jz, _) {
          return Column(
            children: [
              Text(hintText),
              ElevatedButton(
                  onPressed: () {
                    List<JiaZi>? initJiaZiList;

                    // 当前选择按钮是月干支选择时，年干支已经选择，使用"五虎遁"简化选择难度
                    if (_selectedYearNotifier.value != null) {
                      if (_bt == _ButtonType.month) {
                        initJiaZiList =
                            generateMonthGanzhi(_selectedYearNotifier.value!);
                      }
                    }

                    // 当前选择按钮是时干支选择时，日干支已经选择，使用“五鼠遁”简化选择难度
                    if (_selectedDayNotifier.value != null) {
                      if (_bt == _ButtonType.time) {
                        initJiaZiList =
                            generateTimeGanzhi(_selectedDayNotifier.value!);
                      }
                    }
                    showJiaZiPicker(context, jz, initJiaZiList)
                        .then((JiaZi? value) {
                      if (notifier.value == value) {
                        return true;
                      }
                      notifier.value = value;
                      if (_bt == _ButtonType.year) {
                        // 当年干支变更时，需要取消月干支
                        _selectedMonthNotifier.value = null;
                        _selectedDayNotifier.value = null;
                        _selectedTimeNotifier.value = null;
                      } else if (_bt == _ButtonType.month) {
                        _selectedDayNotifier.value = null;
                        _selectedTimeNotifier.value = null;
                      } else if (_bt == _ButtonType.day) {
                        _selectedTimeNotifier.value = null;
                      }
                    });
                  },
                  child: Text(
                    jz?.name ?? "选择",
                    style: TextStyle(height: 1.0, fontSize: 24),
                  )),
              Container(
                height: 24,
                width: 48,
                child: Text(jz?.naYinStr ?? ""),
              )
            ],
          );
        });
  }

  // 根据年干支生成对应的12个月干支
  List<JiaZi> generateMonthGanzhi(JiaZi yearJiaZi) {
    // 提取年天干（如"甲子"→"甲"）
    // TianGan yearGan = yearJiaZi.tianGan;

    // 获取起始干支（如"甲"→"丙寅"）
    // JiaZi start = yearGanToStart[yearGan]!;
    // var result = JiaZi.listAll.sublist(start.index);
    // if (result.length > 12) {
    //   result = result.sublist(0, 12);
    // } else {
    //   result.addAll(JiaZi.listAll.sublist(0, 12).toList());
    //   result = result.sublist(0, 12);
    // }
    // // print(result.map((r) => r.name));
    // return result;
    return generateJiaZiDun(yearJiaZi, yearGanToStart);
  }

  List<JiaZi> generateTimeGanzhi(JiaZi yearJiaZi) {
    // TianGan yearGan = yearJiaZi.tianGan;

    // JiaZi start = timeGanToStart[yearGan]!;
    // var result = JiaZi.listAll.sublist(start.index);
    // if (result.length > 12) {
    //   result = result.sublist(0, 12);
    // } else {
    //   result.addAll(JiaZi.listAll.sublist(0, 12).toList());
    //   result = result.sublist(0, 12);
    // }
    return generateJiaZiDun(yearJiaZi, timeGanToStart);
  }

  List<JiaZi> generateJiaZiDun(JiaZi yearJiaZi, Map<TianGan, JiaZi> mapper) {
    TianGan yearGan = yearJiaZi.tianGan;

    JiaZi start = mapper[yearGan]!;
    var result = JiaZi.listAll.sublist(start.index);
    if (result.length > 12) {
      result = result.sublist(0, 12);
    } else {
      result.addAll(JiaZi.listAll.sublist(0, 12).toList());
      result = result.sublist(0, 12);
    }
    return result;
  }

  Map<_ButtonType, String> hintTextMapper = {
    _ButtonType.year: "年干支",
    _ButtonType.month: "月干支",
    _ButtonType.day: "日干支",
    _ButtonType.time: "时干支"
  };

  ValueNotifier<JiaZi?> getValueNotifierByType(_ButtonType _bt) {
    switch (_bt) {
      case _ButtonType.year:
        return _selectedYearNotifier;
      case _ButtonType.month:
        return _selectedMonthNotifier;
      case _ButtonType.day:
        return _selectedDayNotifier;
      case _ButtonType.time:
        return _selectedTimeNotifier;
    }
  }

  // 年天干对应的正月起始干支， 五虎遁
  final Map<TianGan, JiaZi> yearGanToStart = {
    TianGan.JIA: JiaZi.BING_YIN,
    TianGan.JI: JiaZi.BING_YIN,
    TianGan.YI: JiaZi.WU_YIN,
    TianGan.GENG: JiaZi.WU_YIN,
    TianGan.BING: JiaZi.GENG_YIN,
    TianGan.XIN: JiaZi.GENG_YIN,
    TianGan.DING: JiaZi.REN_YIN,
    TianGan.REN: JiaZi.REN_YIN,
    TianGan.WU: JiaZi.JIA_YIN,
    TianGan.GUI: JiaZi.JIA_YIN,
  };

  // 年天干对应的日干起时干， 五鼠遁
  final Map<TianGan, JiaZi> timeGanToStart = {
    TianGan.JIA: JiaZi.JIA_ZI,
    TianGan.JI: JiaZi.JIA_ZI,
    TianGan.YI: JiaZi.BING_ZI,
    TianGan.GENG: JiaZi.BING_ZI,
    TianGan.BING: JiaZi.WU_ZI,
    TianGan.XIN: JiaZi.WU_ZI,
    TianGan.DING: JiaZi.GENG_ZI,
    TianGan.REN: JiaZi.WU_ZI,
    TianGan.WU: JiaZi.REN_ZI,
    TianGan.GUI: JiaZi.REN_ZI,
  };
}

enum _ButtonType {
  year,
  month,
  day,
  time,
}
