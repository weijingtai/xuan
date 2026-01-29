import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_v2_demo_page.dart';
import 'package:tiebanshenshu/presentation/pages/strategy_demo_page.dart';
import 'package:tiebanshenshu/presentation/pages/four_doors_and_gun_fa_page.dart';
import 'package:tiebanshenshu/ui/pages/dev_page.dart';
import 'package:provider/provider.dart';
import 'infrastructure/di/strategy_providers.dart';
import 'features/liuqinkaoke/pages/liuqinkaoke_selection_page.dart';
import 'features/kao_ke/kao_ke_interactive_page.dart';
import 'features/kao_ding_liu_qin/pages/kao_ding_liu_qin_page.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static final routes = {
    "/dev": (ctx, {arguments}) => const DevPage(),

    // "/tiebanshenshu/huang_ji_demo": (context, {arguments}) => const HuangJi6aDemoPage(),
    // 新的V2 Demo页面
    "/tiebanshenshu/huang_ji_v2_demo": (context, {arguments}) =>
        const HuangJiV2DemoPage(),
    // 旧的V2 Demo路由已删除
    // "/tiebanshenshu/huang_ji_v2_demo": (context, {arguments}) =>
    //     const HuangJiV2DemoPage(),
    "/tiebanshenshu/strategy_demo": (context, {arguments}) =>
        const StrategyDemoPage(),
    "/tiebanshenshu/four_doors_and_gun_fa": (context, {arguments}) =>
        const FourDoorsAndGunFaPage(),

    // 六亲考刻：取数候选选择页
    "/tiebanshenshu/liuqinkaoke/selection": (context, {arguments}) {
      return const LiuQinKaoKeSelectionPage();
    },

    // 考刻：八刻秘数表考刻交互页
    "/tiebanshenshu/kaoke": (context, {arguments}) {
      // 默认使用测试数据的八字
      final defaultEightChars = EightChars(
        year: JiaZi.GUI_SI, // 癸巳
        month: JiaZi.JIA_ZI, // 甲子
        day: JiaZi.DING_YOU, // 丁酉
        time: JiaZi.GUI_MAO, // 癸卯
      );

      // 尝试从参数中获取八字,如果没有则使用默认值
      final eightChars = arguments is EightChars
          ? arguments
          : defaultEightChars;

      return MultiProvider(
        providers: StrategyProviders.providers,
        child: KaoKeInteractivePage(eightChars: eightChars),
      );
    },

    // 考订六亲：六亲推算交互页
    "/tiebanshenshu/kao_ding_liu_qin": (context, {arguments}) {
      // 默认使用测试数据的八字（辛未年月日时 - 包含所有六亲）
      final defaultEightChars = EightChars(
        year: JiaZi.XIN_WEI, // 辛未
        month: JiaZi.XIN_WEI, // 辛未
        day: JiaZi.XIN_WEI, // 辛未
        time: JiaZi.XIN_WEI, // 辛未
      );

      // 尝试从参数中获取八字,如果没有则使用默认值
      final eightChars = arguments is EightChars
          ? arguments
          : defaultEightChars;

      return KaoDingLiuQinPage(eightChars: eightChars);
    },
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name != null && name.isNotEmpty) {
      final Function? pageContentBuilder = routes[name];
      if (pageContentBuilder != null) {
        final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments),
        );
        return route;
      }
    }

    // 如果没有找到对应的路由，返回默认的错误页面
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('铁版神数_未知页面')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
