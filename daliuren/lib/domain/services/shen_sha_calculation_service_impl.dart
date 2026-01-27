import 'package:common/enums.dart';
import '../../domain/services/shen_sha_calculation_service.dart';
import '../../domain/entities/shen_sha_entity.dart';
import '../../data/services/shen_sha_data_service_impl.dart';

/// 大六壬神煞计算服务实现类
class ShenShaCalculationServiceImpl implements ShenShaCalculationService {
  final ShenShaDataService _dataService;

  ShenShaCalculationServiceImpl({
    ShenShaDataService? dataService,
  }) : _dataService = dataService ?? ShenShaDataServiceImpl();

  @override
  Future<Map<DiZhi, List<ShenShaResult>>> calculateAllShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  }) async {
    final Map<DiZhi, List<ShenShaResult>> result = {};

    // 初始化所有地支位置为空列表
    for (final diZhi in DiZhi.values) {
      result[diZhi] = [];
    }

    try {
      // 计算天干神煞
      final tianGanResults = await calculateTianGanShenSha(
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      // 计算年支神煞
      final yearResults = await calculateYearShenSha(yearJiaZi: yearJiaZi);

      // 计算月支神煞
      final monthResults = await calculateMonthShenSha(monthJiaZi: monthJiaZi);

      // 计算地支神煞
      final diZhiResults = await calculateDiZhiShenSha(
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      // 计算季煞
      final jiShenShaResults = await calculateJiShenSha(monthJiaZi: monthJiaZi);

      // 计算旬煞
      final xunShenShaResults = await calculateXunShenSha(dayJiaZi: dayJiaZi);

      // 合并所有结果
      final allResults = [
        ...tianGanResults,
        ...yearResults,
        ...monthResults,
        ...diZhiResults,
        ...jiShenShaResults,
        ...xunShenShaResults,
      ];

      // 按位置分组
      for (final shenShaResult in allResults) {
        result[shenShaResult.location]!.add(shenShaResult);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to calculate all 神煞: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> calculateTianGanShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  }) async {
    final List<ShenShaResult> results = [];

    try {
      final tianGanShenShaList = await _dataService.loadTianGanShenSha();

      for (final shenSha in tianGanShenShaList) {
        // 年干神煞
        final yearLocation = shenSha.getLocationByTianGan(yearJiaZi.gan);
        if (yearLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: yearLocation,
          ));
        }

        // 月干神煞
        final monthLocation = shenSha.getLocationByTianGan(monthJiaZi.gan);
        if (monthLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: monthLocation,
          ));
        }

        // 日干神煞
        final dayLocation = shenSha.getLocationByTianGan(dayJiaZi.gan);
        if (dayLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: dayLocation,
          ));
        }

        // 时干神煞
        final hourLocation = shenSha.getLocationByTianGan(hourJiaZi.gan);
        if (hourLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: hourLocation,
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to calculate 天干神煞: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> calculateYearShenSha({
    required JiaZi yearJiaZi,
  }) async {
    final List<ShenShaResult> results = [];

    try {
      final yearShenShaList = await _dataService.loadYearShenSha();

      for (final shenSha in yearShenShaList) {
        final location = shenSha.getLocationByYearZhi(yearJiaZi.zhi);
        if (location != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: location,
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to calculate 年支神煞: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> calculateMonthShenSha({
    required JiaZi monthJiaZi,
  }) async {
    final List<ShenShaResult> results = [];

    try {
      final monthShenShaList = await _dataService.loadMonthShenSha();

      for (final shenSha in monthShenShaList) {
        final location = shenSha.getLocationByMonthZhi(monthJiaZi.zhi);
        if (location != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: location,
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to calculate 月支神煞: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> calculateDiZhiShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  }) async {
    final List<ShenShaResult> results = [];

    try {
      final diZhiShenShaList = await _dataService.loadDiZhiShenSha();

      for (final shenSha in diZhiShenShaList) {
        // 年支神煞
        final yearLocation = shenSha.getLocationByDiZhi(yearJiaZi.zhi);
        if (yearLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: yearLocation,
          ));
        }

        // 月支神煞
        final monthLocation = shenSha.getLocationByDiZhi(monthJiaZi.zhi);
        if (monthLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: monthLocation,
          ));
        }

        // 日支神煞
        final dayLocation = shenSha.getLocationByDiZhi(dayJiaZi.zhi);
        if (dayLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: dayLocation,
          ));
        }

        // 时支神煞
        final hourLocation = shenSha.getLocationByDiZhi(hourJiaZi.zhi);
        if (hourLocation != null) {
          results.add(ShenShaResult(
            shenSha: shenSha,
            location: hourLocation,
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to calculate 地支神煞: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> calculateJiShenSha({
    required JiaZi monthJiaZi,
  }) async {
    final jiShenShaList = await _dataService.loadJiShenSha();
    final results = <ShenShaResult>[];

    // 从月支获取季节
    final season = _getSeasonFromDiZhi(monthJiaZi.diZhi);
    final seasonName = season.name;

    for (final jiShenSha in jiShenShaList) {
      final location = jiShenSha.getLocationBySeason(seasonName);
      if (location != null) {
        results.add(ShenShaResult(
          shenSha: jiShenSha,
          location: location,
          // calculationBasis: '月支${monthJiaZi.diZhi.value}，季节：$seasonName',
        ));
      }
    }

    return results;
  }

  @override
  Future<List<ShenShaResult>> calculateXunShenSha({
    required JiaZi dayJiaZi,
  }) async {
    final xunShenShaList = await _dataService.loadXunShenSha();
    final results = <ShenShaResult>[];

    // 获取日干支的旬
    final xunKey = '${dayJiaZi.tianGan.value}${dayJiaZi.diZhi.value}';

    for (final xunShenSha in xunShenShaList) {
      final location = xunShenSha.getLocationByXun(xunKey);
      if (location != null) {
        results.add(ShenShaResult(
          shenSha: xunShenSha,
          location: location,
          // calculationBasis:
          // '日干支${dayJiaZi.tianGan.value}${dayJiaZi.diZhi.value}旬',
        ));
      }
    }

    return results;
  }

  @override
  Future<ShenShaEntity?> findShenShaByName(String name) async {
    try {
      final allShenSha = await _dataService.loadAllShenSha();

      for (final shenSha in allShenSha) {
        if (shenSha.name == name) {
          return shenSha;
        }
        // 检查别名
        if (shenSha.otherNameList != null &&
            shenSha.otherNameList!.contains(name)) {
          return shenSha;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to find 神煞 by name: $e');
    }
  }

  @override
  Future<List<ShenShaResult>> getShenShaAtLocation(
    DiZhi location, {
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  }) async {
    try {
      final allResults = await calculateAllShenSha(
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      return allResults[location] ?? [];
    } catch (e) {
      throw Exception('Failed to get 神煞 at location: $e');
    }
  }

  /// 从地支获取季节
  FourSeasons _getSeasonFromDiZhi(DiZhi diZhi) {
    switch (diZhi) {
      case DiZhi.YIN:
      case DiZhi.MAO:
      case DiZhi.CHEN:
        return FourSeasons.SPRING;
      case DiZhi.SI:
      case DiZhi.WU:
      case DiZhi.WEI:
        return FourSeasons.SUMMER;
      case DiZhi.SHEN:
      case DiZhi.YOU:
      case DiZhi.XU:
        return FourSeasons.AUTUMN;
      case DiZhi.HAI:
      case DiZhi.ZI:
      case DiZhi.CHOU:
        return FourSeasons.WINTER;
    }
  }
}
