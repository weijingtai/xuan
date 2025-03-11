import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class WangShuaiHint extends StatefulWidget {
  Size size;
  bool showHint;
  Duration duration;
  Alignment alignment;
  Tuple2<String, String> textTuple2; // item1 is topText, item2 is bottomText
  // String topText;
  // String bottomText;
  WangShuaiHint(
      {super.key,
      required this.textTuple2,
      required this.size,
      required this.showHint,
      required this.duration,
      this.alignment = Alignment.centerRight});

  @override
  State<WangShuaiHint> createState() => _WangShuaiHintState();
}

class _WangShuaiHintState extends State<WangShuaiHint> {
  @override
  Widget build(BuildContext context) {
    double height = widget.size.height * .5;
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: widget.size.width,
                    height: widget.size.width,
                    // height: height,
                    // alignment: widget.alignment,
                    alignment: Alignment.bottomRight,
                    child: AutoSizeText(
                      widget.textTuple2.item1,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                          height: 1),
                      minFontSize: 8,
                      maxFontSize: 24,
                    ),
                  ),
                  Container(
                    width: widget.size.width,
                    height: widget.size.width,
                    // height: height,
                    // alignment:  widget.alignment,
                    alignment: Alignment.topRight,
                    child: AutoSizeText(
                      widget.textTuple2.item2,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                          height: 1),
                      minFontSize: 8,
                      maxFontSize: 24,
                    ),
                  )
                ],
              )
            : Container(),
      ),
    );
  }
}
