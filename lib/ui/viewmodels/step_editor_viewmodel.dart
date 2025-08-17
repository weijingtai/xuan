import 'package:flutter/foundation.dart';
import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package.collection/collection.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';
import 'package:tiebanshenshu/data/repositories/atomic_operation_repository.dart';

class StepEditorViewModel extends ChangeNotifier {
  final AtomicOperationRepository _atomicOperationRepository;
  final List<ExecutionStep> _precedingSteps;
  final ExecutionStep? _editingStep;

  StepEditorViewModel({
    required AtomicOperationRepository atomicOperationRepository,
    List<ExecutionStep> precedingSteps = const [],
    ExecutionStep? editingStep,
  })  : _atomicOperationRepository = atomicOperationRepository,
        _precedingSteps = precedingSteps,
        _editingStep = editingStep {
    // Initialize state
    _initialize();
  }

  // --- State ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<AtomicOperation> _availableAtoms = [];
  List<AtomicOperation> get availableAtoms => _availableAtoms;

  AtomicOperation? _selectedAtom;
  AtomicOperation? get selectedAtom => _selectedAtom;

  List<String> _availableInputSources = [];
  List<String> get availableInputSources => _availableInputSources;

  // --- Form State ---
  late String _stepName;
  String get stepName => _stepName;

  late String _stepDescription;
  String get stepDescription => _stepDescription;

  late Map<String, String> _inputMapping;
  Map<String, String> get inputMapping => _inputMapping;

  late Map<String, String> _outputMapping;
  Map<String, String> get outputMapping => _outputMapping;

  late Map<String, dynamic> _configMapping;
  Map<String, dynamic> get configMapping => _configMapping;

  void _initialize() {
    _loadAvailableAtoms();
    _computeAvailableInputSources();

    if (_editingStep != null) {
      // Editing an existing step
      _stepName = _editingStep!.name;
      _stepDescription = _editingStep!.description;
      _inputMapping = Map.from(_editingStep!.inputs);
      _outputMapping = Map.from(_editingStep!.outputs);
      _configMapping = Map.from(_editingStep!.config);
      // Find and set the selected atom
      selectAtomById(_editingStep!.operationId);
    } else {
      // Creating a new step
      _stepName = "新步骤";
      _stepDescription = "";
      _inputMapping = {};
      _outputMapping = {};
      _configMapping = {};
    }
  }

  Future<void> _loadAvailableAtoms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableAtoms = await _atomicOperationRepository.getAvailableAtoms();
    } catch (e) {
      _error = "Failed to load atoms: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _computeAvailableInputSources() {
    final sources = <String>['input.birthInfo']; // Default global input
    for (final step in _precedingSteps) {
      for (final outputKey in step.outputs.values) {
        sources.add('intermediate.$outputKey');
      }
    }
    _availableInputSources = sources;
  }

  Future<void> selectAtomById(String atomId) async {
    _selectedAtom = await _atomicOperationRepository.getAtomById(atomId);
    if (_selectedAtom != null) {
      // Reset mappings when atom changes, pre-filling with defaults
      _inputMapping = {};
      _outputMapping = {};
      _configMapping = {};

      _selectedAtom!.configParameters.forEach((key, paramDef) {
        if (paramDef.defaultValue != null) {
          _configMapping[key] = paramDef.defaultValue;
        }
      });
    }
    notifyListeners();
  }

  void updateStepName(String name) {
    _stepName = name;
    notifyListeners();
  }

  void updateStepDescription(String description) {
    _stepDescription = description;
    notifyListeners();
  }

  void updateInputMapping(String paramName, String? source) {
    if (source != null) {
      _inputMapping[paramName] = source;
    } else {
      _inputMapping.remove(paramName);
    }
    notifyListeners();
  }

  void updateOutputMapping(String paramName, String targetName) {
    _outputMapping[paramName] = targetName;
    notifyListeners();
  }

  void updateConfigMapping(String paramName, dynamic value) {
    _configMapping[paramName] = value;
    notifyListeners();
  }

  ExecutionStep? buildStep() {
    if (_selectedAtom == null) {
      _error = "Please select an operation first.";
      notifyListeners();
      return null;
    }

    return ExecutionStep(
      id: _editingStep?.id ?? 'new_step_${DateTime.now().millisecondsSinceEpoch}',
      name: _stepName,
      description: _stepDescription,
      operationId: _selectedAtom!.id,
      config: _configMapping,
      inputs: _inputMapping,
      outputs: _outputMapping,
    );
  }
}
