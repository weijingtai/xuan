import 'package:common/enums.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../pages/editable_four_zhu_card_demo_page.dart';

class EditableFourZhuCardv2 extends StatefulWidget {
  final ValueNotifier<CardMode> cardModeNotifier;
  final ValueNotifier<List<Tuple2<String, JiaZi>>> jiaZiNotifier;
  final ValueNotifier<List<String>> rowListNotifier;
  final ValueNotifier<EdgeInsets> paddingNotifier;
  final Gender gender;

  const EditableFourZhuCardv2(
      {super.key,
      required this.cardModeNotifier,
      required this.jiaZiNotifier,
      required this.rowListNotifier,
      required this.paddingNotifier,
      required this.gender});

  @override
  State<EditableFourZhuCardv2> createState() => _EditableFourZhuCardv2State();
}

class _EditableFourZhuCardv2State extends State<EditableFourZhuCardv2> {
  late final ValueNotifier<Size> totalSizeNotifier;
  late final VoidCallback _jiaZiListener;
  late final VoidCallback _rowListListener;
  late final ValueNotifier<CardMode?> _lockedModeNotifier; // 标题点击锁定的模式
  double pillarWidth = 64;
  double rowTitleWidth = 52;
  double columnTitleHeight = 24;

  double cellWidth = 48;

  Size get ganZhiCellSize => Size(pillarWidth, 48);
  double otherCellHeight = 32;

  @override
  void initState() {
    super.initState();
    totalSizeNotifier = ValueNotifier<Size>(_computeTotalSize());
    _lockedModeNotifier = ValueNotifier<CardMode?>(null);

    // Listen to data changes to keep size in sync
    _jiaZiListener = () {
      totalSizeNotifier.value = _computeTotalSize();
    };
    _rowListListener = () {
      totalSizeNotifier.value = _computeTotalSize();
    };
    widget.jiaZiNotifier.addListener(_jiaZiListener);
    widget.rowListNotifier.addListener(_rowListListener);
  }

  @override
  void dispose() {
    widget.jiaZiNotifier.removeListener(_jiaZiListener);
    widget.rowListNotifier.removeListener(_rowListListener);
    totalSizeNotifier.dispose();
    _lockedModeNotifier.dispose();
    super.dispose();
  }

  Size _computeTotalSize() {
    final pillars = widget.jiaZiNotifier.value.length;
    final rows = widget.rowListNotifier.value.length;
    // Height: title row + two gan/zhi rows + remaining rows treated as otherCellHeight
    final double height = columnTitleHeight +
        ganZhiCellSize.height * 2 +
        (rows - 3) * otherCellHeight;
    final double width = rowTitleWidth + pillarWidth * pillars;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: totalSizeNotifier,
        builder: (context, Size size, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ValueListenableBuilder<CardMode>(
                  valueListenable: widget.cardModeNotifier,
                  builder: (context, value, child) {
                    switch (value) {
                      case CardMode.normal:
                        return normal(size);
                      case CardMode.column:
                        return column(size);
                      case CardMode.row:
                        return ValueListenableBuilder(
                            valueListenable: widget.jiaZiNotifier,
                            builder: (context, value, child) {
                              return row(size, value);
                            });
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget normal(Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget row(Size size, List<Tuple2<String, JiaZi>> zhuList) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ValueListenableBuilder<List<String>>(
            valueListenable: widget.rowListNotifier,
            builder: (context, value, child) {
              // 先渲染首行（“乾造/坤造”），从可重排列表中剥离，保证绝对固定
              // 计算首行总宽度：标题列宽 + 四柱列宽总和
              final double _headerTotalWidth =
                  rowTitleWidth + pillarWidth * zhuList.length;
              final headerRow = SizedBox(
                key: const ValueKey('row-header-gender'),
                width: _headerTotalWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 性别标题单元格（固定，不可拖拽）
                    cell(Size(rowTitleWidth, columnTitleHeight),
                        getGenderText(widget.gender)),
                    // 四柱列标题（年/月/日/时），与原实现保持一致
                    for (final t2 in zhuList)
                      cell(
                          Size(pillarWidth, columnTitleHeight),
                          _dragColumnTitleSwitcher(
                              getColumnTitleText(t2.item1))),
                  ],
                ),
              );

              // 构建其余可重排行（不包含首行）
              final reorderable = ReorderableListView.builder(
                  scrollDirection: Axis.vertical,
                  buildDefaultDragHandles: false,
                  itemCount: (value.length - 1).clamp(0, value.length),
                  onReorder: (oldIndex, newIndex) {
                    // 将局部索引映射到全局索引（+1），首行固定不参与
                    int oi = oldIndex + 1;
                    int ni = newIndex + 1;
                    onRowReorder(oi, ni);
                  },
                  itemBuilder: (context, index) {
                    // 注意：此处 index 为局部索引，真实标题取 value[index+1]
                    double itemWidth = pillarWidth;
                    double height = otherCellHeight;
                    final title = value[index + 1];
                    List<Widget> cellList = [];

                    // 标题可拖拽
                    final titleCell = cell(
                      Size(
                          rowTitleWidth,
                          (title == "天干" || title == "地支")
                              ? ganZhiCellSize.height
                              : otherCellHeight),
                      ValueListenableBuilder<CardMode?>(
                        valueListenable: _lockedModeNotifier,
                        builder: (context, locked, _) {
                          final bool? active =
                              locked == null ? null : (locked == CardMode.row);
                          return _dragRowHandle(
                            getColumnTitleText(title.toString()),
                            active: active,
                          );
                        },
                      ),
                    );
                    cellList.add(
                      ReorderableDragStartListener(
                          index: index, child: titleCell),
                    );

                    if (title == "天干" || title == "地支") {
                      height = otherCellHeight * 2;
                      for (int i = 0; i < zhuList.length; i++) {
                        cellList.add(cell(
                            ganZhiCellSize,
                            title == "天干"
                                ? getTianGanText(zhuList[i].item2.tianGan)
                                : getDiZhiText(zhuList[i].item2.diZhi)));
                      }
                    } else if (title == "纳音") {
                      for (final t2 in zhuList) {
                        cellList.add(cell(Size(itemWidth, otherCellHeight),
                            getNaYinText(t2.item2.naYinStr)));
                      }
                    } else {
                      for (final t2 in zhuList) {
                        cellList.add(cell(Size(itemWidth, columnTitleHeight),
                            getColumnTitleText(t2.item1)));
                      }
                    }

                    return SizedBox(
                      key: ValueKey(widget.rowListNotifier.value[index + 1]),
                      width: pillarWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...cellList,
                        ],
                      ),
                    );
                  });

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerRow,
                  Expanded(child: reorderable),
                ],
              );
            }));
  }

  Widget column(Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ValueListenableBuilder<List<Tuple2<String, JiaZi>>>(
        valueListenable: widget.jiaZiNotifier,
        builder: (context, value, child) {
          // 固定首列（标题列）剥离，不参与可重排，始终位于最左侧
          final headerColumn = SizedBox(
            key: const ValueKey("rowTitle"),
            width: rowTitleWidth,
            child: _rowTitleColumnItem(
                widget.rowListNotifier.value, size.height, rowTitleWidth),
          );

          // 其余列可重排，仅包含柱数据
          final reorderable = ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            itemCount: value.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = widget.jiaZiNotifier.value.removeAt(oldIndex);
                widget.jiaZiNotifier.value.insert(newIndex, item);
                // 触发监听者更新，避免列表原地变更未通知到外部
                widget.jiaZiNotifier.value =
                    List.of(widget.jiaZiNotifier.value);
              });
            },
            itemBuilder: (context, index) {
              final tuple = value[index];
              return SizedBox(
                key: ValueKey(tuple.item1),
                width: pillarWidth,
                child: _pillarItemForColumn(
                    tuple, size.height, pillarWidth, index),
              );
            },
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerColumn,
              Expanded(child: reorderable),
            ],
          );
        },
      ),
    );
  }

  void onRowReorder(int oldIndex, int newIndex) {
    // 固定首行：不允许移动索引0的项目，也不允许将其他项目放到索引0
    debugPrint('onRowReorder: oldIndex=$oldIndex, newIndex=$newIndex');
    if (oldIndex == 0 || newIndex == 0) {
      debugPrint('onRowReorder: skip, header row fixed at index 0');
      return; // 直接跳过，保证首行不变
    }
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = widget.rowListNotifier.value.removeAt(oldIndex);
      widget.rowListNotifier.value.insert(newIndex, item);
      debugPrint('onRowReorder: applied, insert at index=$newIndex');
      // 触发监听者更新，避免列表原地变更未通知到外部
      widget.rowListNotifier.value = List.of(widget.rowListNotifier.value);
    });
  }

  void onColumnReorder(int oldIndex, int newIndex) {
    // 首项为行标题列（索引0），实际柱数据从索引1开始
    if (oldIndex == 0 || newIndex == 0) return;
    setState(() {
      int o = oldIndex - 1;
      int n = newIndex - 1;
      if (o < n) {
        n -= 1;
      }
      final item = widget.jiaZiNotifier.value.removeAt(o);
      widget.jiaZiNotifier.value.insert(n, item);
      // 触发监听者更新，避免列表原地变更未通知到外部
      widget.jiaZiNotifier.value = List.of(widget.jiaZiNotifier.value);
    });
  }

  Widget _columnTitlePillarItem(
      List<String> titleList, double height, double width, double pillarWidth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(10),
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: _lockedModeNotifier,
          builder: (context, locked, child) {
            final bool? active =
                locked == null ? null : (locked == CardMode.column);
            return Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cell(Size(pillarWidth, columnTitleHeight),
                    getColumnTitleText(titleList[0], active: active)),

                cell(Size(pillarWidth, columnTitleHeight),
                    getColumnTitleText(titleList[1], active: active)),
                cell(Size(pillarWidth, ganZhiCellSize.height),
                    getColumnTitleText(titleList[1], active: active)),

                // 地支
                cell(Size(pillarWidth, ganZhiCellSize.height),
                    getColumnTitleText(titleList[1], active: active)),
                cell(Size(pillarWidth, otherCellHeight),
                    getColumnTitleText(titleList[1], active: active)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _rowTitlePillarItem(
      List<String> titleList, double height, double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // title
          cell(Size(width, columnTitleHeight), getRowTitleText(titleList[0])),

          // 天干
          cell(Size(width, ganZhiCellSize.height),
              getRowTitleText(titleList[1])),

          // 地支
          cell(Size(width, ganZhiCellSize.height),
              getRowTitleText(titleList[2])),
          // 纳音
          cell(Size(width, otherCellHeight), getRowTitleText(titleList[3])),
        ],
      ),
    );
  }

  Widget _rowTitleColumnItem(
      List<String> titleList, double height, double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // title
          // 首项为“乾造/坤造”等性别标题，不加入拖拽指示图标，仅显示文本
          cell(Size(width, columnTitleHeight), getGenderText(widget.gender)),

          // 天干
          cell(Size(width, ganZhiCellSize.height),
              _dragTitleSwitcher(getRowTitleText(titleList[1]))),

          // 地支
          cell(Size(width, ganZhiCellSize.height),
              _dragTitleSwitcher(getRowTitleText(titleList[2]))),
          // 纳音
          cell(Size(width, otherCellHeight),
              _dragTitleSwitcher(getRowTitleText(titleList[3]))),
        ],
      ),
    );
  }

  Widget _pillarItemForColumn(
      Tuple2<String, JiaZi> tuple, double height, double width, int index) {
    final jiaZi = tuple.item2;
    // Build vertical content based on current row order to keep row/column synchronized
    final List<String> rowOrder = widget.rowListNotifier.value;
    final List<Widget> children = [];

    for (int i = 0; i < rowOrder.length; i++) {
      final String rowName = rowOrder[i];
      if (i == 0) {
        // First row represents column title; keep drag handle here
        children.add(
          ReorderableDragStartListener(
            index: index,
            child: cell(
              Size(ganZhiCellSize.width, columnTitleHeight),
              ValueListenableBuilder<CardMode?>(
                valueListenable: _lockedModeNotifier,
                builder: (context, locked, _) {
                  final bool? active =
                      locked == null ? null : (locked == CardMode.column);
                  return _dragColumnHandle(
                    getColumnTitleText(tuple.item1, active: active),
                    active: active,
                  );
                },
              ),
            ),
          ),
        );
        continue;
      }

      if (rowName == "天干") {
        children.add(cell(ganZhiCellSize, getTianGanText(jiaZi.tianGan)));
      } else if (rowName == "地支") {
        children.add(cell(ganZhiCellSize, getDiZhiText(jiaZi.diZhi)));
      } else if (rowName == "纳音") {
        children.add(cell(Size(ganZhiCellSize.width, otherCellHeight),
            getNaYinText(jiaZi.naYinStr)));
      } else {
        // Fallback: show column title text for unknown row types
        children.add(cell(Size(ganZhiCellSize.width, otherCellHeight),
            getColumnTitleText(tuple.item1)));
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.teal.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _pillarItemForRow(
      Text rowTitle, List<Text> rowContent, double height, double width) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cell(Size(width, columnTitleHeight), rowTitle),
            ...rowContent
                .map((e) => cell(Size(width, otherCellHeight), e))
                .toList(),
          ],
        ));
  }

  Widget cell(Size cellSize, Widget child) {
    return Container(
      width: cellSize.width,
      height: cellSize.height,
      decoration: BoxDecoration(
        color: Colors.pink.withAlpha(10),
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: child,
      ),
    );
  }

  // 统一封装：根据锁定状态显示不同颜色的拖拽图标；文本颜色由外部 AnimatedDefaultTextStyle 控制
  // active == true => 黑色；active == false => 灰色；active == null => 中性
  Widget _dragRowHandle(Widget title, {bool? active}) {
    final Color targetIconColor =
        active == null ? Colors.black45 : (active ? Colors.black : Colors.grey);
    final Color targetTextColor =
        active == null ? Colors.black87 : (active ? Colors.black : Colors.grey);
    Widget _animatedTitle(Widget t, Color target) {
      if (t is Text) {
        final String data = t.data ?? '';
        final TextStyle base = t.style ?? const TextStyle();
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: target),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, color, _) => Text(
            data,
            style: base.copyWith(color: color),
            textAlign: t.textAlign,
            maxLines: t.maxLines,
            overflow: t.overflow,
            softWrap: t.softWrap,
          ),
        );
      }
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        style: TextStyle(color: target),
        child: t,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: targetIconColor),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, color, _) =>
              Icon(Icons.drag_indicator, size: 16, color: color),
        ),
        const SizedBox(width: 4),
        Flexible(child: _animatedTitle(title, targetTextColor)),
      ],
    );
  }

  Widget _dragColumnHandle(Widget title, {bool? active}) {
    final Color targetIconColor =
        active == null ? Colors.black87 : (active ? Colors.black : Colors.grey);
    final Color targetTextColor =
        active == null ? Colors.black87 : (active ? Colors.black : Colors.grey);
    Widget _animatedTitle(Widget t, Color target) {
      if (t is Text) {
        final String data = t.data ?? '';
        final TextStyle base = t.style ?? const TextStyle();
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: target),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, color, _) => Text(
            data,
            style: base.copyWith(color: color),
            textAlign: t.textAlign,
            maxLines: t.maxLines,
            overflow: t.overflow,
            softWrap: t.softWrap,
          ),
        );
      }
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        style: TextStyle(color: target),
        child: t,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: targetIconColor),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, color, _) =>
              Icon(Icons.drag_indicator, size: 16, color: color),
        ),
        const SizedBox(width: 4),
        Flexible(child: _animatedTitle(title, targetTextColor)),
      ],
    );
  }

  // 桌面端：悬停“无感”切换；触屏端：点击切换
  Widget _dragTitleSwitcher(Widget title) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _lockedModeNotifier.value = CardMode.row;
        widget.cardModeNotifier.value = CardMode.row;
      },
      child: MouseRegion(
        onEnter: (_) {
          _lockedModeNotifier.value = CardMode.row;
          widget.cardModeNotifier.value = CardMode.row;
        },
        child: ValueListenableBuilder<CardMode?>(
          valueListenable: _lockedModeNotifier,
          builder: (context, locked, _) {
            final bool? active =
                locked == null ? null : (locked == CardMode.row);
            return _dragRowHandle(title, active: active);
          },
        ),
      ),
    );
  }

  // 鼠标经过列标题时切换到列模式，用于从行视图快速切回列视图
  Widget _dragColumnTitleSwitcher(Widget title) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _lockedModeNotifier.value = CardMode.column;
        widget.cardModeNotifier.value = CardMode.column;
      },
      child: MouseRegion(
        onEnter: (_) {
          _lockedModeNotifier.value = CardMode.column;
          widget.cardModeNotifier.value = CardMode.column;
        },
        child: ValueListenableBuilder<CardMode?>(
          valueListenable: _lockedModeNotifier,
          builder: (context, locked, _) {
            final bool? active =
                locked == null ? null : (locked == CardMode.column);
            return _dragColumnHandle(title, active: active);
          },
        ),
      ),
    );
  }

  Text getTianGanText(TianGan tianGan) {
    return Text(tianGan.name,
        style: TextStyle(fontSize: 24, color: Colors.black87));
  }

  Text getDiZhiText(DiZhi diZhi) {
    return Text(diZhi.name,
        style: TextStyle(fontSize: 24, color: Colors.black87));
  }

  AnimatedDefaultTextStyle getRowTitleText(String rowTitle, {bool? active}) {
    return AnimatedDefaultTextStyle(
      child: Text(rowTitle),
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: active == null
              ? Colors.black87
              : (active == true ? Colors.black : Colors.black26)),
      duration: const Duration(milliseconds: 180),
    );
  }

  AnimatedDefaultTextStyle getColumnTitleText(String title, {bool? active}) {
    return AnimatedDefaultTextStyle(
      child: Text(title),
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: active == null
              ? Colors.black87
              : (active ? Colors.black : Colors.black26)),
      duration: const Duration(milliseconds: 180),
    );
  }

  Text getNaYinText(String content) {
    return Text(content,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.amber));
  }

  Text getGenderText(Gender gender) {
    String content;
    if (gender == Gender.male) {
      content = '乾造';
    } else {
      content = '坤造';
    }
    return Text(content, style: TextStyle(fontSize: 14, color: Colors.black87));
  }
}
