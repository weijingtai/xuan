import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
part 'door_star_ke_ying.g.dart';

@JsonSerializable()
class DoorStarKeYing {
  EightDoorEnum door;
  NineStarsEnum star;
  JiXiongEnum jiXiong;
  String description;
  DoorStarKeYing(
      {required this.door,
      required this.star,
      required this.jiXiong,
      required this.description});

  factory DoorStarKeYing.fromJson(Map<String, dynamic> json) =>
      _$DoorStarKeYingFromJson(json);
  Map<String, dynamic> toJson() => _$DoorStarKeYingToJson(this);
}
