import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:common/widgets/row_reorderable_card.dart'; // To reuse CardRow constants
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColumnReorderableCard extends StatelessWidget {
  final String? title;
  final Map<String, JiaZi> pillars;
  final List<String> pillarOrder;
  final void Function(int oldIndex, int newIndex) onPillarReorder;

  const ColumnReorderableCard({
    Key? key,
    this.title,
    required this.pillars,
    required this.pillarOrder,
    required this.onPillarReorder,
  }) : super(key: key);

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

  Widget _buildPillarColumn(BuildContext context, String pillarKey) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    final jiaZi = pillars[pillarKey]!;

    return Container(
      key: ValueKey('${title}_${pillarKey}_col'),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(pillarKey,
              style: _labelTextStyle.copyWith(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          // Tian Gan
          Text(
            jiaZi.tianGan.value,
            style: _tianGanTextStyle.copyWith(
                color: AppColors.zodiacGanColors[jiaZi.tianGan]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Di Zhi
          Text(
            jiaZi.diZhi.value,
            style: _diZhiTextStyle.copyWith(
                color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
            textAlign: TextAlign.center,
          ),
          const Divider(),
          // Info Rows (simplified for column view)
          Text(jiaZi.getXunHeader().ganZhiStr, style: _labelTextStyle.copyWith(color: labelColor)),
          Text(jiaZi.naYin.name, style: _labelTextStyle.copyWith(color: labelColor)),
          Text('${jiaZi.getKongWang().item1.value}${jiaZi.getKongWang().item2.value}', style: _labelTextStyle.copyWith(color: labelColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          SizedBox(
            height: 250, // Fixed height for horizontal list
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              onReorder: onPillarReorder,
              children: pillarOrder
                  .map((pillarKey) => _buildPillarColumn(context, pillarKey))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
