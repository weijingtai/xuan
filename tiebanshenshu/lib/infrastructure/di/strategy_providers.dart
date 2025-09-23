import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../repository/repository_factory.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../service/strategy/four_zhu_tian_gan_strategy.dart';
import '../../service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../../service/strategy/tai_xuan_four_zhu_interactive_strategy.dart';
import '../../service/strategy/tiao_wen_list_calculation.dart';
import '../../usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';
import '../../usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart';
import '../../usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart';
import '../../usecases/tai_xuan_four_zhu_interactive_use_case.dart';
import '../../presentation/viewmodels/day_gan_zhi_gua_view_model.dart';
import '../../presentation/viewmodels/four_zhu_tian_gan_view_model.dart';
import '../../presentation/viewmodels/tai_xuan_four_zhu_view_model.dart';
import '../../providers/tai_xuan_four_zhu_interactive_provider.dart';

/// Strategy相关的Provider配置
///
/// 提供MVVM+UseCase架构所需的所有依赖注入配置
class StrategyProviders {
  /// 获取所有Strategy相关的Provider配置
  ///
  /// 包含Repository、Strategy、UseCase和ViewModel的完整依赖链
  static List<SingleChildWidget> get providers => [
    // Repository层
    Provider<TiaoWenRepository>(
      create: (_) => RepositoryFactory.defaultTiaoWenRepository,
    ),

    // 条文列表计算配置层
    Provider<TiaoWenListCalculationConfig>(
      create: (_) => TiaoWenListCalculationConfig.listAdd(
        customList: [96, 192, 384, 768], // 使用传统的48倍数配置：2*48, 4*48, 8*48, 16*48
        withSub: true, // 包含减法计算
      ),
    ),

    // Strategy层
    Provider<DayGanZhiGuaStrategy>(create: (_) => DayGanZhiGuaStrategy()),
    Provider<FourZhuTianGanStrategy>(create: (_) => FourZhuTianGanStrategy()),
    Provider<TaiXuanFourZhuStrategy>(create: (_) => TaiXuanFourZhuStrategy()),

    // Interactive Strategy层
    Provider<TaiXuanFourZhuInteractiveStrategy>(
      create: (_) => TaiXuanFourZhuInteractiveStrategy(),
    ),

    // UseCase层
    Provider<DayGanZhiGuaTiaoWenListUseCase>(
      create: (context) => DayGanZhiGuaTiaoWenListUseCase(
        context.read<DayGanZhiGuaStrategy>(),
        context.read<TiaoWenRepository>(),
        context.read<TiaoWenListCalculationConfig>(),
      ),
    ),
    Provider<FourZhuTianGanTiaoWenListUseCase>(
      create: (context) => FourZhuTianGanTiaoWenListUseCase(
        context.read<FourZhuTianGanStrategy>(),
        context.read<TiaoWenRepository>(),
        context.read<TiaoWenListCalculationConfig>(),
      ),
    ),
    Provider<TaiXuanFourZhuTiaoWenListUseCase>(
      create: (context) => TaiXuanFourZhuTiaoWenListUseCase(
        context.read<TaiXuanFourZhuStrategy>(),
        context.read<TiaoWenRepository>(),
        context.read<TiaoWenListCalculationConfig>(),
      ),
    ),

    // Interactive UseCase层
    Provider<TaiXuanFourZhuInteractiveUseCase>(
      create: (context) => TaiXuanFourZhuInteractiveUseCase(
        context.read<TaiXuanFourZhuInteractiveStrategy>(),
        context.read<TiaoWenRepository>(),
        context.read<TiaoWenListCalculationConfig>(),
      ),
    ),

    // ViewModel层
    ChangeNotifierProvider<DayGanZhiGuaViewModel>(
      create: (context) =>
          DayGanZhiGuaViewModel(context.read<DayGanZhiGuaTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<FourZhuTianGanViewModel>(
      create: (context) => FourZhuTianGanViewModel(
        context.read<FourZhuTianGanTiaoWenListUseCase>(),
      ),
    ),
    ChangeNotifierProvider<TaiXuanFourZhuViewModel>(
      create: (context) => TaiXuanFourZhuViewModel(
        context.read<TaiXuanFourZhuTiaoWenListUseCase>(),
      ),
    ),
    
    // Interactive Provider层
    ChangeNotifierProvider<TaiXuanFourZhuInteractiveProvider>(
      create: (context) => TaiXuanFourZhuInteractiveProvider(
        context.read<TaiXuanFourZhuInteractiveUseCase>(),
      ),
    ),
  ];
}
