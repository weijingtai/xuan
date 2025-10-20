import 'package:common/models/pillar_data.dart';
import 'package:common/models/pillar_group.dart';
import 'package:common/viewmodels/bazi_card_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditGroupWidget extends StatefulWidget {
  final PillarGroup group;

  const EditGroupWidget({Key? key, required this.group}) : super(key: key);

  @override
  _EditGroupWidgetState createState() => _EditGroupWidgetState();
}

class _EditGroupWidgetState extends State<EditGroupWidget> {
  late TextEditingController _titleController;
  late List<PillarData> _pillars;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.title);
    _pillars = List<PillarData>.from(widget.group.pillars);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BaziCardViewModel>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '分组标题'),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _pillars.length,
            itemBuilder: (context, index) {
              final pillar = _pillars[index];
              return ListTile(
                key: ValueKey(pillar.pillarId),
                title: Text(pillar.label),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _pillars.removeAt(index);
                    });
                  },
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _pillars.removeAt(oldIndex);
                _pillars.insert(newIndex, item);
              });
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement Add Pillar functionality
          },
          child: const Text('添加柱'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedGroup = widget.group.copyWith(
              title: _titleController.text,
              pillars: _pillars,
            );
            viewModel.updateGroup(updatedGroup);
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
