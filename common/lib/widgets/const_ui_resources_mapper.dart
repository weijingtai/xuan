import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConstUIResourcesMapper {
  static final TextStyle twelveDiZhiTextStyle = GoogleFonts.longCang(
      color: Colors.grey,
      fontSize: 24,
      height: 1,
      // fontWeight: FontWeight.w500,
      shadows: [
        const Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
      ]);
  static final TextStyle tianGanTextStyle = GoogleFonts.maShanZheng(
      color: Colors.black87,
      fontSize: 28,
      height: 1.0,
      shadows: [
        const Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
      ]);
}
