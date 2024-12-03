import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/models/observer_position.dart';
import 'package:qizhengsiyu/models/stars_angle.dart';
import 'package:qizhengsiyu/pages/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/services/an_shen_li_ming_service.dart';
import 'package:qizhengsiyu/utils/star_walking_info_utils.dart';

void main() {

  test('345 <= 9 <= 15', () {
    expect(QiZhengSiYuViewModel.isInDegreeRange(345, 15, 9), true);

  });
  test('345 <= 350 <= 15', () {
    expect(QiZhengSiYuViewModel.isInDegreeRange(345, 15, 350), true);

  });

  test('320 <= 350 <= 0', () {
    expect(QiZhengSiYuViewModel.isInDegreeRange(320, 0, 350), true);
    expect(QiZhengSiYuViewModel.isInDegreeRange(320, 0, 319), false);
  });
  test('320 <= 0 <= 1', () {
    expect(QiZhengSiYuViewModel.isInDegreeRange(320, 1, 0), true);
  });
  test('320 <= 1 <= 1', () {
    expect(QiZhengSiYuViewModel.isInDegreeRange(320, 1, 1), true);
    expect(QiZhengSiYuViewModel.isInDegreeRange(320, 1, 2), false);
  });

}
