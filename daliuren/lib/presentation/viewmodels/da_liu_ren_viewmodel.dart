import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:daliuren/domain/usecases/base_usecase.dart';
import 'package:daliuren/domain/usecases/calculate_divination_usecase.dart';
import 'package:daliuren/domain/usecases/load_divination_data_usecase.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/presentation/viewmodels/base_viewmodel.dart';

class DaLiuRenViewModel extends BaseViewModel {
  final CalculateDivinationUseCase _calculateDivinationUseCase;
  final LoadDivinationDataUseCase _loadDivinationDataUseCase;

  DaLiuRenViewModel({
    required CalculateDivinationUseCase calculateDivinationUseCase,
    required LoadDivinationDataUseCase loadDivinationDataUseCase,
  })  : _calculateDivinationUseCase = calculateDivinationUseCase,
        _loadDivinationDataUseCase = loadDivinationDataUseCase;

  // Data properties
  DateTime _selectedDateTime = DateTime.now();
  String? _question;
  DaLiuRenKePan? _currentDivination;

  // UI State properties
  JiaZi? _yearJiaZi;
  JiaZi? _monthJiaZi;
  JiaZi? _dayJiaZi;
  JiaZi? _timeJiaZi;
  DiZhi? _dunGanZhi;
  int? _juNumber;
  bool _isDataLoaded = false;

  // Getters
  DateTime get selectedDateTime => _selectedDateTime;
  String? get question => _question;
  DaLiuRenKePan? get currentDivination => _currentDivination;
  JiaZi? get yearJiaZi => _yearJiaZi;
  JiaZi? get monthJiaZi => _monthJiaZi;
  JiaZi? get dayJiaZi => _dayJiaZi;
  JiaZi? get timeJiaZi => _timeJiaZi;
  DiZhi? get dunGanZhi => _dunGanZhi;
  int? get juNumber => _juNumber;
  bool get isDataLoaded => _isDataLoaded;

  // Initialize data
  Future<void> initializeData() async {
    if (_isDataLoaded) return;

    logger.d('🔵 [ViewModel] initializeData() called');
    setLoading();
    try {
      logger.d('🔵 [ViewModel] Calling LoadDivinationDataUseCase...');
      await _loadDivinationDataUseCase.call(NoParams());
      _isDataLoaded = true;
      logger.d('🔵 [ViewModel] Data loaded successfully');
      setSuccess();
    } catch (e) {
      logger.e('🔴 [ViewModel] Error loading data: $e');
      setError(e is DivinationFailure ? e.message : e.toString());
    }
  }

  // Update selected date/time
  void updateDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    notifyListeners();
    _calculateDivination();
  }

  // Update question
  void updateQuestion(String? question) {
    _question = question;
    notifyListeners();
  }

  // Calculate divination
  Future<void> _calculateDivination() async {
    if (!_isDataLoaded) {
      await initializeData();
    }

    logger.d(
        '🔵 [ViewModel] _calculateDivination() called for ${_selectedDateTime}');
    setLoading();
    try {
      final params = DateTimeParams(_selectedDateTime, question: _question);
      logger.d('🔵 [ViewModel] Calling CalculateDivinationUseCase...');
      final divination = await _calculateDivinationUseCase.call(params);
      _currentDivination = divination;
      logger.d(
          '🔵 [ViewModel] Calculation successful: ${divination.dayJiaZi.name}日');
      _updateDivinationProperties();
      setSuccess();
    } catch (e) {
      logger.e('🔴 [ViewModel] Calculation error: $e');
      setError(e is DivinationFailure ? e.message : e.toString());
    }
  }

  void _updateDivinationProperties() {
    if (_currentDivination != null) {
      _yearJiaZi = _currentDivination!.yearJiaZi;
      _monthJiaZi = _currentDivination!.monthJiaZi;
      _dayJiaZi = _currentDivination!.dayJiaZi;
      _timeJiaZi = _currentDivination!.timeJiaZi;
      // Add other property mappings as needed
    }
  }

  // Trigger shake animation
  void triggerShakeAnimation() {
    // This will be handled by UI widgets with GlobalKey
    notifyListeners();
  }

  // Recalculate with current parameters
  Future<void> recalculate() async {
    await _calculateDivination();
  }

  // Reset to current time
  void resetToNow() {
    updateDateTime(DateTime.now());
  }
}
