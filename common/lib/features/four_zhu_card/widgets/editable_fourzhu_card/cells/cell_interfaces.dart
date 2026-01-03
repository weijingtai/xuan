import 'package:flutter/material.dart';

enum CellType { singleText, multiText, richDecorated }

@Deprecated("")
class TextLineModel {
  final String content;
  final TextStyle style;
  final TextAlign? align;
  TextLineModel({required this.content, required this.style, this.align});
}

class CellDecorationProps {
  final Color? background;
  final double? borderWidth;
  final Color? borderColor;
  final double? cornerRadius;
  final List<BoxShadow>? boxShadow;
  final List<Widget>? cornerBadges;
  final List<Widget>? sideLabels;
  final List<Widget>? positionedIcons;
  const CellDecorationProps({
    this.background,
    this.borderWidth,
    this.borderColor,
    this.cornerRadius,
    this.boxShadow,
    this.cornerBadges,
    this.sideLabels,
    this.positionedIcons,
  });
}
