import 'package:common/enums.dart';
import 'package:tiebanshenshu/usecase/six_qin_correct_ke/six_qin_correct_ke_strategy.dart';

import 'six_qin_correct_ke_usecase.dart';

void main() {
  final strategy = SixQinCorrectKeStrategy();
  final usecase = SixQinCorrectKeUsecase(strategy);

  final result = usecase.execute(
    topGua: Enum8Gua.Qian,
    bottomGua: Enum8Gua.Kun,
    originalGuaNum: 1234,
    totalGuaNum: 5678,
    ke: 1,
  );

  print('Algorithm: ${result.algorithmName}');
  print('Description: ${result.algorithmDescription}');
  print('TiaoWen List: ${result.tiaoWen.map((e) => e.id).toList()}');
}
