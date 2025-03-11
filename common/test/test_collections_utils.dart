import 'package:common/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('changeSeq 测试', () {
    test('起始元素是第一个元素', () {
      List<String> original = ['a', 'b', 'c', 'd'];
      List<String> result = CollectUtils.changeSeq('a', original);
      expect(result, original);
    });

    test('isReversed 为 false', () {
      List<String> original = ['a', 'b', 'c', 'd'];
      List<String> result = CollectUtils.changeSeq('c', original);
      expect(result, ['c', 'd', 'a', 'b']);
    });

    test('isReversed 为 true', () {
      List<String> original = ['a', 'b', 'c', 'd', "e"];
      List<String> result =
          CollectUtils.changeSeq('c', original, isReversed: true);
      expect(result, ['c', 'b', 'a', 'e', 'd']);
    });
    test('isReversed 为 true, start 为第一个', () {
      List<String> original = ['c', 'd', 'e', 'f'];
      List<String> result =
          CollectUtils.changeSeq('c', original, isReversed: true);
      expect(result, ['c', "f", "e", "d"]);
    });

    test('start 不在第一个位置', () {
      List<String> original = ['a', 'b', 'c', 'd'];
      List<String> result = CollectUtils.changeSeq('d', original);
      expect(result, ['d', 'a', 'b', 'c']);
    });

    test('空列表测试', () {
      List<String> original = [];

      try {
        List<String> result = CollectUtils.changeSeq('a', original);
        fail("应该抛出 argumentException");
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect(e.toString(), contains("empty"));
      }
    });

    test('start 不在列表内', () {
      List<String> original = ['a', 'b', 'c', 'd'];

      try {
        List<String> result = CollectUtils.changeSeq('e', original);
        fail("应该抛出 argumentException");
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect(e.toString(), contains("not in"));
      }
    });
  });
}
