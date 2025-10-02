import 'fei_xian.dart';

void main() {
  // 示例：午宫（阳宫）行限10年
  final feiXian = FeiXian(
    currentAge: 1,
    mainPalace: "午",
    yinYang: "阳",
  );

  final sequence = feiXian.generateSequence(10);

  print('飞限序列：');
  for (var info in sequence) {
    print(info.toString());
  }
}
