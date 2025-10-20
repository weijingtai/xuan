import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/huang_ji/huang_ji_session_manager.dart';
import '../../features/huang_ji/huang_ji_v2_calculation_strategy.dart';
import '../../features/huang_ji/huang_ji_v2_calculation_strategy_impl.dart';
import '../../features/huang_ji/huang_ji_v2_use_case.dart';
import '../../features/huang_ji/huang_ji_v2_view_model.dart';
import '../../features/liuqinkaoke/repository/liuqinkaoke_session_repository.dart';
import '../../features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart';
import '../../repository/repository_factory.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../service/strategy/four_zhu_tian_gan_strategy.dart';
import '../../service/strategy/middle_palace_five_strategy.dart';
import '../../service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../../service/strategy/tai_xuan_four_zhu_interactive_strategy.dart';
import '../../service/strategy/ba_gua_jia_ze_strategy.dart';
import '../../service/strategy/yuan_tang_strategy.dart';
import '../../service/strategy/xian_houtian_jia_ze_strategy.dart';
import '../../service/strategy/liu_yao_gan_zhi_he_strategy.dart';
import '../../service/strategy/gua_yao_gan_zhi_he_strategy.dart';
import '../../service/strategy/xian_houtian_qu_shu_strategy.dart';
import '../../service/strategy/qian_hou_gua_strategy.dart';
import '../../service/strategy/gua_zhong_strategy.dart';
import '../../service/strategy/si_men_fa_strategy.dart';
import '../../service/strategy/ba_gua_gun_strategy.dart';
import '../../service/strategy/tiao_wen_list_calculation.dart';
import '../../usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';
import '../../usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart';
import '../../usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart';
import '../../usecases/tai_xuan_four_zhu_interactive_use_case.dart';
import '../../usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart';
import '../../usecases/yuan_tang_tiao_wen_list_use_case.dart';
import '../../usecases/xian_houtian_jia_ze_tiao_wen_list_use_case.dart';
import '../../usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart';
import '../../usecases/gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart';
import '../../usecases/xian_houtian_qu_shu_tiao_wen_list_use_case.dart';
import '../../usecases/qian_hou_gua_tiao_wen_list_use_case.dart';
import '../../usecases/gua_zhong_tiao_wen_list_use_case.dart';
import '../../usecases/si_men_fa_tiao_wen_list_use_case.dart';
import '../../usecases/ba_gua_gun_tiao_wen_list_use_case.dart';
import '../../presentation/viewmodels/day_gan_zhi_gua_view_model.dart';
import '../../presentation/viewmodels/four_zhu_tian_gan_view_model.dart';
import '../../presentation/viewmodels/tai_xuan_four_zhu_view_model.dart';
import '../../presentation/viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';
import '../../presentation/viewmodels/ba_gua_jia_ze_view_model.dart';
import '../../presentation/viewmodels/yuan_tang_view_model.dart';
import '../../presentation/viewmodels/xian_houtian_jia_ze_view_model.dart';
import '../../presentation/viewmodels/liu_yao_gan_zhi_he_view_model.dart';
import '../../presentation/viewmodels/gua_yao_gan_zhi_he_view_model.dart';
import '../../presentation/viewmodels/xian_houtian_qu_shu_view_model.dart';
import '../../presentation/viewmodels/qian_hou_gua_view_model.dart';
import '../../presentation/viewmodels/gua_zhong_view_model.dart';
import '../../presentation/viewmodels/si_men_fa_view_model.dart';
import '../../presentation/viewmodels/ba_gua_gun_view_model.dart';
// 新的V2架构
import '../../repository/session_repository.dart';
import '../../repository/session_repository_impl.dart';
// 六亲考刻
import '../../features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import '../../features/liuqinkaoke/strategy/liuqinkaoke_default_strategy.dart';
import '../../features/liuqinkaoke/usecase/liuqinkaoke_use_case.dart';
import '../../features/liuqinkaoke/viewmodels/liuqinkaoke_view_model.dart';
// 考刻
import '../../constant/kao_ke_constants.dart';
import '../../features/kao_ke/kao_ke_session_manager.dart';
import '../../features/kao_ke/kao_ke_calculation_strategy.dart';
import '../../features/kao_ke/kao_ke_calculation_strategy_impl.dart';
import '../../features/kao_ke/kao_ke_use_case.dart';
import '../../features/kao_ke/kao_ke_view_model.dart';
// 考订六亲
import '../../features/kao_ding_liu_qin/repositories/liu_du_table_repository.dart';
import '../../features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart';
import '../../features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart';
import '../../features/kao_ding_liu_qin/models/session_manager.dart';
import '../../presentation/viewmodels/kao_ding_liu_qin_view_model.dart';

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
        customList: [96, 192, 384, 768],
        withSub: true,
      ),
    ),

    // Strategy层
    Provider<DayGanZhiGuaStrategy>(create: (_) => DayGanZhiGuaStrategy()),
    Provider<FourZhuTianGanStrategy>(create: (_) => FourZhuTianGanStrategy()),
    Provider<TaiXuanFourZhuStrategy>(create: (_) => TaiXuanFourZhuStrategy()),
    Provider<BaGuaJiaZeStrategy>(create: (_) => BaGuaJiaZeStrategy()),
    Provider<YuanTangStrategy>(create: (_) => YuanTangStrategy()),
    Provider<XianHoutianJiaZeStrategy>(
      create: (_) => XianHoutianJiaZeStrategy(),
    ),
    Provider<LiuYaoGanZhiHeStrategy>(create: (_) => LiuYaoGanZhiHeStrategy()),
    Provider<GuaYaoGanZhiHeStrategy>(create: (_) => GuaYaoGanZhiHeStrategy()),
    Provider<XianHoutianQuShuStrategy>(
      create: (_) => XianHoutianQuShuStrategy(),
    ),
    Provider<QianHouGuaStrategy>(create: (_) => QianHouGuaStrategy()),
    Provider<GuaZhongStrategy>(create: (_) => GuaZhongStrategy()),
    Provider<SiMenFaStrategy>(create: (_) => SiMenFaStrategy()),
    Provider<BaGuaGunStrategy>(create: (_) => BaGuaGunStrategy()),

    // Interactive Strategy层
    Provider<TaiXuanFourZhuInteractiveStrategy>(
      create: (_) => TaiXuanFourZhuInteractiveStrategy(),
    ),

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
    Provider<BaGuaJiaZeTiaoWenListUseCase>(
      create: (context) => BaGuaJiaZeTiaoWenListUseCase(
        context.read<BaGuaJiaZeStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<YuanTangTiaoWenListUseCase>(
      create: (context) => YuanTangTiaoWenListUseCase(
        context.read<YuanTangStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<XianHoutianJiaZeTiaoWenListUseCase>(
      create: (context) => XianHoutianJiaZeTiaoWenListUseCase(
        context.read<XianHoutianJiaZeStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<LiuYaoGanZhiHeTiaoWenListUseCase>(
      create: (context) => LiuYaoGanZhiHeTiaoWenListUseCase(
        context.read<LiuYaoGanZhiHeStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<GuaYaoGanZhiHeTiaoWenListUseCase>(
      create: (context) => GuaYaoGanZhiHeTiaoWenListUseCase(
        context.read<GuaYaoGanZhiHeStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<XianHoutianQuShuTiaoWenListUseCase>(
      create: (context) => XianHoutianQuShuTiaoWenListUseCase(
        context.read<XianHoutianQuShuStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<QianHouGuaTiaoWenListUseCase>(
      create: (context) => QianHouGuaTiaoWenListUseCase(
        context.read<QianHouGuaStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<GuaZhongTiaoWenListUseCase>(
      create: (context) => GuaZhongTiaoWenListUseCase(
        context.read<GuaZhongStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<SiMenFaTiaoWenListUseCase>(
      create: (context) => SiMenFaTiaoWenListUseCase(
        context.read<SiMenFaStrategy>(),
        context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<BaGuaGunTiaoWenListUseCase>(
      create: (context) => BaGuaGunTiaoWenListUseCase(
        context.read<BaGuaGunStrategy>(),
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
    ChangeNotifierProvider<BaGuaJiaZeViewModel>(
      create: (context) =>
          BaGuaJiaZeViewModel(context.read<BaGuaJiaZeTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<YuanTangViewModel>(
      create: (context) =>
          YuanTangViewModel(context.read<YuanTangTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<XianHoutianJiaZeViewModel>(
      create: (context) => XianHoutianJiaZeViewModel(
        context.read<XianHoutianJiaZeTiaoWenListUseCase>(),
      ),
    ),
    ChangeNotifierProvider<LiuYaoGanZhiHeViewModel>(
      create: (context) => LiuYaoGanZhiHeViewModel(
        context.read<LiuYaoGanZhiHeTiaoWenListUseCase>(),
      ),
    ),
    ChangeNotifierProvider<GuaYaoGanZhiHeViewModel>(
      create: (context) => GuaYaoGanZhiHeViewModel(
        context.read<GuaYaoGanZhiHeTiaoWenListUseCase>(),
      ),
    ),
    ChangeNotifierProvider<XianHoutianQuShuViewModel>(
      create: (context) => XianHoutianQuShuViewModel(
        context.read<XianHoutianQuShuTiaoWenListUseCase>(),
      ),
    ),
    ChangeNotifierProvider<QianHouGuaViewModel>(
      create: (context) =>
          QianHouGuaViewModel(context.read<QianHouGuaTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<GuaZhongViewModel>(
      create: (context) =>
          GuaZhongViewModel(context.read<GuaZhongTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<SiMenFaViewModel>(
      create: (context) =>
          SiMenFaViewModel(context.read<SiMenFaTiaoWenListUseCase>()),
    ),
    ChangeNotifierProvider<BaGuaGunViewModel>(
      create: (context) =>
          BaGuaGunViewModel(context.read<BaGuaGunTiaoWenListUseCase>()),
    ),

    // Interactive Provider层
    ChangeNotifierProvider<TaiXuanFourZhuInteractiveViewModel>(
      create: (context) => TaiXuanFourZhuInteractiveViewModel(
        context.read<TaiXuanFourZhuInteractiveUseCase>(),
      ),
    ),

    // HuangJi V2 新架构 ViewModel
    ChangeNotifierProvider<HuangJiV2ViewModel>(
      create: (context) =>
          HuangJiV2ViewModel(useCase: context.read<HuangJiV2UseCase>()),
    ),

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

    // —— 考刻 DI ——
    Provider<KaoKeConstants>(create: (_) => KaoKeConstants()),
    Provider<KaoKeSessionManager>(create: (_) => KaoKeSessionManager()),
    Provider<KaoKeCalculationStrategy>(
      create: (context) => KaoKeCalculationStrategyImpl(
        tiaoWenRepository: context.read<TiaoWenRepository>(),
      ),
    ),
    Provider<KaoKeUseCase>(
      create: (context) => KaoKeUseCase(
        sessionManager: context.read<KaoKeSessionManager>(),
        calculationStrategy: context.read<KaoKeCalculationStrategy>(),
        kaoKeConstants: context.read<KaoKeConstants>(),
      ),
    ),
    ChangeNotifierProvider<KaoKeViewModel>(
      create: (context) =>
          KaoKeViewModel(useCase: context.read<KaoKeUseCase>()),
    ),

    // —— 考订六亲 DI ——
    Provider<LiuDuTableRepository>(create: (_) => LiuDuTableRepository()),
    Provider<KaoDingLiuQinSessionManager>(
      create: (_) => KaoDingLiuQinSessionManager(),
    ),
    Provider<KaoDingLiuQinStrategy>(
      create: (context) =>
          KaoDingLiuQinStrategy(context.read<LiuDuTableRepository>()),
    ),
    Provider<KaoDingLiuQinUseCase>(
      create: (context) => KaoDingLiuQinUseCase(
        liuDuTableRepository: context.read<LiuDuTableRepository>(),
        tiaoWenRepository: context.read<TiaoWenRepository>(),
        sessionManager: context.read<KaoDingLiuQinSessionManager>(),
      ),
    ),
    ChangeNotifierProvider<KaoDingLiuQinViewModel>(
      create: (context) =>
          KaoDingLiuQinViewModel(context.read<KaoDingLiuQinUseCase>()),
    ),
  ];
}
