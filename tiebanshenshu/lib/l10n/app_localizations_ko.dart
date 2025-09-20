// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '노드 편집기 예제';

  @override
  String get saveProjectDialogTitle => '프로젝트 저장';

  @override
  String get unsavedChangesTitle => '저장되지 않은 변경사항';

  @override
  String get unsavedChangesMsg => '저장되지 않은 변경사항이 있습니다. 저장하지 않고 계속하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get proceed => '계속';

  @override
  String get failedToLoadSampleProject => '샘플 프로젝트를 로드하지 못했습니다. 인터넷 연결을 확인하세요.';

  @override
  String get searchNodesTooltip => '이름으로 노드 검색';

  @override
  String get toggleHierarchyTooltip => '계층 구조 패널 토글';

  @override
  String get toggleSnapToGridTooltip => '그리드 스냅 토글';

  @override
  String get executeGraphTooltip => '그래프 실행';

  @override
  String get touchCommandsTitle => '터치 명령:';

  @override
  String get touchTap => '- 터치: 노드 선택';

  @override
  String get touchDoubleTap => '- 더블 터치: 선택 해제';

  @override
  String get touchLongPress => '- 길게 누르기: 컨텍스트 메뉴 열기';

  @override
  String get touchDrag => '- 드래그: 연결 시작 / 노드 선택';

  @override
  String get touchPinch => '- 핀치: 확대/축소';

  @override
  String get touchAdditionalGestures => '추가 제스처:';

  @override
  String get touchTwoFingerDrag => '- 두 손가락 드래그: 패닝';

  @override
  String get mouseCommandsTitle => '마우스 명령:';

  @override
  String get mouseLeftClick => '- 왼쪽 클릭: 노드/연결 선택';

  @override
  String get mouseRightClick => '- 오른쪽 클릭: 컨텍스트 메뉴 열기';

  @override
  String get mouseScroll => '- 스크롤: 확대/축소';

  @override
  String get mouseMiddleClick => '- 가운데 클릭: 패닝';

  @override
  String get keyboardCommandsTitle => '키보드 명령:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S: 프로젝트 저장';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O: 프로젝트 열기';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N: 새 프로젝트';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C: 노드 복사';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V: 노드 붙여넣기';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X: 노드 잘라내기';
  }

  @override
  String get keyboardDelete => '- Delete | Backspace: 노드 제거';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z: 실행 취소';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y: 다시 실행';
  }

  @override
  String get searching => '검색 중...';

  @override
  String get noResults => '결과 없음';

  @override
  String get nextResult => '다음 결과';

  @override
  String get previousResult => '이전 결과';

  @override
  String resultsCount(int count) {
    return '$count개 결과';
  }

  @override
  String resultPosition(int current, int total) {
    return '$total개 중 $current번째';
  }

  @override
  String get numericValueNodeName => '숫자 값';

  @override
  String get booleanValueNodeName => '불린 값';

  @override
  String get stringValueNodeName => '문자열 값';

  @override
  String get numericListValueNodeName => '숫자 값 목록';

  @override
  String get booleanListValueNodeName => '불린 값 목록';

  @override
  String get stringListValueNodeName => '문자열 값 목록';

  @override
  String valueNodeDescription(String type) {
    return '다른 노드에서 사용할 수 있는 값을 포함합니다.';
  }

  @override
  String get completedPortName => '완료';

  @override
  String get valuePortName => '값';

  @override
  String get valueFieldName => '값';

  @override
  String get operatorNodeName => '연산자';

  @override
  String get operatorNodeDescription => '선택한 연산을 두 숫자에 적용합니다.';

  @override
  String get execPortName => '실행';

  @override
  String get resultPortName => '결과';

  @override
  String get operationPortName => '연산';

  @override
  String get addFieldOption => '더하기';

  @override
  String get subtractFieldOption => '빼기';

  @override
  String get multiplyFieldOption => '곱하기';

  @override
  String get divideFieldOption => '나누기';

  @override
  String get randomNodeName => '랜덤';

  @override
  String get randomNodeDescription => '0과 1 사이의 랜덤한 숫자를 반환합니다.';

  @override
  String get ifNodeName => '만약';

  @override
  String get ifNodeDescription => '조건에 따라 분기를 실행합니다.';

  @override
  String get conditionPortName => '조건';

  @override
  String get truePortName => '참';

  @override
  String get falsePortName => '거짓';

  @override
  String get comparatorNodeName => '비교자';

  @override
  String get comparatorNodeDescription => '선택한 비교자를 기반으로 두 숫자를 비교합니다.';

  @override
  String get comparatorPortName => '비교자';

  @override
  String get equalFieldOption => '==';

  @override
  String get notEqualFieldOption => '!=';

  @override
  String get greaterFieldOption => '>';

  @override
  String get greaterEqualFieldOption => '>=';

  @override
  String get lessFieldOption => '<';

  @override
  String get lessEqualFieldOption => '<=';

  @override
  String get printNodeName => '출력';

  @override
  String get printNodeDescription => '콘솔에 값을 출력합니다.';

  @override
  String printNodeSnackbarMessage(String value) {
    return '값: $value';
  }

  @override
  String get roundNodeName => '반올림';

  @override
  String get roundNodeDescription => '숫자를 지정된 소수점 자릿수로 반올림합니다.';

  @override
  String get roundedPortName => '반올림됨';

  @override
  String get decimalsFieldName => '소수점';

  @override
  String get forEachLoopNodeName => 'For Each 루프';

  @override
  String get forEachLoopNodeDescription => '목록의 각 요소에 대해 루프를 실행하여 연산을 수행합니다.';

  @override
  String get listPortName => '목록';

  @override
  String get loopBodyPortName => '루프 본문';

  @override
  String get listElementPortName => '목록 요소';

  @override
  String get listIndexPortName => '목록 인덱스';

  @override
  String get cycleLocaleTooltip => '언어 변경';
}
