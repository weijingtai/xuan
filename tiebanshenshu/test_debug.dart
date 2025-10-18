import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/constant/constants.dart' as constants;

void main() {
  // 测试乾为天
  final qian = Enum64Gua.qian_wei_tian;
  print('乾为天:');
  print('  top (上卦): ${qian.top}');
  print('  bottom (下卦): ${qian.bottom}');
  print('  top number: ${constants.houGuaNumberMapper[qian.top]}');
  print('  bottom number: ${constants.houGuaNumberMapper[qian.bottom]}');
  
  // 测试坤为地
  final kun = Enum64Gua.kun_wei_di;
  print('\n坤为地:');
  print('  top (上卦): ${kun.top}');
  print('  bottom (下卦): ${kun.bottom}');
  print('  top number: ${constants.houGuaNumberMapper[kun.top]}');
  print('  bottom number: ${constants.houGuaNumberMapper[kun.bottom]}');
}
