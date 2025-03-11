import 'package:common/models/ConstantNineGongDataClass.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:tuple/tuple.dart';

class ConstantQiMenNineGongDataClass extends ConstantNineGongDataClass {
  final NineStarsEnum defaultStar;
  final EightDoorEnum defaultDoor;
  final Tuple3<String, String, String> jieQiTuple;
  ConstantQiMenNineGongDataClass(
      this.defaultStar,
      this.defaultDoor,
      this.jieQiTuple,
      String name,
      String number,
      Tuple2<String, String?> diZhi,
      {String? tianMenDiHu})
      : super(name, number, diZhi, tianMenDiHu);
}
