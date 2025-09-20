// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ノードエディター例';

  @override
  String get saveProjectDialogTitle => 'プロジェクトを保存';

  @override
  String get unsavedChangesTitle => '未保存の変更';

  @override
  String get unsavedChangesMsg => '未保存の変更があります。保存せずに続行しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get proceed => '続行';

  @override
  String get failedToLoadSampleProject =>
      'サンプルプロジェクトの読み込みに失敗しました。インターネット接続を確認してください。';

  @override
  String get searchNodesTooltip => '名前でノードを検索';

  @override
  String get toggleHierarchyTooltip => '階層パネルの表示/非表示';

  @override
  String get toggleSnapToGridTooltip => 'グリッドスナップの有効/無効';

  @override
  String get executeGraphTooltip => 'グラフを実行';

  @override
  String get touchCommandsTitle => 'タッチコマンド:';

  @override
  String get touchTap => '- タップ：ノードを選択';

  @override
  String get touchDoubleTap => '- ダブルタップ：選択をクリア';

  @override
  String get touchLongPress => '- 長押し：コンテキストメニューを開く';

  @override
  String get touchDrag => '- ドラッグ：接続を開始/ノードを選択';

  @override
  String get touchPinch => '- ピンチ：ズームイン/アウト';

  @override
  String get touchAdditionalGestures => '追加ジェスチャー:';

  @override
  String get touchTwoFingerDrag => '- 2本指ドラッグ：パン';

  @override
  String get mouseCommandsTitle => 'マウスコマンド:';

  @override
  String get mouseLeftClick => '- 左クリック：ノード/接続を選択';

  @override
  String get mouseRightClick => '- 右クリック：コンテキストメニューを開く';

  @override
  String get mouseScroll => '- スクロール：ズームイン/アウト';

  @override
  String get mouseMiddleClick => '- 中クリック：パン';

  @override
  String get keyboardCommandsTitle => 'キーボードコマンド:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S：プロジェクトを保存';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O：プロジェクトを開く';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N：新しいプロジェクト';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C：ノードをコピー';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V：ノードを貼り付け';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X：ノードを切り取り';
  }

  @override
  String get keyboardDelete => '- Delete | Backspace：ノードを削除';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z：元に戻す';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y：やり直し';
  }

  @override
  String get searching => '検索中...';

  @override
  String get noResults => '結果がありません';

  @override
  String get nextResult => '次の結果';

  @override
  String get previousResult => '前の結果';

  @override
  String resultsCount(int count) {
    return '$count件の結果';
  }

  @override
  String resultPosition(int current, int total) {
    return '$total件中$current件目';
  }

  @override
  String get numericValueNodeName => '数値';

  @override
  String get booleanValueNodeName => 'ブール値';

  @override
  String get stringValueNodeName => '文字列値';

  @override
  String get numericListValueNodeName => '数値リスト';

  @override
  String get booleanListValueNodeName => 'ブール値リスト';

  @override
  String get stringListValueNodeName => '文字列リスト';

  @override
  String valueNodeDescription(String type) {
    return '他のノードで使用できる値を含みます。';
  }

  @override
  String get completedPortName => '完了';

  @override
  String get valuePortName => '値';

  @override
  String get valueFieldName => '値';

  @override
  String get operatorNodeName => '演算子';

  @override
  String get operatorNodeDescription => '選択した演算を2つの数値に適用します。';

  @override
  String get execPortName => '実行';

  @override
  String get resultPortName => '結果';

  @override
  String get operationPortName => '演算';

  @override
  String get addFieldOption => '加算';

  @override
  String get subtractFieldOption => '減算';

  @override
  String get multiplyFieldOption => '乗算';

  @override
  String get divideFieldOption => '除算';

  @override
  String get randomNodeName => 'ランダム';

  @override
  String get randomNodeDescription => '0と1の間のランダムな数値を返します。';

  @override
  String get ifNodeName => 'もし';

  @override
  String get ifNodeDescription => '条件に基づいて分岐を実行します。';

  @override
  String get conditionPortName => '条件';

  @override
  String get truePortName => '真';

  @override
  String get falsePortName => '偽';

  @override
  String get comparatorNodeName => '比較子';

  @override
  String get comparatorNodeDescription => '選択した比較子に基づいて2つの数値を比較します。';

  @override
  String get comparatorPortName => '比較子';

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
  String get printNodeName => '印刷';

  @override
  String get printNodeDescription => 'コンソールに値を出力します。';

  @override
  String printNodeSnackbarMessage(String value) {
    return '値：$value';
  }

  @override
  String get roundNodeName => '四捨五入';

  @override
  String get roundNodeDescription => '数値を指定した小数点以下桁数に四捨五入します。';

  @override
  String get roundedPortName => '四捨五入済み';

  @override
  String get decimalsFieldName => '小数点以下桁数';

  @override
  String get forEachLoopNodeName => 'For Eachループ';

  @override
  String get forEachLoopNodeDescription => 'リストの各要素に対してループを実行し、演算を実行します。';

  @override
  String get listPortName => 'リスト';

  @override
  String get loopBodyPortName => 'ループ本体';

  @override
  String get listElementPortName => 'リスト要素';

  @override
  String get listIndexPortName => 'リストインデックス';

  @override
  String get cycleLocaleTooltip => '言語を変更';
}
