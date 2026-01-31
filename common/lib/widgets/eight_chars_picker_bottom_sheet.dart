import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';
import 'package:common/module.dart';

/// 显示八字选择器底部弹窗
Future<EightChars?> showEightCharsPickerBottomSheet({
  required BuildContext context,
  required EightChars? eightChars,
}) {
  return showModalBottomSheet<EightChars>(
    context: context,
    isScrollControlled: true, // 允许弹窗占据更大空间
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7, // 初始高度为屏幕的70%
      minChildSize: 0.5, // 最小高度为屏幕的50%
      maxChildSize: 0.9, // 最大高度为屏幕的90%
      expand: false,
      builder: (context, scrollController) {
        return EightCharsPickerBottomSheet(
          eightChars: eightChars,
          scrollController: scrollController,
        );
      },
    ),
  );
}

/// 城市选择器底部弹窗
class EightCharsPickerBottomSheet extends StatefulWidget {
  /// 初始选中的地理位置编码
  // final String? initialCode;
  final EightChars? eightChars;

  /// 滚动控制器
  final ScrollController scrollController;

  const EightCharsPickerBottomSheet({
    Key? key,
    required this.eightChars,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<EightCharsPickerBottomSheet> createState() =>
      _EightCharsPickerBottomSheetSheetState();
}

class _EightCharsPickerBottomSheetSheetState
    extends State<EightCharsPickerBottomSheet> {
  final _selectedYear = ValueNotifier<JiaZi?>(null);
  final _selectedMonth = ValueNotifier<JiaZi?>(null);
  final _selectedDay = ValueNotifier<JiaZi?>(null);
  final _selectedTime = ValueNotifier<JiaZi?>(null);

  final _selectedBirthYearGan = ValueNotifier<TianGan?>(null);
  final _selectedBirthYearZhi = ValueNotifier<DiZhi?>(null);

  // 年命 天干，生年天干
  final _birthYearGanList = TianGan.listAll;
  // 生年地支，生肖
  final _birthYearZhiList = DiZhi.listAll;
  // 年
  final _yearListNotifier = ValueNotifier<List<JiaZi>>(JiaZi.listAll);

  // 月
  final _monthListNotifier = ValueNotifier<List<JiaZi>?>(null);

  // 日辰列表
  final _dayListNotifier = ValueNotifier<List<JiaZi>?>(null);
  // 时辰列表
  final _timeListNotifier = ValueNotifier<List<JiaZi>?>(null);

  // 是否正在加载数据
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);
  // bool _isLoading = true;

  // 是否发生错误
  // bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectedYear.dispose();
    _selectedMonth.dispose();
    _selectedDay.dispose();
    _selectedTime.dispose();

    _selectedBirthYearZhi.dispose();
    _selectedBirthYearGan.dispose();

    _yearListNotifier.dispose();
    _monthListNotifier.dispose();
    _dayListNotifier.dispose();
    _timeListNotifier.dispose();
    super.dispose();
  }

  /// 完成选择
  void _finishSelection() {
    final year = _selectedYear.value ?? JiaZi.JIA_ZI;
    final month = _selectedMonth.value ?? JiaZi.JIA_ZI;
    final day = _selectedDay.value ?? JiaZi.JIA_ZI;
    final time = _selectedTime.value ?? JiaZi.JIA_ZI;
    final result = EightChars(year: year, month: month, day: day, time: time);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部拖动条和标题栏
          _buildHeader(),

          // 选择信息面板
          _buildSelectionInfoPanel(),

          // 列表区域

          Expanded(
            child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (ctx, isLoading, child) {
                  if (isLoading) return child!;
                  return ValueListenableBuilder(
                    valueListenable: _hasError,
                    builder: (ctx, hasError, child2) {
                      if (hasError) return child2!;
                      return _buildListsView();
                    },
                    // child: _buildErrorView(),
                  );
                },
                child: const Center(child: CircularProgressIndicator())),
          )

          // 底部确认按钮
          // _buildBottomButton(),
        ],
      ),
    );
  }

  /// 构建顶部拖动条和标题
  Widget _buildHeader() {
    return Column(
      children: [
        // 拖动条
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择生辰八字',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.grey),
                    )),
                ValueListenableBuilder(
                    valueListenable: _selectedTime,
                    builder: (ctx, birthTimeJiaZi, _) {
                      return TextButton(
                          onPressed: birthTimeJiaZi == null
                              ? null
                              : () => _finishSelection(),
                          child: Text(
                            "完成",
                            style: TextStyle(
                                color: birthTimeJiaZi == null
                                    ? Colors.grey
                                    : Colors.blue),
                          ));
                    })
              ])
            ],
          ),
        ),
      ],
    );
  }

  /// 构建列表视图
  Widget _buildListsView() {
    return Row(
      children: [
        // 第一部分：年
        Expanded(
          child: ValueListenableBuilder<List<JiaZi>>(
            valueListenable: _yearListNotifier,
            builder: (ctx, yearList, child) {
              return _buildJiaZiList(
                yearList,
                _selectedYear,
                selectYearJiaZi,
                '年干支',
              );
            },
            child: const Center(child: Text('加载中...')),
          ),
        ),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),

        // 第二部分：城市列表
        Expanded(
          child: ValueListenableBuilder<List<JiaZi>?>(
            valueListenable: _monthListNotifier,
            builder: (ctx, jiaZiList, child) {
              if (jiaZiList == null) return child!;
              return _buildJiaZiList(
                jiaZiList,
                _selectedMonth,
                selectMonthJiaZi,
                '选择月干支',
              );
            },
            child: const Center(child: Text('请先选择年干支')),
          ),
        ),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),

        // 第三部分：日干支
        Expanded(
          child: ValueListenableBuilder<List<JiaZi>?>(
            valueListenable: _dayListNotifier,
            builder: (ctx, jiaZiList, child) {
              if (jiaZiList == null) return child!;
              return _buildJiaZiList(
                jiaZiList,
                _selectedDay,
                selectDayJiaZi,
                '选择日干支',
              );
            },
            child: const Center(child: Text('请先选择月干支')),
          ),
        ),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
          child: ValueListenableBuilder<List<JiaZi>?>(
            valueListenable: _timeListNotifier,
            builder: (ctx, jiaZiList, child) {
              if (jiaZiList == null) return child!;
              return _buildJiaZiList(
                jiaZiList,
                _selectedTime,
                selectTimeJiaZi,
                '选择时干支',
              );
            },
            child: const Center(child: Text('请先选择日干支')),
          ),
        ),
      ],
    );
  }

  void selectYearJiaZi(JiaZi jiaZi) {
    _selectedYear.value = jiaZi;
    _monthListNotifier.value = generateMonthGanzhi(jiaZi);
    logger.d("选择的年干支： ${jiaZi.name}");
  }

  void selectMonthJiaZi(JiaZi jiaZi) {
    logger.d("选择的月干支： ${jiaZi.name}");
  }

  void selectDayJiaZi(JiaZi jiaZi) {
    logger.d("选择的日干支： ${jiaZi.name}");
  }

  void selectTimeJiaZi(JiaZi jiaZi) {
    logger.d("选择的时干支： ${jiaZi.name}");
  }

  /// 构建选择信息面板
  Widget _buildSelectionInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 使用ValueListenableBuilder监听选择变化
          ValueListenableBuilder<JiaZi?>(
              valueListenable: _selectedYear,
              builder: (ctx, year, _) {
                if (year == null) return const SizedBox();
                return Text(year.name);
              }),

          ValueListenableBuilder<JiaZi?>(
              valueListenable: _selectedMonth,
              builder: (ctx, jiaZi, _) {
                if (jiaZi == null) return const SizedBox();
                return Text(" · ${jiaZi.name}");
              }),

          ValueListenableBuilder<JiaZi?>(
              valueListenable: _selectedDay,
              builder: (ctx, jiaZi, _) {
                if (jiaZi == null) return const SizedBox();
                return Text(" · ${jiaZi.name}");
              }),
          ValueListenableBuilder<JiaZi?>(
              valueListenable: _selectedTime,
              builder: (ctx, jiaZi, _) {
                if (jiaZi == null) return const SizedBox();
                return Text(" · ${jiaZi.name}");
              }),
        ],
      ),
    );
  }

  // /// 构建底部确认按钮
  // Widget _buildBottomButton() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.shade300,
  //           blurRadius: 4,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: ValueListenableBuilder<GeoLocation?>(
  //       valueListenable: _selectedProvince,
  //       builder: (context, province, _) {
  //         final bool canConfirm = province != null;

  //         return ElevatedButton(
  //           onPressed: canConfirm ? _finishSelection : null,
  //           style: ElevatedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: const Text('确定选择'),
  //         );
  //       },
  //     ),
  //   );
  // }

  /// 构建位置列表
  Widget _buildJiaZiList(
    List<JiaZi> jiaZiList,
    ValueNotifier<JiaZi?> selectedJiaZiNotifier,
    Function(JiaZi) onSelect,
    String emptyText,
  ) {
    if (jiaZiList.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ValueListenableBuilder<JiaZi?>(
      valueListenable: selectedJiaZiNotifier,
      builder: (context, selectedJiaZi, _) {
        return ListView.builder(
          // controller: widget.scrollController,
          controller: ScrollController(),
          itemCount: jiaZiList.length,
          itemBuilder: (context, index) {
            final jiaZi = jiaZiList[index];
            logger.d("selected $index --- ${jiaZi.name}");
            final isSelected = selectedJiaZi == jiaZi;

            return ListTile(
              title: Text(jiaZi.name),
              selected: isSelected,
              selectedTileColor: Colors.blue.withValues(alpha: 0.1),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => onSelect(jiaZi),
            );
          },
        );
      },
    );
  }

  // 年天干对应的正月起始干支
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

  // 根据年干支生成对应的12个月干支
  List<JiaZi> generateMonthGanzhi(JiaZi yearJiaZi) {
    // 提取年天干（如"甲子"→"甲"）
    TianGan yearGan = yearJiaZi.tianGan;

    // 获取起始干支（如"甲"→"丙寅"）
    JiaZi start = yearGanToStart[yearGan]!;
    var result = JiaZi.listAll.sublist(start.index);
    if (result.length > 12) {
      result = result.sublist(0, 12);
    } else {
      result.addAll(JiaZi.listAll.sublist(0, 12).toList());
      result = result.sublist(0, 12);
    }
    logger.d(result.map((r) => r.name).toString());
    return result;
  }
}
