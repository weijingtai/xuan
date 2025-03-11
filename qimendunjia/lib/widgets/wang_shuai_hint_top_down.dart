import 'package:flutter/material.dart';

class WangShuaiHintTopDown extends StatefulWidget {
  Size size;
  bool showHint;
  Duration duration;
  Alignment alignment;
  Widget top;
  Widget bottom;
  // Tuple2<Widget,Widget> widgetTuple2; // item1 is topText, item2 is bottomText
  // String topText;
  // String bottomText;
  WangShuaiHintTopDown(
      {super.key,
      required this.top,
      required this.bottom,
      required this.size,
      required this.showHint,
      required this.duration,
      this.alignment = Alignment.centerRight});

  @override
  State<WangShuaiHintTopDown> createState() => _WangShuaiHintTopDownState();
}

class _WangShuaiHintTopDownState extends State<WangShuaiHintTopDown> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      height: widget.size.height,
      width: widget.showHint ? widget.size.width : 0,
      alignment: widget.alignment,
      child: AnimatedSwitcher(
        duration: widget.duration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: const Offset(0, 0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: widget.showHint
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [widget.top, widget.bottom],
              )
            : Container(),
      ),
    );
  }
}
