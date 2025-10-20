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
                  color: Colors.white.withValues(alpha: .2),
                  offset: const Offset(1, 1),
                  blurRadius: 1)
            ]);
  }

  @override
  Widget build(BuildContext context) {
    var listContent = name.split("");
    final first = listContent.first;
    final second = listContent.last;
    return Container(
      // padding: EdgeInsets.only(bottom: 3,left: 3,right: 3),
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
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 6),
        // padding: EdgeInsets.only(top: 4,bottom: 6),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: isBold ? 2 : 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: borderColor.withValues(alpha: .2),
                  offset: const Offset(1, 1),
                  blurRadius: 1)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(first, style: fontStyle),
            Text(second, style: fontStyle),
          ],
        ),
      ),
    );
  }
}
