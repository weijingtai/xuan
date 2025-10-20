import 'package:flutter/material.dart';

class ReorderableRowItem extends StatefulWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onCheckedChanged;

  const ReorderableRowItem({
    Key? key,
    required this.title,
    required this.isChecked,
    required this.onCheckedChanged,
  }) : super(key: key);

  @override
  _ReorderableRowItemState createState() => _ReorderableRowItemState();
}

class _ReorderableRowItemState extends State<ReorderableRowItem> {
  bool _showTitle = true;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Row(
              children: [
                Checkbox(
                  value: widget.isChecked,
                  onChanged: widget.onCheckedChanged,
                ),
                Text(widget.title),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('显示标题', style: theme.textTheme.bodySmall),
                Switch(
                  value: _showTitle,
                  onChanged: (value) {
                    setState(() {
                      _showTitle = value;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Family
                  DropdownButtonFormField<String>(
                    value: '系统默认',
                    items: <String>['系统默认', '黑体', '宋体']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {},
                    decoration: const InputDecoration(
                      labelText: '字体',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Font Size and Color
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '12',
                          decoration: const InputDecoration(
                            labelText: '字号',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            const Text('颜色'),
                            const SizedBox(width: 16),
                            Container(
                              width: 24,
                              height: 24,
                              color: Colors.red, // Placeholder
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: '#DC2626',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
