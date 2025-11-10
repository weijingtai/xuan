import 'package:flutter/material.dart';

/// TextGroup
/// Defines logical text groups in the FourZhu V3 card for per-group styling.
///
/// Groups:
/// - tianGan: 天干文本
/// - diZhi: 地支文本
/// - naYin: 纳音文本
/// - kongWang: 空亡文本
/// - columnTitle: 柱标题（列标题）
/// - rowTitle: 行标题
enum TextGroup {
  tianGan,
  diZhi,
  naYin,
  kongWang,
  columnTitle,
  rowTitle,
  /// 十神内容文本（保守默认样式）
  tenGod,
  /// 旬首内容文本（保守默认样式）
  xunShou,
  /// 藏干系列内容文本（统一映射到一个分组，保守默认样式）
  hiddenStems,
}

/// Utility to clone a `TextStyle` ensuring null-safety.
///
/// Parameters:
/// - [style]: Base style to clone; may be null.
///
/// Returns: A cloned `TextStyle` or a default empty style.
TextStyle cloneTextStyle(TextStyle? style) {
  return (style ?? const TextStyle()).copyWith();
}