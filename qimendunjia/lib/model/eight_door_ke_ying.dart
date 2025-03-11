import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
part 'eight_door_ke_ying.g.dart';

@JsonSerializable()
class EightDoorKeYing {
  EightDoorEnum door;
  EightDoorEnum fixDoor;
  YinYang dongJingYing; // 阳为动应
  String description;
  EightDoorKeYing(
      {required this.door,
      required this.fixDoor,
      required this.dongJingYing,
      required this.description});

  factory EightDoorKeYing.fromJson(Map<String, dynamic> json) =>
      _$EightDoorKeYingFromJson(json);
  Map<String, dynamic> toJson() => _$EightDoorKeYingToJson(this);
}
