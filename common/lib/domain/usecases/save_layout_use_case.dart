import 'package:common/repositories/eight_chars_info_repository.dart';

class SaveLayoutParams {
  final List<String> benMingRowOrder;
  final List<String> liuYunRowOrder;
  final List<String> benMingPillarOrder;
  final List<String> liuYunPillarOrder;

  SaveLayoutParams({
    required this.benMingRowOrder,
    required this.liuYunRowOrder,
    required this.benMingPillarOrder,
    required this.liuYunPillarOrder,
  });
}

class SaveLayoutUseCase {
  final EightCharsInfoRepository _repository;

  SaveLayoutUseCase(this._repository);

  Future<void> call(SaveLayoutParams params) async {
    await _repository.saveBenMingRowOrder(params.benMingRowOrder);
    await _repository.saveLiuYunRowOrder(params.liuYunRowOrder);
    await _repository.saveBenMingPillarOrder(params.benMingPillarOrder);
    await _repository.saveLiuYunPillarOrder(params.liuYunPillarOrder);
  }
}
