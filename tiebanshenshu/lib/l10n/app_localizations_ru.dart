// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Пример редактора узлов';

  @override
  String get saveProjectDialogTitle => 'Сохранить проект';

  @override
  String get unsavedChangesTitle => 'Несохранённые изменения';

  @override
  String get unsavedChangesMsg =>
      'У вас есть несохранённые изменения. Хотите продолжить без сохранения?';

  @override
  String get cancel => 'Отмена';

  @override
  String get proceed => 'Продолжить';

  @override
  String get failedToLoadSampleProject =>
      'Не удалось загрузить пример проекта. Пожалуйста, проверьте подключение к интернету.';

  @override
  String get searchNodesTooltip => 'Поиск узлов по имени';

  @override
  String get toggleHierarchyTooltip => 'Переключить панель иерархии';

  @override
  String get toggleSnapToGridTooltip => 'Переключить привязку к сетке';

  @override
  String get executeGraphTooltip => 'Выполнить граф';

  @override
  String get touchCommandsTitle => 'Жесты касания:';

  @override
  String get touchTap => '- Касание: выбрать узел';

  @override
  String get touchDoubleTap => '- Двойное касание: очистить выбор';

  @override
  String get touchLongPress => '- Долгое нажатие: открыть контекстное меню';

  @override
  String get touchDrag => '- Перетаскивание: начать соединение / выбрать узлы';

  @override
  String get touchPinch => '- Сведение пальцев: масштабировать';

  @override
  String get touchAdditionalGestures => 'Дополнительные жесты:';

  @override
  String get touchTwoFingerDrag =>
      '- Перетаскивание двумя пальцами: панорамирование';

  @override
  String get mouseCommandsTitle => 'Действия мышью:';

  @override
  String get mouseLeftClick => '- ЛКМ: выбрать узел/связь';

  @override
  String get mouseRightClick => '- ПКМ: открыть контекстное меню';

  @override
  String get mouseScroll => '- Колёсико: масштабировать';

  @override
  String get mouseMiddleClick => '- Средняя кнопка: панорамирование';

  @override
  String get keyboardCommandsTitle => 'Команды клавиатуры:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S: сохранить проект';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O: открыть проект';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N: новый проект';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C: копировать узел';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V: вставить узел';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X: вырезать узел';
  }

  @override
  String get keyboardDelete => '- Delete | Backspace: удалить узел';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z: отмена';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y: повтор';
  }

  @override
  String get searching => 'Поиск...';

  @override
  String get noResults => 'Результаты не найдены';

  @override
  String get nextResult => 'Следующий результат';

  @override
  String get previousResult => 'Предыдущий результат';

  @override
  String resultsCount(int count) {
    return '$count результатов';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current из $total';
  }

  @override
  String get numericValueNodeName => 'Числовое значение';

  @override
  String get booleanValueNodeName => 'Булево значение';

  @override
  String get stringValueNodeName => 'Строковое значение';

  @override
  String get numericListValueNodeName => 'Список чисел';

  @override
  String get booleanListValueNodeName => 'Список булевых значений';

  @override
  String get stringListValueNodeName => 'Список строк';

  @override
  String valueNodeDescription(String type) {
    return 'Хранит постоянное значение $type.';
  }

  @override
  String get completedPortName => 'Завершено';

  @override
  String get valuePortName => 'Значение';

  @override
  String get valueFieldName => 'Значение';

  @override
  String get operatorNodeName => 'Оператор';

  @override
  String get operatorNodeDescription =>
      'Применяет выбранную операцию к двум числам.';

  @override
  String get execPortName => 'Исполн.';

  @override
  String get resultPortName => 'Результат';

  @override
  String get operationPortName => 'Операция';

  @override
  String get addFieldOption => 'Сложение';

  @override
  String get subtractFieldOption => 'Вычитание';

  @override
  String get multiplyFieldOption => 'Умножение';

  @override
  String get divideFieldOption => 'Деление';

  @override
  String get randomNodeName => 'Случайное';

  @override
  String get randomNodeDescription => 'Выводит случайное число между 0 и 1.';

  @override
  String get ifNodeName => 'Если';

  @override
  String get ifNodeDescription => 'Выполняет ветку на основе условия.';

  @override
  String get conditionPortName => 'Условие';

  @override
  String get truePortName => 'Истина';

  @override
  String get falsePortName => 'Ложь';

  @override
  String get comparatorNodeName => 'Сравнитель';

  @override
  String get comparatorNodeDescription =>
      'Сравнивает два числа с использованием выбранного оператора.';

  @override
  String get comparatorPortName => 'Сравнитель';

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
  String get printNodeName => 'Печать';

  @override
  String get printNodeDescription => 'Выводит значение в консоль.';

  @override
  String printNodeSnackbarMessage(String value) {
    return 'Значение: $value';
  }

  @override
  String get roundNodeName => 'Округление';

  @override
  String get roundNodeDescription =>
      'Округляет число до заданного количества десятичных знаков.';

  @override
  String get roundedPortName => 'Округлено';

  @override
  String get decimalsFieldName => 'Десятичные';

  @override
  String get forEachLoopNodeName => 'Цикл For Each';

  @override
  String get forEachLoopNodeDescription =>
      'Выполняет цикл для каждого элемента списка.';

  @override
  String get listPortName => 'Список';

  @override
  String get loopBodyPortName => 'Тело цикла';

  @override
  String get listElementPortName => 'Элемент списка';

  @override
  String get listIndexPortName => 'Индекс списка';

  @override
  String get cycleLocaleTooltip => 'Изменить язык';
}
