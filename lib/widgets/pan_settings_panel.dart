import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_center_gong_ji_gong_type.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/jia_zi.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/enums.dart'; // For PlateType

// It's good practice to also import other enums if they are used in dropdowns, etc.
// For now, these are the direct parameters.

/// 排盘设置面板Widget。
///
/// 负责展示和处理所有与奇门遁甲盘面排列相关的用户设置，
/// 包括排盘类型、置闰方式、月令类型、四维宫类型、神盘类型、干支选择等。
class PanSettingsPanel extends StatelessWidget {
  /// 盘面类型 (转盘/飞盘) 的通知器。
  final ValueNotifier<PlateType> plateTypeNotifier;

  /// 排列方式 (拆补/置闰/茅山/阴盘) 的通知器。
  final ValueNotifier<ArrangeType> arrangeTypeNotifier;

  /// 中宫寄宫方式的通知器。
  final ValueNotifier<CenterGongJiGongType> jiGongHintNotifier;

  /// 九星旺衰参考月令类型的通知器。
  final ValueNotifier<MonthTokenTypeEnum> monthTokenTypeNotifier;

  /// 八神随宫方式的通知器。
  final ValueNotifier<GodWithGongTypeEnum> godWithGongTypeNotifier;

  /// 九星在四维宫旺衰类型的通知器。
  final ValueNotifier<GongTypeEnum> starGongTypeNotifier;

  /// 八门在四维宫旺衰类型的通知器。
  final ValueNotifier<GongTypeEnum> doorGongTypeNotifier;

  /// 天干在宫内十二长生状态旺衰类型的通知器。
  final ValueNotifier<GanGongTypeEnum> ganGongTypeNotifier;

  /// 当前选择的日期时间通知器。
  final ValueNotifier<DateTime?> selectedDateTimeNotifier;

  /// "排盘"按钮按下时的回调。
  final VoidCallback onArrangePlatePressed;

  /// "清除"按钮按下时的回调。
  final VoidCallback onClearPlatePressed;

  /// "选择时间"按钮按下时的回调。
  final Future<void> Function() onSelectDateTimePressed;

  /// 年干支手动更改时的回调。
  final Function(JiaZi?) onYearJiaZiChanged;

  /// 月干支手动更改时的回调。
  final Function(JiaZi?) onMonthJiaZiChanged;

  /// 日干支手动更改时的回调。
  final Function(JiaZi?) onDayJiaZiChanged;

  /// 时干支手动更改时的回调。
  final Function(JiaZi?) onTimeJiaZiChanged;

  /// 阴阳遁和局数手动更改时的回调。
  final Function(String?) onDunJuChanged;

  // final Function(String?) onJieQiChanged; // Manual JieQi selection not implemented yet

  /// 年干支输入框的抖动动画GlobalKey。
  final GlobalKey<ShakeWidgetState> yearGanZhiShakeKey;
  /// 月干支输入框的抖动动画GlobalKey。
  final GlobalKey<ShakeWidgetState> monthGanZhiShakeKey;
  /// 日干支输入框的抖动动画GlobalKey。
  final GlobalKey<ShakeWidgetState> dayGanZhiShakeKey;
  /// 时干支输入框的抖动动画GlobalKey。
  final GlobalKey<ShakeWidgetState> timeGanZhiShakeKey;
  /// 局数输入框的抖动动画GlobalKey。
  final GlobalKey<ShakeWidgetState> dunGanZhiShakeKey;

  /// SlideSwitcher未激活状态的文本样式。
  final TextStyle switcherInactivatedStyle;
  /// SlideSwitcher激活状态的文本样式。
  final TextStyle switcherActivatedStyle;
  /// 转盘激活时的文本样式。
  final TextStyle zhuanPanActivatedStyle;
  /// 飞盘激活时的文本样式。
  final TextStyle feiPanActivatedStyle;

  const PanSettingsPanel({
    super.key,
    required this.plateTypeNotifier,
    required this.arrangeTypeNotifier,
    required this.jiGongHintNotifier,
    required this.monthTokenTypeNotifier,
    required this.godWithGongTypeNotifier,
    required this.starGongTypeNotifier,
    required this.doorGongTypeNotifier,
    required this.ganGongTypeNotifier,
    required this.selectedDateTimeNotifier,
    required this.onArrangePlatePressed,
    required this.onClearPlatePressed,
    required this.onSelectDateTimePressed,
    required this.onYearJiaZiChanged,
    required this.onMonthJiaZiChanged,
    required this.onDayJiaZiChanged,
    required this.onTimeJiaZiChanged,
    required this.onDunJuChanged,
    // required this.onJieQiChanged,
    required this.yearGanZhiShakeKey,
    required this.monthGanZhiShakeKey,
    required this.dayGanZhiShakeKey,
    required this.timeGanZhiShakeKey,
    required this.dunGanZhiShakeKey,
    required this.switcherInactivatedStyle,
    required this.switcherActivatedStyle,
    required this.zhuanPanActivatedStyle,
    required this.feiPanActivatedStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // PlateType and ArrangeType Switchers
        Center(
          child: ValueListenableBuilder<PlateType>(
            valueListenable: plateTypeNotifier,
            builder: (ctx, type, _) {
              return SlideSwitcher(
                  onSelect: (index) {
                    switch (index) {
                      case 0:
                        plateTypeNotifier.value = PlateType.ZHUAN_PAN;
                        break;
                      case 1:
                        plateTypeNotifier.value = PlateType.FEI_PAN;
                        break;
                    }
                  },
                  containerHeight: 56,
                  containerWight: 240,
                  indents: 2,
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
                    AnimatedDefaultTextStyle(
                        style: type != PlateType.ZHUAN_PAN
                            ? switcherActivatedStyle.copyWith(fontSize: 24, color: zhuanPanActivatedStyle.color)
                            : zhuanPanActivatedStyle.copyWith(fontSize: 24),
                        duration: const Duration(milliseconds: 200),
                        child: Text(PlateType.ZHUAN_PAN.name)),
                    AnimatedDefaultTextStyle(
                        style: type != PlateType.FEI_PAN
                            ? switcherActivatedStyle.copyWith(fontSize: 24, color: feiPanActivatedStyle.color)
                            : feiPanActivatedStyle.copyWith(fontSize: 24),
                        duration: const Duration(milliseconds: 200),
                        child: Text(PlateType.FEI_PAN.name)),
                  ]);
            },
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<ArrangeType>(
            valueListenable: arrangeTypeNotifier,
            builder: (ctx, arrangeType, _) {
              return SlideSwitcher(
                  initialIndex: arrangeType.index,
                  onSelect: (index) {
                    arrangeTypeNotifier.value = ArrangeType.values[index];
                  },
                  containerHeight: 42,
                  containerWight: 350,
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
                  children: ArrangeType.values
                      .map((t) => AnimatedDefaultTextStyle(
                          style: arrangeType != t
                              ? switcherInactivatedStyle
                              : (plateTypeNotifier.value == PlateType.ZHUAN_PAN ? zhuanPanActivatedStyle : feiPanActivatedStyle),
                          duration: const Duration(milliseconds: 200),
                          child: Text("${t.name}法")))
                      .toList());
            }),
        const SizedBox(height: 16),
        // Settings Dropdowns and Hint Text
        Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row( // JiGong and JieQi/Season selection
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text("中宫寄宫：", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black87)),
                        ),
                        ValueListenableBuilder<CenterGongJiGongType>(
                            valueListenable: jiGongHintNotifier,
                            builder: (ctx, cgg, _) {
                              return SlideSwitcher(
                                  initialIndex: cgg.index,
                                  onSelect: (index) {
                                    jiGongHintNotifier.value = CenterGongJiGongType.values[index];
                                  },
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  children: CenterGongJiGongType.values
                                      .map((t) => AnimatedDefaultTextStyle(
                                          style: cgg != t ? switcherInactivatedStyle : (plateTypeNotifier.value == PlateType.ZHUAN_PAN ? zhuanPanActivatedStyle : feiPanActivatedStyle),
                                          duration: const Duration(milliseconds: 200),
                                          child: Text(t.name)))
                                      .toList());
                            }),
                         Container(
                           alignment: Alignment.center,
                           width: 240,
                           child: ValueListenableBuilder<CenterGongJiGongType>(
                               valueListenable: jiGongHintNotifier,
                               builder: (ctx, hint, _) {
                                 return Text(
                                     ConstantResourcesOfQiMen.hitCenterGongJiGongMapper[hint]!,
                                     style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w300, height: 1.1));
                               }),
                         )
                      ],
                    ),
                     // JieQi/Season dropdown for manual mode (if arrangeType is MANUALLY and jiGong type requires it)
                    ValueListenableBuilder(
                        valueListenable: arrangeTypeNotifier,
                        builder: (ctx, arrangeType, _) {
                          return ValueListenableBuilder(
                            valueListenable: jiGongHintNotifier,
                            builder: (ctx, jiGong, _) {
                                if (arrangeType == ArrangeType.MANUALLY &&
                                    (jiGong == CenterGongJiGongType.FOUR_WEI_GONG || jiGong == CenterGongJiGongType.EIGTH_GONG)) {
                                  List<String> items;
                                  String hintText;
                                  if (jiGong == CenterGongJiGongType.EIGTH_GONG) {
                                    items = const ["立春（艮）", "春分（震）", "立夏（巽）", "夏至（离）", "立秋（坤）", "秋分（兑）", "立冬（乾）", "冬至（坎）"];
                                    hintText = "八节";
                                  } else { // FOUR_WEI_GONG
                                    items = const ["春（艮）", "夏（巽）", "秋（坤）", "冬（乾）"];
                                    hintText = "四季";
                                  }
                                  return SizedBox(
                                    width: 160,
                                    height: 48,
                                    child: CustomDropdown<String>.search(
                                      decoration: CustomDropdownDecoration( /* ... styles ... */ ),
                                      hintText: hintText,
                                      items: items,
                                      onChanged: (value) {
                                        // This logic was previously in ShiJiaQiMenViewPage, needs to call a callback if state change is needed higher up
                                        // For now, assuming onJieQiChanged callback handles this.
                                        // onJieQiChanged(value);
                                      },
                                    ),
                                  );
                                }
                                return const SizedBox();
                            }
                          );
                        }
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingRow<MonthTokenTypeEnum>("月令旺衰取法：", monthTokenTypeNotifier, MonthTokenTypeEnum.values, ConstantResourcesOfQiMen.monthTokenHintMapper),
                const SizedBox(height: 12),
                _buildSettingRow<GodWithGongTypeEnum>("“神”与“宫”旺衰：", godWithGongTypeNotifier, GodWithGongTypeEnum.values, ConstantResourcesOfQiMen.godWithGongTypeMapper),
                const SizedBox(height: 12),
                _buildSettingRow<GongTypeEnum>("“星”与“宫”旺衰：", starGongTypeNotifier, GongTypeEnum.values, ConstantResourcesOfQiMen.gongTypeMapper),
                const SizedBox(height: 12),
                _buildSettingRow<GongTypeEnum>("“门”与“宫”旺衰：", doorGongTypeNotifier, GongTypeEnum.values, ConstantResourcesOfQiMen.gongTypeMapper),
                const SizedBox(height: 12),
                _buildSettingRow<GanGongTypeEnum>("“干”与“宫”旺衰：", ganGongTypeNotifier, GanGongTypeEnum.values, ConstantResourcesOfQiMen.ganGongTypeMapper),
              ],
            )),
        const SizedBox(height: 16),
        ValueListenableBuilder<ArrangeType>(
            valueListenable: arrangeTypeNotifier,
            builder: (ctx, arrangeType, _) {
              if (arrangeType == ArrangeType.MANUALLY) {
                return _buildManuallyJuPanel(context);
              }
              // Return a SizedBox that matches the typical height of the manual panel to avoid layout jumps
              // This might need adjustment based on the actual height of _buildManuallyJuPanel
              return const SizedBox(height: 48 + 16);
            }),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onArrangePlatePressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), textStyle: const TextStyle(fontSize: 18, color: Colors.black87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('排盘'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onClearPlatePressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), textStyle: const TextStyle(fontSize: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('清除'),
            ),
            const SizedBox(width: 16),
            _buildSelectDateTimeButton(context),
          ],
        ),
         const SizedBox(height: 24), // Added some padding at the bottom
      ],
    );
  }

  Widget _buildSettingRow<T extends Enum>(
    String title,
    ValueNotifier<T> notifier,
    List<T> enumValues,
    Map<T, String> hintMapper,
  ) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: 240,
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black87)),
        ),
        ValueListenableBuilder<T>(
            valueListenable: notifier,
            builder: (ctx, currentValue, _) {
              return ValueListenableBuilder<PlateType>( // Listen to plateType for dynamic styling
                valueListenable: plateTypeNotifier,
                builder: (context, currentPlateType, _) {
                  TextStyle activeStyle = currentPlateType == PlateType.ZHUAN_PAN ? zhuanPanActivatedStyle : feiPanActivatedStyle;
                  return SlideSwitcher(
                      initialIndex: currentValue.index,
                      onSelect: (index) {
                        notifier.value = enumValues[index];
                      },
                      containerHeight: 36,
                      containerWight: 240,
                      indents: 4,
                      containerColor: const Color(0xffe4e5eb),
                      slidersColors: const [Color(0xfff7f5f7)],
                      children: enumValues
                          .map((t) => AnimatedDefaultTextStyle(
                              style: currentValue != t ? switcherInactivatedStyle : activeStyle,
                              duration: const Duration(milliseconds: 200),
                              child: Text(t.name)))
                          .toList());
                }
              );
            }),
        Container(
          alignment: Alignment.center,
          width: 240,
          child: ValueListenableBuilder<T>(
              valueListenable: notifier,
              builder: (ctx, hintKey, _) {
                // Special handling for MonthTokenTypeEnum to show dynamic hint
                if (hintKey is MonthTokenTypeEnum) {
                  Lunar lunar = Lunar.fromDate(DateTime.now()); // Or use selectedDateTimeNotifier.value
                  String monthTokenStr = lunar.getMonthZhi();
                  MonthToken monthToken = DiZhi.getFromValue(monthTokenStr)!.asMonthToken;
                   return RichText(
                                    text: TextSpan(
                                        text: hintMapper[hintKey]!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w300,
                                            height: 1.1),
                                        children: [
                                      const TextSpan(text: "："),
                                      TextSpan(
                                          text: monthToken.diZhi.name,
                                          style: TextStyle(
                                              color: ConstResourcesMapper
                                                      .zodiacZhiColors[
                                                  monthToken.diZhi]!)),
                                      const TextSpan(text: " → "),
                                      TextSpan(
                                          text: monthToken.majorQi.name,
                                          style: TextStyle(
                                            color: ConstResourcesMapper
                                                    .zodiacGanColors[
                                                monthToken.majorQi]!,
                                            fontWeight: hintKey ==
                                                    MonthTokenTypeEnum.ZHU_QI_NA_GUA
                                                ? FontWeight.w300
                                                : FontWeight.w500,
                                          )),
                                      hintKey == MonthTokenTypeEnum.ZHU_QI_NA_GUA
                                          ? const TextSpan(text: " → ")
                                          : const TextSpan(text: ""),
                                      hintKey == MonthTokenTypeEnum.ZHU_QI_NA_GUA
                                          ? TextSpan(
                                              text: monthToken.majorQi.naJiaGua,
                                              style: TextStyle(
                                                  color: ConstResourcesMapper
                                                          .zodiacGuaColors[
                                                      HouTianGua.getGuaByName(
                                                          monthToken.majorQi
                                                              .naJiaGua)]!,
                                                  fontWeight: FontWeight.w500))
                                          : const TextSpan(text: ""),
                                    ]));
                }
                return Text(
                    hintMapper[hintKey] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w300, height: 1.1));
              }),
        )
      ],
    );
  }

  Widget _buildManuallyJuPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGanZhiDropdown("年干支", yearGanZhiShakeKey, JiaZi.listAll.map((e) => e.name).toList(), onYearJiaZiChanged),
          const SizedBox(width: 12),
          _buildGanZhiDropdown("月干支", monthGanZhiShakeKey, JiaZi.listAll.map((e) => e.name).toList(), onMonthJiaZiChanged),
          const SizedBox(width: 12),
          _buildGanZhiDropdown("日干支", dayGanZhiShakeKey, JiaZi.listAll.map((e) => e.name).toList(), onDayJiaZiChanged),
          const SizedBox(width: 12),
          _buildGanZhiDropdown("时干支", timeGanZhiShakeKey, JiaZi.listAll.map((e) => e.name).toList(), onTimeJiaZiChanged),
          const SizedBox(width: 12),
          ShakeMe(
            key: dunGanZhiShakeKey,
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.4), spreadRadius: 1, blurRadius: 2)],
                    expandedShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.4), spreadRadius: 1, blurRadius: 2)],
                    searchFieldDecoration: const SearchFieldDecoration(prefixIcon: null)
                ),
                hintText: "阴阳遁局",
                items: List.generate(9, (i) => "阳遁${ConstResourcesMapper.chineseNumberMapper[i + 1]!}局")
                  ..addAll(List.generate(9, (i) => "阴遁${ConstResourcesMapper.chineseNumberMapper[i + 1]!}局")),
                onChanged: onDunJuChanged,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGanZhiDropdown(String hintText, GlobalKey<ShakeWidgetState> shakeKey, List<String> items, Function(JiaZi?) onChanged) {
    return ShakeMe(
      key: shakeKey,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 128,
        height: 48,
        child: CustomDropdown<String>.search(
          decoration: CustomDropdownDecoration(
              closedShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), spreadRadius: 1, blurRadius: 2)],
              expandedShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), spreadRadius: 1, blurRadius: 2)],
              searchFieldDecoration: const SearchFieldDecoration(prefixIcon: null)
          ),
          hintText: hintText,
          items: items,
          onChanged: (value) {
            if (value != null) {
              onChanged(JiaZi.getFromGanZhiValue(value));
            } else {
              onChanged(null);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectDateTimeButton(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onSelectDateTimePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDateTimeNotifier,
                  builder: (ctx, dateTime, _) {
                    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm");
                    return Text(dateFormat.format(dateTime ?? DateTime.now()), style: const TextStyle(fontSize: 16));
                  }),
              const Text('选择时间', style: TextStyle(fontSize: 12))
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: () {
             selectedDateTimeNotifier.value = DateTime.now();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('现在'),
        ),
      ],
    );
  }
}
