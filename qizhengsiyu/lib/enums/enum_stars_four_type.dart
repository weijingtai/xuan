import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

enum EnumStarsFourType {
  @JsonValue("恩")
  En("恩"),
  @JsonValue("难")
  Nan("难"),
  @JsonValue("仇")
  Chou("仇"),
  @JsonValue("用")
  Yong("用"),
  @JsonValue("无")
  Unknown("无");

  final String name;
  const EnumStarsFourType(this.name);

  /// @description:
  ///  根据星体间的 “生克泻耗同”
  static EnumStarsFourType getByFiveXingRelationship(
      FiveXingRelationship relationship) {
    switch (relationship) {
      case FiveXingRelationship.SHENG:
        return En;
      case FiveXingRelationship.KE:
        return Nan;
      case FiveXingRelationship.XIE:
        return Yong;
      case FiveXingRelationship.HAO:
        return Chou;
      default:
        return Unknown;
    }
  }
}
