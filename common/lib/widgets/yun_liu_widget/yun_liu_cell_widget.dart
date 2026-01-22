import 'package:common/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum YunLiuHiddenDisplayMode {
  hideHiddenGan,
  hideHiddenTenGod,
  showAll,
}

class YunLiuCellWidget extends StatelessWidget {
  final TianGan tianGan;
  final DiZhi diZhi;
  final ValueListenable<bool> isHoveredListenable;
  final ValueListenable<YunLiuHiddenDisplayMode> displayModeListenable;

  double ganZhiFontSize = 20;
  double hiddenFontSize = 10;

  YunLiuCellWidget({
    super.key,
    required this.tianGan,
    required this.diZhi,
    required this.isHoveredListenable,
    required this.displayModeListenable,
    this.centerRowFlex = 5,
    this.centerColFlex = 5,
    this.ganZhiFontSize = 24,
  });

  final int centerRowFlex;
  final int centerColFlex;

  @override
  Widget build(BuildContext context) {
    return _buildOuterContainer(
      child: _buildJingGrid(
        context: context,
        centerRowFlex: centerRowFlex,
        centerColFlex: centerColFlex,
      ),
    );
  }

  Widget buildCenterContent(
    BuildContext context, {
    required bool isHovered,
    required YunLiuHiddenDisplayMode displayMode,
  }) {
    final diZhiHiddenCount = _diZhiHiddenCount();
    final sharedHiddenCount = diZhiHiddenCount == 0 ? 1 : diZhiHiddenCount;
    final hiddenFontScale =
        displayMode == YunLiuHiddenDisplayMode.showAll ? 1.0 : 1.6;
    final dxCompensationFactor =
        displayMode == YunLiuHiddenDisplayMode.showAll ? 0.55 : 1.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAnimatedMainAndHiddenLine(
              isHovered: isHovered,
              hiddenCount: sharedHiddenCount,
              hiddenFontScale: hiddenFontScale,
              dxCompensationFactor: dxCompensationFactor,
              main: Text(
                tianGan.name,
                style: getTianGanStyle(),
              ),
              hidden: _buildTianGanHiddenTenGod(displayMode),
            ),
            const SizedBox(height: 2),
            _buildAnimatedMainAndHiddenLine(
              isHovered: isHovered,
              hiddenCount: diZhiHiddenCount,
              hiddenFontScale: hiddenFontScale,
              dxCompensationFactor: dxCompensationFactor,
              main: Text(
                diZhi.name,
                style: getDiZhiStyle(),
              ),
              hidden: _buildDiZhiHiddenRow(displayMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTianGanHiddenTenGod(YunLiuHiddenDisplayMode displayMode) {
    final showGan = displayMode != YunLiuHiddenDisplayMode.hideHiddenGan;
    final showTenGod = displayMode != YunLiuHiddenDisplayMode.hideHiddenTenGod;
    final isSingleLine = showGan ^ showTenGod;
    final fontSizeScale = isSingleLine ? 1.6 : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showGan)
          Text(
            tianGan.name,
            style: getDiZhiHiddenGanStyle(
              tianGan,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
        if (showTenGod)
          Text(
            EnumTenGods.ZhenCai.shortName,
            style: getDiZhiHiddenGodsStyle(
              EnumTenGods.ZhenCai,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
      ],
    );
  }

  List<MapEntry<TianGan, EnumTenGods>> _diZhiHiddenDefs() {
    return [
      const MapEntry(TianGan.JIA, EnumTenGods.ZhengYin),
      const MapEntry(TianGan.YI, EnumTenGods.PanYin),
      // const MapEntry(TianGan.BING, EnumTenGods.JieCai),
    ];
  }

  int _diZhiHiddenCount() => _diZhiHiddenDefs().length;

  List<Widget> _buildDiZhiHiddenItems(YunLiuHiddenDisplayMode displayMode) {
    return _diZhiHiddenDefs()
        .map((e) => buildDiZhiEachHidden(e.key, e.value, displayMode))
        .toList();
  }

  Widget _buildDiZhiHiddenRow(YunLiuHiddenDisplayMode displayMode) {
    final items = _buildDiZhiHiddenItems(displayMode);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i > 0 && i != items.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildAnimatedMainAndHiddenLine({
    required bool isHovered,
    required int hiddenCount,
    required double hiddenFontScale,
    required double dxCompensationFactor,
    required Widget main,
    required Widget hidden,
  }) {
    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOutCubic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final baseHiddenWidth = _reservedWidthForHidden(
          maxWidth: maxWidth,
          hiddenCount: hiddenCount,
          hiddenFontScale: hiddenFontScale,
        );

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isHovered ? 1.0 : 0.0),
          duration: duration,
          curve: curve,
          builder: (context, t, _) {
            const gap = 10.0;
            final gapWidth = gap * t;
            final hiddenWidth = baseHiddenWidth * t + gapWidth;

            final rawDxMain =
                (baseHiddenWidth * 0.22).clamp(0.0, maxWidth * 0.22) * t;

            final rawDxHidden =
                (baseHiddenWidth * 0.55).clamp(0.0, maxWidth * 0.45) * t;
            final maxDxHidden =
                ((maxWidth - hiddenWidth) / 2).clamp(0.0, maxWidth).toDouble();
            final dxHidden = rawDxHidden.clamp(0.0, maxDxHidden).toDouble();

            final rawDxGapLoss = (rawDxHidden - dxHidden).clamp(0.0, maxWidth);
            final maxMainShiftFactor = dxCompensationFactor < 1 ? 0.24 : 0.28;
            final dxMain = rawDxHidden <= 0
                ? 0.0
                : (rawDxMain + rawDxGapLoss * dxCompensationFactor)
                    .clamp(0.0, maxWidth * maxMainShiftFactor)
                    .toDouble();

            return SizedBox(
              height: ganZhiFontSize * 1.1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(-dxMain, 0),
                    child: main,
                  ),
                  if (baseHiddenWidth > 0)
                    IgnorePointer(
                      ignoring: t == 0,
                      child: Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(dxHidden, 0),
                          child: SizedBox(
                            width: hiddenWidth,
                            child: Padding(
                              padding: EdgeInsets.only(left: gapWidth),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: hidden,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _reservedWidthForHidden({
    required double maxWidth,
    required int hiddenCount,
    required double hiddenFontScale,
  }) {
    if (hiddenCount <= 0) return 0;

    const spacing = 4.0;
    const padding = 6.0;

    final perItem = hiddenFontSize * hiddenFontScale * 1.7 + 6;
    final raw = hiddenCount * perItem + (hiddenCount - 1) * spacing + padding;

    final maxAllowed = maxWidth * 0.70;
    final minMainWidth = maxWidth * 0.48;
    final maxReservedByMinMain = (maxWidth - minMainWidth).clamp(0.0, maxWidth);

    final capped = raw.clamp(0.0, maxAllowed);
    return capped.clamp(0.0, maxReservedByMinMain).toDouble();
  }

  Widget buildDiZhiEachHidden(
    TianGan gan,
    EnumTenGods tenGods,
    YunLiuHiddenDisplayMode displayMode,
  ) {
    final showGan = displayMode != YunLiuHiddenDisplayMode.hideHiddenGan;
    final showTenGod = displayMode != YunLiuHiddenDisplayMode.hideHiddenTenGod;
    final isSingleLine = showGan ^ showTenGod;
    final fontSizeScale = isSingleLine ? 1.6 : 1.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showGan)
          Text(
            gan.name,
            style: getDiZhiHiddenGanStyle(
              gan,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
        if (showTenGod)
          Text(
            tenGods.shortName,
            style: getDiZhiHiddenGodsStyle(
              tenGods,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
      ],
    );
  }

  Widget _buildOuterContainer({required Widget child}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.blueGrey.withAlpha(50),
      child: child,
    );
  }

  Widget _buildJingGrid({
    required BuildContext context,
    required int centerRowFlex,
    required int centerColFlex,
  }) {
    final lineColor = Colors.white.withAlpha(140);
    const lineWidth = 1.0;

    final rowFlex = [1, centerRowFlex, 1];
    final colFlex = [1, centerColFlex, 1];

    return Container(
      child: Column(
        children: List.generate(3, (row) {
          return Flexible(
            flex: rowFlex[row],
            child: Row(
              children: List.generate(3, (col) {
                return Flexible(
                  flex: colFlex[col],
                  child: _buildGridCellContainer(
                    row: row,
                    col: col,
                    lineColor: lineColor,
                    lineWidth: lineWidth,
                    child: _buildGridCellChild(context, row, col),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridCellContainer({
    required int row,
    required int col,
    required Color lineColor,
    required double lineWidth,
    required Widget child,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: col < 2
              ? BorderSide(color: lineColor, width: lineWidth)
              : BorderSide.none,
          bottom: row < 2
              ? BorderSide(color: lineColor, width: lineWidth)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  Widget _buildGridCellChild(BuildContext context, int row, int col) {
    if (row == 0 && col == 0) return _buildTopLeft(context);
    if (row == 0 && col == 1) return _buildTopCenter(context);
    if (row == 0 && col == 2) return _buildTopRight(context);
    if (row == 1 && col == 0) return _buildMiddleLeft(context);
    if (row == 1 && col == 1) return _buildMiddleCenter(context);
    if (row == 1 && col == 2) return _buildMiddleRight(context);
    if (row == 2 && col == 0) return _buildBottomLeft(context);
    if (row == 2 && col == 1) return _buildBottomCenter(context);
    if (row == 2 && col == 2) return _buildBottomRight(context);
    return const SizedBox.shrink();
  }

  Widget _buildTopLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildTopCenter(BuildContext context) => const SizedBox.shrink();

  Widget _buildTopRight(BuildContext context) => const SizedBox.shrink();

  Widget _buildMiddleLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildMiddleCenter(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isHoveredListenable,
      builder: (context, isHovered, _) {
        return ValueListenableBuilder<YunLiuHiddenDisplayMode>(
          valueListenable: displayModeListenable,
          builder: (context, displayMode, __) {
            return buildCenterContent(
              context,
              isHovered: isHovered,
              displayMode: displayMode,
            );
          },
        );
      },
    );
  }

  Widget _buildMiddleRight(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomCenter(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomRight(BuildContext context) => const SizedBox.shrink();

  TextStyle getTenGodsStyle(EnumTenGods tenGods) {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.purple,
    );
  }

  TextStyle getDiZhiHiddenGodsStyle(
    EnumTenGods tenGods, {
    double? fontSize,
  }) {
    return TextStyle(
        fontSize: fontSize ?? hiddenFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.purple,
        height: 1.1);
  }

  TextStyle getDiZhiHiddenGanStyle(
    TianGan tianGan, {
    double? fontSize,
  }) {
    return TextStyle(
        fontSize: fontSize ?? hiddenFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
        height: 1.1);
  }

  TextStyle getTianGanStyle() {
    return TextStyle(
      fontSize: ganZhiFontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.1,
    );
  }

  TextStyle getDiZhiStyle() {
    return TextStyle(
        fontSize: ganZhiFontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.1);
  }
}

class YunLiuCellWidget2 extends StatelessWidget {
  final TianGan tianGan;
  final DiZhi diZhi;
  final EnumTenGods ganGod = EnumTenGods.ZhengYin;
  final ValueListenable<bool> isHoveredListenable;
  final ValueListenable<YunLiuHiddenDisplayMode> displayModeListenable;

  double ganZhiFontSize = 14;
  double hiddenFontSize = 10;

  YunLiuCellWidget2({
    super.key,
    required this.tianGan,
    required this.diZhi,
    required this.isHoveredListenable,
    required this.displayModeListenable,
    this.centerRowFlex = 5,
    this.centerColFlex = 5,
    // this.ganZhiFontSize = 24,
  });

  final int centerRowFlex;
  final int centerColFlex;

  @override
  Widget build(BuildContext context) {
    return _buildOuterContainer(
      child: _buildJingGrid(
        context: context,
        centerRowFlex: centerRowFlex,
        centerColFlex: centerColFlex,
      ),
    );
  }

  Widget buildCenterContent(
    BuildContext context, {
    required bool isHovered,
    required YunLiuHiddenDisplayMode displayMode,
  }) {
    final diZhiHiddenCount = _diZhiHiddenCount();
    final sharedHiddenCount = diZhiHiddenCount == 0 ? 1 : diZhiHiddenCount;
    final hiddenFontScale =
        displayMode == YunLiuHiddenDisplayMode.showAll ? 1.0 : 1.6;
    final dxCompensationFactor =
        displayMode == YunLiuHiddenDisplayMode.showAll ? 0.55 : 1.0;

    return Container(
      color: Colors.amber.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  tianGan.name,
                  style: getTianGanStyle(),
                ),
                Text(
                  ganGod.shortName,
                  style: getTenGodsStyle(EnumTenGods.BiJian),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      diZhi.name,
                      style: getDiZhiStyle(),
                    ),
                    Text(
                      " ",
                      style: getTenGodsStyle(EnumTenGods.BiJian),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      EnumTenGods.BiJian.shortName,
                      style: getTenGodsStyle(EnumTenGods.BiJian),
                    ),
                    Text(
                      TianGan.GUI.name,
                      style: getDiZhiHiddenGanStyle(TianGan.GUI),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      EnumTenGods.PanYin.shortName,
                      style: getTenGodsStyle(EnumTenGods.BiJian),
                    ),
                    Text(
                      TianGan.GENG.name,
                      style: getDiZhiHiddenGanStyle(TianGan.GENG),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      EnumTenGods.PanYin.shortName,
                      style: getTenGodsStyle(EnumTenGods.BiJian),
                    ),
                    Text(
                      TianGan.WU.name,
                      style: getDiZhiHiddenGanStyle(TianGan.WU),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTianGanHiddenTenGod(YunLiuHiddenDisplayMode displayMode) {
    final showGan = displayMode != YunLiuHiddenDisplayMode.hideHiddenGan;
    final showTenGod = displayMode != YunLiuHiddenDisplayMode.hideHiddenTenGod;
    final isSingleLine = showGan ^ showTenGod;
    final fontSizeScale = isSingleLine ? 1.6 : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showGan)
          Text(
            tianGan.name,
            style: getDiZhiHiddenGanStyle(
              tianGan,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
        if (showTenGod)
          Text(
            EnumTenGods.ZhenCai.shortName,
            style: getDiZhiHiddenGodsStyle(
              EnumTenGods.ZhenCai,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
      ],
    );
  }

  List<MapEntry<TianGan, EnumTenGods>> _diZhiHiddenDefs() {
    return [
      const MapEntry(TianGan.JIA, EnumTenGods.ZhengYin),
      const MapEntry(TianGan.YI, EnumTenGods.PanYin),
      // const MapEntry(TianGan.BING, EnumTenGods.JieCai),
    ];
  }

  int _diZhiHiddenCount() => _diZhiHiddenDefs().length;

  List<Widget> _buildDiZhiHiddenItems(YunLiuHiddenDisplayMode displayMode) {
    return _diZhiHiddenDefs()
        .map((e) => buildDiZhiEachHidden(e.key, e.value, displayMode))
        .toList();
  }

  Widget _buildDiZhiHiddenRow(YunLiuHiddenDisplayMode displayMode) {
    final items = _buildDiZhiHiddenItems(displayMode);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i > 0 && i != items.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildAnimatedMainAndHiddenLine({
    required bool isHovered,
    required int hiddenCount,
    required double hiddenFontScale,
    required double dxCompensationFactor,
    required Widget main,
    required Widget hidden,
  }) {
    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOutCubic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final baseHiddenWidth = _reservedWidthForHidden(
          maxWidth: maxWidth,
          hiddenCount: hiddenCount,
          hiddenFontScale: hiddenFontScale,
        );

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isHovered ? 1.0 : 0.0),
          duration: duration,
          curve: curve,
          builder: (context, t, _) {
            const gap = 10.0;
            final gapWidth = gap * t;
            final hiddenWidth = baseHiddenWidth * t + gapWidth;

            final rawDxMain =
                (baseHiddenWidth * 0.22).clamp(0.0, maxWidth * 0.22) * t;

            final rawDxHidden =
                (baseHiddenWidth * 0.55).clamp(0.0, maxWidth * 0.45) * t;
            final maxDxHidden =
                ((maxWidth - hiddenWidth) / 2).clamp(0.0, maxWidth).toDouble();
            final dxHidden = rawDxHidden.clamp(0.0, maxDxHidden).toDouble();

            final rawDxGapLoss = (rawDxHidden - dxHidden).clamp(0.0, maxWidth);
            final maxMainShiftFactor = dxCompensationFactor < 1 ? 0.24 : 0.28;
            final dxMain = rawDxHidden <= 0
                ? 0.0
                : (rawDxMain + rawDxGapLoss * dxCompensationFactor)
                    .clamp(0.0, maxWidth * maxMainShiftFactor)
                    .toDouble();

            return SizedBox(
              height: ganZhiFontSize * 1.1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(-dxMain, 0),
                    child: main,
                  ),
                  if (baseHiddenWidth > 0)
                    IgnorePointer(
                      ignoring: t == 0,
                      child: Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(dxHidden, 0),
                          child: SizedBox(
                            width: hiddenWidth,
                            child: Padding(
                              padding: EdgeInsets.only(left: gapWidth),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: hidden,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _reservedWidthForHidden({
    required double maxWidth,
    required int hiddenCount,
    required double hiddenFontScale,
  }) {
    if (hiddenCount <= 0) return 0;

    const spacing = 4.0;
    const padding = 6.0;

    final perItem = hiddenFontSize * hiddenFontScale * 1.7 + 6;
    final raw = hiddenCount * perItem + (hiddenCount - 1) * spacing + padding;

    final maxAllowed = maxWidth * 0.70;
    final minMainWidth = maxWidth * 0.48;
    final maxReservedByMinMain = (maxWidth - minMainWidth).clamp(0.0, maxWidth);

    final capped = raw.clamp(0.0, maxAllowed);
    return capped.clamp(0.0, maxReservedByMinMain).toDouble();
  }

  Widget buildDiZhiEachHidden(
    TianGan gan,
    EnumTenGods tenGods,
    YunLiuHiddenDisplayMode displayMode,
  ) {
    final showGan = displayMode != YunLiuHiddenDisplayMode.hideHiddenGan;
    final showTenGod = displayMode != YunLiuHiddenDisplayMode.hideHiddenTenGod;
    final isSingleLine = showGan ^ showTenGod;
    final fontSizeScale = isSingleLine ? 1.6 : 1.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showGan)
          Text(
            gan.name,
            style: getDiZhiHiddenGanStyle(
              gan,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
        if (showTenGod)
          Text(
            tenGods.shortName,
            style: getDiZhiHiddenGodsStyle(
              tenGods,
              fontSize: hiddenFontSize * fontSizeScale,
            ),
          ),
      ],
    );
  }

  Widget _buildOuterContainer({required Widget child}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.blueGrey.withAlpha(50),
      child: child,
    );
  }

  Widget _buildJingGrid({
    required BuildContext context,
    required int centerRowFlex,
    required int centerColFlex,
  }) {
    final lineColor = Colors.white.withAlpha(140);
    const lineWidth = 1.0;

    final rowFlex = [1, centerRowFlex, 1];
    final colFlex = [1, centerColFlex, 1];

    return Container(
      child: Column(
        children: List.generate(3, (row) {
          return Flexible(
            flex: rowFlex[row],
            child: Row(
              children: List.generate(3, (col) {
                return Flexible(
                  flex: colFlex[col],
                  child: _buildGridCellContainer(
                    row: row,
                    col: col,
                    lineColor: lineColor,
                    lineWidth: lineWidth,
                    child: _buildGridCellChild(context, row, col),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridCellContainer({
    required int row,
    required int col,
    required Color lineColor,
    required double lineWidth,
    required Widget child,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: col < 2
              ? BorderSide(color: lineColor, width: lineWidth)
              : BorderSide.none,
          bottom: row < 2
              ? BorderSide(color: lineColor, width: lineWidth)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  Widget _buildGridCellChild(BuildContext context, int row, int col) {
    if (row == 0 && col == 0) return _buildTopLeft(context);
    if (row == 0 && col == 1) return _buildTopCenter(context);
    if (row == 0 && col == 2) return _buildTopRight(context);
    if (row == 1 && col == 0) return _buildMiddleLeft(context);
    if (row == 1 && col == 1) return _buildMiddleCenter(context);
    if (row == 1 && col == 2) return _buildMiddleRight(context);
    if (row == 2 && col == 0) return _buildBottomLeft(context);
    if (row == 2 && col == 1) return _buildBottomCenter(context);
    if (row == 2 && col == 2) return _buildBottomRight(context);
    return const SizedBox.shrink();
  }

  Widget _buildTopLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildTopCenter(BuildContext context) => const SizedBox.shrink();

  Widget _buildTopRight(BuildContext context) => const SizedBox.shrink();

  Widget _buildMiddleLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildMiddleCenter(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isHoveredListenable,
      builder: (context, isHovered, _) {
        return ValueListenableBuilder<YunLiuHiddenDisplayMode>(
          valueListenable: displayModeListenable,
          builder: (context, displayMode, __) {
            return buildCenterContent(
              context,
              isHovered: isHovered,
              displayMode: displayMode,
            );
          },
        );
      },
    );
  }

  Widget _buildMiddleRight(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomLeft(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomCenter(BuildContext context) => const SizedBox.shrink();

  Widget _buildBottomRight(BuildContext context) => const SizedBox.shrink();

  TextStyle getTenGodsStyle(EnumTenGods tenGods) {
    return TextStyle(
      fontSize: hiddenFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
    );
  }

  TextStyle getDiZhiHiddenGodsStyle(
    EnumTenGods tenGods, {
    double? fontSize,
  }) {
    return TextStyle(
        fontSize: fontSize ?? hiddenFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.purple,
        height: 1.1);
  }

  TextStyle getDiZhiHiddenGanStyle(
    TianGan tianGan, {
    double? fontSize,
  }) {
    return TextStyle(
      fontSize: hiddenFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.purple,
    );
    // return TextStyle(
    //     fontSize: fontSize ?? hiddenFontSize,
    //     fontWeight: FontWeight.normal,
    //     color: Colors.black87,
    //     height: 1.1);
  }

  TextStyle getTianGanStyle() {
    return TextStyle(
      fontSize: ganZhiFontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
      height: 1.1,
    );
  }

  TextStyle getDiZhiStyle() {
    return TextStyle(
        fontSize: ganZhiFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
        height: 1.1);
  }
}
