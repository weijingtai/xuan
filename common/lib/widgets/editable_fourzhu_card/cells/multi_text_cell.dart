import 'package:flutter/material.dart';
import 'cell_interfaces.dart';

class EditableMultiTextCell extends StatefulWidget {
  final List<TextLineModel> lines;
  const EditableMultiTextCell({super.key, required this.lines});
  @override
  State<EditableMultiTextCell> createState() => _EditableMultiTextCellState();
}

class _EditableMultiTextCellState extends State<EditableMultiTextCell> {
  late List<TextLineModel> _lines;
  @override
  void initState() {
    super.initState();
    _lines = widget.lines;
  }
  @override
  void didUpdateWidget(covariant EditableMultiTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines != widget.lines) _lines = widget.lines;
  }
  void _openEditor() async {
    final controllers = _lines.map((e) => TextEditingController(text: e.content)).toList();
    final sizes = _lines.map((e) => e.style.fontSize ?? 14.0).toList();
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_lines.length, (i) {
                  return Column(children: [
                    TextField(controller: controllers[i]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Expanded(child: Text('字号')),
                      Text(sizes[i].toStringAsFixed(0)),
                    ]),
                    Slider(
                      value: sizes[i],
                      min: 10,
                      max: 36,
                      onChanged: (v) {
                        setState(() {
                          sizes[i] = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ]);
                }),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
          ],
        );
      },
    );
    if (res == true) {
      setState(() {
        _lines = List.generate(_lines.length, (i) {
          return TextLineModel(
            content: controllers[i].text,
            style: _lines[i].style.copyWith(fontSize: sizes[i]),
            align: _lines[i].align,
          );
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _openEditor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            _lines.map((l) => Text(l.content, style: l.style, textAlign: l.align)).toList(),
      ),
    );
  }
}
