import 'package:common/enums.dart';

import 'six_qin_correct_ke.dart';
import 'six_qin_correct_ke_strategy.dart';

class SixQinCorrectKeUsecase {
  final SixQinCorrectKeStrategy _strategy;

  SixQinCorrectKeUsecase(this._strategy);

  SixQinCorrectKeResult execute({
    required Enum8Gua topGua,
    required Enum8Gua bottomGua,
    required int originalGuaNum,
    required int totalGuaNum,
    required int ke,
  }) {
    final params = SixQinCorrectKeParams(
      topGua: topGua,
      bottomGua: bottomGua,
      originalGuaNum: originalGuaNum,
      totalGuaNum: totalGuaNum,
      ke: ke,
    );
    return _strategy.execute(params);
  }
}