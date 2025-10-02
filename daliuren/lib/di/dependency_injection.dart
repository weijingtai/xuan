import 'package:daliuren/data/repositories/da_liu_ren_repository_impl.dart';
import 'package:daliuren/domain/repositories/da_liu_ren_repository.dart';
import 'package:daliuren/domain/services/calculators/lunar_calculator.dart';
import 'package:daliuren/domain/services/calculators/tian_di_pan_calculator.dart';
import 'package:daliuren/domain/services/calculators/gui_ren_calculator.dart';
import 'package:daliuren/domain/services/calculators/four_class_calculator.dart';
import 'package:daliuren/domain/services/calculators/three_chuan_calculator.dart';
import 'package:daliuren/domain/services/da_liu_ren_calculation_service.dart';
import 'package:daliuren/domain/usecases/calculate_divination_usecase.dart';
import 'package:daliuren/domain/usecases/load_divination_data_usecase.dart';
import 'package:daliuren/presentation/viewmodels/da_liu_ren_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjection {
  static List<SingleChildWidget> getProviders() {
    return [
      // Calculators
      Provider<LunarCalculator>(
        create: (_) => LunarCalculator(),
      ),
      Provider<TianDiPanCalculator>(
        create: (_) => TianDiPanCalculator(),
      ),
      Provider<GuiRenCalculator>(
        create: (_) => GuiRenCalculator(),
      ),
      Provider<FourClassCalculator>(
        create: (_) => FourClassCalculator(),
      ),
      Provider<ThreeChuanCalculator>(
        create: (_) => ThreeChuanCalculator(),
      ),

      // Calculation Service
      Provider<DaLiuRenCalculationService>(
        create: (context) => DaLiuRenCalculationService(
          lunarCalculator: context.read<LunarCalculator>(),
          tianDiPanCalculator: context.read<TianDiPanCalculator>(),
          guiRenCalculator: context.read<GuiRenCalculator>(),
          fourClassCalculator: context.read<FourClassCalculator>(),
          threeChuanCalculator: context.read<ThreeChuanCalculator>(),
        ),
      ),

      // Repository
      Provider<DaLiuRenRepository>(
        create: (context) => DaLiuRenRepositoryImpl(
          calculationService: context.read<DaLiuRenCalculationService>(),
        ),
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
