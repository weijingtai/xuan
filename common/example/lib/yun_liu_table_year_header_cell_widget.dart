import 'package:common/enums.dart';
import 'package:flutter/material.dart';

class YunLiuTableYearHeaderCellWidget extends StatelessWidget {
  const YunLiuTableYearHeaderCellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F4), // stone-100
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120),
              child: DaYunHeaderCell(
                year: 2024,
                age: 28,
                yearGanZhi: JiaZi.JIA_CHEN,
                ganGod: EnumTenGods.ZhenCai,
                hiddenGans: const [
                  (gan: TianGan.WU, hiddenGods: EnumTenGods.ZhenCai),
                  (gan: TianGan.YI, hiddenGods: EnumTenGods.ZhengGuan),
                  (gan: TianGan.BING, hiddenGods: EnumTenGods.PanYin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DaYunHeaderCell extends StatefulWidget {
  final JiaZi yearGanZhi;
  final EnumTenGods ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans;

  // final String zodiacZn;

  final int age;
  final int year;

  DaYunHeaderCell({
    super.key,
    required this.yearGanZhi,
    required this.ganGod,
    // required this.zodiacZn,
    required this.hiddenGans,
    required this.age,
    required this.year,
  });

  @override
  State<DaYunHeaderCell> createState() => _DaYunHeaderCellState();
}

class _DaYunHeaderCellState extends State<DaYunHeaderCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const paperLight = Color(0xFFFDFaf5);
    const paperDark = Color(0xFFF4F0E6);
    const ink = Color(0xFF1A1A1A);
    const cinnabar = Color(0xFFC0392B);
    const goldLine = Color(0x4DD4AF37);

    final ganGodVertical = widget.ganGod.name.split('').join('\n');
    final zodiacChar = widget.yearGanZhi.chinese12Zodiac.name;

    final hidden = <({TianGan gan, EnumTenGods hiddenGods})>[...widget.hiddenGans];
    while (hidden.length < 3) {
      hidden.add((gan: TianGan.JIA, hiddenGods: EnumTenGods.BiJian));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: LayoutBuilder(
        builder: (context, c) {
          final sx = (c.maxWidth / 170.0).clamp(0.4, 2.0);
          final sy = (c.maxHeight / 195.0).clamp(0.4, 2.0);
          final s = sx < sy ? sx : sy;

          final radius = 12.0 * s;
          final borderW = 2.0 * s;

          final yearStyle = TextStyle(
            fontSize: 20.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0 * s,
            color: paperLight,
            fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
          );

          final ageStyle = TextStyle(
            fontSize: 12.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w700,
            color: paperLight.withAlpha(210),
            fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
          );

          final pillarStyle = TextStyle(
            fontSize: 48.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.0 * s,
            color: ink,
            shadows: [Shadow(color: paperLight, blurRadius: 8.0 * s)],
            fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
          );

          final ganGodStyle = TextStyle(
            fontSize: 14.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: cinnabar,
            fontFamilyFallback: const ['Noto Serif SC', 'serif'],
          );

          final watermarkStyle = TextStyle(
            fontSize: 100.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w900,
            color: Colors.black.withOpacity(0.06),
            fontFamilyFallback: const ['Noto Serif SC', 'serif'],
          );

          final rootCharStyle = TextStyle(
            fontSize: 15.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w900,
            color: ink,
            fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
          );

          final rootGodStyle = TextStyle(
            fontSize: 11.0 * s,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: cinnabar,
            fontFamilyFallback: const ['Noto Serif SC', 'serif'],
          );

          final body = ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: paperLight,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: ink, width: borderW),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 20.0 * s,
                    offset: Offset(0, 8.0 * s),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6.0 * s),
                        decoration: const BoxDecoration(color: ink),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${widget.year}', style: yearStyle),
                            SizedBox(height: 2.0 * s),
                            Text('${widget.age}岁', style: ageStyle),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10.0 * s,
                              bottom: -15.0 * s,
                              child: IgnorePointer(
                                child: Transform.rotate(
                                  angle: -0.35,
                                  child: Text(zodiacChar, style: watermarkStyle),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 15.0 * s,
                              top: 10.0 * s,
                              bottom: 10.0 * s,
                              child: IgnorePointer(
                                child: Text(
                                  ganGodVertical,
                                  style: ganGodStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                widget.yearGanZhi.name,
                                style: pillarStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6.0 * s),
                        decoration: BoxDecoration(
                          color: paperDark,
                          border: Border(top: BorderSide(color: goldLine, width: 1.0 * s)),
                        ),
                        child: Row(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: i == 0
                                        ? null
                                        : Border(
                                            left: BorderSide(
                                              color: Colors.black.withOpacity(0.08),
                                              width: 1.0 * s,
                                            ),
                                          ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(hidden[i].gan.name, style: rootCharStyle),
                                      SizedBox(height: 2.0 * s),
                                      Text(hidden[i].hiddenGods.name, style: rootGodStyle),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _hovered ? 1.0 : 0.0,
                        child: Container(
                          margin: EdgeInsets.all(2.0 * s),
                          decoration: BoxDecoration(
                            border: Border.all(color: cinnabar.withAlpha(90), width: 1.0 * s),
                            borderRadius: BorderRadius.circular(radius - 2.0 * s),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          return SizedBox(width: c.maxWidth, height: c.maxHeight, child: body);
        },
      ),
    );
  }
}

