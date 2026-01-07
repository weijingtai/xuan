import 'package:common/models/pillar_data.dart';
import 'package:common/themes/editor_theme.dart';
import 'package:common/widgets/layout_editor_sidebar.dart';
import 'package:common/widgets/pillar_tag_bar.dart';
import 'package:common/widgets/pillar_card.dart';
import 'package:flutter/material.dart';

import '../enums/enum_jia_zi.dart';
import '../enums/layout_template_enums.dart';
import '../models/pillar_preset.dart';
import '../widgets/row_tag_bar.dart';

class LayoutEditorPage extends StatefulWidget {
  const LayoutEditorPage({Key? key}) : super(key: key);

  @override
  _LayoutEditorPageState createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<LayoutEditorPage> {
  List<PillarData> _canvasPillars = [];
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? EditorTheme.darkTheme : EditorTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.space_dashboard_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              // Dropdown
              DropdownButton<String>(
                value: '我的默认四柱',
                underline: const SizedBox.shrink(),
                items: <String>['我的默认四柱', '大运流年专用', '胎元分析盘', '新建布局...']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: Theme.of(context).textTheme.titleMedium),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
              const SizedBox(width: 16),
              // TextField
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: '大运流年专用'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 16),
              label: const Text('保存'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('另存为...'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: () {},
            ),
            const VerticalDivider(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Left Sideba
            const LayoutEditorSidebar(),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // 画布区域：占 80%
                  Expanded(
                    child: DragTarget<Object>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: ReorderableListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              for (int index = 0;
                                  index < _canvasPillars.length;
                                  index += 1)
                                PillarCard(
                                  key: Key(_canvasPillars[index].pillarId),
                                  pillar: _canvasPillars[index],
                                  onDelete: () {
                                    setState(() {
                                      _canvasPillars.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final PillarData item =
                                    _canvasPillars.removeAt(oldIndex);
                                _canvasPillars.insert(newIndex, item);
                              });
                            },
                          ),
                        );
                      },
                      onAccept: (Object data) {
                        setState(() {
                          if (data is PillarData) {
                            _canvasPillars.add(data);
                          } else if (data is PillarPreset) {
                            for (final id in (data as PillarPreset).pillarIds) {
                              _canvasPillars.add(PillarData(
                                pillarType: PillarType.year,
                                pillarId: id,
                                label: id, // 或适当标签
                                jiaZi: JiaZi.JIA_ZI, // 默认值，根据需要调整
                              ));
                            }
                          }
                        });
                      },
                    ),
                  ),
                  // 底部 TagBar：占用剩余 20% 高度（通过 Flexible 实现相对比例）
                  RowTagBar(),
                  const Flexible(
                    flex: 1,
                    child: PillarTagBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
