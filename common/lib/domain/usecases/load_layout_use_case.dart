import 'package:common/repositories/eight_chars_info_repository.dart';

class LayoutData {
  final List<String>? benMingRowOrder;
  final List<String>? liuYunRowOrder;
  final List<String>? benMingPillarOrder;
  final List<String>? liuYunPillarOrder;

  LayoutData({
    this.benMingRowOrder,
    this.liuYunRowOrder,
    this.benMingPillarOrder,
    this.liuYunPillarOrder,
  });
}

class LoadLayoutUseCase {
  final EightCharsInfoRepository _repository;

  LoadLayoutUseCase(this._repository);

  Future<LayoutData> call() async {
    final benMingRowOrder = await _repository.loadBenMingRowOrder();
    final liuYunRowOrder = await _repository.loadLiuYunRowOrder();
    final benMingPillarOrder = await _repository.loadBenMingPillarOrder();
    final liuYunPillarOrder = await _repository.loadLiuYunPillarOrder();

    return LayoutData(
      benMingRowOrder: benMingRowOrder,
      liuYunRowOrder: liuYunRowOrder,
      benMingPillarOrder: benMingPillarOrder,
      liuYunPillarOrder: liuYunPillarOrder,
    );
  }
}
