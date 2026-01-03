import 'package:common/enums.dart';
import 'package:common/models/pillar_data.dart';
import 'package:common/utils/constant_values_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';

/// 符合设计稿的垂直柱式八字卡片
/// 每个柱垂直排列，从上到下显示：柱头、天干、十神、地支、藏干、底部信息
class VerticalPillarCard extends StatelessWidget {
  final String? title;
  final List<PillarData> pillars;
  final TianGan dayMaster;
  final bool isBenMing;
  final Gender? gender;

  final bool showTenGods;
  final bool showTianGan;
  final bool showDiZhi;
  final bool showCangGanMain;
  final bool showCangGanZhong;
  final bool showCangGanYu;
  final bool showXunShou;
  final bool showNaYin;
  final bool showKongWang;

  const VerticalPillarCard({
    Key? key,
    this.title,
    required this.pillars,
    required this.dayMaster,
    required this.isBenMing,
    this.gender,
    this.showTenGods = true,
    this.showTianGan = true,
    this.showDiZhi = true,
    this.showCangGanMain = true,
    this.showCangGanZhong = false,
    this.showCangGanYu = false,
    this.showXunShou = false,
    this.showNaYin = true,
    this.showKongWang = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildCardHeader(theme),
          const Divider(height: 1),
          // 内容区 - 垂直柱布局
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildVerticalPillarLayout(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? '流年盘',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: '添加新属盘',
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.unfold_less, size: 20),
            tooltip: '收起',
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalPillarLayout(ThemeData theme) {
    // 过滤掉separator类型的柱
    final validPillars =
        pillars.where((p) => p.pillarId != 'separator').toList();

    if (validPillars.isEmpty) {
      return Center(
        child: Text(
          '暂无柱位数据',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < validPillars.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            Expanded(
              child: _buildSinglePillarColumn(
                pillar: validPillars[i],
                theme: theme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSinglePillarColumn({
    required PillarData pillar,
    required ThemeData theme,
  }) {
    final jiaZi = pillar.jiaZi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 柱头标签
          Text(
            pillar.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          // 天干
          if (showTianGan) ...[
            Text(
              jiaZi.tianGan.value,
              style: _getTianGanTextStyle().copyWith(
                color: AppColors.zodiacGanColors[jiaZi.tianGan] ?? Colors.black,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // 十神
          if (showTenGods) ...[
            Text(
              _getTenGodText(pillar.label, jiaZi),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.red.shade600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 地支
          if (showDiZhi) ...[
            Text(
              jiaZi.diZhi.value,
              style: _getDiZhiTextStyle().copyWith(
                color: AppColors.zodiacZhiColors[jiaZi.diZhi] ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 藏干信息
          if (showCangGanMain || showCangGanZhong || showCangGanYu) ...[
            _buildCangGanInfo(jiaZi, theme),
            const SizedBox(height: 8),
          ],

          // 底部信息区
          _buildBottomInfo(jiaZi, theme),
        ],
      ),
    );
  }

  Widget _buildCangGanInfo(JiaZi jiaZi, ThemeData theme) {
    final cangGanList = jiaZi.diZhi.cangGan;
    final parts = <String>[];

    if (showCangGanMain && cangGanList.isNotEmpty) {
      parts.add(cangGanList[0].value);
    }
    if (showCangGanZhong && cangGanList.length > 1) {
      parts.add(cangGanList[1].value);
    }
    if (showCangGanYu && cangGanList.length > 2) {
      parts.add(cangGanList[2].value);
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      '藏干: ${parts.join('')}',
      style: theme.textTheme.labelSmall?.copyWith(
        color: Colors.red.shade700,
        fontSize: 10,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomInfo(JiaZi jiaZi, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showKongWang)
          _buildBottomInfoLine('空亡', _getKongWangText(jiaZi), theme),
        if (showNaYin) _buildBottomInfoLine('纳音', jiaZi.naYin.name, theme),
        if (showXunShou)
          _buildBottomInfoLine('旬首', jiaZi.getXunHeader().ganZhiStr, theme),
      ],
    );
  }

  Widget _buildBottomInfoLine(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getTenGodText(String pillarLabel, JiaZi jiaZi) {
    if (isBenMing && pillarLabel == '日') {
      return FourZhuText.zaoLabelForGender(gender ?? Gender.unknown);
    }
    return jiaZi.tianGan.getTenGods(dayMaster).name;
  }

  String _getKongWangText(JiaZi jiaZi) {
    final kongWang = jiaZi.getKongWang();
    return '${kongWang.item1.value}${kongWang.item2.value}';
  }

  TextStyle _getTianGanTextStyle() {
    return GoogleFonts.zhiMangXing(
      fontWeight: FontWeight.w200,
      fontSize: 32,
      height: 1.0,
    );
  }

  TextStyle _getDiZhiTextStyle() {
    return GoogleFonts.longCang(
      fontSize: 32,
      height: 1.0,
      fontWeight: FontWeight.w500,
    );
  }
}
