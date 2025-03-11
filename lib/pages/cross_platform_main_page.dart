import 'dart:ui';

import 'package:daliuren/pages/my_home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CrossPlatformMainPage extends StatefulWidget {
  static const String routeName = "main";
  const CrossPlatformMainPage({super.key});

  @override
  State<CrossPlatformMainPage> createState() => _CrossPlatformMainPageState();
}

class _CrossPlatformMainPageState extends State<CrossPlatformMainPage> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> isHorizontalNotifier = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _selectedIndexNotifier.dispose();
    isHorizontalNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool is4K = ResponsiveBreakpoints.of(context).equals("4K");
    bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    bool isTablet = ResponsiveBreakpoints.of(context).isTablet;
    bool isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    bool isPhone = ResponsiveBreakpoints.of(context).isPhone;
    print(
        '{"mobile":$isMobile,"phone":$isPhone,"tablet":$isTablet,"desktop":$isDesktop,"4K":$is4K}');

    return MaterialApp(
      home: Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(kToolbarHeight),
        //   child: ResponsiveVisibility(
        //       // visible:ResponsiveBreakpoints.of(context).smallerThan(TABLET),
        //     hiddenConditions: const [Condition.smallerThan(name: TABLET)],
        //     visible: ResponsiveBreakpoints.of(context).isMobile
        //         || ResponsiveBreakpoints.of(context).isPhone
        //         || ResponsiveBreakpoints.of(context).isTablet
        //         || ResponsiveBreakpoints.of(context).equals("4K"),
        //     child: AppBar(
        //       title: const Text('Responsive NavBar'),
        //       actions: [
        //         IconButton(
        //           icon: const Icon(Icons.search),
        //           onPressed: () {},
        //         ),
        //         IconButton(
        //           icon: const Icon(Icons.settings),
        //           onPressed: () {},
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        body: Row(
          children: <Widget>[
            ResponsiveVisibility(
              visible: ResponsiveBreakpoints.of(context).isDesktop ||
                  ResponsiveBreakpoints.of(context).isTablet,
              child: ValueListenableBuilder(
                  valueListenable: _selectedIndexNotifier,
                  builder: (ctx, selectedIndex, _) {
                    return NavigationRail(
                      labelType: NavigationRailLabelType.none,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) {
                        _selectedIndexNotifier.value = index;
                      },
                      // labelType: NavigationRailLabelType.selected,
                      // backgroundColor: Colors.green,
                      destinations: const <NavigationRailDestination>[
                        // navigation destinations
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite_border),
                          selectedIcon: Icon(Icons.favorite),
                          label: Text(
                            'Wishlist',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Account',
                              style: TextStyle(color: Colors.black87)),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.shopping_cart_outlined),
                          selectedIcon: Icon(Icons.shopping_cart),
                          label: Text('Cart',
                              style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                      selectedIconTheme: IconThemeData(color: Colors.white),
                      unselectedIconTheme: IconThemeData(color: Colors.black),
                      selectedLabelTextStyle: TextStyle(color: Colors.white),
                      extended: true,
                    );
                  }),
            ),
            // const VerticalDivider(thickness: 1, width: 2),
            // Expanded(
            //   child: Center(
            //     child: ValueListenableBuilder(valueListenable: _selectedIndexNotifier, builder: (ctx,_selectedIndex,_)=>Text('Page Number: $_selectedIndex')),
            //   ),
            // )
            Expanded(
                child: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.pink,
                title: Text('SliverAppBar'),
              ),
              SliverList(
                delegate:
                    SliverChildBuilderDelegate(childCount: 2, (ctx, index) {
                  if (index == 1) {
                    return ElevatedButton(
                        onPressed: () {
                          isHorizontalNotifier.value =
                              !isHorizontalNotifier.value;
                        },
                        child: Text("ok"));
                  }
                  return Stack(children: [
                    ValueListenableBuilder(
                        valueListenable: isHorizontalNotifier,
                        builder: (ctx, isHorizontal, _) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            color: Colors.blue.withOpacity(.1),
                            width: isHorizontal ? 120 : 80,
                            height: isHorizontal ? 40 : 60,
                            child: Wrap(
                              spacing: 0.0,
                              runSpacing: 0.0,
                              alignment: WrapAlignment.center,
                              children: [
                                // Chip(
                                //   avatar: CircleAvatar(backgroundColor: Colors.blue.shade900, child: const Text('AH')),
                                //   label: const Text('Hamilton'),
                                // ),
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.red.withOpacity(.4),
                                    ),
                                    AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 100),
                                            alignment: Alignment.center,
                                            color:
                                                Colors.orange.withOpacity(.4),
                                            height: 40,
                                            width: isHorizontal ? 80 : 0,
                                            child: Container(
                                                child: Text("click me")))
                                        .animate()
                                        .show(
                                            delay: Duration(milliseconds: 600),
                                            duration:
                                                Duration(milliseconds: 200)),
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  color: Colors.orange.withOpacity(.4),
                                  height: isHorizontal ? 0 : 20,
                                  width: 80,
                                  child: Text("click me"),
                                )
                              ],
                            ),
                          );
                          return AnimatedAlign(
                              alignment: isHorizontal
                                  ? Alignment.centerRight
                                  : Alignment.bottomCenter,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOut,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 50),
                                  SizedBox(
                                      width: isHorizontal ? 8 : 0,
                                      height: isHorizontal ? 0 : 8),
                                  Text('Star Icon'),
                                ],
                              ));
                        })
                  ]);
                }),
              )
            ]))
          ],
        ),
        drawer: ResponsiveVisibility(
          // visible: ResponsiveBreakpoints.of(context).equals("4K"),
          child: ValueListenableBuilder(
              valueListenable: _selectedIndexNotifier,
              builder: (ctx, selectedIndex, _) {
                return NavigationDrawer(
                  onDestinationSelected: (index) =>
                      _selectedIndexNotifier.value = index,
                  selectedIndex: selectedIndex,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                      child: Text(
                        'Header',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    // navigation destination
                    NavigationDrawerDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: Text('Wishlist'),
                    ),
                    NavigationDrawerDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Account'),
                    ),
                    NavigationDrawerDestination(
                      icon: Icon(Icons.shopping_cart_outlined),
                      selectedIcon: Icon(Icons.shopping_cart),
                      label: Text('Cart'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                      child: Divider(),
                    ),
                  ],
                );
              }),
        ),
        bottomNavigationBar: ResponsiveVisibility(
          visible: ResponsiveBreakpoints.of(context).isMobile,
          visibleConditions: [Condition.smallerThan(name: TABLET)],
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
            ],
            onTap: (index) {},
          ),
        ),
      ),
    );
  }
}
