import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../application/services/candidate_generation_service.dart';
import '../../application/services/interactive_session_service.dart';
import '../../application/services/multi_base_number_selection_service.dart';
import '../../features/huang_ji/huang_ji_session_manager.dart';
import '../../features/huang_ji/huang_ji_v2_calculation_strategy.dart';
import '../../features/huang_ji/huang_ji_v2_calculation_strategy_impl.dart';
import '../../features/huang_ji/huang_ji_v2_use_case.dart';
import '../../features/huang_ji/huang_ji_v2_view_model.dart';
import '../../features/liuqinkaoke/repository/liuqinkaoke_session_repository.dart';
import '../../features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart';
import '../../presentation/viewmodels/multi_base_number_selection_view_model.dart';
import '../../repository/repository_factory.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../service/strategy/four_zhu_tian_gan_strategy.dart';
import '../../service/strategy/middle_palace_five_strategy.dart';
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
import '../../presentation/viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';
// 新的V2架构
import '../../repository/session_repository.dart';
import '../../repository/session_repository_impl.dart';
// 六亲考刻
import '../../features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import '../../features/liuqinkaoke/strategy/liuqinkaoke_default_strategy.dart';
import '../../features/liuqinkaoke/usecase/liuqinkaoke_use_case.dart';
import '../../features/liuqinkaoke/viewmodels/liuqinkaoke_view_model.dart';

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

    // HuangJiV2 Strategy层 - 已删除旧架构
    // Provider<HuangJiV2Strategy>(
    //   create: (_) => HuangJiV2Strategy(),
    // ),

    // Service层
    Provider<InteractiveSessionService>(
      create: (_) => InteractiveSessionServiceImpl(),
    ),
    Provider<CandidateGenerationService>(
      create: (context) =>
          CandidateGenerationServiceImpl(context.read<TiaoWenRepository>()),
    ),
    Provider<MultiBaseNumberSelectionService>(
      create: (context) => MultiBaseNumberSelectionService(
        context.read<CandidateGenerationService>(),
      ),
    ),
    // HuangJiV2SessionService - 已删除旧架构
    // Provider<HuangJiV2SessionService>(
    //   create: (_) => HuangJiV2SessionService(),
    // ),

    // HuangJi V2 新架构
    Provider<HuangJiV2CalculationStrategy>(
      create: (_) => HuangJiV2CalculationStrategyImpl(),
    ),
    Provider<SessionRepository>(create: (_) => InMemorySessionRepository()),
    Provider<HuangJiSessionManager>(
      create: (context) => HuangJiSessionManager(
        sessionRepository: context.read<SessionRepository>(),
        calculationStrategy: context.read<HuangJiV2CalculationStrategy>(),
      ),
    ),
    Provider<HuangJiV2UseCase>(
      create: (context) => HuangJiV2UseCase(
        sessionManager: context.read<HuangJiSessionManager>(),
        calculationStrategy: context.read<HuangJiV2CalculationStrategy>(),
        tiaoWenRepository: context.read<TiaoWenRepository>(),
      ),
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
    ChangeNotifierProvider<TaiXuanFourZhuInteractiveViewModel>(
      create: (context) => TaiXuanFourZhuInteractiveViewModel(
        context.read<TaiXuanFourZhuInteractiveUseCase>(),
      ),
    ),

    // Multi Base Number Selection Provider层
    ChangeNotifierProvider<MultiBaseNumberSelectionViewModel>(
      create: (context) => MultiBaseNumberSelectionViewModel(
        context.read<MultiBaseNumberSelectionService>(),
      ),
    ),

    // HuangJi V2 新架构 ViewModel
    ChangeNotifierProvider<HuangJiV2ViewModel>(
      create: (context) =>
          HuangJiV2ViewModel(useCase: context.read<HuangJiV2UseCase>()),
    ),

    // HuangJiV2 ViewModel层 - 已删除旧架构
    // ChangeNotifierProvider<HuangJiV2ViewModel>(
    //   create: (context) => HuangJiV2ViewModel(
    //     context.read<HuangJiV2UseCase>(),
    //     context.read<MultiBaseNumberSelectionService>(),
    //     context.read<TiaoWenRepository>(),
    //   ),
    // ),

    // —— 六亲考刻 DI ——
    Provider<LiuQinKaoKeSessionRepository>(
      create: (_) => InMemoryLiuQinKaoKeSessionRepository(),
    ),
    Provider<MiddlePalaceFiveStrategy>(
      create: (_) => DefaultMiddlePalaceFiveStrategy(),
    ),
    Provider<LiuQinKaoKeCalculationStrategy>(
      create: (context) => LiuQinKaokeDefaultCalculationStrategy(
        context.read<MiddlePalaceFiveStrategy>(),
      ),
    ),
    Provider<LiuQinKaoKeSessionManager>(
      create: (context) => LiuQinKaoKeSessionManager(
        context.read<LiuQinKaoKeSessionRepository>(),
        context.read<LiuQinKaoKeCalculationStrategy>(),
        context.read<TiaoWenRepository>(),
        context.read<TiaoWenListCalculationConfig>(),
      ),
    ),
    Provider<LiuQinKaoKeUseCase>(
      create: (context) =>
          LiuQinKaoKeUseCase(context.read<LiuQinKaoKeSessionManager>()),
    ),
    ChangeNotifierProvider<LiuQinKaoKeViewModel>(
      create: (context) =>
          LiuQinKaoKeViewModel(context.read<LiuQinKaoKeUseCase>()),
    ),
  ];
}
