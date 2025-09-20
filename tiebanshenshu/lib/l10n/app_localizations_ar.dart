// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محرر العقد التجريبي';

  @override
  String get saveProjectDialogTitle => 'حفظ المشروع';

  @override
  String get unsavedChangesTitle => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesMsg =>
      'لديك تغييرات غير محفوظة. هل تريد المتابعة بدون حفظ؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get proceed => 'متابعة';

  @override
  String get failedToLoadSampleProject =>
      'فشل في تحميل المشروع التجريبي. تحقق من اتصالك بالإنترنت.';

  @override
  String get searchNodesTooltip => 'البحث في العقد بالاسم';

  @override
  String get toggleHierarchyTooltip => 'تشغيل/إيقاف لوحة التسلسل الهرمي';

  @override
  String get toggleSnapToGridTooltip => 'تشغيل/إيقاف الالتصاق بالشبكة';

  @override
  String get executeGraphTooltip => 'تنفيذ الرسم البياني';

  @override
  String get touchCommandsTitle => 'أوامر اللمس:';

  @override
  String get touchTap => '- لمسة: تحديد عقدة';

  @override
  String get touchDoubleTap => '- لمسة مزدوجة: مسح التحديد';

  @override
  String get touchLongPress => '- ضغطة طويلة: فتح القائمة السياقية';

  @override
  String get touchDrag => '- سحب: بدء الاتصال / تحديد العقد';

  @override
  String get touchPinch => '- قرصة: تكبير/تصغير';

  @override
  String get touchAdditionalGestures => 'إيماءات إضافية:';

  @override
  String get touchTwoFingerDrag => '- سحب بإصبعين: تحريك عمودي';

  @override
  String get mouseCommandsTitle => 'أوامر الماوس:';

  @override
  String get mouseLeftClick => '- نقرة يسرى: تحديد عقدة/اتصال';

  @override
  String get mouseRightClick => '- نقرة يمنى: فتح القائمة السياقية';

  @override
  String get mouseScroll => '- التمرير: تكبير/تصغير';

  @override
  String get mouseMiddleClick => '- نقرة وسطى: تحريك عمودي';

  @override
  String get keyboardCommandsTitle => 'أوامر لوحة المفاتيح:';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S: حفظ المشروع';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O: فتح مشروع';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N: مشروع جديد';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C: نسخ العقدة';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V: لصق العقدة';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X: قص العقدة';
  }

  @override
  String get keyboardDelete => '- Delete | Backspace: إزالة العقدة';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z: تراجع';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y: إعادة';
  }

  @override
  String get searching => 'جاري البحث...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get nextResult => 'النتيجة التالية';

  @override
  String get previousResult => 'النتيجة السابقة';

  @override
  String resultsCount(int count) {
    return '$count نتائج';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current من $total';
  }

  @override
  String get numericValueNodeName => 'قيمة رقمية';

  @override
  String get booleanValueNodeName => 'قيمة منطقية';

  @override
  String get stringValueNodeName => 'قيمة نصية';

  @override
  String get numericListValueNodeName => 'قائمة قيم رقمية';

  @override
  String get booleanListValueNodeName => 'قائمة قيم منطقية';

  @override
  String get stringListValueNodeName => 'قائمة قيم نصية';

  @override
  String valueNodeDescription(String type) {
    return 'تحتوي على قيمة يمكن استخدامها في عقد أخرى.';
  }

  @override
  String get completedPortName => 'مكتمل';

  @override
  String get valuePortName => 'قيمة';

  @override
  String get valueFieldName => 'قيمة';

  @override
  String get operatorNodeName => 'مشغل';

  @override
  String get operatorNodeDescription => 'يطبق عملية مختارة على رقمين.';

  @override
  String get execPortName => 'تنفيذ';

  @override
  String get resultPortName => 'نتيجة';

  @override
  String get operationPortName => 'عملية';

  @override
  String get addFieldOption => 'جمع';

  @override
  String get subtractFieldOption => 'طرح';

  @override
  String get multiplyFieldOption => 'ضرب';

  @override
  String get divideFieldOption => 'قسمة';

  @override
  String get randomNodeName => 'عشوائي';

  @override
  String get randomNodeDescription => 'يعيد رقماً عشوائياً بين 0 و 1.';

  @override
  String get ifNodeName => 'إذا';

  @override
  String get ifNodeDescription => 'ينفذ فرعاً بناءً على شرط.';

  @override
  String get conditionPortName => 'شرط';

  @override
  String get truePortName => 'صحيح';

  @override
  String get falsePortName => 'خطأ';

  @override
  String get comparatorNodeName => 'مقارن';

  @override
  String get comparatorNodeDescription => 'يقارن رقمين بناءً على مقارن مختار.';

  @override
  String get comparatorPortName => 'مقارن';

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
  String get printNodeName => 'طباعة';

  @override
  String get printNodeDescription => 'يطبع قيمة في وحدة التحكم.';

  @override
  String printNodeSnackbarMessage(String value) {
    return 'القيمة: $value';
  }

  @override
  String get roundNodeName => 'تقريب';

  @override
  String get roundNodeDescription =>
      'يقرب رقماً إلى عدد محدد من المنازل العشرية.';

  @override
  String get roundedPortName => 'مقرب';

  @override
  String get decimalsFieldName => 'منازل عشرية';

  @override
  String get forEachLoopNodeName => 'حلقة لكل عنصر';

  @override
  String get forEachLoopNodeDescription =>
      'ينفذ حلقة لكل عنصر في قائمة منفذاً عملية.';

  @override
  String get listPortName => 'قائمة';

  @override
  String get loopBodyPortName => 'جسم الحلقة';

  @override
  String get listElementPortName => 'عنصر القائمة';

  @override
  String get listIndexPortName => 'فهرس القائمة';

  @override
  String get cycleLocaleTooltip => 'تغيير اللغة';
}
