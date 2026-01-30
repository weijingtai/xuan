import '../../enums/enum_arrange_plate_type.dart';
import '../entities/shi_jia_ju.dart';
import '../repositories/qimen_calculator_repository.dart';
import 'base_usecase.dart';

/// 计算局数用例参数
class CalculateJuParams {
  final DateTime dateTime;
  final ArrangeType arrangeType;

  const CalculateJuParams({
    required this.dateTime,
    required this.arrangeType,
  });
}

/// 计算局数用例
///
/// 负责计算奇门遁甲的局数（1-9局）
///
/// 使用示例:
/// ```dart
/// final params = CalculateJuParams(
///   dateTime: DateTime.now(),
///   arrangeType: ArrangeType.CHAI_BU,
/// );
/// final ju = await calculateJuUseCase.execute(params);
/// ```
class CalculateJuUseCase extends UseCase<ShiJiaJu, CalculateJuParams> {
  final QiMenCalculatorRepository _repository;

  CalculateJuUseCase(this._repository);

  @override
  Future<ShiJiaJu> execute(CalculateJuParams params) async {
    try {
      return await _repository.calculateJu(
        dateTime: params.dateTime,
        arrangeType: params.arrangeType,
      );
    } catch (e) {
      throw QiMenCalculationException('计算局数失败: $e');
    }
  }
}
