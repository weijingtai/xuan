import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

class CommonLogger {
  static final CommonLogger _instance = CommonLogger._internal();
  late final Logger logger;

  factory CommonLogger() {
    return _instance;
  }

  CommonLogger._internal() {
    Level level;
    LogPrinter printer;

    if (kDebugMode) {
      level = Level.trace;
      printer = PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      );
    } else if (kReleaseMode) {
      level = Level.error;
      printer = SimplePrinter(printTime: false);
    } else {
      level = Level.info;
      printer = PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        printTime: false,
      );
    }

    logger = Logger(
      level: level,
      printer: printer,
    );
  }

}

enum AppFeatureModule {
  @JsonValue("golabel")
  Golabel(""),
  @JsonValue("daliu")
  DaLiuRen("daliu"),
  @JsonValue("qimen")
  QiMenDunJia("qimen"),
  @JsonValue("taiyi")
  TaiYiShenShu("taiyi"),
  @JsonValue("74")
  QiZhengSiYu("74");
  final String shortName;
  String get spPrefix => "${shortName}_";
  const AppFeatureModule(this.shortName);
}

interface class AppModuleInfo {
  AppFeatureModule get featureInfo {
    throw UnimplementedError();
  }
}


