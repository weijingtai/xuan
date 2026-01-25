import 'package:flutter/material.dart';
import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class DaYunTabs extends StatelessWidget {
  final TabController controller;
  final List<String> daYun;
  final bool isPhone;

  const DaYunTabs({
    super.key,
    required this.controller,
    required this.daYun,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final itemPadding = EdgeInsets.symmetric(
      horizontal: isPhone ? 12 : 14,
      vertical: isPhone ? 10 : 12,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selectedIndex = controller.index;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: InkTheme.line(70), width: 0.6),
            color: InkTheme.paperHi.withAlpha(180),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStatePropertyAll(InkTheme.ink.withAlpha(12)),
            indicator: StampIndicator(
              stampWidth: isPhone ? 58 : 70,
              stampHeight: 16,
              rotation: -0.06,
            ),
            labelColor: InkTheme.seal.withAlpha(220),
            unselectedLabelColor: InkTheme.ink.withAlpha(200),
            labelStyle: TextStyle(
              fontSize: isPhone ? 12 : 14,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isPhone ? 12 : 14,
              height: 1.0,
              fontWeight: FontWeight.w500,
            ),
            tabs: List<Widget>.generate(daYun.length, (i) {
              final selected = i == selectedIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: itemPadding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? InkTheme.seal.withAlpha(110)
                        : InkTheme.line(70),
                    width: selected ? 0.8 : 0.6,
                  ),
                  color: selected
                      ? InkTheme.sealWash(34)
                      : Colors.white.withAlpha(120),
                ),
                child: Text(daYun[i]),
              );
            }),
          ),
        );
      },
    );
  }
}
