// lib/presentation/viewmodels/my_home_viewmodel.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:fpdart/fpdart.dart'; // For Either type
import 'package:daliuren/core/errors/failures.dart'; // For Failure type
import 'package:daliuren/domain/entities/liuren_pan.dart'; // Domain entities
import 'package:daliuren/domain/entities/yuding_entry.dart'; // Domain entities
import 'package:daliuren/domain/entities/pan_input.dart';   // Domain entities
import 'package:daliuren/domain/usecases/calculate_liuren_pan_usecase.dart'; // Use cases
import 'package:daliuren/domain/usecases/get_yuding_entry_usecase.dart';     // Use cases
import 'package:daliuren/domain/usecases/initialize_database_usecase.dart'; // Use cases
import 'package:daliuren/core/usecase/usecase.dart'; // For NoParams

/// Represents the state of the MyHomePage.
/// This class is immutable and used by [MyHomePageViewModel] to expose UI state.
class MyHomePageState {
  /// True if the database is currently being initialized.
  final bool isInitializing;
  /// True if a Liu Ren Pan is currently being calculated or fetched.
  final bool isLoadingPan;
  /// True if a Yu Ding Entry is currently being fetched.
  final bool isLoadingYuDing;
  /// The current Liu Ren Pan data, if available.
  final LiuRenPan? liuRenPan;
  /// The current Yu Ding Entry data, if available.
  final YuDingEntry? yuDingEntry;
  /// Holds any error that occurred during operations.
  final Failure? error;
  /// True if the database has been successfully initialized.
  final bool isDbInitialized;

  MyHomePageState({
    this.isInitializing = false,
    this.isLoadingPan = false,
    this.isLoadingYuDing = false,
    this.liuRenPan,
    this.yuDingEntry,
    this.error,
    this.isDbInitialized = false,
  });

  /// Creates a copy of the current state with updated values.
  /// Allows for controlled state mutation by the ViewModel.
  MyHomePageState copyWith({
    bool? isInitializing,
    bool? isLoadingPan,
    bool? isLoadingYuDing,
    LiuRenPan? liuRenPan,
    bool clearLiuRenPan = false, // If true, liuRenPan will be set to null
    YuDingEntry? yuDingEntry,
    bool clearYuDingEntry = false, // If true, yuDingEntry will be set to null
    Failure? error,
    bool clearError = false, // If true, error will be set to null
    bool? isDbInitialized,
  }) {
    return MyHomePageState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoadingPan: isLoadingPan ?? this.isLoadingPan,
      isLoadingYuDing: isLoadingYuDing ?? this.isLoadingYuDing,
      liuRenPan: clearLiuRenPan ? null : liuRenPan ?? this.liuRenPan,
      yuDingEntry: clearYuDingEntry ? null : yuDingEntry ?? this.yuDingEntry,
      error: clearError ? null : error ?? this.error,
      isDbInitialized: isDbInitialized ?? this.isDbInitialized,
    );
  }
}

/// ViewModel for MyHomePage.
/// It manages the state ([MyHomePageState]) and orchestrates actions by calling use cases.
/// Uses [ChangeNotifier] to notify listeners (typically the UI) of state changes.
class MyHomePageViewModel with ChangeNotifier {
  final CalculateLiuRenPanUseCase _calculateLiuRenPanUseCase;
  final GetYuDingEntryUseCase _getYuDingEntryUseCase;
  final InitializeDatabaseUseCase _initializeDatabaseUseCase;

  /// Current state of the ViewModel.
  late MyHomePageState _state;
  MyHomePageState get state => _state;

  MyHomePageViewModel({
    required CalculateLiuRenPanUseCase calculateLiuRenPanUseCase,
    required GetYuDingEntryUseCase getYuDingEntryUseCase,
    required InitializeDatabaseUseCase initializeDatabaseUseCase,
  }) : _calculateLiuRenPanUseCase = calculateLiuRenPanUseCase,
       _getYuDingEntryUseCase = getYuDingEntryUseCase,
       _initializeDatabaseUseCase = initializeDatabaseUseCase {
    // Set initial state to indicate database initialization is in progress.
    _state = MyHomePageState(isInitializing: true);
    notifyListeners(); // Notify UI about the initial loading state.
    _initialize(); // Trigger asynchronous database initialization.
  }

  /// Initializes the database by calling the [InitializeDatabaseUseCase].
  /// Updates the state based on the success or failure of the initialization.
  Future<void> _initialize() async {
    final result = await _initializeDatabaseUseCase.call(NoParams());
    result.fold(
      (failure) {
        _state = _state.copyWith(isInitializing: false, error: failure, isDbInitialized: false);
      },
      (_) {
        _state = _state.copyWith(isInitializing: false, isDbInitialized: true);
      },
    );
    notifyListeners(); // Notify UI of the outcome.
  }

  /// Calculates or retrieves a Liu Ren Pan based on the provided [dateTime].
  /// Also fetches the corresponding Yu Ding entry upon successful pan retrieval.
  Future<void> getPanByTime(DateTime dateTime) async {
    // Set loading state and clear previous pan/error data.
    _state = _state.copyWith(isLoadingPan: true, clearLiuRenPan: true, clearYuDingEntry: true, clearError: true);
    notifyListeners();

    final panInput = PanInput.byTime(dateTime: dateTime);
    final result = await _calculateLiuRenPanUseCase.call(panInput);

    // Process the result of the pan calculation.
    await result.fold(
      (failure) async { // Left side: Failure
        _state = _state.copyWith(isLoadingPan: false, error: failure);
      },
      (pan) async { // Right side: Success (LiuRenPan)
        _state = _state.copyWith(isLoadingPan: false, liuRenPan: pan);
        // If pan calculation is successful and pan data is available,
        // attempt to fetch the corresponding Yu Ding entry.
        if (pan.fourClasses.isNotEmpty) {
          final String dayJiaZiName = pan.dayJiaZiName;
          // 干上神 (GanShangShen) is the sky DiZhi of the first Ke (Class).
          final String ganShangDiZhiName = pan.fourClasses[0].sky.name;
          await _fetchYuDingEntry(dayJiaZiName, ganShangDiZhiName);
        }
      },
    );
    notifyListeners(); // Notify UI of the final state after all operations.
  }

  /// Calculates or retrieves a Liu Ren Pan based on manually provided GanZhi parameters.
  /// Also fetches the corresponding Yu Ding entry upon successful pan retrieval.
  Future<void> getPanByGanZhi({
    String? yearJiaZi,
    String? monthJiaZi,
    required String dayJiaZi,
    String? timeJiaZi,
    String? yinYangDun, // Expected as String (e.g., "YANG", "YIN") from UI
    int? juNumber,
  }) async {
    _state = _state.copyWith(isLoadingPan: true, clearLiuRenPan: true, clearYuDingEntry: true, clearError: true);
    notifyListeners();

    final panInput = PanInput.byGanZhi(
      yearJiaZi: yearJiaZi,
      monthJiaZi: monthJiaZi,
      dayJiaZi: dayJiaZi,
      timeJiaZi: timeJiaZi,
      yinYangDun: yinYangDun,
      juNumber: juNumber,
    );
    final result = await _calculateLiuRenPanUseCase.call(panInput);

    await result.fold(
      (failure) async {
        _state = _state.copyWith(isLoadingPan: false, error: failure);
      },
      (pan) async {
        _state = _state.copyWith(isLoadingPan: false, liuRenPan: pan);
        // Similar to getPanByTime, fetch YuDingEntry if pan is successful.
        if (pan.fourClasses.isNotEmpty) {
          final String dayJiaZiName = pan.dayJiaZiName;
          final String ganShangDiZhiName = pan.fourClasses[0].sky.name;
          await _fetchYuDingEntry(dayJiaZiName, ganShangDiZhiName);
        }
      },
    );
    notifyListeners();
  }

  /// Fetches the Yu Ding interpretation entry based on [dayJiaZi] and [ganShangDiZhi].
  /// This is an internal method typically called after a pan is successfully generated.
  Future<void> _fetchYuDingEntry(String dayJiaZi, String ganShangDiZhi) async {
    // Set loading state specifically for Yu Ding entry, keep existing error state for pan if any.
    _state = _state.copyWith(isLoadingYuDing: true, clearError: true);
    notifyListeners(); // Notify UI that YuDing fetching has started.

    final params = GetYuDingEntryUseCaseParams(dayJiaZi: dayJiaZi, ganShangDiZhi: ganShangDiZhi);
    final result = await _getYuDingEntryUseCase.call(params);

    result.fold(
      (failure) {
        // If YuDing fetching fails, update error state but keep the successfully loaded LiuRenPan.
        _state = _state.copyWith(isLoadingYuDing: false, error: failure);
      },
      (entry) {
        _state = _state.copyWith(isLoadingYuDing: false, yuDingEntry: entry);
      },
    );
    // The final notifyListeners() is typically called by the public methods (getPanByTime/getPanByGanZhi)
    // after all operations (pan + yuding) are complete. If this method were public or needed
    // immediate independent UI updates, a notifyListeners() call would be here.
  }

  /// Clears the current pan and Yu Ding entry data from the state.
  /// Resets loading flags and errors.
  void clearPan() {
    _state = _state.copyWith(
      isLoadingPan: false,
      isLoadingYuDing: false,
      clearLiuRenPan: true,
      clearYuDingEntry: true,
      clearError: true // Clears any existing errors.
    );
    notifyListeners();
  }
}
