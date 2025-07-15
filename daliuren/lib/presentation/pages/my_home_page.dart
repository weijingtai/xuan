import 'dart:async';
// import 'dart:convert'; // No longer directly used for JSON loading here

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/widgets/four_zhu_eight_char.dart'; // May be used if LiuRenPan has BaZi
import 'package:daliuren/presentation/widgets/pan_display_widget.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // No longer directly loading from rootBundle here
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/Lunar.dart'; // For displaying Lunar date if needed
import 'package:provider/provider.dart';

// Domain entities that the View will now primarily deal with
import 'package:daliuren/domain/entities/liu_ren_pan_model.dart';

import '../viewmodels/my_home_viewmodel.dart';
import '../widgets/yu_ding_display_widget.dart';

// View Model

class MyHomePage extends StatefulWidget {
  DivinationInfoModel divinationInfoModel;
  const MyHomePage(
      {super.key,
      required this.title,
      divinationInfoModel: DivinationInfoModel()});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String ICONS_ASSETS_PATH =
      "assets/icons/"; // Keep for local asset paths if any remain

  // Keys for shake widgets (for manual input validation)
  final GlobalKey<ShakeWidgetState> renYearGanZhiShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> renMonthGanZhiShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> renDayGanZhiShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> renTimeGanZhiShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> renDunGanZhiShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> renJuNumberShakeKey =
      GlobalKey<ShakeWidgetState>();

  // Local state for UI interactions (e.g., selected date before "排盘")
  DateTime? _selectedDateTimeForPan;

  // Local state for manual GanZhi input before submitting to ViewModel
  JiaZi? _manualYearJiaZi;
  JiaZi? _manualMonthJiaZi;
  JiaZi? _manualDayJiaZi;
  JiaZi? _manualTimeJiaZi;
  YinYang? _manualYinYangDun;
  int? _manualJuNumber;

  // For月将 hover/long-press effect (can be kept if UI needs it)
  final ValueNotifier<bool> _showMonthGeneralJieQi = ValueNotifier(false);
  Timer? _showMonthGeneralJieQiTimer;
  bool _isMonthGeneralSticky = false;

  @override
  void initState() {
    super.initState();
    // ViewModel initialization (like DB init) is handled by the ViewModel itself now.
    // We can choose to set an initial date for the picker here if desired.
    _selectedDateTimeForPan = DateTime.now();
  }

  @override
  void dispose() {
    _showMonthGeneralJieQi.dispose();
    if (_showMonthGeneralJieQiTimer != null) {
      _showMonthGeneralJieQiTimer!.cancel();
      _showMonthGeneralJieQiTimer = null;
    }
    super.dispose();
  }

  // --- UI Building Methods ---
  // Many of the old build_panel, panel_gong, etc. methods will be deprecated or moved
  // into PanDisplayWidget and its sub-components. For now, this file will simplify.

  Size panSize = const Size(400, 400); // Keep for layout reference
  // Size gongSize = const Size(400 * .25, 400 * .25); // This will be internal to PanDisplayWidget

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyHomePageViewModel>();
    final MyHomePageState state = viewModel.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.liuRenPan?.dayJiaZi != null
            ? "${state.liuRenPan!.dayJiaZi}日 ${state.liuRenPan!.timeChen}时 ${state.liuRenPan!.dayNight} ${state.liuRenPan!.nineZongMen.name}" // Simplified title
            : widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (state.isInitializing)
                const CircularProgressIndicator(
                  semanticsLabel: "数据库初始化中...",
                )
              else if (!state.isDbInitialized && state.error != null)
                Text("数据库初始化失败: ${state.error!.message}",
                    style: const TextStyle(color: Colors.red))
              else ...[
                // Pan Base Info (Simplified or using parts of PanDisplayWidget later)
                _buildPanBaseInfo(state.liuRenPan),
                const SizedBox(height: 16),

                // Main Pan Display Area
                if (state.isLoadingPan)
                  const CircularProgressIndicator(
                    semanticsLabel: "排盘中...",
                  )
                else if (state.liuRenPan != null)
                  PanDisplayWidget(liuRenPan: state.liuRenPan) // New Widget
                else if (state.error?.message.contains("LiuRenPan") ??
                    false) // Check if error is pan related
                  Text("排盘失败: ${state.error!.message}",
                      style: const TextStyle(color: Colors.red))
                else
                  Container(
                    // Placeholder for pan display area
                    width: panSize.width,
                    height: panSize.height,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text("请选择条件进行排盘")),
                  ),
                const SizedBox(height: 16),

                // YuDing Entry Display Area
                if (state.isLoadingYuDing)
                  const CircularProgressIndicator(
                    semanticsLabel: "获取课义中...",
                  )
                else if (state.yuDingEntry != null)
                  YuDingDisplayWidget(
                      yuDingEntry: state.yuDingEntry!) // New Widget
                else if (state.error?.message.contains("YuDing") ??
                    false) // Check if error is YuDing related
                  Text("获取课义失败: ${state.error!.message}",
                      style: const TextStyle(color: Colors.red))
                else
                  const SizedBox
                      .shrink(), // No YuDing or error related to it specifically

                const SizedBox(height: 32),
                _buildManualInputSection(
                    context, viewModel), // Manual GanZhi Inputs
                const SizedBox(height: 32),
                _buildActionButtons(context, viewModel), // Action Buttons
                const SizedBox(height: 56),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanBaseInfo(LiuRenPanModel? pan) {
    if (pan == null) return const SizedBox.shrink();

    // Simplified display of base info. Could be expanded or part of PanDisplayWidget.
    // Lunar? lunarDate =
    //     pan.panDateTime != null ? Lunar.fromDate(pan.panDateTime!) : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // if (pan.panDateTime != null)
            //   Text(
            //       "公历: ${DateFormat("yyyy-MM-dd HH:mm").format(pan.panDateTime!)}"),
            // if (lunarDate != null)
            //   Text(
            //       "农历: ${lunarDate.getYearInGanZhi()}年 ${lunarDate.getMonthInChinese()}月 ${lunarDate.getDayInChinese()} ${lunarDate.getTimeZhi()}时"),

            Text("日课: ${pan.dayJiaZi.name} ${pan.timeChen}时"),
            // Could add FourZhuEightChar widget here if BaZi is part of LiuRenPan entity
            if (pan.dayJiaZi != null &&
                pan.timeChen != null /* and other BaZi parts */)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FourZhuEightChar(
                  year: pan.dayJiaZi!, // Placeholder, need full BaZi from pan
                  month: pan.dayJiaZi!, // Placeholder
                  day: pan.dayJiaZi!,
                  chen: JiaZi.getFromGanZhiEnum(
                      pan.dayJiaZi!.tianGan, pan.timeChen!), // Approximate
                  isColorful: true,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputSection(
      BuildContext context, MyHomePageViewModel viewModel) {
    // This section retains the CustomDropdowns for manual input.
    // Their onChanged callbacks will update the local _manual* variables.
    // The "干支排盘" button will then use these variables.
    return Column(
      children: [
        Text("或手动选择干支局数排盘:", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          // Using Wrap for better responsiveness
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildGanZhiDropdown(renDayGanZhiShakeKey, "日干支", JiaZi.listAll,
                (val) => _manualDayJiaZi = val),
            _buildGanZhiDropdown(renTimeGanZhiShakeKey, "时干支", JiaZi.listAll,
                (val) => _manualTimeJiaZi = val),
            // For simplicity, Year and Month GanZhi inputs are omitted as they are often less critical for basic LiuRen
            // _buildGanZhiDropdown(renYearGanZhiShakeKey, "年干支", JiaZi.listAll, (val) => _manualYearJiaZi = val),
            // _buildGanZhiDropdown(renMonthGanZhiShakeKey, "月干支", JiaZi.listAll, (val) => _manualMonthJiaZi = val),
            _buildYinYangDropdown(
                renDunGanZhiShakeKey, (val) => _manualYinYangDun = val),
            _buildJuNumberDropdown(
                renJuNumberShakeKey, (val) => _manualJuNumber = val),
          ],
        ),
      ],
    );
  }

  Widget _buildGanZhiDropdown(
      Key key, String hint, List<JiaZi> items, ValueChanged<JiaZi?> onChanged) {
    return ShakeMe(
      key: key,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 135, // Adjusted width
        height: 48,
        child: CustomDropdown<JiaZi>.search(
          decoration: CustomDropdownDecoration(
              searchFieldDecoration:
                  const SearchFieldDecoration(prefixIcon: null)),
          hintText: hint,
          items: items,
          onChanged: onChanged,
          headerBuilder: (context, item, isEnable) => Text(item.name),
          listItemBuilder: (_, item, isSelected, onTap) => ListTile(
            title: Text(item.name),
            onTap: onTap,
            selected: isSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildYinYangDropdown(Key key, ValueChanged<YinYang?> onChanged) {
    return ShakeMe(
      key: key,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 135,
        height: 48,
        child: CustomDropdown<YinYang>.search(
          decoration: CustomDropdownDecoration(
              searchFieldDecoration:
                  const SearchFieldDecoration(prefixIcon: null)),
          hintText: "阴阳遁",
          items: YinYang.values.toList(), // Filter out UNKNOWN
          onChanged: onChanged,
          headerBuilder: (context, item, isEnable) =>
              Text(item.isYang ? "阳遁" : "阴遁"),
          listItemBuilder: (_, item, isSelected, onTap) => ListTile(
            title: Text(item.isYang ? "阳遁" : "阴遁"),
            onTap: onTap,
            selected: isSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildJuNumberDropdown(Key key, ValueChanged<int?> onChanged) {
    final items = List.generate(12, (i) => i + 1);
    return ShakeMe(
      key: key,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 135,
        height: 48,
        child: CustomDropdown<int>.search(
          decoration: CustomDropdownDecoration(
              searchFieldDecoration:
                  const SearchFieldDecoration(prefixIcon: null)),
          hintText: "局数",
          items: items,
          onChanged: onChanged,
          headerBuilder: (context, item, isEnable) =>
              Text("${ConstResourcesMapper.chineseNumberMapper[item]!}局"),
          listItemBuilder: (_, item, isSelected, onTap) => ListTile(
            title: Text("${ConstResourcesMapper.chineseNumberMapper[item]!}局"),
            onTap: onTap,
            selected: isSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, MyHomePageViewModel viewModel) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await showBoardDateTimePicker(
              context: context,
              pickerType: DateTimePickerType.datetime,
              initialDate: _selectedDateTimeForPan ?? DateTime.now(),
            );
            if (result != null) {
              setState(() {
                _selectedDateTimeForPan = result;
              });
              // Option 1: Pan immediately after selection
              // viewModel.getPanByTime(result);
            }
          },
          child: const Text('选择时间'),
        ),
        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();
            setState(() {
              _selectedDateTimeForPan = now;
            });
            // Option 1: Pan immediately
            // viewModel.getPanByTime(now);
          },
          child: const Text('现在时间'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white),
          onPressed: () {
            // Option 2: "排盘" button uses the _selectedDateTimeForPan
            if (_selectedDateTimeForPan != null) {
              viewModel.calculateByDivinationInfo(_selectedDateTimeForPan!);
            } else {
              InteractiveToast.slide(context,
                  title: const Text("请先选择时间或使用现在时间"));
            }
          },
          child: const Text('依时间排盘'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white),
          onPressed: () {
            bool isValid = true;
            if (_manualDayJiaZi == null) {
              (renDayGanZhiShakeKey.currentState as ShakeWidgetState?)?.shake();
              isValid = false;
            }
            // Time OR JuNumber+YinYangDun must be present
            if (_manualTimeJiaZi == null &&
                (_manualJuNumber == null || _manualYinYangDun == null)) {
              (renTimeGanZhiShakeKey.currentState as ShakeWidgetState?)
                  ?.shake();
              (renJuNumberShakeKey.currentState as ShakeWidgetState?)?.shake();
              (renDunGanZhiShakeKey.currentState as ShakeWidgetState?)?.shake();
              isValid = false;
            }
            if (!isValid) {
              InteractiveToast.slide(context,
                  title: const Text("请完成干支、局数等必要选择"));
              return;
            }

            // viewModel.getPanByGanZhi(
            //   yearJiaZi: _manualYearJiaZi?.name,
            //   monthJiaZi: _manualMonthJiaZi?.name,
            //   dayJiaZi: _manualDayJiaZi!.name, // Already checked for null
            //   timeJiaZi: _manualTimeJiaZi?.name,
            //   yinYangDun:
            //       _manualYinYangDun?.name, // ViewModel expects String name
            //   juNumber: _manualJuNumber,
            // );
          },
          child: const Text('依干支局数排盘'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            viewModel.clearPan();
            setState(() {
              // Clear local selections too
              _selectedDateTimeForPan = DateTime.now();
              _manualYearJiaZi = null;
              _manualMonthJiaZi = null;
              _manualDayJiaZi = null;
              _manualTimeJiaZi = null;
              _manualYinYangDun = null;
              _manualJuNumber = null;
            });
          },
          child: const Text('清除盘面'),
        ),
      ],
    );
  }

  // --- Old UI rendering methods (to be deprecated/moved) ---
  // build_panel, panel_gong, build_four_ke, build_san_chuan, etc.
  // These detailed rendering methods will be moved into PanDisplayWidget and its children.
  // For now, PanDisplayWidget is a placeholder.

  // Example of how a sub-widget (like one for YuDing) might be structured:
  // (This is already created as YuDingDisplayWidget placeholder)
  /*
  Widget _buildYuDingDisplay(YuDingEntry? entry) {
    if (entry == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("原文: ${entry.原文.join(' ')}"),
            const SizedBox(height: 8),
            Text("课义: ${entry.課義}"),
            // ... display other fields ...
          ],
        ),
      ),
    );
  }
  */

  // --- Month General Hover/LongPress Logic (can be kept if desired) ---
  // This logic was for showing JieQi details related to YueJiang.
  // It would need to be adapted to get YueJiang from the LiuRenPan entity.
  void _showMonthlyGeneralJieQi({bool autoHidden = true}) {
    // ... (implementation can be adapted from original if this feature is kept)
  }
  void _hideMonthlyGeneralJieQi() {
    // ...
  }
}

// Placeholder for YuDingDisplayWidget if not created yet
// class YuDingDisplayWidget extends StatelessWidget {
//   final YuDingEntry yuDingEntry;
//   const YuDingDisplayWidget({Key? key, required this.yuDingEntry}) : super(key: key);
//   @override
//   Widget build(BuildContext context) { // ... implement actual display ...
// }
// }
