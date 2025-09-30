import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/domain/usecases/base_usecase.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';

class CalculateDivinationUseCase
    extends UseCase<DaLiuRenKePan, DateTimeParams> {
  final DaLiuRenRepository repository;

  CalculateDivinationUseCase(this.repository);

  @override
  Future<DaLiuRenKePan> call(DateTimeParams params) async {
    try {
      final result = await repository.calculateDivination(
        params.dateTime,
        question: params.question,
      );
      return result;
    } catch (e) {
      throw DivinationFailure('Failed to calculate divination: $e');
    }
  }
}
