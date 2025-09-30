import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/domain/usecases/base_usecase.dart';

class LoadDivinationDataUseCase extends UseCase<void, NoParams> {
  final DaLiuRenRepository repository;

  LoadDivinationDataUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    try {
      await repository.loadDivinationData();
    } catch (e) {
      throw DivinationFailure('Failed to load divination data: $e');
    }
  }
}
