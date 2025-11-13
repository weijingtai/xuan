import 'package:flutter/material.dart';

class EditableSingleTextCell extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign? align;
  const EditableSingleTextCell({
    super.key,
    required this.text,
    required this.style,
    this.align,
  });
  @override
  State<EditableSingleTextCell> createState() => _EditableSingleTextCellState();
}

class _EditableSingleTextCellState extends State<EditableSingleTextCell> {
  late String _text;
  late TextStyle _style;
  @override
  void initState() {
    super.initState();
    _text = widget.text;
    _style = widget.style;
  }
  @override
  void didUpdateWidget(covariant EditableSingleTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _text = widget.text;
    if (oldWidget.style != widget.style) _style = widget.style;
  }
  void _openEditor() async {
    final controller = TextEditingController(text: _text);
    double size = _style.fontSize ?? 14;
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: controller),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Text('字号')),
                    Text(size.toStringAsFixed(0)),
                  ],
                ),
                Slider(
                  value: size,
                  min: 10,
                  max: 36,
                  onChanged: (v) {
                    size = v;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, {
                'text': controller.text,
                'size': size,
              }),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    if (res != null) {
      setState(() {
        _text = res['text'] as String? ?? _text;
        final double s = (res['size'] as double?) ?? (_style.fontSize ?? 14);
        _style = _style.copyWith(fontSize: s);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _openEditor,
      child: Text(_text, style: _style, textAlign: widget.align),
    );
  }
}
