import 'package:flutter/material.dart';
import '../models/cell_style_config.dart';
import 'cell_interfaces.dart';

class EditableMultiTextCell extends StatefulWidget {
  final Text content;
  final Widget? upChild;
  final Widget? subChild;

  final double constant; // 用于计算字体和预测行高的常数 建议为1.4
  final CellStyleConfig cellStyleConfig;
  final Size size;
  const EditableMultiTextCell({
    super.key,
    required this.content,
    required this.size,
    this.upChild,
    this.subChild,
    this.constant = 1.4,
    required this.cellStyleConfig,
  });
  @override
  State<EditableMultiTextCell> createState() => _EditableMultiTextCellState();
}

class _EditableMultiTextCellState extends State<EditableMultiTextCell> {
  // late List<TextLineModel> _lines;
  @override
  void initState() {
    super.initState();
    // _lines = widget.lines;
  }

  @override
  void didUpdateWidget(covariant EditableMultiTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.lines != widget.lines) _lines = widget.lines;
  }

  // double get defaultSubTopContentHeight => (widget.defaultSubTopTextSize * 1.4).ceilToDouble(); 11.2 -> 12
  double get defaultSubTopContentHeight => 12.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        clipBehavior: Clip.none,
        duration: const Duration(milliseconds: 200),
        margin: widget.cellStyleConfig.margin,
        padding: widget.cellStyleConfig.padding,
        width: widget.size.width,
        height: widget.size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.transparent,
          color: (Theme.of(context).brightness == Brightness.dark
                  ? (widget.cellStyleConfig.darkBackgroundColor ==
                          Colors.transparent
                      ? Colors.transparent
                      : widget.cellStyleConfig.darkBackgroundColor)
                  : widget.cellStyleConfig.lightBackgroundColor ==
                          Colors.transparent
                      ? Colors.transparent
                      : widget.cellStyleConfig.lightBackgroundColor) ??
              Colors.white,
          border: (widget.cellStyleConfig.border?.enabled ?? false) &&
                  (widget.cellStyleConfig.border!.width > 0)
              ? Border.all(
                  color: widget.cellStyleConfig.border!.lightColor,
                  width: widget.cellStyleConfig.border!.width,
                )
              : null,
          borderRadius:
              BorderRadius.circular(widget.cellStyleConfig.border?.radius ?? 0),
          boxShadow: widget.cellStyleConfig.shadow.withShadow
              ? [
                  BoxShadow(
                    color: (widget.cellStyleConfig.shadow
                                .followCardBackgroundColor
                            ? ((Theme.of(context).brightness == Brightness.dark
                                    ? widget.cellStyleConfig.darkBackgroundColor
                                    : widget.cellStyleConfig
                                        .lightBackgroundColor) ??
                                Colors.transparent)
                                .withAlpha(
                                  (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? widget.cellStyleConfig.shadow
                                              .darkThemeColor
                                          : widget.cellStyleConfig.shadow
                                              .lightThemeColor)
                                      .alpha,
                                )
                            : (Theme.of(context).brightness == Brightness.dark
                                ? widget.cellStyleConfig.shadow.darkThemeColor
                                : widget
                                    .cellStyleConfig.shadow.lightThemeColor)),
                    offset: widget.cellStyleConfig.shadow.offset,
                    blurRadius: widget.cellStyleConfig.shadow.blurRadius,
                    spreadRadius: widget.cellStyleConfig.shadow.spreadRadius,
                  )
                ]
              : null,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.upChild != null) widget.upChild!,
              Container(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                // color: Colors.red.withAlpha(100),
                // height: (widget.content.style!.fontSize! * widget.constant)
                //     .toInt()
                //     .toDouble(),
                child: widget.content,
              ),
              if (widget.subChild != null) widget.subChild!,
            ]));
  }
}
