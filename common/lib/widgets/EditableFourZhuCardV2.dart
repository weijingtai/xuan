import 'package:common/enums.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../pages/editable_four_zhu_card_demo_page.dart';
import '../models/drag_payloads.dart';
import '../enums/layout_template_enums.dart';

// --- Drag-in insert support: shared types ---
enum _DragKind { column, row }

class _InsertPayload {
  final String title;
  final JiaZi? jiaZi;
  const _InsertPayload(this.title, {this.jiaZi});
}

/// Deprecated: 请使用 `EditableFourZhuCardV3`。
///
/// 该组件已被新版 V3 替换，后续所有 `TODO_CHECKLIST` 任务与验收
/// 均聚焦于 `EditableFourZhuCardV3`，本组件不再演进，仅保留以防兼容需求。
@Deprecated('Use EditableFourZhuCardV3 instead')
class EditableFourZhuCardv2 extends StatefulWidget {
  final ValueNotifier<CardMode> cardModeNotifier;
  final ValueNotifier<List<Tuple2<String, JiaZi>>> jiaZiNotifier;
  final ValueNotifier<List<String>> rowListNotifier;
  final ValueNotifier<EdgeInsets> paddingNotifier;
  final Gender gender;

  /// 构造函数（废弃）：请改用 V3 版本。
  ///
  /// Parameters:
  /// - [cardModeNotifier]: 卡片模式通知器（列模式/行模式）。
  /// - [jiaZiNotifier]: 甲子数据通知器。
  /// - [rowListNotifier]: 行标题列表通知器（V2 字符串驱动）。
  /// - [paddingNotifier]: 内边距通知器。
  /// - [gender]: 性别标识（乾造/坤造）。
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

  // 分割线参数：按“padding + thickness”动态计算尺寸（与V3保持一致）
  double _rowDividerPaddingTop = 4.0;
  double _rowDividerPaddingBottom = 4.0;
  double _rowDividerThickness = 0.8;
  double get _rowDividerHeightEffective =>
      _rowDividerPaddingTop + _rowDividerPaddingBottom + _rowDividerThickness;

  // --- Drag-in insert support ---
  int? _hoverColumnInsertIndex;
  int? _hoverRowInsertIndex;

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
    final rows = widget.rowListNotifier.value;
    // 高度：标题行 + 逐行累计（天干/地支用48，其它用32，分隔行用有效高度）
    double height = columnTitleHeight; // 首行（性别/标题）
    for (int i = 0; i < rows.length; i++) {
      if (i == 0) continue; // 跳过标题行
      height += _rowHeightByName(rows[i]);
    }
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
                child: Stack(
                  children: [
                    Row(
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
                    // 覆盖在标题区域的列插入 DragTarget（不改变布局宽度）
                    Positioned.fill(
                      child: DragTarget<Tuple2<_DragKind, _InsertPayload>>(
                        onWillAccept: (data) => data?.item1 == _DragKind.column,
                        onMove: (details) {
                          final data = details.data;
                          if (data.item1 != _DragKind.column) return;
                          final box = context.findRenderObject() as RenderBox?;
                          if (box == null) return;
                          final local = box.globalToLocal(details.offset);
                          final dx = local.dx - rowTitleWidth;
                          _hoverColumnInsertIndex =
                              _computeColumnInsertIndexFromDx(
                                  dx, zhuList.length);
                          setState(() {});
                        },
                        onLeave: (_) {
                          setState(() => _hoverColumnInsertIndex = null);
                        },
                        onAccept: (payload) {
                          final insertIndex = _hoverColumnInsertIndex ?? 0;
                          _addColumnAt(insertIndex, payload.item2);
                          setState(() => _hoverColumnInsertIndex = null);
                        },
                        builder: (context, c, r) {
                          // 透明覆盖，不改变原布局；可按需添加可视反馈
                          return Container(color: Colors.transparent);
                        },
                      ),
                    ),
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
                    } else if (title == "空亡") {
                      for (final t2 in zhuList) {
                        cellList.add(cell(Size(itemWidth, otherCellHeight),
                            getKongWangText(t2.item2.getKongWang())));
                      }
                    } else {
                      for (final t2 in zhuList) {
                        cellList.add(cell(Size(itemWidth, columnTitleHeight),
                            getColumnTitleText(t2.item1)));
                      }
                    }

                    // 在每个行项之前增加一个“缝隙式”插入接收层，避免覆盖拖拽手柄
                    const double insertGapHeight = 10;
                    final int globalIndex = index + 1; // 行视图索引从1开始（0为标题行）
                    return Column(
                      key: ValueKey(widget.rowListNotifier.value[index + 1]),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: insertGapHeight,
                          child: DragTarget<Object>(
                            onWillAccept: (data) {
                              // 仅接受外部行插入或内部行插入负载，忽略重排拖拽
                              return (data is Tuple2<_DragKind,
                                          _InsertPayload> &&
                                      data.item1 == _DragKind.row) ||
                                  (data is RowInfoPayload);
                            },
                            onAccept: (payload) {
                              final insertIndex = globalIndex; // 在该行之前插入
                              if (payload
                                  is Tuple2<_DragKind, _InsertPayload>) {
                                _addRowAt(insertIndex, payload.item2);
                              } else if (payload is RowInfoPayload) {
                                final title =
                                    payload.rowLabel ?? payload.rowType.name;
                                _addRowAt(insertIndex, _InsertPayload(title));
                              }
                            },
                            builder: (context, c, r) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        SizedBox(
                          width: pillarWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ...cellList,
                            ],
                          ),
                        ),
                        if (index == (value.length - 2))
                          // 末尾再增加一个插入接收层，允许插入到最后
                          SizedBox(
                            height: insertGapHeight,
                            child: DragTarget<Object>(
                              onWillAccept: (data) {
                                return (data is Tuple2<_DragKind,
                                            _InsertPayload> &&
                                        data.item1 == _DragKind.row) ||
                                    (data is RowInfoPayload);
                              },
                              onAccept: (payload) {
                                final insertIndex =
                                    widget.rowListNotifier.value.length; // 末尾
                                if (payload
                                    is Tuple2<_DragKind, _InsertPayload>) {
                                  _addRowAt(insertIndex, payload.item2);
                                } else if (payload is RowInfoPayload) {
                                  final title =
                                      payload.rowLabel ?? payload.rowType.name;
                                  _addRowAt(insertIndex, _InsertPayload(title));
                                }
                              },
                              builder: (context, c, r) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                      ],
                    );
                  });

              return Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerRow,
                      Expanded(child: reorderable),
                    ],
                  ),
                  // 暂时移除行视图数据区域的插入接收层，避免影响行重排交互
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
              // 在每个列项之前增加一个“缝隙式”插入接收层，避免覆盖拖拽手柄
              const double insertGapWidth = 12;
              return Row(
                key: ObjectKey(tuple),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: insertGapWidth,
                    child: DragTarget<Object>(
                      onWillAccept: (data) {
                        return (data is Tuple2<_DragKind, _InsertPayload> &&
                                data.item1 == _DragKind.column) ||
                            (data is PillarPayload);
                      },
                      onAccept: (payload) {
                        final insertIndex = index; // 在该列之前插入
                        if (payload is Tuple2<_DragKind, _InsertPayload>) {
                          _addColumnAt(insertIndex, payload.item2);
                        } else if (payload is PillarPayload) {
                          final label =
                              payload.pillarLabel ?? payload.pillarType.name;
                          JiaZi? jz;
                          final gan =
                              payload.perRowValues[RowType.heavenlyStem];
                          final zhi =
                              payload.perRowValues[RowType.earthlyBranch];
                          if (gan != null && zhi != null) {
                            jz = JiaZi.getFromGanZhiValue('$gan$zhi');
                          }
                          _addColumnAt(
                              insertIndex, _InsertPayload(label, jiaZi: jz));
                        }
                      },
                      builder: (context, c, r) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  SizedBox(
                    width: pillarWidth,
                    child: _pillarItemForColumn(
                        tuple, size.height, pillarWidth, index),
                  ),
                  if (index == value.length - 1)
                    SizedBox(
                      width: insertGapWidth,
                      child: DragTarget<Object>(
                        onWillAccept: (data) {
                          return (data is Tuple2<_DragKind, _InsertPayload> &&
                                  data.item1 == _DragKind.column) ||
                              (data is PillarPayload);
                        },
                        onAccept: (payload) {
                          final insertIndex = value.length; // 末尾
                          if (payload is Tuple2<_DragKind, _InsertPayload>) {
                            _addColumnAt(insertIndex, payload.item2);
                          } else if (payload is PillarPayload) {
                            final label =
                                payload.pillarLabel ?? payload.pillarType.name;
                            JiaZi? jz;
                            final gan =
                                payload.perRowValues[RowType.heavenlyStem];
                            final zhi =
                                payload.perRowValues[RowType.earthlyBranch];
                            if (gan != null && zhi != null) {
                              jz = JiaZi.getFromGanZhiValue('$gan$zhi');
                            }
                            _addColumnAt(
                                insertIndex, _InsertPayload(label, jiaZi: jz));
                          }
                        },
                        builder: (context, c, r) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                ],
              );
            },
          );

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerColumn,
                  Expanded(child: reorderable),
                ],
              ),
              // 左侧标题列上的行插入 DragTarget（不改变布局宽度）
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: rowTitleWidth,
                child: DragTarget<Object>(
                  onWillAccept: (data) {
                    debugPrint('Row DragTarget(title col) onWillAccept: $data');
                    // 接受内部行插入 Tuple2<_DragKind,row> 或外部 RowInfoPayload
                    final ok = (data is Tuple2<_DragKind, _InsertPayload> &&
                            data.item1 == _DragKind.row) ||
                        (data is RowInfoPayload);
                    return ok;
                  },
                  onMove: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.offset);
                    final dy = local.dy;
                    _hoverRowInsertIndex = _computeRowInsertIndexFromDy(
                        dy, widget.rowListNotifier.value);
                    debugPrint(
                        'Row DragTarget(title col) hover index: $_hoverRowInsertIndex, dy: $dy');
                    setState(() {});
                  },
                  onLeave: (_) {
                    debugPrint('Row DragTarget(title col) onLeave');
                    setState(() => _hoverRowInsertIndex = null);
                  },
                  onAccept: (payload) {
                    final insertIndex = _hoverRowInsertIndex ?? 1;
                    debugPrint(
                        'Row DragTarget(title col) onAccept: insertIndex=$insertIndex, payload=$payload');
                    if (payload is Tuple2<_DragKind, _InsertPayload>) {
                      _addRowAt(insertIndex, payload.item2);
                    } else if (payload is RowInfoPayload) {
                      final title = payload.rowLabel ?? payload.rowType.name;
                      _addRowAt(insertIndex, _InsertPayload(title));
                    }
                    setState(() => _hoverRowInsertIndex = null);
                  },
                  builder: (context, c, r) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),
              // 暂时移除列视图中的行数据区域插入接收层，避免影响重排
              // 暂时移除列视图数据区域的列插入接收层，避免影响列重排
              /*Positioned(
                left: rowTitleWidth,
                top: columnTitleHeight,
                right: 0,
                bottom: 0,
                child: DragTarget<Object>(
                  onWillAccept: (data) {
                    debugPrint('Column DragTarget onWillAccept: $data');
                    final ok = (data is Tuple2<_DragKind, _InsertPayload> &&
                            data.item1 == _DragKind.column) ||
                        (data is PillarPayload);
                    return ok;
                  },
                  onMove: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.offset);
                    // 覆盖层已从 rowTitleWidth 开始，坐标系本身不含标题列宽度
                    final dx = local.dx;
                    _hoverColumnInsertIndex =
                        _computeColumnInsertIndexFromDx(dx, value.length);
                    debugPrint(
                        'Column insert index: $_hoverColumnInsertIndex, dx: $dx');
                    setState(() {});
                  },
                  onLeave: (_) {
                    debugPrint('Column DragTarget onLeave');
                    setState(() => _hoverColumnInsertIndex = null);
                  },
                  onAccept: (payload) {
                    final insertIndex = _hoverColumnInsertIndex ?? 0;
                    debugPrint(
                        'Column DragTarget onAccept: insertIndex=$insertIndex, payload=$payload');
                    if (payload is Tuple2<_DragKind, _InsertPayload>) {
                      _addColumnAt(insertIndex, payload.item2);
                    } else if (payload is PillarPayload) {
                      // Map external payload to internal insert payload
                      final label =
                          payload.pillarLabel ?? payload.pillarType.name;
                      JiaZi? jz;
                      final gan = payload.perRowValues[RowType.heavenlyStem];
                      final zhi = payload.perRowValues[RowType.earthlyBranch];
                      if (gan != null && zhi != null) {
                        jz = JiaZi.getFromGanZhiValue('$gan$zhi');
                      }
                      _addColumnAt(
                          insertIndex, _InsertPayload(label, jiaZi: jz));
                    }
                    setState(() => _hoverColumnInsertIndex = null);
                  },
                  builder: (context, c, r) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),*/
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
                    getColumnTitleText(tuple.item1),
                    active: active,
                  );
                },
              ),
            ),
          ),
        );
        continue;
      }

      final RowType? rtype = _rowTypeOf(rowName);
      switch (rtype) {
        case RowType.heavenlyStem:
          children.add(
              cell(ganZhiCellSize, getTianGanText(jiaZi.tianGan)));
          break;
        case RowType.earthlyBranch:
          children.add(
              cell(ganZhiCellSize, getDiZhiText(jiaZi.diZhi)));
          break;
        case RowType.separator:
          children.add(
            SizedBox(
              width: ganZhiCellSize.width,
              height: _rowDividerHeightEffective,
              child: Center(
                child: Divider(
                  height: _rowDividerHeightEffective,
                  thickness: _rowDividerThickness,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          );
          break;
        case RowType.naYin:
          children.add(
            cell(
              Size(ganZhiCellSize.width, otherCellHeight),
              getNaYinText(jiaZi.naYinStr),
            ),
          );
          break;
        case RowType.kongWang:
          children.add(
            cell(
              Size(ganZhiCellSize.width, otherCellHeight),
              getKongWangText(jiaZi.getKongWang()),
            ),
          );
          break;
        default:
          // Fallback: show column title text for unknown row types
          children.add(
            cell(
              Size(ganZhiCellSize.width, otherCellHeight),
              getColumnTitleText(tuple.item1),
            ),
          );
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

  /// 行高解析：按名称映射至 `RowType` 决定高度（含分隔行别名）。
  ///
  /// Parameters:
  /// - [name]: Row title text, possibly localized aliases.
  ///
  /// Returns: Effective row height derived from `RowType` mapping.
  double _rowHeightByName(String name) {
    final RowType? rtype = _rowTypeOf(name);
    if (rtype == RowType.heavenlyStem || rtype == RowType.earthlyBranch) {
      return ganZhiCellSize.height;
    }
    if (rtype == RowType.separator) {
      return _rowDividerHeightEffective;
    }
    return otherCellHeight;
  }

  /// 名称到 `RowType` 的兼容映射，统一行逻辑并移除字符串比较。
  ///
  /// Parameters:
  /// - [name]: Row title text used historically (e.g., '天干').
  ///
  /// Returns: The mapped `RowType` or `null` if unknown.
  RowType? _rowTypeOf(String name) {
    switch (name) {
      case '天干':
        return RowType.heavenlyStem;
      case '地支':
        return RowType.earthlyBranch;
      case '纳音':
        return RowType.naYin;
      case '空亡':
        return RowType.kongWang;
      case '分割线':
      case '行分割线':
      case '行分割符':
      case '行分隔符':
        return RowType.separator;
      default:
        return null;
    }
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

  Text getKongWangText(Tuple2<DiZhi, DiZhi> kongWang) {
    return Text('${kongWang.item1.name}/${kongWang.item2.name}',
        style: const TextStyle(fontSize: 14, color: Colors.black87));
  }

  Text getRowTitleText(String rowTitle) {
    return Text(rowTitle,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  Text getColumnTitleText(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
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

  // --- Helpers: compute insert index & apply insert ---
  int _computeColumnInsertIndexFromDx(double dx, int n) {
    if (dx <= 0) return 0;
    final double w = pillarWidth;
    // midpoint-based index: gaps from 0..n
    final int cell = (dx / w).floor();
    final double within = dx - cell * w;
    final int insert = within < w / 2 ? cell : (cell + 1);
    return insert.clamp(0, n);
  }

  int _computeRowInsertIndexFromDy(double dy, List<String> rows) {
    // rows[0] is gender header (fixed), insert index starts from 1
    double cy = 0;
    // gap before first data row is index 1
    if (dy <= columnTitleHeight) return 1;
    cy += columnTitleHeight;
    // 天干
    if (dy <= cy + ganZhiCellSize.height) return 2;
    cy += ganZhiCellSize.height;
    // 地支
    if (dy <= cy + ganZhiCellSize.height) return 3;
    cy += ganZhiCellSize.height;
    // remaining rows (each otherCellHeight)
    final int restCount = rows.length - 3;
    final double restDy = dy - cy;
    final int cell = (restDy / otherCellHeight).floor();
    final double within = restDy - cell * otherCellHeight;
    final int insert = (within < otherCellHeight / 2 ? cell : (cell + 1)) + 4;
    return insert.clamp(1, rows.length);
  }

  void _addColumnAt(int insertIndex, _InsertPayload payload) {
    final list = List<Tuple2<String, JiaZi>>.of(widget.jiaZiNotifier.value);
    final title = payload.title.isNotEmpty ? payload.title : '新柱';
    final jz = payload.jiaZi ?? JiaZi.JIA_ZI;
    insertIndex = insertIndex.clamp(0, list.length);
    list.insert(insertIndex, Tuple2(title, jz));
    widget.jiaZiNotifier.value = list;
  }

  void _addRowAt(int insertIndex, _InsertPayload payload) {
    final list = List<String>.of(widget.rowListNotifier.value);
    // 保持首行不变：插入索引最小为1
    insertIndex = insertIndex.clamp(1, list.length);
    final title = payload.title.isNotEmpty ? payload.title : '自定义';
    list.insert(insertIndex, title);
    widget.rowListNotifier.value = list;
  }
}
