import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/utils/star_enter_info_calculator.dart';

void main() {
  test('345 <= 9 <= 15', () {
    expect(StarEnterInfoCalculator.isInDegreeRange(345, 15, 9), true);
  });
  test('345 <= 350 <= 15', () {
    expect(StarEnterInfoCalculator.isInDegreeRange(345, 15, 350), true);
  });

  test('320 <= 350 <= 0', () {
    expect(StarEnterInfoCalculator.isInDegreeRange(320, 0, 350), true);
    expect(StarEnterInfoCalculator.isInDegreeRange(320, 0, 319), false);
  });
  test('320 <= 0 <= 1', () {
    expect(StarEnterInfoCalculator.isInDegreeRange(320, 1, 0), true);
  });
  test('320 <= 1 <= 1', () {
    expect(StarEnterInfoCalculator.isInDegreeRange(320, 1, 1), true);
    expect(StarEnterInfoCalculator.isInDegreeRange(320, 1, 2), false);
  });
}
