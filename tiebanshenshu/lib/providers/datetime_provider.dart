import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:flutter/foundation.dart';

class DateTimeProvider extends ChangeNotifier {
  DateTimeDetailsBundle? _currentDateTimeBundle;

  DateTimeDetailsBundle? get currentDateTimeBundle => _currentDateTimeBundle;

  void updateDateTime(DateTimeDetailsBundle bundle) {
    _currentDateTimeBundle = bundle;
    notifyListeners();
  }

  void clearDateTime() {
    _currentDateTimeBundle = null;
    notifyListeners();
  }

  bool get hasDateTime => _currentDateTimeBundle != null;
}
