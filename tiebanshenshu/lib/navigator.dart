import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_v2_demo_page.dart';
import 'package:tiebanshenshu/presentation/pages/multi_base_number_selection_page.dart';
import 'package:tiebanshenshu/presentation/pages/strategy_demo_page.dart';
import 'package:tiebanshenshu/presentation/pages/tai_xuan_interactive_page.dart';
import 'package:tiebanshenshu/presentation/pages/four_doors_and_gun_fa_page.dart';
import 'package:tiebanshenshu/ui/pages/dev_page.dart';

import 'domain/models/multi_base_number_selection.dart';
import 'features/liuqinkaoke/pages/liuqinkaoke_selection_page.dart';
// 旧的V2 Demo页面已删除
// import 'features/huang_ji_v2_demo_page.dart';

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
    "/tiebanshenshu/multi_selection": (context, {arguments}) =>
        MultiBaseNumberSelectionPage(
          yuanHuiYunShi: YuanHuiYunShi.fromEightChars(
            EightChars(
              year: JiaZi.GUI_SI, // 癸巳
              month: JiaZi.JIA_ZI, // 甲子
              day: JiaZi.DING_YOU, // 丁酉
              time: JiaZi.GUI_MAO, // 癸卯
            ),
          ),
          requiredTypes: [
            BaseNumberSelectionType.yuanHui,
            BaseNumberSelectionType.yunShi,
          ],
        ),
    "/tiebanshenshu/strategy_demo": (context, {arguments}) =>
        const StrategyDemoPage(),
    "/tiebanshenshu/tai_xuan": (context, {arguments}) =>
        const TaiXuanInteractivePage(),
    "/tiebanshenshu/four_doors_and_gun_fa": (context, {arguments}) =>
        const FourDoorsAndGunFaPage(),

    // 六亲考刻：取数候选选择页
    "/tiebanshenshu/liuqinkaoke/selection": (context, {arguments}) {
      return const LiuQinKaoKeSelectionPage();
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
      } else {
        return _errorPage('Could not found route for $name');
      }
    } else {
      return _errorPage("Navigator required naviation name.");
    }
  }

  static Route _errorPage(msg) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('铁板神数_未知页面')),
          body: Center(child: Text(msg)),
        );
      },
    );
  }
}
