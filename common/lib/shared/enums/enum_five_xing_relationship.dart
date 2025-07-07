import 'enum_di_zhi.dart';
import 'enum_five_xing.dart';
import 'enum_four_seasons.dart';

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

  /// 根据四季获取地支的旺衰状态
  /// 春季：寅卯旺，辰土相，巳午休，未申囚，酉戌亥子丑死
  /// 夏季：巳午旺，未土相，申酉休，戌亥囚，子丑寅卯辰死
  /// 秋季：申酉旺，戌土相，亥子休，丑寅囚，卯辰巳午未死
  /// 冬季：亥子旺，丑土相，寅卯休，辰巳囚，午未申酉戌死
  /// 四季土月：辰戌丑未旺，申酉相，亥子休，寅卯囚，巳午死
  static FiveEnergyStatus getDiZhiWangShuaiAtFourSeasons(
      DiZhi diZhi, FourSeasons season) {
    switch (season) {
      case FourSeasons.SPRING:
        // 春季：木旺火相土死金囚水休
        switch (diZhi) {
          case DiZhi.YIN:
          case DiZhi.MAO:
            return FiveEnergyStatus.WANG; // 木旺
          case DiZhi.SI:
          case DiZhi.WU:
            return FiveEnergyStatus.XIANG; // 火相
          case DiZhi.HAI:
          case DiZhi.ZI:
            return FiveEnergyStatus.XIU; // 水休
          case DiZhi.SHEN:
          case DiZhi.YOU:
            return FiveEnergyStatus.QIU; // 金囚
          default:
            return FiveEnergyStatus.SI; // 土死
        }
      case FourSeasons.SUMMER:
        // 夏季：火旺土相木死水囚金休
        switch (diZhi) {
          case DiZhi.SI:
          case DiZhi.WU:
            return FiveEnergyStatus.WANG; // 火旺
          case DiZhi.CHEN:
          case DiZhi.WEI:
          case DiZhi.XU:
          case DiZhi.CHOU:
            return FiveEnergyStatus.XIANG; // 土相
          case DiZhi.SHEN:
          case DiZhi.YOU:
            return FiveEnergyStatus.XIU; // 金休
          case DiZhi.HAI:
          case DiZhi.ZI:
            return FiveEnergyStatus.QIU; // 水囚
          default:
            return FiveEnergyStatus.SI; // 木死
        }
      case FourSeasons.AUTUMN:
        // 秋季：金旺水相火死木囚土休
        switch (diZhi) {
          case DiZhi.SHEN:
          case DiZhi.YOU:
            return FiveEnergyStatus.WANG; // 金旺
          case DiZhi.HAI:
          case DiZhi.ZI:
            return FiveEnergyStatus.XIANG; // 水相
          case DiZhi.CHEN:
          case DiZhi.WEI:
          case DiZhi.XU:
          case DiZhi.CHOU:
            return FiveEnergyStatus.XIU; // 土休
          case DiZhi.YIN:
          case DiZhi.MAO:
            return FiveEnergyStatus.QIU; // 木囚
          default:
            return FiveEnergyStatus.SI; // 火死
        }
      case FourSeasons.WINTER:
        // 冬季：水旺木相金死火囚土休
        switch (diZhi) {
          case DiZhi.HAI:
          case DiZhi.ZI:
            return FiveEnergyStatus.WANG; // 水旺
          case DiZhi.YIN:
          case DiZhi.MAO:
            return FiveEnergyStatus.XIANG; // 木相
          case DiZhi.CHEN:
          case DiZhi.WEI:
          case DiZhi.XU:
          case DiZhi.CHOU:
            return FiveEnergyStatus.XIU; // 土休
          case DiZhi.SI:
          case DiZhi.WU:
            return FiveEnergyStatus.QIU; // 火囚
          default:
            return FiveEnergyStatus.SI; // 金死
        }
      case FourSeasons.EARTH:
        // 四季土月：土旺金相水死木囚火休
        switch (diZhi) {
          case DiZhi.CHEN:
          case DiZhi.WEI:
          case DiZhi.XU:
          case DiZhi.CHOU:
            return FiveEnergyStatus.WANG; // 土旺
          case DiZhi.SHEN:
          case DiZhi.YOU:
            return FiveEnergyStatus.XIANG; // 金相
          case DiZhi.SI:
          case DiZhi.WU:
            return FiveEnergyStatus.XIU; // 火休
          case DiZhi.YIN:
          case DiZhi.MAO:
            return FiveEnergyStatus.QIU; // 木囚
          default:
            return FiveEnergyStatus.SI; // 水死
        }
    }
  }
}
