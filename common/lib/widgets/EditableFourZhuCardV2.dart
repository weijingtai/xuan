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
  double pillarWidth = 64;
  double rowTitleWidth = 52;
  double columnTitleHeight = 24;

  double cellWidth = 48;

  Size get ganZhiCellSize => Size(pillarWidth, 48);
  double otherCellHeight = 32;

  @override
  void initState() {
    super.initState();
    totalSizeNotifier = ValueNotifier<Size>(Size(
        pillarWidth * widget.jiaZiNotifier.value.length + rowTitleWidth,
        ganZhiCellSize.height * 2 +
            (widget.rowListNotifier.value.length - 3) * otherCellHeight +
            columnTitleHeight));
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
              return ReorderableListView.builder(
                  scrollDirection: Axis.vertical,
                  buildDefaultDragHandles: false,
                  itemCount: value.length,
                  onReorder: onRowReorder,
                  itemBuilder: (context, index) {
                    double itemWidth = pillarWidth;
                    double height = otherCellHeight;
                    final title = value[index];
                    List<Widget> cellList = [];
                    // double itemWidth = pillarWidth;
                    if (index == 0) {
                      cellList.add(cell(Size(rowTitleWidth, columnTitleHeight),
                          getGenderText(widget.gender)));
                    } else {
                      cellList.add(cell(Size(rowTitleWidth, height),
                          getColumnTitleText(title.toString())));
                    }
                    if (title == "天干" || title == "地支") {
                      // itemWidth = ganZhiCellSize.width;
                      height = otherCellHeight * 2;
                      for (int i = 0; i < zhuList.length; i++) {
                        cellList.add(cell(
                            ganZhiCellSize,
                            title == "天干"
                                ? getTianGanText(zhuList[i].item2.tianGan)
                                : getDiZhiText(zhuList[i].item2.diZhi)));
                      }
                    } else if (title == "纳音") {
                      zhuList.forEach((t2) {
                        cellList.add(cell(Size(itemWidth, otherCellHeight),
                            getNaYinText(t2.item2.naYinStr)));
                      });
                    } else {
                      zhuList.forEach((t2) {
                        cellList.add(cell(Size(itemWidth, columnTitleHeight),
                            getColumnTitleText(t2.item1)));
                      });
                    }

                    return SizedBox(
                      key: ValueKey(widget.rowListNotifier.value[index]),
                      width: pillarWidth,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...cellList,
                          ],
                        ),
                      ),
                    );
                  });
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
          return ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            itemCount: value.length + 1,
            onReorder: onColumnReorder,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  key: ValueKey("rowTitle"),
                  width: rowTitleWidth,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: _rowTitleColumnItem(widget.rowListNotifier.value,
                        size.height, rowTitleWidth),
                  ),
                );
              }
              final tuple = value[index - 1];
              return SizedBox(
                key: ValueKey(tuple.item1),
                width: pillarWidth,
                child: ReorderableDragStartListener(
                  index: index,
                  child: _pillarItemForColumn(tuple, size.height, pillarWidth),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void onRowReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = widget.rowListNotifier.value.removeAt(oldIndex);
      widget.rowListNotifier.value.insert(newIndex, item);
    });
  }

  void onColumnReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Tuple2<String, JiaZi> item =
          widget.jiaZiNotifier.value.removeAt(oldIndex);
      widget.jiaZiNotifier.value.insert(newIndex, item);
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
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cell(Size(pillarWidth, columnTitleHeight),
                getColumnTitleText(titleList[0])),

            cell(Size(pillarWidth, columnTitleHeight),
                getColumnTitleText(titleList[1])),
            cell(Size(pillarWidth, ganZhiCellSize.height),
                getColumnTitleText(titleList[1])),

            // 地支
            cell(Size(pillarWidth, ganZhiCellSize.height),
                getColumnTitleText(titleList[1])),
            cell(Size(pillarWidth, otherCellHeight),
                getColumnTitleText(titleList[1])),
          ],
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
          cell(Size(width, columnTitleHeight), getGenderText(widget.gender)),

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

  Widget _pillarItemForColumn(
      Tuple2<String, JiaZi> tuple, double height, double width) {
    final jiaZi = tuple.item2;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.teal.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // title
          cell(Size(ganZhiCellSize.width, columnTitleHeight),
              getColumnTitleText(tuple.item1)),

          // 天干
          cell(ganZhiCellSize, getTianGanText(jiaZi.tianGan)),

          // 地支
          cell(ganZhiCellSize, getDiZhiText(jiaZi.diZhi)),
          // 纳音
          cell(Size(ganZhiCellSize.width, otherCellHeight),
              getNaYinText(jiaZi.naYinStr)),
        ],
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

  Widget cell(Size cellSize, Text text) {
    return Container(
      width: cellSize.width,
      height: cellSize.height,
      decoration: BoxDecoration(
        color: Colors.pink.withAlpha(10),
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: text,
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

  Text getRowTitleText(String rowTitle) {
    return Text(rowTitle,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  Text getColumnTitleText(String title) {
    return Text(title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
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
