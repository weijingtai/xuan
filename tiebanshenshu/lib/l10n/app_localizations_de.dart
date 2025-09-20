// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Beispiel Knoten-Editor';

  @override
  String get saveProjectDialogTitle => 'Projekt Speichern';

  @override
  String get unsavedChangesTitle => 'Ungespeicherte Änderungen';

  @override
  String get unsavedChangesMsg =>
      'Sie haben ungespeicherte Änderungen. Möchten Sie fortfahren, ohne zu speichern?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get proceed => 'Fortfahren';

  @override
  String get failedToLoadSampleProject =>
      'Beispielprojekt konnte nicht geladen werden. Überprüfen Sie Ihre Internetverbindung.';

  @override
  String get searchNodesTooltip => 'Knoten nach Name suchen';

  @override
  String get toggleHierarchyTooltip => 'Hierarchie-Panel ein/ausblenden';

  @override
  String get toggleSnapToGridTooltip => 'Rasterausrichtung ein/ausschalten';

  @override
  String get executeGraphTooltip => 'Graph ausführen';

  @override
  String get touchCommandsTitle => 'Touch-Befehle:';

  @override
  String get touchTap => '- Tippen: Knoten auswählen';

  @override
  String get touchDoubleTap => '- Doppeltippen: Auswahl aufheben';

  @override
  String get touchLongPress => '- Langer Druck: Kontextmenü öffnen';

  @override
  String get touchDrag => '- Ziehen: Verbindung beginnen / Knoten auswählen';

  @override
  String get touchPinch => '- Kneifen: Hinein-/Herauszoomen';

  @override
  String get touchAdditionalGestures => 'Zusätzliche Gesten:';

  @override
  String get touchTwoFingerDrag => '- Zwei-Finger-Ziehen: Schwenken';

  @override
  String get mouseCommandsTitle => 'Maus-Befehle:';

  @override
  String get mouseLeftClick => '- Linksklick: Knoten/Verbindung auswählen';

  @override
  String get mouseRightClick => '- Rechtsklick: Kontextmenü öffnen';

  @override
  String get mouseScroll => '- Scrollen: Hinein-/Herauszoomen';

  @override
  String get mouseMiddleClick => '- Mittelklick: Schwenken';

  @override
  String get keyboardCommandsTitle => 'Tastatur-Befehle:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S: Projekt speichern';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O: Projekt öffnen';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N: Neues Projekt';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C: Knoten kopieren';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V: Knoten einfügen';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X: Knoten ausschneiden';
  }

  @override
  String get keyboardDelete => '- Entf | Rücktaste: Knoten entfernen';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z: Rückgängig';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y: Wiederholen';
  }

  @override
  String get searching => 'Suche läuft...';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get nextResult => 'Nächstes Ergebnis';

  @override
  String get previousResult => 'Vorheriges Ergebnis';

  @override
  String resultsCount(int count) {
    return '$count Ergebnisse';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current von $total';
  }

  @override
  String get numericValueNodeName => 'Zahlenwert';

  @override
  String get booleanValueNodeName => 'Boolescher Wert';

  @override
  String get stringValueNodeName => 'Zeichenketten-Wert';

  @override
  String get numericListValueNodeName => 'Zahlenliste';

  @override
  String get booleanListValueNodeName => 'Boolesche Liste';

  @override
  String get stringListValueNodeName => 'Zeichenketten-Liste';

  @override
  String valueNodeDescription(String type) {
    return 'Enthält einen Wert, der in anderen Knoten verwendet werden kann.';
  }

  @override
  String get completedPortName => 'Abgeschlossen';

  @override
  String get valuePortName => 'Wert';

  @override
  String get valueFieldName => 'Wert';

  @override
  String get operatorNodeName => 'Operator';

  @override
  String get operatorNodeDescription =>
      'Wendet eine gewählte Operation auf zwei Zahlen an.';

  @override
  String get execPortName => 'Ausführen';

  @override
  String get resultPortName => 'Ergebnis';

  @override
  String get operationPortName => 'Operation';

  @override
  String get addFieldOption => 'Addieren';

  @override
  String get subtractFieldOption => 'Subtrahieren';

  @override
  String get multiplyFieldOption => 'Multiplizieren';

  @override
  String get divideFieldOption => 'Dividieren';

  @override
  String get randomNodeName => 'Zufall';

  @override
  String get randomNodeDescription =>
      'Gibt eine Zufallszahl zwischen 0 und 1 zurück.';

  @override
  String get ifNodeName => 'Wenn';

  @override
  String get ifNodeDescription =>
      'Führt einen Zweig basierend auf einer Bedingung aus.';

  @override
  String get conditionPortName => 'Bedingung';

  @override
  String get truePortName => 'Wahr';

  @override
  String get falsePortName => 'Falsch';

  @override
  String get comparatorNodeName => 'Vergleicher';

  @override
  String get comparatorNodeDescription =>
      'Vergleicht zwei Zahlen basierend auf einem gewählten Vergleichsoperator.';

  @override
  String get comparatorPortName => 'Vergleichsoperator';

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
  String get printNodeName => 'Drucken';

  @override
  String get printNodeDescription => 'Gibt einen Wert in der Konsole aus.';

  @override
  String printNodeSnackbarMessage(String value) {
    return 'Wert: $value';
  }

  @override
  String get roundNodeName => 'Runden';

  @override
  String get roundNodeDescription =>
      'Rundet eine Zahl auf eine bestimmte Anzahl von Dezimalstellen.';

  @override
  String get roundedPortName => 'Gerundet';

  @override
  String get decimalsFieldName => 'Dezimalstellen';

  @override
  String get forEachLoopNodeName => 'Für-Jedes-Schleife';

  @override
  String get forEachLoopNodeDescription =>
      'Führt eine Schleife für jedes Element einer Liste aus und führt eine Operation aus.';

  @override
  String get listPortName => 'Liste';

  @override
  String get loopBodyPortName => 'Schleifenkörper';

  @override
  String get listElementPortName => 'Listenelement';

  @override
  String get listIndexPortName => 'Listenindex';

  @override
  String get cycleLocaleTooltip => 'Sprache wechseln';
}
