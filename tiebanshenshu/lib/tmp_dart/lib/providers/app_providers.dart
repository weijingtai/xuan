import 'package:provider/provider.dart';
import '../viewmodels/algorithm_editor_viewmodel.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(create: (_) => AlgorithmEditorViewModel()),
  ];
}
