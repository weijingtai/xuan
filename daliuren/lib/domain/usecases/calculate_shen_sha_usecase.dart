import 'package:common/enums.dart';
import '../entities/shen_sha_entity.dart';
import '../services/shen_sha_calculation_service.dart';

/// 计算神煞UseCase的参数
class CalculateShenShaParams {
  final JiaZi yearJiaZi;
  final JiaZi monthJiaZi;
  final JiaZi dayJiaZi;
  final JiaZi hourJiaZi;

  const CalculateShenShaParams({
    required this.yearJiaZi,
    required this.monthJiaZi,
    required this.dayJiaZi,
    required this.hourJiaZi,
  });
}

/// 计算神煞UseCase
class CalculateShenShaUseCase {
  final ShenShaCalculationService _calculationService;

  CalculateShenShaUseCase(this._calculationService);

  Future<Map<DiZhi, List<ShenShaResult>>> call(CalculateShenShaParams params) async {
    try {
      return await _calculationService.calculateAllShenSha(
        yearJiaZi: params.yearJiaZi,
        monthJiaZi: params.monthJiaZi,
        dayJiaZi: params.dayJiaZi,
        hourJiaZi: params.hourJiaZi,
      );
    } catch (e) {
      throw Exception('Failed to calculate 神煞: $e');
    }
  }
}

/// 获取指定位置神煞UseCase的参数
class GetShenShaAtLocationParams {
  final DiZhi location;
  final JiaZi yearJiaZi;
  final JiaZi monthJiaZi;
  final JiaZi dayJiaZi;
  final JiaZi hourJiaZi;

  const GetShenShaAtLocationParams({
    required this.location,
    required this.yearJiaZi,
    required this.monthJiaZi,
    required this.dayJiaZi,
    required this.hourJiaZi,
  });
}

/// 获取指定位置神煞UseCase
class GetShenShaAtLocationUseCase {
  final ShenShaCalculationService _calculationService;

  GetShenShaAtLocationUseCase(this._calculationService);

  Future<Map<DiZhi, List<ShenShaResult>>> call(GetShenShaAtLocationParams params) async {
    try {
      // 获取所有神煞的位置映射
      final allShenSha = await _calculationService.calculateAllShenSha(
        yearJiaZi: params.yearJiaZi,
        monthJiaZi: params.monthJiaZi,
        dayJiaZi: params.dayJiaZi,
        hourJiaZi: params.hourJiaZi,
      );
      
      // 筛选出指定位置的神煞
      final result = <DiZhi, List<ShenShaResult>>{};
      if (allShenSha.containsKey(params.location)) {
        result[params.location] = allShenSha[params.location]!;
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to get 神煞 at location: $e');
    }
  }
}

/// 查找神煞UseCase
class FindShenShaByNameUseCase {
  final ShenShaCalculationService _calculationService;

  FindShenShaByNameUseCase(this._calculationService);

  Future<ShenShaEntity?> call(String name) async {
    try {
      return await _calculationService.findShenShaByName(name);
    } catch (e) {
      throw Exception('Failed to find 神煞 by name: $e');
    }
  }
}