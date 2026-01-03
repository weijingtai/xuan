import 'package:flutter/material.dart';
import 'text_groups.dart';
import 'package:common/enums/enum_di_zhi.dart' as dz;
import 'package:common/enums/enum_tian_gan.dart' as tg;
import 'package:common/palette/card_palette.dart';

/// ColorfulCellWidget
/// Renders a single token with either uniform style or per-token palette color
/// based on the `colorful` flag and current brightness.
///
/// Parameters:
/// - [group]: Text group metadata (e.g., tianGan/diZhi) for styling decisions.
/// - [text]: Display text content.
/// - [gan]: Optional `tg.TianGan` enum when rendering a Heavenly Stem.
/// - [zhi]: Optional `dz.DiZhi` enum when rendering an Earthly Branch.
/// - [uniformStyle]: Base text style (font family/size/weight/color).
/// - [colorful]: Whether to use per-token color from a type-safe palette.
/// - [palette]: Optional `CardPalette`; falls back to `CardPalette.defaultPalette()`.
/// - [perTokenColor]: Optional explicit per-token color override.
/// - [perTokenStyle]: Optional full per-token `TextStyle` override.
///
/// Returns: A `Text` widget with resolved style.
class ColorfulCellWidget extends StatelessWidget {
  /// 文本分组（用于样式分组选择与元数据标识）。
  final TextGroup group;
  /// 需要展示的文本。
  final String text;
  /// 天干枚举（与 `zhi` 二选一）。
  final tg.TianGan? gan;
  /// 地支枚举（与 `gan` 二选一）。
  final dz.DiZhi? zhi;
  /// 基础（统一）样式，用于未开启彩色或未找到映射时。
  final TextStyle uniformStyle;
  /// 是否启用彩色模式（按枚举映射至调色盘）。
  final bool colorful;
  /// 类型安全的卡片调色盘（枚举键映射）。
  final CardPalette? palette;
  /// 显式的每项颜色覆写（优先级高于调色盘）。
  final Color? perTokenColor;
  /// 显式的每项样式覆写（最高优先级）。
  final TextStyle? perTokenStyle;

  const ColorfulCellWidget({
    super.key,
    required this.group,
    required this.text,
    this.gan,
    this.zhi,
    required this.uniformStyle,
    required this.colorful,
    this.palette,
    this.perTokenColor,
    this.perTokenStyle,
  });

  @override
  Widget build(BuildContext context) {
    final CardPalette pal = palette ?? CardPalette.defaultPalette();

    // Highest priority: explicit per-token full style
    if (perTokenStyle != null) {
      return Text(text, style: perTokenStyle);
    }

    // Next priority: explicit per-token color, overriding uniformStyle.color
    if (perTokenColor != null) {
      return Text(text, style: uniformStyle.copyWith(color: perTokenColor));
    }

    // Colorful mode: resolve palette color by enum keys (type-safe)
    if (colorful) {
      Color? resolved;
      if (gan != null) {
        resolved = pal.ganColors[gan!];
      } else if (zhi != null) {
        resolved = pal.zhiColors[zhi!];
      }
      if (resolved != null) {
        return Text(text, style: uniformStyle.copyWith(color: resolved));
      }
    }

    // Fallback: uniform style
    return Text(text, style: uniformStyle);
  }
}
