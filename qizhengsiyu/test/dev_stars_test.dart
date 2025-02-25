import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_stars.dart';
import 'package:qizhengsiyu/pages/balls.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';

void main(){
  group("ball check",(){
    double rangeAngle = 4;
    test('around star 2 same angle 90°', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
         UIStarModel(
             star: EnumStars.Moon,
             originalAngle: 90,
             rangeAngleEachSide: rangeAngle),
      ];

      final resolver = CollisionResolver([]);
      final resolvedStars = resolver.doResolve(stars);
      expect(resolvedStars.length, 2);
      expect(resolvedStars.first, 88.0);
      expect(resolvedStars.last, 92.0);

    });
  });
}