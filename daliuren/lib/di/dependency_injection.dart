import 'package:daliuren/data/repositories/da_liu_ren_repository_impl.dart';
import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/domain/usecases/calculate_divination_usecase.dart';
import 'package:daliuren/domain/usecases/load_divination_data_usecase.dart';
import 'package:daliuren/presentation/viewmodels/da_liu_ren_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjection {
  static List<SingleChildWidget> getProviders() {
    return [
      // Repository
      Provider<DaLiuRenRepository>(
        create: (_) => DaLiuRenRepositoryImpl(),
      ),

      // ViewModel - 直接创建 UseCase 实例，简化依赖链
      ChangeNotifierProvider<DaLiuRenViewModel>(
        create: (context) {
          final repository = context.read<DaLiuRenRepository>();
          return DaLiuRenViewModel(
            calculateDivinationUseCase: CalculateDivinationUseCase(repository),
            loadDivinationDataUseCase: LoadDivinationDataUseCase(repository),
          );
        },
      ),
    ];
  }
}