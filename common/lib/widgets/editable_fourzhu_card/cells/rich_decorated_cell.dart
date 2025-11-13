import 'package:flutter/material.dart';
import 'cell_interfaces.dart';

class EditableRichDecoratedCell extends StatefulWidget {
  final String centerText;
  final TextStyle centerStyle;
  final CellDecorationProps? decoration;
  final Widget? rightIcon;
  final Widget? leftLabel;
  const EditableRichDecoratedCell({
    super.key,
    required this.centerText,
    required this.centerStyle,
    this.decoration,
    this.rightIcon,
    this.leftLabel,
  });
  @override
  State<EditableRichDecoratedCell> createState() => _EditableRichDecoratedCellState();
}

class _EditableRichDecoratedCellState extends State<EditableRichDecoratedCell> {
  late String _text;
  late TextStyle _style;
  @override
  void initState() {
    super.initState();
    _text = widget.centerText;
    _style = widget.centerStyle;
  }
  @override
  void didUpdateWidget(covariant EditableRichDecoratedCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerText != widget.centerText) _text = widget.centerText;
    if (oldWidget.centerStyle != widget.centerStyle) _style = widget.centerStyle;
  }
  void _openEditor() async {
    final controller = TextEditingController(text: _text);
    double size = _style.fontSize ?? 24;
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: controller),
                const SizedBox(height: 12),
                Row(children: [
                  const Expanded(child: Text('字号')),
                  Text(size.toStringAsFixed(0)),
                ]),
                Slider(value: size, min: 12, max: 48, onChanged: (v) { size = v; }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, { 'text': controller.text, 'size': size }),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    if (res != null) {
      setState(() {
        _text = res['text'] as String? ?? _text;
        final double s = (res['size'] as double?) ?? (_style.fontSize ?? 24);
        _style = _style.copyWith(fontSize: s);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final deco = widget.decoration;
    final box = BoxDecoration(
      color: deco?.background,
      border: deco?.borderWidth != null && (deco!.borderWidth!) > 0
          ? Border.all(color: deco.borderColor ?? Colors.transparent, width: deco.borderWidth!)
          : null,
      borderRadius: deco?.cornerRadius != null
          ? BorderRadius.circular(deco!.cornerRadius!)
          : null,
      boxShadow: deco?.boxShadow,
    );
    return GestureDetector(
      onDoubleTap: _openEditor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: DecoratedBox(decoration: box)),
          Center(child: Text(_text, style: _style)),
          if (widget.rightIcon != null)
            Positioned(right: 4, top: 4, bottom: 4, child: widget.rightIcon!),
          if (widget.leftLabel != null)
            Positioned(left: 4, top: 4, bottom: 4, child: widget.leftLabel!),
          if (deco?.cornerBadges != null)
            ..._cornerBadges(deco!.cornerBadges!),
        ],
      ),
    );
  }

  List<Widget> _cornerBadges(List<Widget> badges) {
    final List<Widget> out = [];
    if (badges.isEmpty) return out;
    out.add(Positioned(left: 2, top: 2, child: badges[0]));
    if (badges.length > 1) out.add(Positioned(right: 2, top: 2, child: badges[1]));
    if (badges.length > 2) out.add(Positioned(left: 2, bottom: 2, child: badges[2]));
    if (badges.length > 3) out.add(Positioned(right: 2, bottom: 2, child: badges[3]));
    return out;
  }
}
