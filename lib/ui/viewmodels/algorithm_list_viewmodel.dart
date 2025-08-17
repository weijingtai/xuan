import 'package:flutter/foundation.dart';
import 'package:tiebanshenshu/data/models/algorithm_summary.dart';
import 'package:tiebanshenshu/data/repositories/algorithm_repository.dart';

class AlgorithmListViewModel extends ChangeNotifier {
  final AlgorithmRepository _repository;

  AlgorithmListViewModel({required AlgorithmRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AlgorithmSummary> _algorithms = [];
  List<AlgorithmSummary> get algorithms => _algorithms;

  String? _error;
  String? get error => _error;

  Future<void> loadAlgorithms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _algorithms = await _repository.getAlgorithmSummaries();
    } catch (e) {
      _error = "Failed to load algorithms: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
