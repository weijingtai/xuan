import 'package:flutter/material.dart';
import '../../../enums/layout_template_enums.dart';
import '../../../themes/editable_four_zhu_card_theme.dart';

/// CardStyleConfig
///
/// 功能描述：
/// - 封装卡片容器的视觉样式（边框、背景、圆角、内边距、阴影、尺寸）。
/// - 提供类型转换方法以应用到 Flutter 的 `BoxDecoration`、`EdgeInsets` 与 `BoxConstraints`。
/// - 提供 JSON 序列化/反序列化与向后兼容的工厂方法。
/// 参数说明：各字段均为可选，缺省时不影响现有渲染（保持向后兼容）。
/// 返回值：不可变对象；通过 `copyWith` 创建更新版本。
class CardShadow {
  final bool withShadow;
  final bool followCardBackgroundColor;
  final Color lightThemeColor;
  final Color darkThemeColor;
  final Offset offset;
  final double blurRadius;
  final double spreadRadius;
  // 阴影透明度（0.0~1.0）。与颜色的 Alpha 叠加时，以该值为准。
  final double opacity;

  CardShadow({
    required this.withShadow,
    required this.followCardBackgroundColor,
    required this.lightThemeColor,
    required this.darkThemeColor,
    required this.offset,
    required this.blurRadius,
    required this.spreadRadius,
    required this.opacity,
  });

  static CardShadow defaultShadow = CardShadow(
    withShadow: true,
    followCardBackgroundColor: false,
    lightThemeColor: Colors.black87.withAlpha(100),
    darkThemeColor: Colors.white.withAlpha(100),
    offset: const Offset(1, 1),
    blurRadius: 3,
    spreadRadius: 7,
    opacity: 0.4,
  );
  copyWith({
    bool? followCardBackgroundColor,
    Color? lightThemeColor,
    Color? darkThemeColor,
    Offset? offset,
    double? blurRadius,
    double? spreadRadius,
    double? opacity,
    bool? withShadow,
  }) {
    return CardShadow(
      withShadow: withShadow ?? this.withShadow,
      followCardBackgroundColor:
          followCardBackgroundColor ?? this.followCardBackgroundColor,
      lightThemeColor: lightThemeColor ?? this.lightThemeColor,
      darkThemeColor: darkThemeColor ?? this.darkThemeColor,
      offset: offset ?? this.offset,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
      opacity: opacity ?? this.opacity,
    );
  }
}

class CardBorder {
  final double width;
  final Color lightColor;
  final Color darkColor;
  final double radius;
  final bool enabled;

  // final BorderType? type;

  CardBorder({
    required this.enabled,
    required this.width,
    required this.lightColor,
    required this.darkColor,
    required this.radius,
    // this.type,
  });

  CardBorder copyWith({
    bool? enabled,
    double? width,
    Color? lightColor,
    Color? darkColor,
    double? radius,
  }) {
    return CardBorder(
      enabled: enabled ?? this.enabled,
      width: width ?? this.width,
      lightColor: lightColor ?? this.lightColor,
      darkColor: darkColor ?? this.darkColor,
      radius: radius ?? this.radius,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'lightColor': lightColor.value.toRadixString(16).padLeft(8, '0'),
      'darkColor': darkColor.value.toRadixString(16).padLeft(8, '0'),
      'radius': radius,
    };
  }

  factory CardBorder.fromJson(Map<String, dynamic> json) {
    return CardBorder(
      enabled: json['enabled'] as bool? ?? false,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      lightColor: Color(
          int.parse(json['lightColor'] as String? ?? '00000000', radix: 16)),
      darkColor: Color(
          int.parse(json['darkColor'] as String? ?? '00000000', radix: 16)),
      radius: (json['radius'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CardStyleConfig {
  const CardStyleConfig({
    this.border,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.padding = EdgeInsets.zero,
    this.shadow,
    // this.size,
  });

  // Border
  final CardBorder? border;

  // Background
  final Color? lightBackgroundColor;
  final Color? darkBackgroundColor;

  // Padding
  final EdgeInsets padding;

  // Shadow
  final CardShadow? shadow;

  // Size
  // final Size? size;

  /// 复制更新当前样式配置。
  ///
  /// 参数：对应字段的可选新值；未提供的字段保持原值。
  /// 返回：新配置对象。
  CardStyleConfig copyWith({
    CardBorder? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    CardShadow? shadow,
    // Size? size,
  }) {
    return CardStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      shadow: shadow ?? this.shadow,
      // size: size ?? this.size,
    );
  }

  /// 将配置转换为 `BoxDecoration`。
  ///
  /// 行为：仅转换非空字段；未设置的属性保持默认，避免破坏现有渲染。
  BoxDecoration toBoxDecoration() {
    return BoxDecoration(
      color: lightBackgroundColor ?? Colors.transparent,
      border: _buildBorder(),
      borderRadius: _buildBorderRadius(),
      boxShadow: _buildShadows(),
    );
  }

  // /// 计算 `BoxConstraints` 尺寸约束。
  // /// 返回：若所有相关字段为 null，则返回 null；否则返回合成约束。
  // BoxConstraints? get constraints {
  //   if (size == null) return null;
  //   return BoxConstraints.tight(size!);
  // }

  /// 将对象序列化为 JSON。仅写入非空字段，减少冗余。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    void put(String key, Object? value) {
      if (value == null) return;
      json[key] = value;
    }

    put('border', border?.toJson());
    put('backgroundColor', lightBackgroundColor);
    put('darkBackgroundColor', darkBackgroundColor);
    put('padding', _edgeInsetsToJson(padding));
    put('shadow', _cardShadowToJson(shadow));
    // put('size', _sizeToJson(size));
    return json;
  }

  /// 从 JSON 反序列化，支持可选字段与向后兼容。
  factory CardStyleConfig.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] as String?;
    double? pickNum(String k) => (json[k] as num?)?.toDouble();

    return CardStyleConfig(
      border: CardBorder.fromJson(json['border']),
      lightBackgroundColor: _parseColor(pickStr('lightBackgroundColorHex')),
      darkBackgroundColor: _parseColor(pickStr('darkBackgroundColorHex')),
      padding: _jsonToEdgeInsets(json['padding']),
      shadow: _jsonToCardShadow(json['shadow']),
      // size: _jsonToSize(json['size']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CardStyleConfig &&
        other.border == border &&
        other.lightBackgroundColor == lightBackgroundColor &&
        other.darkBackgroundColor == darkBackgroundColor &&
        other.padding == padding &&
        other.shadow == shadow;
    // other.size == size;
  }

  @override
  int get hashCode => Object.hashAll([
        border,
        lightBackgroundColor,
        darkBackgroundColor,
        padding,
        shadow,
        // size,
      ]);

  // ===== Helper implementations =====

  Border? _buildBorder() {
    if (border == null) return null;
    final w = border!.width.clamp(0.0, double.infinity).toDouble();
    if (w <= 0) return null;
    // 目前仅支持 solid；其他样式需自绘，后续扩展。
    return Border.all(color: border!.lightColor, width: w);
  }

  BorderRadius? _buildBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(border?.radius ?? 0.0),
      topRight: Radius.circular(border?.radius ?? 0.0),
      bottomLeft: Radius.circular(border?.radius ?? 0.0),
      bottomRight: Radius.circular(border?.radius ?? 0.0),
    );
  }

  List<BoxShadow>? _buildShadows({Brightness brightness = Brightness.light}) {
    if (shadow == null) return null;

    // 注意：这里需要传入BuildContext来获取当前主题，但这个方法没有上下文
    // 暂时使用lightThemeColor作为默认值
    final baseColor = shadow!.followCardBackgroundColor
        ? lightBackgroundColor
        : shadow!.lightThemeColor;

    if (baseColor == null) return null;
    final color = baseColor.withOpacity(shadow!.opacity.clamp(0.0, 1.0));

    return [
      BoxShadow(
        color: color,
        offset: shadow!.offset,
        blurRadius: shadow!.blurRadius.clamp(0.0, double.infinity).toDouble(),
        spreadRadius:
            shadow!.spreadRadius.clamp(0.0, double.infinity).toDouble(),
      ),
    ];
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var v = hex.trim().toUpperCase();
    if (v.startsWith('0X')) v = v.substring(2);
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    if (v.length != 8) return null;
    final intVal = int.tryParse(v, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  static String? _colorToAhex(Color? c) {
    if (c == null) return null;
    final v = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$v';
  }

  static double? _borderWidthOf(BoxBorder? border) {
    if (border == null) return null;
    final dims = border.dimensions;
    final resolved =
        dims is EdgeInsets ? dims : dims.resolve(TextDirection.ltr);
    // 仅当四边等宽时返回该宽度
    if (resolved.left == resolved.right &&
        resolved.top == resolved.bottom &&
        resolved.left == resolved.top) {
      return resolved.left;
    }
    return null;
  }

  static String? _borderColorHexOf(BoxBorder? border) {
    if (border == null) return null;
    if (border is Border) {
      return _colorToAhex(border.top.color);
    }
    // BorderDirectional 不直接暴露颜色；此处暂无法安全解析，返回 null 保持兼容。
    return null;
  }

  static BorderType? _borderTypeOf(BoxBorder? border) {
    if (border == null) return null;
    // 目前仅识别 solid
    return BorderType.solid;
  }

  static double? _uniformRadiusOf(BorderRadiusGeometry? radius) {
    if (radius == null) return null;
    final resolved = radius.resolve(TextDirection.ltr);
    final tl = resolved.topLeft.x;
    final tr = resolved.topRight.x;
    final bl = resolved.bottomLeft.x;
    final br = resolved.bottomRight.x;
    if (tl == tr && tl == bl && tl == br) {
      return tl;
    }
    return null;
  }

  static CardShadow? _boxShadowToCardShadow(List<BoxShadow>? shadows) {
    if (shadows == null || shadows.isEmpty) return null;
    final shadow = shadows.first;
    return CardShadow(
      withShadow: true,
      followCardBackgroundColor: false,
      lightThemeColor: shadow.color,
      darkThemeColor: shadow.color,
      offset: shadow.offset,
      blurRadius: shadow.blurRadius,
      spreadRadius: shadow.spreadRadius,
      opacity: shadow.color.opacity,
    );
  }

  static Map<String, dynamic>? _edgeInsetsToJson(EdgeInsets? padding) {
    if (padding == null) return null;
    return {
      'top': padding.top,
      'bottom': padding.bottom,
      'left': padding.left,
      'right': padding.right,
    };
  }

  static EdgeInsets _jsonToEdgeInsets(dynamic json) {
    // if (json is! Map<String, dynamic>) return null;
    return EdgeInsets.only(
      top: (json['top'] as num?)?.toDouble() ?? 0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
      left: (json['left'] as num?)?.toDouble() ?? 0,
      right: (json['right'] as num?)?.toDouble() ?? 0,
    );
  }

  static Map<String, dynamic>? _cardShadowToJson(CardShadow? shadow) {
    if (shadow == null) return null;
    return {
      'followCardBackgroundColor': shadow.followCardBackgroundColor,
      'lightThemeColor': _colorToAhex(shadow.lightThemeColor),
      'darkThemeColor': _colorToAhex(shadow.darkThemeColor),
      'offset': {'dx': shadow.offset.dx, 'dy': shadow.offset.dy},
      'blurRadius': shadow.blurRadius,
      'spreadRadius': shadow.spreadRadius,
      'opacity': shadow.opacity,
    };
  }

  static CardShadow? _jsonToCardShadow(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return CardShadow(
      withShadow: true,
      followCardBackgroundColor:
          json['followCardBackgroundColor'] as bool? ?? false,
      lightThemeColor: _parseColor(json['lightThemeColor'] as String?) ??
          Colors.black87.withAlpha(100),
      darkThemeColor: _parseColor(json['darkThemeColor'] as String?) ??
          Colors.white.withAlpha(100),
      offset: Offset(
        (json['offset']?['dx'] as num?)?.toDouble() ?? 0,
        (json['offset']?['dy'] as num?)?.toDouble() ?? 0,
      ),
      blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 0,
      spreadRadius: (json['spreadRadius'] as num?)?.toDouble() ?? 0,
      opacity: (json['opacity'] as num?)?.toDouble() ??
          (_parseColor(json['lightThemeColor'] as String?)?.opacity ?? 0.4),
    );
  }

  static Map<String, dynamic>? _sizeToJson(Size? size) {
    if (size == null) return null;
    return {
      'width': size.width,
      'height': size.height,
    };
  }

  static Size? _jsonToSize(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return Size(
      (json['width'] as num?)?.toDouble() ?? 0,
      (json['height'] as num?)?.toDouble() ?? 0,
    );
  }

  /// 创建默认的 CardStyleConfig
  static CardStyleConfig get defaultCardStyleConfig {
    return CardStyleConfig(
      border: CardBorder(
        enabled: true,
        width: 1.0,
        lightColor: Colors.grey.shade300,
        darkColor: Colors.grey.shade700,
        radius: 8.0,
      ),
      lightBackgroundColor: Colors.white,
      darkBackgroundColor: Colors.grey.shade900,
      padding: const EdgeInsets.all(16.0),
      shadow: CardShadow.defaultShadow,
      // size: null,
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

double? _cornerRadiusOf(BorderRadiusGeometry? radius, _Corner corner) {
  if (radius == null) return null;
  final resolved = radius.resolve(TextDirection.ltr);
  switch (corner) {
    case _Corner.topLeft:
      return resolved.topLeft.x;
    case _Corner.topRight:
      return resolved.topRight.x;
    case _Corner.bottomLeft:
      return resolved.bottomLeft.x;
    case _Corner.bottomRight:
      return resolved.bottomRight.x;
  }
}
