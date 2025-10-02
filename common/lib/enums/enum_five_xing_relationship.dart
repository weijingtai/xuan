import 'enum_di_zhi.dart';
import 'enum_five_xing.dart';

enum FiveXingRelationship {
  SHENG("生"),
  KE("克"),
  XIE("泄"),
  HAO("耗"),
  TONG("同");

  final String value;
  const FiveXingRelationship(this.value);

  static const Map<FiveXing, Map<FiveXing, FiveXingRelationship>>
      _checkerMapper = {
    FiveXing.JIN: {
      FiveXing.MU: FiveXingRelationship.HAO,
      FiveXing.SHUI: FiveXingRelationship.XIE,
      FiveXing.HUO: FiveXingRelationship.KE,
      FiveXing.TU: FiveXingRelationship.SHENG,
      FiveXing.JIN: FiveXingRelationship.TONG,
    },
    FiveXing.MU: {
      FiveXing.SHUI: FiveXingRelationship.SHENG,
      FiveXing.HUO: FiveXingRelationship.XIE,
      FiveXing.TU: FiveXingRelationship.HAO,
      FiveXing.JIN: FiveXingRelationship.KE,
      FiveXing.MU: FiveXingRelationship.TONG,
    },
    FiveXing.SHUI: {
      FiveXing.HUO: FiveXingRelationship.HAO,
      FiveXing.TU: FiveXingRelationship.KE,
      FiveXing.JIN: FiveXingRelationship.SHENG,
      FiveXing.MU: FiveXingRelationship.XIE,
      FiveXing.SHUI: FiveXingRelationship.TONG,
    },
    FiveXing.HUO: {
      FiveXing.TU: FiveXingRelationship.XIE,
      FiveXing.JIN: FiveXingRelationship.HAO,
      FiveXing.MU: FiveXingRelationship.SHENG,
      FiveXing.SHUI: FiveXingRelationship.KE,
      FiveXing.HUO: FiveXingRelationship.TONG,
    },
    FiveXing.TU: {
      FiveXing.JIN: FiveXingRelationship.XIE,
      FiveXing.MU: FiveXingRelationship.KE,
      FiveXing.SHUI: FiveXingRelationship.HAO,
      FiveXing.HUO: FiveXingRelationship.SHENG,
      FiveXing.TU: FiveXingRelationship.TONG,
    },
  };

  static FiveXingRelationship? checkRelationship(
      FiveXing thisElement, FiveXing otherElement) {
    return _checkerMapper[thisElement]?[otherElement];
  }

  static FiveXingRelationship? getFromValue(String value) {
    for (var element in FiveXingRelationship.values) {
      if (element.value == value) {
        return element;
      }
    }
    return null;
  }

  static Map<FiveXing, FiveXingRelationship> getShengKeXieHaoTongDict(
      FiveXing thisElement) {
    return _checkerMapper[thisElement]!;
  }
}

enum FiveEnergyStatus {
  WANG("旺"),
  XIANG("相"),
  XIU("休"),
  QIU("囚"),
  SI("死");

  final String name;
  const FiveEnergyStatus(this.name);
  bool get isStrong => checkStrong(this);
  bool get isWeak => checkWeak(this);
  static FiveEnergyStatus getWangShuaiByName(String name) {
    switch (name) {
      case "旺":
        return FiveEnergyStatus.WANG;
      case "相":
        return FiveEnergyStatus.XIANG;
      case "休":
        return FiveEnergyStatus.XIU;
      case "囚":
        return FiveEnergyStatus.QIU;
      case "死":
        return FiveEnergyStatus.SI;
    }
    throw UnsupportedError("仅支持：旺相休囚死");
  }

  static FiveEnergyStatus getFiveXingWangShuaiAtDiZhi(
      DiZhi diZhi, FiveXing fiveXing) {
    switch (diZhi) {
      case DiZhi.YIN:
      case DiZhi.MAO:
        if (fiveXing == FiveXing.MU) {
          return WANG;
        } else if (fiveXing == FiveXing.HUO) {
          return XIANG;
        } else if (fiveXing == FiveXing.SHUI) {
          return XIU;
        } else if (fiveXing == FiveXing.JIN) {
          return QIU;
        } else {
          return SI;
        }
      case DiZhi.SI:
      case DiZhi.WU:
        if (fiveXing == FiveXing.HUO) {
          return WANG;
        } else if (fiveXing == FiveXing.TU) {
          return XIANG;
        } else if (fiveXing == FiveXing.MU) {
          return XIU;
        } else if (fiveXing == FiveXing.SHUI) {
          return QIU;
        } else {
          return SI;
        }
      case DiZhi.SHEN:
      case DiZhi.YOU:
        if (fiveXing == FiveXing.JIN) {
          return WANG;
        } else if (fiveXing == FiveXing.SHUI) {
          return XIANG;
        } else if (fiveXing == FiveXing.JIN) {
          return XIU;
        } else if (fiveXing == FiveXing.HUO) {
          return QIU;
        } else {
          return SI;
        }
      case DiZhi.HAI:
      case DiZhi.ZI:
        if (fiveXing == FiveXing.SHUI) {
          return WANG;
        } else if (fiveXing == FiveXing.MU) {
          return XIANG;
        } else if (fiveXing == FiveXing.JIN) {
          return XIU;
        } else if (fiveXing == FiveXing.TU) {
          return QIU;
        } else {
          return SI;
        }
      default:
        if (fiveXing == FiveXing.TU) {
          return WANG;
        } else if (fiveXing == FiveXing.JIN) {
          return XIANG;
        } else if (fiveXing == FiveXing.HUO) {
          return XIU;
        } else if (fiveXing == FiveXing.MU) {
          return QIU;
        } else {
          return SI;
        }
    }
  }

  static bool checkWeak(FiveEnergyStatus wangShuai) {
    return [FiveEnergyStatus.XIU, FiveEnergyStatus.QIU, FiveEnergyStatus.SI]
        .contains(wangShuai);
  }

  static bool checkStrong(FiveEnergyStatus wangShuai) {
    return [FiveEnergyStatus.WANG, FiveEnergyStatus.XIANG].contains(wangShuai);
  }
}
