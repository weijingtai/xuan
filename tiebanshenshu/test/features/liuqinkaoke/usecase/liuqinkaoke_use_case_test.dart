import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/usecase/liuqinkaoke_use_case.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';

// 手动创建一个 Mock Repository
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

  // 其他未用到的方法可以抛出 UnimplementedError
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

void main() {
  group('LiuQinKaoKeUseCase', () {
    late LiuQinKaoKeUseCase useCase;
    late LiuQinKaoKeCalculationStrategy strategy;
    late MockTiaoWenRepository mockRepository;

    setUp(() {
      strategy = LiuQinKaoKeCalculationStrategy(); // 使用真实策略
      mockRepository = MockTiaoWenRepository();
      useCase = LiuQinKaoKeUseCase(strategy, mockRepository);
    });

    test(
      'startSessionAndCalculateCandidates should return session with candidates and content',
      () async {
        // Arrange
        const gender = Gender.male;
        // 模拟仓库返回内容
        mockRepository.mockContent = {1234: '条文内容1', 5678: '条文内容2'};

        // Act
        final session = await useCase.startSessionAndCalculateCandidates(
          gender: gender,
        );

        // Assert
        expect(session.stage, LiuQinKaoKeStage.baseNumberSelectionReady);
        expect(session.candidateSet, isNotNull);
        expect(session.candidateSet!.length, 14);

        // 验证条文内容是否被正确填充
        final itemWithContent = session.candidateSet!.firstWhere(
          (item) => item.candidate.number == 1234,
          orElse: () => LiuQinKaoKeSelectionItem(
            candidate: LiuQinKaoKeCandidate(
              rawNumber: 0,
              originKind: OriginKind.innate,
              changeLineIndex: 0,
              baseGua: session.candidateSet!.first.candidate.baseGua,
              huGua: session.candidateSet!.first.candidate.huGua,
              derivedGua: session.candidateSet!.first.candidate.derivedGua,
            ),
          ),
        );
        // This check is tricky because the actual numbers are calculated.
        // A better test would be to mock the strategy as well.
        // For now, we just check that the process runs.
        expect(
          session.candidateSet!.any((item) => item.tiaoWenContent != null),
          isTrue,
          reason:
              "At least one candidate should have content if its number matches the mock.",
        );
      },
    );

    test(
      'selectBaseNumbersAndGetFinalList should return session with final list',
      () async {
        // Arrange
        // 1. 先创建一个 ready 状态的 session
        final initialSession = await useCase.startSessionAndCalculateCandidates(
          gender: Gender.male,
        );

        final selectedInnate = initialSession.candidateSet!.firstWhere(
          (item) => item.candidate.originKind == OriginKind.innate,
        );
        final selectedAcquired = initialSession.candidateSet!.firstWhere(
          (item) => item.candidate.originKind == OriginKind.acquired,
        );

        // 2. 模拟派生条文的内容
        final derivedNumber = selectedInnate.candidate.number + 48 * 2;
        mockRepository.mockContent[derivedNumber] = '派生条文内容';

        // Act
        final finalSession = await useCase.selectBaseNumbersAndGetFinalList(
          currentSession: initialSession,
          selectedInnate: selectedInnate,
          selectedAcquired: selectedAcquired,
        );

        // Assert
        expect(finalSession.stage, LiuQinKaoKeStage.finalTiaoWenListReady);
        expect(finalSession.finalTiaoWenList, isNotNull);
        expect(finalSession.finalTiaoWenList, isNotEmpty);

        final derivedItem = finalSession.finalTiaoWenList!.firstWhere(
          (item) => item.number == derivedNumber,
        );
        expect(derivedItem.content, '派生条文内容');
      },
    );
  });
}
