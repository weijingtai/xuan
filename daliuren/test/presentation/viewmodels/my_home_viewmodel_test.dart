import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/core/usecase/usecase.dart'; // For NoParams
import 'package:daliuren/domain/entities/liuren_pan.dart';
import 'package:daliuren/domain/entities/yuding_entry.dart';
import 'package:daliuren/domain/entities/pan_input.dart';
import 'package:daliuren/domain/usecases/initialize_database_usecase.dart';
import 'package:daliuren/domain/usecases/calculate_liuren_pan_usecase.dart';
import 'package:daliuren/domain/usecases/get_yuding_entry_usecase.dart';
import 'package:daliuren/presentation/viewmodels/my_home_viewmodel.dart';

// Generate mocks for UseCases
@GenerateMocks([
  InitializeDatabaseUseCase,
  CalculateLiuRenPanUseCase,
  GetYuDingEntryUseCase,
])
import 'my_home_viewmodel_test.mocks.dart'; // Generated file

void main() {
  late MockInitializeDatabaseUseCase mockInitializeDatabaseUseCase;
  late MockCalculateLiuRenPanUseCase mockCalculateLiuRenPanUseCase;
  late MockGetYuDingEntryUseCase mockGetYuDingEntryUseCase;
  late MyHomePageViewModel viewModel;

  // Sample Pan and YuDingEntry for testing
  final tPanInputTime = PanInput.byTime(dateTime: DateTime.now());
  final tLiuRenPan = LiuRenPan(
      panDateTime: DateTime.now(), dayJiaZiName: "甲子", dayGanZhi: "甲子", timeGanZhi: "甲子",
      shiChenZhiName: "子", yueJiangName: "登明", guiRenType: "阳贵", heavenPlate: {}, earthPlate: {},
      fourClasses: [], threeChuans: [], nineZongMen: domain_enums.NineZongMen.UNKNOWN, // Assuming domain_enums alias
      keTiComplement: ["Test Pan"]
  );
  final tYuDingEntry = YuDingEntry(title: "Test Title", 原文: [], 課義: "", 解曰: "", 斷曰: "", 杂占: {}, 经典: {});


  setUp(() {
    mockInitializeDatabaseUseCase = MockInitializeDatabaseUseCase();
    mockCalculateLiuRenPanUseCase = MockCalculateLiuRenPanUseCase();
    mockGetYuDingEntryUseCase = MockGetYuDingEntryUseCase();

    // Default success for DB initialization for most tests
    when(mockInitializeDatabaseUseCase.call(any))
        .thenAnswer((_) async => const Right(null));

    viewModel = MyHomePageViewModel(
      initializeDatabaseUseCase: mockInitializeDatabaseUseCase,
      calculateLiuRenPanUseCase: mockCalculateLiuRenPanUseCase,
      getYuDingEntryUseCase: mockGetYuDingEntryUseCase,
    );
  });

  // Helper for domain_enums.NineZongMen.UNKNOWN
  // This is needed because the original LiuRenPan has NineZongMen enum.
  // To avoid importing it everywhere or if there's an alias issue in test setup:
  const domain_enums_NineZongMen_UNKNOWN = null; // Adjust if actual enum is directly usable. For mock, this is fine.


  test('initial state should be loading and then db initialized', () async {
    // Arrange: ViewModel is created in setUp, _initialize is called.
    // Act: Wait for initialization to complete if it's async (it is)
    await untilCalled(mockInitializeDatabaseUseCase.call(any)); // Ensure it's called

    // Assert
    // Initial state before _initialize completes might be isInitializing=true
    // After _initialize, if successful:
    expect(viewModel.state.isInitializing, false);
    expect(viewModel.state.isDbInitialized, true);
    expect(viewModel.state.error, null);
  });

  test('getPanByTime should update state correctly on success', () async {
    // Arrange
    when(mockCalculateLiuRenPanUseCase.call(any))
        .thenAnswer((_) async => Right(tLiuRenPan));
    when(mockGetYuDingEntryUseCase.call(any)) // Assuming YuDing is fetched after Pan
        .thenAnswer((_) async => Right(tYuDingEntry));

    // Act
    await viewModel.getPanByTime(tPanInputTime.dateTime!);

    // Assert
    expect(viewModel.state.isLoadingPan, false);
    expect(viewModel.state.liuRenPan, tLiuRenPan);
    expect(viewModel.state.yuDingEntry, tYuDingEntry); // Check if YuDing was also fetched
    expect(viewModel.state.error, null);
    verify(mockCalculateLiuRenPanUseCase.call(any)); // any PanInput for byTime
    verify(mockGetYuDingEntryUseCase.call(any)); // Check params if specific
  });

  test('getPanByTime should update state with error on pan calculation failure', () async {
    // Arrange
    final tFailure = GenericFailure("Pan calculation failed");
    when(mockCalculateLiuRenPanUseCase.call(any))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    await viewModel.getPanByTime(tPanInputTime.dateTime!);

    // Assert
    expect(viewModel.state.isLoadingPan, false);
    expect(viewModel.state.liuRenPan, null);
    expect(viewModel.state.error, tFailure);
    verify(mockCalculateLiuRenPanUseCase.call(any));
    verifyNever(mockGetYuDingEntryUseCase.call(any)); // Should not be called if pan fails
  });

  test('clearPan should reset pan and yuding entry in state', () {
    // Arrange: Set some initial pan data
    when(mockCalculateLiuRenPanUseCase.call(any))
        .thenAnswer((_) async => Right(tLiuRenPan));
    when(mockGetYuDingEntryUseCase.call(any))
        .thenAnswer((_) async => Right(tYuDingEntry));

    // Populate state first
    viewModel.getPanByTime(tPanInputTime.dateTime!).then((_) {
       // Act
      viewModel.clearPan();

      // Assert
      expect(viewModel.state.liuRenPan, null);
      expect(viewModel.state.yuDingEntry, null);
      expect(viewModel.state.isLoadingPan, false);
      expect(viewModel.state.isLoadingYuDing, false);
      expect(viewModel.state.error, null); // Assuming clearPan also clears errors
    });
  });
}

// Helper for domain_enums.NineZongMen if direct import is problematic in test setup
// This is a workaround if `domain_enums.NineZongMen.UNKNOWN` is not directly accessible
// or to avoid complex imports in test files.
class domain_enums {
  enum NineZongMen { UNKNOWN }
}
