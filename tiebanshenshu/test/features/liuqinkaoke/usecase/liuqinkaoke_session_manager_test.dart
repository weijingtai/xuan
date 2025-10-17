import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/repository/liuqinkaoke_session_repository.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';
import 'package:tiebanshenshu/service/strategy/tiao_wen_list_calculation.dart';
import 'package:common/models/eight_chars.dart';

// Mocks
class MockSessionRepository extends InMemoryLiuQinKaoKeSessionRepository {}

class MockTiaoWenRepository implements TiaoWenRepository {
  Map<int, String> mockContent = {};
  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) async {
    final result = <int, String>{};
    for (var number in numbers) {
      if (mockContent.containsKey(number)) {
        result[number] = mockContent[number]!;
      }
    }
    return result;
  }

  // Unimplemented methods
  @override
  Future<TiaoWenDataModel?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> listAll() => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) => throw UnimplementedError();
  @override
  Future<int> getCount() => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) => throw UnimplementedError();
  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) => throw UnimplementedError();
  @override
  Future<String?> getTiaoWenContentByNumber(int number) =>
      throw UnimplementedError();
}

class MockCalculationStrategy implements LiuQinKaoKeCalculationStrategy {
  @override
  List<LiuQinKaoKeCandidate> calculateCandidates({
    required EightChars eightChars,
    required Gender gender,
    required bool isYangNianGan,
  }) {
    // Return a fixed list for predictable testing
    return List.generate(14, (index) {
      final origin = index < 7 ? OriginKind.innate : OriginKind.acquired;
      final changeLine = index % 7;
      return LiuQinKaoKeCandidate(
        rawNumber: 1000 + index,
        originKind: origin,
        changeLineIndex: changeLine,
        baseGua: Enum64Gua.qian_wei_tian,
        huGua: Enum64Gua.tian_feng_gou,
        derivedGua: Enum64Gua.qian_wei_tian,
      );
    });
  }
}

void main() {
  late LiuQinKaoKeSessionManager sessionManager;
  late MockSessionRepository mockSessionRepo;
  late MockCalculationStrategy mockStrategy;
  late MockTiaoWenRepository mockTiaoWenRepo;
  late TiaoWenListCalculationConfig config;

  setUp(() {
    mockSessionRepo = MockSessionRepository();
    mockStrategy = MockCalculationStrategy();
    mockTiaoWenRepo = MockTiaoWenRepository();
    config = TiaoWenListCalculationConfig.listAdd(
      customList: [96, 192],
      withSub: true,
    );
    sessionManager = LiuQinKaoKeSessionManager(
      mockSessionRepo,
      mockStrategy,
      mockTiaoWenRepo,
      config,
    );
  });

  test('start should create a new session and save it', () async {
    // Arrange
    mockTiaoWenRepo.mockContent = {1000: 'Test Content'};

    // Act
    final session = await sessionManager.start(gender: Gender.male);

    // Assert
    expect(session.stage, LiuQinKaoKeStage.baseNumberSelectionReady);
    expect(session.candidateSet, isNotEmpty);
    expect(session.candidateSet!.first.tiaoWenContent, 'Test Content');

    final savedSession = await mockSessionRepo.findById(session.id);
    expect(savedSession, isNotNull);
    expect(savedSession!.id, session.id);
  });

  test(
    'completeSelection should advance stage and calculate final list',
    () async {
      // Arrange
      final initialSession = await sessionManager.start(gender: Gender.male);
      final innateItem = initialSession.candidateSet!.firstWhere(
        (i) => i.candidate.originKind == OriginKind.innate,
      );
      final acquiredItem = initialSession.candidateSet!.firstWhere(
        (i) => i.candidate.originKind == OriginKind.acquired,
      );
      mockTiaoWenRepo.mockContent = {
        innateItem.candidate.number + 96: 'Derived Content',
      };

      // Act
      final finalSession = await sessionManager.completeSelection(
        sessionId: initialSession.id,
        innateItem: innateItem,
        acquiredItem: acquiredItem,
      );

      // Assert
      expect(finalSession.stage, LiuQinKaoKeStage.finalTiaoWenListReady);
      expect(finalSession.finalTiaoWenList, isNotEmpty);
      expect(
        finalSession.finalTiaoWenList!.any(
          (item) => item.content == 'Derived Content',
        ),
        isTrue,
      );

      final savedSession = await mockSessionRepo.findById(initialSession.id);
      expect(savedSession!.stage, LiuQinKaoKeStage.finalTiaoWenListReady);
    },
  );

  test('rollback should revert stage and clear selections', () async {
    // Arrange
    final initialSession = await sessionManager.start(gender: Gender.male);
    final innateItem = initialSession.candidateSet!.firstWhere(
      (i) => i.candidate.originKind == OriginKind.innate,
    );
    final acquiredItem = initialSession.candidateSet!.firstWhere(
      (i) => i.candidate.originKind == OriginKind.acquired,
    );
    final finalSession = await sessionManager.completeSelection(
      sessionId: initialSession.id,
      innateItem: innateItem,
      acquiredItem: acquiredItem,
    );

    // Act
    final rolledBackSession = await sessionManager.rollback(
      sessionId: finalSession.id,
    );

    // Assert
    expect(rolledBackSession.stage, LiuQinKaoKeStage.baseNumberSelectionReady);
    expect(rolledBackSession.selectedInnate, isNull);
    expect(rolledBackSession.selectedAcquired, isNull);
    expect(rolledBackSession.finalTiaoWenList, isNull);

    final savedSession = await mockSessionRepo.findById(initialSession.id);
    expect(savedSession!.stage, LiuQinKaoKeStage.baseNumberSelectionReady);
  });

  test(
    'resumeMostRecentSession should return the last saved session',
    () async {
      // Arrange
      final session1 = await sessionManager.start(gender: Gender.male);
      final session2 = await sessionManager.start(gender: Gender.female);

      // Act
      final resumedSession = await sessionManager.resumeMostRecentSession();

      // Assert
      expect(resumedSession, isNotNull);
      expect(resumedSession!.id, session2.id);
      expect(resumedSession.gender, Gender.female);
    },
  );
}
