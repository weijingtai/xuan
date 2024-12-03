import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/main.dart';
import 'package:common/model/enum_jia_zi.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:common/model/enum_yin_yang.dart';
import 'package:common/widgets/four_zhu_eight_char.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/yu_ding_da_liu_ren.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/JieQi.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:tuple/tuple.dart';
import 'package:common/module.dart';

import 'model/da_liu_ren_gong.dart';
import 'model/da_liu_ren_pan_model.dart';
import 'model/four_class.dart';
import 'model/three_chuan.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

