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