import 'package:flutter/material.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';

// 选择器弹窗
Future<JiaZi?> showJiaZiPicker(
    BuildContext context, JiaZi? jiazi, List<JiaZi>? initJiaZiList) {
  return showDialog<JiaZi>(
    context: context,
    builder: (context) => JiaZiPickerDialog(
      initJiaZi: jiazi,
      initJiaZiList: initJiaZiList,
    ),
  );
}

class JiaZiPickerDialog extends StatefulWidget {
  JiaZi? initJiaZi;
  List<JiaZi>? initJiaZiList;
  JiaZiPickerDialog(
      {super.key, required this.initJiaZi, required this.initJiaZiList});

  @override
  State<JiaZiPickerDialog> createState() => _JiaZiPickerDialogState();
}

class _JiaZiPickerDialogState extends State<JiaZiPickerDialog> {
  ValueNotifier<JiaZi?> _selectedJiaZiNotifier = ValueNotifier<JiaZi?>(null);
  ValueNotifier<TianGan?> _tianGanNotifier = ValueNotifier<TianGan?>(null);
  ValueNotifier<DiZhi?> _diZhiNotifier = ValueNotifier<DiZhi?>(null);
  final ValueNotifier<List<TianGan>> tianGanListNotifier =
      ValueNotifier<List<TianGan>>(TianGan.listAll);
  final ValueNotifier<List<DiZhi>> diZhiListNotifier =
      ValueNotifier<List<DiZhi>>(DiZhi.listAll);
  final ValueNotifier<List<JiaZi>> jiaZhiListNotifier =
      ValueNotifier<List<JiaZi>>(JiaZi.listAll);

  // // 获取筛选后的列表
  // List<JiaZi> get _filteredList {
  //   return _allJiaZi.where((jz) {
  //     final ganMatch = _tianGanNotifier.value == null ||
  //         jz.tianGan == _tianGanNotifier.value;
  //     final zhiMatch =
  //         _diZhiNotifier.value == null || jz.diZhi == _diZhiNotifier.value;
  //     return ganMatch && zhiMatch;
  //   }).toList();
  // }

  @override
  void initState() {
    super.initState();
    if (widget.initJiaZi != null) {
      _selectedJiaZiNotifier.value = widget.initJiaZi;
      _tianGanNotifier.value = widget.initJiaZi!.tianGan;
      _diZhiNotifier.value = widget.initJiaZi!.diZhi;
    }
    if (widget.initJiaZiList != null) {
      jiaZhiListNotifier.value = widget.initJiaZiList!;
    }
  }

  @override
  void dispose() {
    _tianGanNotifier.dispose();
    _diZhiNotifier.dispose();
    _selectedJiaZiNotifier.dispose();
    tianGanListNotifier.dispose();
    diZhiListNotifier.dispose();
    jiaZhiListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth > 1200
        ? 800
        : screenWidth > 800
            ? 800
            : screenWidth * 0.9; // 手机端最大宽度占比90%

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: screenWidth > 600 ? 400 : screenWidth * 0.8,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('选择干支'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => finishedPop(widget.initJiaZi),
                          child: const Text('取消'),
                        ),
                        ValueListenableBuilder<JiaZi?>(
                            valueListenable: _selectedJiaZiNotifier,
                            builder: (ctx, selectedJiaZi, child) {
                              return TextButton(
                                onPressed: selectedJiaZi == null
                                    ? null
                                    : () => finishedPop(selectedJiaZi),
                                child: const Text('确认'),
                              );
                            })
                      ],
                    )
                  ],
                ),
                // 天干筛选器
                _buildGanFilter(),
                const SizedBox(height: 12),
                // 地支筛选器
                _buildZhiFilter(),
                const SizedBox(height: 20),
                // 六十甲子列表
                _buildJiaZiList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void finishedPop(JiaZi? jz) {
    if (jz != null) {
      Navigator.pop(context, jz);
    } else {
      Navigator.pop(context, null);
    }
  }

  // 天干筛选组件
  Widget _buildGanFilter() {
    return ValueListenableBuilder<List<TianGan>>(
      valueListenable: tianGanListNotifier,
      builder: (ctx, tianGanList, _) {
        return ValueListenableBuilder<TianGan?>(
          valueListenable: _tianGanNotifier,
          builder: (ctx, tianGan, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tianGanList.map((gan) {
                return ChoiceChip(
                    label: Text(gan.name),
                    selected: tianGan == gan,
                    onSelected: (selected) {
                      // _tianGanNotifier.value = selected ? gan : null;
                      selectTianGan(gan);
                      // 如果当前选中的甲子不符合筛选条件，则清空选择
                      // if (_selectedJiaZi != null &&
                      //     _selectedJiaZi!.tianGan != selected) {
                      //   _selectedJiaZi = null;
                      // }
                    });
              }).toList(),
            );
          },
        );
      },
    );
  }

  // 地支筛选组件
  Widget _buildZhiFilter() {
    return ValueListenableBuilder<List<DiZhi>>(
      valueListenable: diZhiListNotifier,
      builder: (ctx, diZhiList, _) {
        return ValueListenableBuilder<DiZhi?>(
          valueListenable: _diZhiNotifier,
          builder: (ctx, diZhi, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: diZhiList.map((zhi) {
                return ChoiceChip(
                    label: Text(zhi.name),
                    selected: diZhi == zhi,
                    onSelected: (selected) {
                      selectDiZhi(zhi);
                    });
              }).toList(),
            );
          },
        );
      },
    );
  }

  // 六十甲子列表
  Widget _buildJiaZiList() {
    return ValueListenableBuilder<JiaZi?>(
        valueListenable: _selectedJiaZiNotifier,
        builder: (ctx, selectedJiaZi, _) {
          return ValueListenableBuilder<List<JiaZi>>(
            valueListenable: jiaZhiListNotifier,
            builder: (ctx, jiaZhiList, _) {
              if (jiaZhiList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('没有符合条件的干支组合'),
                );
              }
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: jiaZhiList.length,
                  itemBuilder: (context, index) {
                    final jz = jiaZhiList[index];
                    final isSelected = _selectedJiaZiNotifier.value == jz;
                    return InkWell(
                      onTap: () => selectJiaZi(jz),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(height: 4),
                              Text(
                                jz.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(
                                // height: 14,
                                child: Text(
                                  jz.naYinStr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1,
                                    color: isSelected
                                        ? Colors.blue.shade800
                                        : Colors.black54,
                                  ),
                                ),
                              )
                            ],
                          )),
                    );
                  },
                ),
              );
            },
          );
        });
  }

  void selectJiaZi(JiaZi jz) {
    if (_selectedJiaZiNotifier.value == null) {
      if (_tianGanNotifier.value == jz.tianGan &&
          _diZhiNotifier.value == jz.diZhi) {
        finishedPop(jz);
        return;
      }
      _selectedJiaZiNotifier.value = jz;
      _tianGanNotifier.value = jz.tianGan;
      _diZhiNotifier.value = jz.diZhi;
    } else {
      if (_selectedJiaZiNotifier.value == jz) {
        _selectedJiaZiNotifier.value = null;
      } else {
        _selectedJiaZiNotifier.value = jz;
        _tianGanNotifier.value = jz.tianGan;
        _diZhiNotifier.value = jz.diZhi;
      }
    }
  }

  void selectTianGan(TianGan gan) {
    if (_selectedJiaZiNotifier.value != null) {
      _selectedJiaZiNotifier.value = null;
    }
    if (_tianGanNotifier.value != null) {
      // 取消选择
      if (_tianGanNotifier.value == gan) {
        _tianGanNotifier.value = null;
        diZhiListNotifier.value = DiZhi.listAll;
        jiaZhiListNotifier.value = widget.initJiaZiList ?? JiaZi.listAll;

        if (_diZhiNotifier.value != null) {
          jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
            return jz.diZhi == _diZhiNotifier.value;
          }).toList();
        } else {
          jiaZhiListNotifier.value =
              widget.initJiaZiList ?? JiaZi.listAll.toList();
        }
      } else {
        _tianGanNotifier.value = gan;
        if (_diZhiNotifier.value != null) {
          if (_diZhiNotifier.value!.yinYang == gan.yinYang) {
            diZhiListNotifier.value =
                DiZhi.listAll.where((z) => z.yinYang == gan.yinYang).toList();
            jiaZhiListNotifier.value = [
              JiaZi.getFromGanZhiEnum(gan, _diZhiNotifier.value!)
            ];

            // _selectedJiaZiNotifier.value = jiaZhiListNotifier.value.first;
          } else {
            _diZhiNotifier.value = null;
            diZhiListNotifier.value =
                DiZhi.listAll.where((t) => t.yinYang == gan.yinYang).toList();
            jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
              return jz.tianGan == gan;
            }).toList();
          }
        } else {
          // 用户没有选择地支需要更改 地支列表， 六十甲子 中 阳干总时对阳支，阴干总时对阴支
          diZhiListNotifier.value =
              DiZhi.listAll.where((z) => z.yinYang == gan.yinYang).toList();
          jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
            return jz.tianGan == gan;
          }).toList();
        }
      }
    } else {
      _tianGanNotifier.value = gan;
      if (_diZhiNotifier.value != null) {
        diZhiListNotifier.value =
            DiZhi.listAll.where((z) => z.yinYang == gan.yinYang).toList();
        // 用户已经选择地支，
        jiaZhiListNotifier.value = [
          JiaZi.getFromGanZhiEnum(
              _tianGanNotifier.value!, _diZhiNotifier.value!)
        ];
        // _selectedJiaZiNotifier.value = jiaZhiListNotifier.value.first;
      } else {
        // 用户没有选择地支需要更改 地支列表， 六十甲子 中 阳干总时对阳支，阴干总时对阴支
        diZhiListNotifier.value =
            DiZhi.listAll.where((z) => z.yinYang == gan.yinYang).toList();

        jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
          return jz.tianGan == gan &&
              (_diZhiNotifier.value == null ||
                  jz.diZhi == _diZhiNotifier.value);
        }).toList();
      }
    }
  }

  void selectDiZhi(DiZhi zhi) {
    if (_selectedJiaZiNotifier.value != null) {
      _selectedJiaZiNotifier.value = null;
    }
    if (_diZhiNotifier.value != null) {
      // 取消选择
      if (_diZhiNotifier.value == zhi) {
        _diZhiNotifier.value = null;
        tianGanListNotifier.value = TianGan.listAll;
        jiaZhiListNotifier.value = widget.initJiaZiList ?? JiaZi.listAll;
        if (_tianGanNotifier.value != null) {
          jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
            return jz.tianGan == _tianGanNotifier.value;
          }).toList();
        } else {
          jiaZhiListNotifier.value =
              widget.initJiaZiList ?? JiaZi.listAll.toList();
        }
      } else {
        // 用户选择了另外的地支
        _diZhiNotifier.value = zhi;
        if (_tianGanNotifier.value != null) {
          tianGanListNotifier.value =
              TianGan.listAll.where((g) => g.yinYang == zhi.yinYang).toList();
          jiaZhiListNotifier.value = [
            JiaZi.getFromGanZhiEnum(
                _tianGanNotifier.value!, _diZhiNotifier.value!)
          ];

          // _selectedJiaZiNotifier.value = jiaZhiListNotifier.value.first;
        } else {
          // 用户没有选择地支需要更改 地支列表， 六十甲子 中 阳干总时对阳支，阴干总时对阴支
          tianGanListNotifier.value =
              TianGan.listAll.where((z) => z.yinYang == zhi.yinYang).toList();
          jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
            return jz.diZhi == zhi;
          }).toList();
        }

        // jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
        //   return jz.tianGan == gan &&
        //       (_diZhiNotifier.value == null ||
        //           jz.diZhi == _diZhiNotifier.value);
        // }).toList();
      }
    } else {
      _diZhiNotifier.value = zhi;
      if (_tianGanNotifier.value != null) {
        if (_tianGanNotifier.value!.yinYang == zhi.yinYang) {
          // 用户已经选择天干，
          tianGanListNotifier.value =
              TianGan.listAll.where((g) => g.yinYang == zhi.yinYang).toList();
          jiaZhiListNotifier.value = [
            JiaZi.getFromGanZhiEnum(
                _tianGanNotifier.value!, _diZhiNotifier.value!)
          ];

          // _selectedJiaZiNotifier.value = jiaZhiListNotifier.value.first;
        } else {
          _tianGanNotifier.value = null;
          tianGanListNotifier.value =
              TianGan.listAll.where((g) => g.yinYang == zhi.yinYang).toList();
          jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
            return jz.diZhi == zhi;
          }).toList();
        }
      } else {
        // 用户没有选择地支需要更改 地支列表， 六十甲子 中 阳干总时对阳支，阴干总时对阴支
        tianGanListNotifier.value =
            TianGan.listAll.where((z) => z.yinYang == zhi.yinYang).toList();

        jiaZhiListNotifier.value = JiaZi.listAll.where((jz) {
          return jz.diZhi == zhi;
        }).toList();
      }
    }
  }
}
