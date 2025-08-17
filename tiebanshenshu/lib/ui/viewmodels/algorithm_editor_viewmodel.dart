import 'package:flutter/foundation.dart';
import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';
import 'package:tiebanshenshu/data/repositories/algorithm_repository.dart';
import 'package:uuid/uuid.dart';

class AlgorithmEditorViewModel extends ChangeNotifier {
  final AlgorithmRepository _repository;
  final Uuid _uuid = Uuid();

  AlgorithmEditorViewModel({required AlgorithmRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AlgorithmConfig? _algorithm;
  AlgorithmConfig? get algorithm => _algorithm;

  String? _error;
  String? get error => _error;

  // 用来跟踪原始ID，以防名称（ID）被更改
  String? _originalId;

  Future<void> loadAlgorithm(String? algorithmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (algorithmId != null) {
        _originalId = algorithmId;
        _algorithm = await _repository.getAlgorithmById(algorithmId);
      } else {
        // 创建一个新的、空的算法配置
        _algorithm = AlgorithmConfig(
          name: '新算法',
          description: '这是一个新创建的算法',
          version: '1.0.0',
          steps: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _originalId = _algorithm!.name; // 初始时，ID和名称可以相同
      }
    } catch (e) {
      _error = "Failed to load algorithm: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String name) {
    if (_algorithm == null) return;
    _algorithm = _algorithm!.copyWith(name: name, updatedAt: DateTime.now());
    notifyListeners();
  }

  void updateDescription(String description) {
    if (_algorithm == null) return;
    _algorithm = _algorithm!.copyWith(description: description, updatedAt: DateTime.now());
    notifyListeners();
  }

  void reorderStep(int oldIndex, int newIndex) {
    if (_algorithm == null) return;
    final steps = List<ExecutionStep>.from(_algorithm!.steps);
    final item = steps.removeAt(oldIndex);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    steps.insert(newIndex, item);
    _algorithm = _algorithm!.copyWith(steps: steps, updatedAt: DateTime.now());
    notifyListeners();
  }

  void deleteStep(int index) {
    if (_algorithm == null) return;
    final steps = List<ExecutionStep>.from(_algorithm!.steps);
    steps.removeAt(index);
    _algorithm = _algorithm!.copyWith(steps: steps, updatedAt: DateTime.now());
    notifyListeners();
  }

  void addOrUpdateStep(ExecutionStep step, {int? existingIndex}) {
    if (_algorithm == null) return;
    final steps = List<ExecutionStep>.from(_algorithm!.steps);
    if (existingIndex != null) {
      // 更新现有步骤
      steps[existingIndex] = step;
    } else {
      // 添加新步骤，确保ID唯一
      final newStep = step.copyWith(id: _uuid.v4());
      steps.add(newStep);
    }
    _algorithm = _algorithm!.copyWith(steps: steps, updatedAt: DateTime.now());
    notifyListeners();
  }

  Future<bool> saveAlgorithm() async {
    if (_algorithm == null) {
      _error = "No algorithm to save.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveAlgorithm(_algorithm!);
      _originalId = _algorithm!.name;
      return true;
    } catch (e) {
      _error = "Failed to save algorithm: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
