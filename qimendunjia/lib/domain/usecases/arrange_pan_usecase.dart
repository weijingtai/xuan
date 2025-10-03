import '../../enums/enum_arrange_plate_type.dart';
import '../entities/qimen_pan.dart';
import '../entities/shi_jia_ju.dart';
import '../repositories/qimen_calculator_repository.dart';
import 'base_usecase.dart';

/// 排盘用例参数
class ArrangePanParams {
  final ShiJiaJu ju;
  final PlateType plateType;
  final PanSettings settings;

  const ArrangePanParams({
    required this.ju,
    required this.plateType,
    required this.settings,
  });
}

/// 排盘用例
///
/// 负责根据局数进行排盘，生成完整的奇门盘
///
/// 使用示例:
/// ```dart
/// final params = ArrangePanParams(
///   ju: shiJiaJu,
///   plateType: PlateType.ZHUAN_PAN,
///   settings: PanSettings.defaultSettings(),
/// );
/// final pan = await arrangePanUseCase.execute(params);
/// ```
class ArrangePanUseCase extends UseCase<QiMenPan, ArrangePanParams> {
  final QiMenCalculatorRepository _calculatorRepository;

  ArrangePanUseCase(this._calculatorRepository);

  @override
  Future<QiMenPan> execute(ArrangePanParams params) async {
    try {
      // 排盘
      final pan = await _calculatorRepository.arrangePan(
        ju: params.ju,
        plateType: params.plateType,
        settings: params.settings,
      );

      return pan;
    } catch (e) {
      throw QiMenCalculationException('排盘失败: $e');
    }
  }
}
