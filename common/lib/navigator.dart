import 'package:common/dev_select_datetime_page.dart';
// import 'package:common/widgets/map_screen.dart.osm.bak';
import 'package:common/widgets/flutter_map_screen.dart';
import 'package:common/widgets/city_picker_global_widget.dart';
import 'package:flutter/material.dart';

import './divinatioin_history_record/divination_history_record_page.dart';
import 'package:common/pages/dev_test_lunar_info_card_page.dart';
import 'package:common/pages/four_zhu_edit_page.dart';
import 'package:common/pages/editable_four_zhu_card_demo_page.dart';
import 'package:common/pages/fate_calender_page.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static final routes = {
    "/common/dev": (context, {arguments}) => const DevEnterPage(),
    "/common/dev/lunar_info_card": (context, {arguments}) =>
        const DevTestLunarInfoCardPage(),
    "/common/maps": (context, {arguments}) => FlutterMapScreen(
        seerLocation: arguments["seerLocation"],
        seekerLocation: arguments["seekerLocation"]),
    "/common/history": (context, {arguments}) =>
        const DivinationHistoryRecordPage(),
    "/common/four_zhu_edit": (context, {arguments}) => const FourZhuEditPage(),
    "/common/editable_card_demo": (context, {arguments}) =>
        const EditableFourZhuCardDemoPage(),
    "/common/fate_calender": (context, {arguments}) => const FateCalenderPage(),
    // "/common/reorderable_cards": (context, {arguments}) => const ReorderableCardsDemo(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name != null && name.isNotEmpty) {
      final Function? pageContentBuilder = routes[name];
      if (pageContentBuilder != null) {
        final Route route = MaterialPageRoute(
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        return _errorPage('Could not found route for $name');
      }
    } else {
      return _errorPage("Navigator required naviation name.");
    }
  }

  static Route _errorPage(msg) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: const Text('奇门遁甲_未知页面')),
          body: Center(child: Text(msg)));
    });
  }

  static Route<dynamic> generateRoute1(RouteSettings settings) {
    switch (settings.name) {
      case '/dev':
        return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            pageBuilder: (_, __, ___) => const DevEnterPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );
              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            });
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
