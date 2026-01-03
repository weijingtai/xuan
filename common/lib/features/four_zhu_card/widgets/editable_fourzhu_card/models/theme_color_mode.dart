import 'package:json_annotation/json_annotation.dart';

/// 文本样式配置数据类
///
/// 封装所有字体样式属性，支持 JSON 序列化和与 Flutter TextStyle 的双向转换。
///
/// 设计原则：
/// 1. 所有字段可选（nullable），默认值由 TextStyle 提供
/// 2. 使用可序列化类型（String, double, int）而非 Flutter 类型
/// 3. 向后兼容：可从旧的 RowConfig 离散字段构造
/// 颜色预览模式（用于样式编辑场景的模式持久化）
/// - pure：纯色预览（不按五行元素着色）
/// - colorful：彩色预览（按元素或策略着色）
enum TextColorMode {
  @JsonValue("pure")
  pure,
  @JsonValue("colorful")
  colorful
}
