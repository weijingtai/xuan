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
    const borderColor = Color(0xFFD1CDC2);
    const ink = Color(0xFF2D2D2D);
    const seal = Color(0xFFB22D2A);
    const muted = Color(0xFF959595);
    const muted2 = Color(0xFF7A7A7A);

    final titleStyle = const TextStyle(
      fontSize: 12,
      height: 1.0,
      color: ink,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
    );

    final subTitleStyle = const TextStyle(
      fontSize: 10,
      height: 1.0,
      color: muted,
      fontWeight: FontWeight.w400,
      fontFamilyFallback: ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
    );

    final ganZhiStyle = const TextStyle(
      fontSize: 24,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: ink,
      fontFamilyFallback: ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
    );

    final ganGodStyle = const TextStyle(
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: seal,
      fontFamilyFallback: ['Noto Serif SC', 'serif'],
    );

    final zodiacStyle = const TextStyle(
      fontSize: 10,
      height: 1.0,
      color: muted2,
      fontFamilyFallback: ['Noto Serif SC', 'serif'],
    );

    final hiddenGanTextStyle = const TextStyle(
      fontSize: 12,
      height: 1.1,
      color: muted,
      fontFamilyFallback: ['Noto Serif SC', 'serif'],
    );

    final hiddenGanLabelStyle = TextStyle(
      fontSize: 12,
      height: 1.1,
      color: seal.withAlpha(178), // ~70%
      fontWeight: FontWeight.w800,
      fontFamilyFallback: const ['Noto Serif SC', 'serif'],
    );

    // var ganGodName = widget.ganGod.name.replaceFirst("", "\n");
    var ganGodName = widget.ganGod.name.split("").join("\n");

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: 120,
        height: 115,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                // color: const Color(0xFFF2EFE5).withAlpha(77), // /30
                color: const Color(0xFFFCF9F2), // /30
                border: Border.all(color: borderColor, width: 1),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.year.toString(),
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.age}岁',
                    style: subTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Transform.scale(
                            scale: 0.85,
                            child: Text(
                              // widget.ganGod.name.replaceFirst("", "\r\n"),
                              // "比\n肩",
                              ganGodName,
                              style: ganGodStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.yearGanZhi.name,
                          style: ganZhiStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            widget.yearGanZhi.chinese12Zodiac.name,
                            style: ganGodStyle.copyWith(
                              color: Colors.black26,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    // padding: const EdgeInsets.only(top: 4),
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     top: BorderSide(
                    //       color: borderColor.withAlpha(128),
                    //       width: 1,
                    //     ),
                    //   ),
                    // ),
                    child: Column(
                      children: [
                        // Transform.scale(
                        //   scale: 0.9,
                        //   alignment: Alignment.topCenter,
                        //   child: Text(
                        //     widget.zodiacZn,
                        //     style: zodiacStyle,
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ),
                        // const SizedBox(height: 4),
                        Transform.scale(
                          scale: 0.85,
                          // scale: 1,
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: List.generate(3, (i) {
                              final item = widget.hiddenGans[i];
                              var godFirstChar = item.hiddenGods.shortName;
                              // var lastChar = item.hiddenGods.name
                              //     .split("")
                              //     .last;
                              // String? godSecondChar = lastChar;
                              // if (lastChar == "" ||
                              //     item.hiddenGods.name.length == 1) {
                              //   godSecondChar = null;
                              // }
                              var showLeftBorder = false;
                              if (i == 1 || i == 2) {
                                showLeftBorder = true;
                              }
                              // final showLeftBorder = i == 2;
                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: showLeftBorder
                                        ? Border(
                                            left: BorderSide(
                                              color: borderColor.withAlpha(77),
                                              width: 1,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.gan.name,
                                        style: hiddenGanTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Column(
                                        children: [
                                          Text(
                                            godFirstChar,
                                            style: hiddenGanLabelStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                          // if (godSecondChar != null)
                                          //   Text(
                                          //     godSecondChar,
                                          //     style: hiddenGanLabelStyle,
                                          //     textAlign: TextAlign.center,
                                          //   ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: seal.withAlpha(51),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

