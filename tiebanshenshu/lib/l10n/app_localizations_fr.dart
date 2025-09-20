// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Exemple Éditeur de Nœuds';

  @override
  String get saveProjectDialogTitle => 'Enregistrer le Projet';

  @override
  String get unsavedChangesTitle => 'Modifications Non Enregistrées';

  @override
  String get unsavedChangesMsg =>
      'Vous avez des modifications non enregistrées. Voulez-vous continuer sans enregistrer ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get proceed => 'Continuer';

  @override
  String get failedToLoadSampleProject =>
      'Impossible de charger le projet d\'exemple. Vérifiez votre connexion internet.';

  @override
  String get searchNodesTooltip => 'Rechercher les Nœuds par Nom';

  @override
  String get toggleHierarchyTooltip =>
      'Activer/Désactiver le Panneau Hiérarchie';

  @override
  String get toggleSnapToGridTooltip =>
      'Activer/Désactiver l\'Accrochage à la Grille';

  @override
  String get executeGraphTooltip => 'Exécuter le Graphique';

  @override
  String get touchCommandsTitle => 'Commandes Tactiles :';

  @override
  String get touchTap => '- Toucher : Sélectionner un Nœud';

  @override
  String get touchDoubleTap => '- Double Toucher : Effacer la Sélection';

  @override
  String get touchLongPress =>
      '- Pression Prolongée : Ouvrir le Menu Contextuel';

  @override
  String get touchDrag =>
      '- Glisser : Commencer une Connexion / Sélectionner des Nœuds';

  @override
  String get touchPinch => '- Pincer : Zoomer/Dézoomer';

  @override
  String get touchAdditionalGestures => 'Gestes Supplémentaires :';

  @override
  String get touchTwoFingerDrag => '- Glissement à Deux Doigts : Panoramique';

  @override
  String get mouseCommandsTitle => 'Commandes Souris :';

  @override
  String get mouseLeftClick => '- Clic Gauche : Sélectionner Nœud/Connexion';

  @override
  String get mouseRightClick => '- Clic Droit : Ouvrir le Menu Contextuel';

  @override
  String get mouseScroll => '- Molette : Zoomer/Dézoomer';

  @override
  String get mouseMiddleClick => '- Clic Central : Panoramique';

  @override
  String get keyboardCommandsTitle => 'Commandes Clavier :';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S : Enregistrer le Projet';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O : Ouvrir un Projet';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N : Nouveau Projet';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C : Copier le Nœud';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V : Coller le Nœud';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X : Couper le Nœud';
  }

  @override
  String get keyboardDelete => '- Suppr | Retour Arrière : Supprimer le Nœud';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z : Annuler';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y : Rétablir';
  }

  @override
  String get searching => 'Recherche en cours...';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get nextResult => 'Résultat Suivant';

  @override
  String get previousResult => 'Résultat Précédent';

  @override
  String resultsCount(int count) {
    return '$count résultats';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get numericValueNodeName => 'Valeur Numérique';

  @override
  String get booleanValueNodeName => 'Valeur Booléenne';

  @override
  String get stringValueNodeName => 'Valeur Chaîne';

  @override
  String get numericListValueNodeName => 'Liste de Valeurs Numériques';

  @override
  String get booleanListValueNodeName => 'Liste de Valeurs Booléennes';

  @override
  String get stringListValueNodeName => 'Liste de Valeurs Chaînes';

  @override
  String valueNodeDescription(String type) {
    return 'Contient une valeur qui peut être utilisée dans d\'autres nœuds.';
  }

  @override
  String get completedPortName => 'Terminé';

  @override
  String get valuePortName => 'Valeur';

  @override
  String get valueFieldName => 'Valeur';

  @override
  String get operatorNodeName => 'Opérateur';

  @override
  String get operatorNodeDescription =>
      'Applique une opération choisie à deux nombres.';

  @override
  String get execPortName => 'Exécuter';

  @override
  String get resultPortName => 'Résultat';

  @override
  String get operationPortName => 'Opération';

  @override
  String get addFieldOption => 'Additionner';

  @override
  String get subtractFieldOption => 'Soustraire';

  @override
  String get multiplyFieldOption => 'Multiplier';

  @override
  String get divideFieldOption => 'Diviser';

  @override
  String get randomNodeName => 'Aléatoire';

  @override
  String get randomNodeDescription =>
      'Retourne un nombre aléatoire entre 0 et 1.';

  @override
  String get ifNodeName => 'Si';

  @override
  String get ifNodeDescription =>
      'Exécute une branche basée sur une condition.';

  @override
  String get conditionPortName => 'Condition';

  @override
  String get truePortName => 'Vrai';

  @override
  String get falsePortName => 'Faux';

  @override
  String get comparatorNodeName => 'Comparateur';

  @override
  String get comparatorNodeDescription =>
      'Compare deux nombres basés sur un comparateur choisi.';

  @override
  String get comparatorPortName => 'Comparateur';

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
  String get printNodeName => 'Imprimer';

  @override
  String get printNodeDescription => 'Imprime une valeur dans la console.';

  @override
  String printNodeSnackbarMessage(String value) {
    return 'Valeur : $value';
  }

  @override
  String get roundNodeName => 'Arrondir';

  @override
  String get roundNodeDescription =>
      'Arrondit un nombre à un nombre spécifié de décimales.';

  @override
  String get roundedPortName => 'Arrondi';

  @override
  String get decimalsFieldName => 'Décimales';

  @override
  String get forEachLoopNodeName => 'Boucle Pour Chaque';

  @override
  String get forEachLoopNodeDescription =>
      'Exécute une boucle pour chaque élément d\'une liste en exécutant une opération.';

  @override
  String get listPortName => 'Liste';

  @override
  String get loopBodyPortName => 'Corps de Boucle';

  @override
  String get listElementPortName => 'Élément de Liste';

  @override
  String get listIndexPortName => 'Index de Liste';

  @override
  String get cycleLocaleTooltip => 'Changer la langue';
}
