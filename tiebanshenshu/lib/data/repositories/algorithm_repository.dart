import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/data/models/algorithm_summary.dart';

abstract class AlgorithmRepository {
  Future<List<AlgorithmSummary>> getAlgorithmSummaries();
  Future<AlgorithmConfig> getAlgorithmById(String id);
  Future<void> saveAlgorithm(AlgorithmConfig config);
  Future<void> deleteAlgorithm(String id);
}
