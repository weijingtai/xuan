import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Season24Tag extends StatelessWidget {
  String name;
  Color fontColor = Colors.grey;
  Color borderColor = Colors.grey;
  Color backgroundColor = Colors.white;
  bool isBold = false;
  late TextStyle fontStyle;

  Season24Tag({
    super.key,
    required this.name,
    required this.fontColor,
    this.borderColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.isBold = false,
    TextStyle? fontStyle,
  }) {
    this.fontStyle = fontStyle?.copyWith(color: fontColor) ??
        GoogleFonts.notoSerif(
            height: 1,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: fontColor,
            shadows: [
              Shadow(
                  color: Colors.white.withOpacity(.2),
                  offset: const Offset(1, 1),
                  blurRadius: 1)
            ]);
  }

  @override
  Widget build(BuildContext context) {
    var textList = name
        .split("")
        .map((t) => AutoSizeText(t,
            maxLines: 1, maxFontSize: 16, minFontSize: 8, style: fontStyle))
        .toList();
    // final first = listContent.first;
    // final second = listContent.last;
    return Container(
      // padding: EdgeInsets.only(bottom: 3,left: 3,right: 3),
      width: 20,
      height: 42,
      alignment: Alignment.center,
      decoration: isBold
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            )
          : const BoxDecoration(),
      child: Container(
        alignment: Alignment.center,
        // padding: EdgeInsets.fromLTRB(0, 4, 4, 4),
        // padding: EdgeInsets.only(top: 4,bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: isBold ? 2 : 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: borderColor.withOpacity(.2),
                  offset: const Offset(1, 1),
                  blurRadius: 1)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: textList,
        ),
      ),
    );
  }
}
