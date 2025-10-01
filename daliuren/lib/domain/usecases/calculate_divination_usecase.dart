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
      print('🟢 [UseCase] CalculateDivinationUseCase.call() - Calling Repository...');
      final result = await repository.calculateDivination(
        params.dateTime,
        question: params.question,
      );
      print('🟢 [UseCase] Repository returned result successfully');
      return result;
    } catch (e) {
      print('🔴 [UseCase] Error in CalculateDivinationUseCase: $e');
      throw DivinationFailure('Failed to calculate divination: $e');
    }
  }
}
