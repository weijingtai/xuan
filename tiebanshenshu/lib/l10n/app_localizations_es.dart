// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ejemplo Editor de Nodos';

  @override
  String get saveProjectDialogTitle => 'Guardar Proyecto';

  @override
  String get unsavedChangesTitle => 'Cambios Sin Guardar';

  @override
  String get unsavedChangesMsg =>
      'Tienes cambios sin guardar. ¿Quieres continuar sin guardar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get proceed => 'Continuar';

  @override
  String get failedToLoadSampleProject =>
      'No se pudo cargar el proyecto de ejemplo. Verifica tu conexión a internet.';

  @override
  String get searchNodesTooltip => 'Buscar Nodos por Nombre';

  @override
  String get toggleHierarchyTooltip => 'Activar/Desactivar Panel de Jerarquía';

  @override
  String get toggleSnapToGridTooltip =>
      'Activar/Desactivar Ajuste a Cuadrícula';

  @override
  String get executeGraphTooltip => 'Ejecutar Gráfico';

  @override
  String get touchCommandsTitle => 'Comandos Táctiles:';

  @override
  String get touchTap => '- Tocar: Seleccionar Nodo';

  @override
  String get touchDoubleTap => '- Doble Toque: Limpiar Selección';

  @override
  String get touchLongPress => '- Presión Prolongada: Abrir Menú Contextual';

  @override
  String get touchDrag => '- Arrastrar: Iniciar Conexión / Seleccionar Nodos';

  @override
  String get touchPinch => '- Pellizcar: Acercar/Alejar';

  @override
  String get touchAdditionalGestures => 'Gestos Adicionales:';

  @override
  String get touchTwoFingerDrag => '- Arrastrar con Dos Dedos: Panorámica';

  @override
  String get mouseCommandsTitle => 'Comandos del Ratón:';

  @override
  String get mouseLeftClick => '- Clic Izquierdo: Seleccionar Nodo/Conexión';

  @override
  String get mouseRightClick => '- Clic Derecho: Abrir Menú Contextual';

  @override
  String get mouseScroll => '- Scroll: Acercar/Alejar';

  @override
  String get mouseMiddleClick => '- Clic Central: Panorámica';

  @override
  String get keyboardCommandsTitle => 'Comandos de Teclado:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S: Guardar Proyecto';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O: Abrir Proyecto';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N: Nuevo Proyecto';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C: Copiar Nodo';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V: Pegar Nodo';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X: Cortar Nodo';
  }

  @override
  String get keyboardDelete => '- Supr | Retroceso: Eliminar Nodo';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z: Deshacer';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y: Rehacer';
  }

  @override
  String get searching => 'Buscando...';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get nextResult => 'Siguiente Resultado';

  @override
  String get previousResult => 'Resultado Anterior';

  @override
  String resultsCount(int count) {
    return '$count resultados';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current de $total';
  }

  @override
  String get numericValueNodeName => 'Valor Numérico';

  @override
  String get booleanValueNodeName => 'Valor Booleano';

  @override
  String get stringValueNodeName => 'Valor de Cadena';

  @override
  String get numericListValueNodeName => 'Lista de Valores Numéricos';

  @override
  String get booleanListValueNodeName => 'Lista de Valores Booleanos';

  @override
  String get stringListValueNodeName => 'Lista de Valores de Cadena';

  @override
  String valueNodeDescription(String type) {
    return 'Contiene un valor que puede ser utilizado en otros nodos.';
  }

  @override
  String get completedPortName => 'Completado';

  @override
  String get valuePortName => 'Valor';

  @override
  String get valueFieldName => 'Valor';

  @override
  String get operatorNodeName => 'Operador';

  @override
  String get operatorNodeDescription =>
      'Aplica una operación elegida a dos números.';

  @override
  String get execPortName => 'Ejecutar';

  @override
  String get resultPortName => 'Resultado';

  @override
  String get operationPortName => 'Operación';

  @override
  String get addFieldOption => 'Sumar';

  @override
  String get subtractFieldOption => 'Restar';

  @override
  String get multiplyFieldOption => 'Multiplicar';

  @override
  String get divideFieldOption => 'Dividir';

  @override
  String get randomNodeName => 'Aleatorio';

  @override
  String get randomNodeDescription =>
      'Devuelve un número aleatorio entre 0 y 1.';

  @override
  String get ifNodeName => 'Si';

  @override
  String get ifNodeDescription => 'Ejecuta una rama basada en una condición.';

  @override
  String get conditionPortName => 'Condición';

  @override
  String get truePortName => 'Verdadero';

  @override
  String get falsePortName => 'Falso';

  @override
  String get comparatorNodeName => 'Comparador';

  @override
  String get comparatorNodeDescription =>
      'Compara dos números basándose en un comparador elegido.';

  @override
  String get comparatorPortName => 'Comparador';

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
  String get printNodeName => 'Imprimir';

  @override
  String get printNodeDescription => 'Imprime un valor en la consola.';

  @override
  String printNodeSnackbarMessage(String value) {
    return 'Valor: $value';
  }

  @override
  String get roundNodeName => 'Redondear';

  @override
  String get roundNodeDescription =>
      'Redondea un número a un número especificado de decimales.';

  @override
  String get roundedPortName => 'Redondeado';

  @override
  String get decimalsFieldName => 'Decimales';

  @override
  String get forEachLoopNodeName => 'Para Cada Bucle';

  @override
  String get forEachLoopNodeDescription =>
      'Ejecuta un bucle para cada elemento de una lista ejecutando una operación.';

  @override
  String get listPortName => 'Lista';

  @override
  String get loopBodyPortName => 'Cuerpo del Bucle';

  @override
  String get listElementPortName => 'Elemento de Lista';

  @override
  String get listIndexPortName => 'Índice de Lista';

  @override
  String get cycleLocaleTooltip => 'Cambiar idioma';
}
