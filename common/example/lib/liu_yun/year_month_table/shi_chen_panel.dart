import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:flutter/material.dart';

import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class ShiChenPanel extends StatefulWidget {
  final DateTime date;
  final bool isPhone;

  const ShiChenPanel({super.key, required this.date, required this.isPhone});

  @override
  State<ShiChenPanel> createState() => _ShiChenPanelState();
}

class _ShiChenPanelState extends State<ShiChenPanel> {
  bool _minuteMode = false;

  late final List<int?> _selectedQuarterByRow;
  late final List<int?> _selectedMinuteByRow;

  final List<String> _shiChen = const [
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥',
  ];

  @override
  void initState() {
    super.initState();
    _selectedQuarterByRow = List<int?>.filled(_shiChen.length, null);
    _selectedMinuteByRow = List<int?>.filled(_shiChen.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.isPhone;
    final leftW = isPhone ? 54.0 : 72.0;

    return Padding(
      padding: EdgeInsets.all(isPhone ? 12 : 16),
      child: Column(
        children: [
          _InkModeSwitch(
            isPhone: isPhone,
            minuteMode: _minuteMode,
            onChange: (v) => setState(() => _minuteMode = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DoubleInkBorder(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(160),
                      Colors.white.withAlpha(110),
                      InkTheme.washHi(10),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    _InkGridHeader(leftW: leftW, minuteMode: _minuteMode),
                    Expanded(
                      child: Row(
                        children: [
                          _InkShiChenColumn(
                            width: leftW,
                            isPhone: isPhone,
                            labels: _shiChen,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: InkTheme.line(70),
                                    width: 0.6,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (var i = 0; i < _shiChen.length; i++) ...[
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isPhone ? 10 : 14,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _minuteMode
                                              ? _MinuteRuler(
                                                  isPhone: isPhone,
                                                  selectedMinute:
                                                      _selectedMinuteByRow[i],
                                                  onSelect: (m) {
                                                    setState(() {
                                                      _selectedMinuteByRow[i] =
                                                          m;
                                                    });
                                                  },
                                                )
                                              : _QuarterSelectorRow(
                                                  isPhone: isPhone,
                                                  selectedQuarter:
                                                      _selectedQuarterByRow[i],
                                                  onSelect: (q) {
                                                    setState(() {
                                                      _selectedQuarterByRow[i] =
                                                          q;
                                                    });
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                    if (i != _shiChen.length - 1)
                                      Divider(
                                        height: 1,
                                        color: InkTheme.line(70),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkModeSwitch extends StatelessWidget {
  final bool isPhone;
  final bool minuteMode;
  final ValueChanged<bool> onChange;

  const _InkModeSwitch({
    required this.isPhone,
    required this.minuteMode,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
      height: 1.0,
      color: InkTheme.ink.withAlpha(210),
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        SegmentedButton<bool>(
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              label: Text('刻', style: textStyle),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text('分', style: textStyle),
            ),
          ],
          selected: <bool>{minuteMode},
          onSelectionChanged: (s) => onChange(s.first),
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: 8),
            ),
            side: WidgetStateProperty.all(
              BorderSide(color: InkTheme.line(70), width: 0.6),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return InkTheme.sealWash(40);
              }
              return Colors.white.withAlpha(150);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return InkTheme.sealWash(26);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withAlpha(70);
              }
              return null;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            minuteMode ? '选择分钟刻度（5 分钟步进）' : '选择刻度（每刻 15 分钟）',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.0,
              color: InkTheme.ink.withAlpha(140),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InkGridHeader extends StatelessWidget {
  final double leftW;
  final bool minuteMode;

  const _InkGridHeader({required this.leftW, required this.minuteMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
        ),
        color: Colors.white.withAlpha(120),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: leftW,
            child: Center(
              child: Text(
                '时辰',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  color: InkTheme.ink.withAlpha(170),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(width: 1, color: InkTheme.line(70)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  minuteMode ? '分钟' : '刻度',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.0,
                    color: InkTheme.ink.withAlpha(170),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkShiChenColumn extends StatelessWidget {
  final double width;
  final bool isPhone;
  final List<String> labels;

  const _InkShiChenColumn({
    required this.width,
    required this.isPhone,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final box = isPhone ? 30.0 : 40.0;
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(70),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(14),
          ),
        ),
        child: Column(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Expanded(
                child: Center(
                  child: Container(
                    width: box,
                    height: box,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(140),
                      border: Border.all(color: InkTheme.line(55), width: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: ConstUIResourcesMapper.tianGanTextStyle.copyWith(
                          fontSize: isPhone ? 16 : 18,
                          shadows: const [],
                          height: 1.0,
                          color: InkTheme.ink.withAlpha(220),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1)
                Divider(height: 1, color: InkTheme.line(70)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuarterSelectorRow extends StatelessWidget {
  final bool isPhone;
  final int? selectedQuarter;
  final ValueChanged<int> onSelect;

  const _QuarterSelectorRow({
    required this.isPhone,
    required this.selectedQuarter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return LayoutBuilder(
      builder: (context, _) {
        return Row(
          children: [
            for (var i = 0; i < 8; i++) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 2 : 3,
                    vertical: isPhone ? 4 : 6,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: radius,
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return InkTheme.sealWash(26);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.white.withAlpha(70);
                        }
                        return null;
                      }),
                      onTap: () => onSelect(i),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(
                            color: selectedQuarter == i
                                ? InkTheme.seal.withAlpha(150)
                                : InkTheme.line(55),
                            width: selectedQuarter == i ? 1.0 : 0.6,
                          ),
                          color: selectedQuarter == i
                              ? InkTheme.sealWash(38)
                              : Colors.white.withAlpha(150),
                        ),
                        child: Center(
                          child: Text(
                            '${i * 15}',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              color: selectedQuarter == i
                                  ? InkTheme.seal.withAlpha(210)
                                  : InkTheme.ink.withAlpha(170),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MinuteRuler extends StatelessWidget {
  final bool isPhone;
  final int? selectedMinute;
  final ValueChanged<int> onSelect;

  const _MinuteRuler({
    required this.isPhone,
    required this.selectedMinute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final height = isPhone ? 26.0 : 28.0;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return InkTheme.sealWash(26);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withAlpha(70);
                }
                return null;
              }),
              onTapDown: (d) {
                final x = d.localPosition.dx.clamp(0.0, c.maxWidth);
                final raw = ((x / c.maxWidth) * 60).round();
                final snapped = (raw / 5).round() * 5;
                onSelect(snapped.clamp(0, 60));
              },
              onTap: () {},
              child: Ink(
                decoration: BoxDecoration(
                  border: Border.all(color: InkTheme.line(70), width: 0.6),
                  color: Colors.white.withAlpha(150),
                  borderRadius: radius,
                ),
                child: CustomPaint(
                  painter: MinuteRulerPainter(selectedMinute: selectedMinute),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
