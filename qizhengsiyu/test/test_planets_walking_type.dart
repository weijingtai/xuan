import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_stars.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/panel_stars_info.dart';
import 'package:qizhengsiyu/models/stars_angle.dart';
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';

void main() {
  // // 设定观察者的经纬度和高度（例如：上海）
  // double latitude = 31.2304; // 纬度
  // double longitude = 121.4737; // 经度
  // double altitude = 0; // 高度（米）
  // var observerPostion = ObserverPosition(
  //     latitude: latitude,
  //     longitude: longitude,
  //     altitude: altitude,
  //     dateTime: DateTime(2024, 10, 13, 16, 45),
  //     timezone: 'Asia/Shanghai'
  // );
  test('Fire test', () {
    // 逆、留、迟、常、速、常、迟、留
    // 常、速、常、迟、留、逆、留、迟、

    List<FiveStarWalkingType> list = EnumStars.Fire.fullForwardList;
    list.forEach((t)=>print(t.name));

    var result = FiveStarWalkingType.changeFirst(FiveStarWalkingType.Normal,list);
    result.forEach((t)=>print(t.name));
    FiveStarWalkingType.reverseToPreviousListAndChangeFirst(FiveStarWalkingType.Normal,list).forEach((t)=>print(t.name));


  });
  test('Golden test', () {
    // 逆、留、迟、常、速、常、迟、留
    // 常、速、常、迟、留、逆、留、迟、

    List<FiveStarWalkingType> list = EnumStars.Golden.fullForwardList;
    list.forEach((t)=>print(t.name));

    var result = FiveStarWalkingType.changeFirst(FiveStarWalkingType.Normal,list);
    result.forEach((t)=>print(t.name));
    FiveStarWalkingType.reverseToPreviousListAndChangeFirst(FiveStarWalkingType.Normal,list).forEach((t)=>print(t.name));

  });

  test("Golden speed type test",(){
    FiveStarWalkingType result = StarWalkingInfoUtils.getWalkingType(0.100,StarsAngle.moirasFiveStartsMapper[EnumStars.Golden]!);
    expect(result, FiveStarWalkingType.Stay);


    });
  // test('Golden at datetime test',(){
  //
  //   StarWalkingInfoUtils.calculateStarWalkingInfo(EnumSevenZheng.Golden,observerPostion,StarsAngle.moirasFiveStartsMapper);
  //   nextWalkingType(fiveStar,planetBody,observerSpeed, julianDay, currentFiveStarWalkingType, tuple6, speedStringFixed: _speedStringFixed,timeStep: 1/24);
  // });
}
