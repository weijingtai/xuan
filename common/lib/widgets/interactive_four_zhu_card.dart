import 'dart:async';

import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InteractiveFourZhuCard extends StatefulWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final JiaZi? keZhu;
  final double width;

  const InteractiveFourZhuCard({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
    this.width = 380.0,
  }) : super(key: key);

  @override
  _InteractiveFourZhuCardState createState() => _InteractiveFourZhuCardState();
}

class _InteractiveFourZhuCardState extends State<InteractiveFourZhuCard> {
  // --- STATE VARIABLES ---
  // Options state
  bool _showTaiYuan = false;
  bool _showXunShou = false;
  bool _showNaYin = false;
  bool _showKongWang = false;
  bool _showKe = false;

  // Interaction state
  bool _isPinned = false;
  Timer? _exitTimer;

  // --- LIFECYCLE ---
  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  // --- INTERACTION LOGIC ---
  void _hideOptions() {
    _exitTimer?.cancel();
    _exitTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isPinned) {
        setState(() {
          _isPinned = false;
        });
      }
    });
  }

  void _showOptions() {
    _exitTimer?.cancel();
    if (!_isPinned) {
      setState(() {
        _isPinned = true;
      });
    }
  }

  // --- UI HELPERS ---
  TextStyle get _tianGanTextStyle => GoogleFonts.zhiMangXing(
        fontWeight: FontWeight.w200,
        fontSize: 28,
        height: 1,
      );

  TextStyle get _diZhiTextStyle => GoogleFonts.longCang(
        fontSize: 28,
        height: 1,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _labelTextStyle => GoogleFonts.zhiMangXing(
        fontSize: 14,
        height: 1.0,
      );

  Widget _buildInfoRow(BuildContext context, String label,
      Map<String, JiaZi> pillars, String Function(JiaZi) extractor) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20, // Provide a fixed height for the row
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillars.length > 0)
                    ? (constraints.maxWidth / pillars.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillars.entries.toList().asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    var entry = indexedEntry.value;
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: Text(
                        extractor(entry.value),
                        style: _labelTextStyle.copyWith(color: labelColor),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(
      String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildEigthCharsCard(
    BuildContext context,
    ThemeData theme,
    Color? labelColor,
    Map<String, JiaZi> pillars,
    bool showBottomLabels,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            // Pillar Headers
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('四柱',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 22, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.keys.toList().asMap().entries.map((indexedEntry) {
                          int index = indexedEntry.key;
                          String name = indexedEntry.value;
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: index * pillarWidth,
                            width: pillarWidth,
                            top: 0,
                            bottom: 0,
                            child: Text(name,
                                style: _labelTextStyle.copyWith(
                                    color: labelColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tian Gan
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('天干',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 28, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.values.toList().asMap().entries.map((indexedEntry) {
                           int index = indexedEntry.key;
                           JiaZi jiaZi = indexedEntry.value;
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: index * pillarWidth,
                            width: pillarWidth,
                            top: 0,
                            bottom: 0,
                            child: Text(
                              jiaZi.tianGan.value,
                              style: _tianGanTextStyle.copyWith(
                                  color: AppColors
                                      .zodiacGanColors[jiaZi.tianGan]),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Di Zhi
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('地支',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 28, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.values.toList().asMap().entries.map((indexedEntry) {
                          int index = indexedEntry.key;
                          JiaZi jiaZi = indexedEntry.value;
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: index * pillarWidth,
                            width: pillarWidth,
                            top: 0,
                            bottom: 0,
                            child: Text(
                              jiaZi.diZhi.value,
                              style: _diZhiTextStyle.copyWith(
                                  color: AppColors
                                      .zodiacZhiColors[jiaZi.diZhi]),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ],
            ),

            if (showBottomLabels)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
            if (_showXunShou)
              _buildInfoRow(context, '旬首', pillars,
                  (jiazi) => jiazi.getXunHeader().ganZhiStr),
            if (_showNaYin)
              _buildInfoRow(
                  context, '纳音', pillars, (jiazi) => jiazi.naYin.name),
            if (_showKongWang)
              _buildInfoRow(context, '空亡', pillars, (jiazi) {
                final kongWang = jiazi.getKongWang();
                return '${kongWang.item1.value}${kongWang.item2.value}';
              }),
          ],
        ),
      ),
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    final pillars = {
      '年': widget.eightChars.year,
      '月': widget.eightChars.month,
      '日': widget.eightChars.day,
      '时': widget.eightChars.time,
    };

    if (_showTaiYuan) {
      pillars['胎元'] = widget.taiYuan.taiYuanGanZhi;
    }
    if (_showKe && widget.keZhu != null) {
      pillars['刻'] = widget.keZhu!;
    }

    final bool showBottomLabels =
        _showXunShou || _showNaYin || _showKongWang;

    return SizedBox(
      width: widget.width,
      child: MouseRegion(
        onEnter: (_) => _showOptions(),
        onExit: (_) => _hideOptions(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildEigthCharsCard(
                  context,
                  theme,
                  labelColor,
                  pillars,
                  showBottomLabels,
                ),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: IconButton(
                    icon: Icon(
                        _isPinned ? Icons.settings_sharp : Icons.settings_outlined),
                    onPressed: () => setState(() => _isPinned = !_isPinned),
                    tooltip: 'Toggle options',
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: _isPinned
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0), // Increased padding
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildOptionChip('胎元', _showTaiYuan,
                          (val) => setState(() => _showTaiYuan = val)),
                      _buildOptionChip('旬首', _showXunShou,
                          (val) => setState(() => _showXunShou = val)),
                      _buildOptionChip('纳音', _showNaYin,
                          (val) => setState(() => _showNaYin = val)),
                      _buildOptionChip('空亡', _showKongWang,
                          (val) => setState(() => _showKongWang = val)),
                      if (widget.keZhu != null)
                        _buildOptionChip(
                            '刻', _showKe, (val) => setState(() => _showKe = val)),
                    ],
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