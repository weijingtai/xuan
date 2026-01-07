import 'package:common/themes/editor_theme.dart';
import 'package:common/widgets/reorderable_row_item.dart';
import 'package:flutter/material.dart';

class RowData {
  final String title;
  bool isChecked;
  RowData(this.title, this.isChecked);
}

class LayoutEditorSidebar extends StatefulWidget {
  const LayoutEditorSidebar({Key? key}) : super(key: key);

  @override
  _LayoutEditorSidebarState createState() => _LayoutEditorSidebarState();
}

class _LayoutEditorSidebarState extends State<LayoutEditorSidebar> {
  final List<RowData> _rows = [
    RowData('十神', true),
    RowData('纳音', false),
    RowData('空亡', true),
    RowData('旬首', false),
    RowData('地支藏干', true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      // color: theme.cardColor,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.topCenter,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSection(
            context,
            title: '柱间分隔线',
            description: '自定义柱与柱之间的分隔线样式',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: '无',
                  items: <String>['实线', '虚线', '点状', '无']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                  decoration: const InputDecoration(
                    labelText: '样式',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('颜色'),
                    const SizedBox(width: 16),
                    Container(
                      width: 24,
                      height: 24,
                      color: EditorTheme.borderLight,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '#D1D5DB',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: '1',
                  decoration: const InputDecoration(
                    labelText: '粗细 (px)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSection(
            context,
            title: '行信息管理',
            description: '勾选需要显示的信息行，并拖动调整顺序',
            child: Expanded(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('天干 (核心)'),
                    tileColor: Colors.black12,
                  ),
                  const ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('地支 (核心)'),
                    tileColor: Colors.black12,
                  ),
                  Expanded(
                    child: ReorderableListView(
                      children: <Widget>[
                        for (int index = 0; index < _rows.length; index += 1)
                          ReorderableRowItem(
                            key: Key(_rows[index].title),
                            title: _rows[index].title,
                            isChecked: _rows[index].isChecked,
                            onCheckedChanged: (bool? value) {
                              setState(() {
                                _rows[index].isChecked = value ?? false;
                              });
                            },
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final RowData item = _rows.removeAt(oldIndex);
                          _rows.insert(newIndex, item);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required String description,
      required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(description, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
