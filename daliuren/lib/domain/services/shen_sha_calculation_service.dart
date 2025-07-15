import 'package:common/enums.dart';
import '../entities/shen_sha_entity.dart';

/// 大六壬神煞计算服务接口
abstract class ShenShaCalculationService {
  /// 计算所有神煞的位置
  /// 
  /// [yearJiaZi] 年干支
  /// [monthJiaZi] 月干支  
  /// [dayJiaZi] 日干支
  /// [hourJiaZi] 时干支
  /// 
  /// 返回所有神煞及其位置的映射
  Future<Map<DiZhi, List<ShenShaResult>>> calculateAllShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  });

  /// 计算天干神煞
  Future<List<ShenShaResult>> calculateTianGanShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  });

  /// 计算年支神煞
  Future<List<ShenShaResult>> calculateYearShenSha({
    required JiaZi yearJiaZi,
  });

  /// 计算月支神煞
  Future<List<ShenShaResult>> calculateMonthShenSha({
    required JiaZi monthJiaZi,
  });

  /// 计算地支神煞
  Future<List<ShenShaResult>> calculateDiZhiShenSha({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  });

  /// 计算季煞
  Future<List<ShenShaResult>> calculateJiShenSha({
    required JiaZi monthJiaZi,
  });

  /// 计算旬煞
  Future<List<ShenShaResult>> calculateXunShenSha({
    required JiaZi dayJiaZi,
  });

  /// 根据神煞名称查找神煞
  Future<ShenShaEntity?> findShenShaByName(String name);

  /// 获取指定位置的所有神煞
  Future<List<ShenShaResult>> getShenShaAtLocation(DiZhi location, {
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi hourJiaZi,
  });
}

/// 神煞数据加载服务接口
abstract class ShenShaDataService {
  /// 加载天干神煞数据
  Future<List<TianGanShenShaEntity>> loadTianGanShenSha();

  /// 加载年支神煞数据
  Future<List<YearShenShaEntity>> loadYearShenSha();

  /// 加载月支神煞数据
  Future<List<MonthShenShaEntity>> loadMonthShenSha();

  /// 加载地支神煞数据
  Future<List<DiZhiShenShaEntity>> loadDiZhiShenSha();

  /// 加载季煞数据
  Future<List<JiShenShaEntity>> loadJiShenSha();

  /// 加载旬煞数据
  Future<List<XunShenShaEntity>> loadXunShenSha();

  /// 加载所有神煞数据
  Future<List<ShenShaEntity>> loadAllShenSha();
}