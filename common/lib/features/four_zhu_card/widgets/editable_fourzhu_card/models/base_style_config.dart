import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:common/enums/layout_template_enums.dart';

part 'base_style_config.g.dart';

class ColorAHexConverter extends JsonConverter<Color, String> {
  const ColorAHexConverter();

  @override
  Color fromJson(String json) {
    var v = json.trim().toUpperCase();
    if (v.startsWith('0X')) v = v.substring(2);
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    final intVal = int.tryParse(v, radix: 16) ?? 0x00000000;
    return Color(intVal);
  }

  @override
  String toJson(Color object) {
    final v = object.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$v';
  }
}

class NullableColorAHexConverter extends JsonConverter<Color?, String?> {
  const NullableColorAHexConverter();

  @override
  Color? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    var v = json.trim().toUpperCase();
    if (v.startsWith('0X')) v = v.substring(2);
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    final intVal = int.tryParse(v, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  @override
  String? toJson(Color? object) {
    if (object == null) return null;
    final v = object.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$v';
  }
}

class OffsetConverter extends JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num?)?.toDouble() ?? 0,
      (json['dy'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson(Offset object) => {
        'dx': object.dx,
        'dy': object.dy,
      };
}

class EdgeInsetsConverter
    extends JsonConverter<EdgeInsets, Map<String, dynamic>> {
  const EdgeInsetsConverter();

  @override
  EdgeInsets fromJson(Map<String, dynamic> json) {
    return EdgeInsets.only(
      top: (json['top'] as num?)?.toDouble() ?? 0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
      left: (json['left'] as num?)?.toDouble() ?? 0,
      right: (json['right'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson(EdgeInsets object) => {
        'top': object.top,
        'bottom': object.bottom,
        'left': object.left,
        'right': object.right,
      };
}

/// CardStyleConfig
///
/// 功能描述：
/// - 封装卡片容器的视觉样式（边框、背景、圆角、内边距、阴影、尺寸）。
/// - 提供类型转换方法以应用到 Flutter 的 `BoxDecoration`、`EdgeInsets` 与 `BoxConstraints`。
/// - 提供 JSON 序列化/反序列化与向后兼容的工厂方法。
/// 参数说明：各字段均为可选，缺省时不影响现有渲染（保持向后兼容）。
/// 返回值：不可变对象；通过 `copyWith` 创建更新版本。
@JsonSerializable()
class BoxShadowStyle extends Equatable {
  final bool withShadow;
  final bool followCardBackgroundColor;
  @ColorAHexConverter()
  final Color lightThemeColor;
  @ColorAHexConverter()
  final Color darkThemeColor;
  @OffsetConverter()
  final Offset offset;
  final double blurRadius;
  final double spreadRadius;

  BoxShadowStyle({
    required this.withShadow,
    required this.followCardBackgroundColor,
    required this.lightThemeColor,
    required this.darkThemeColor,
    required this.offset,
    required this.blurRadius,
    required this.spreadRadius,
  });

  /// 根据亮度解析最终颜色
  Color resolveColor(Brightness brightness) {
    return brightness == Brightness.light ? lightThemeColor : darkThemeColor;
  }

  static BoxShadowStyle defaultShadow = BoxShadowStyle(
    withShadow: true,
    followCardBackgroundColor: false,
    lightThemeColor: Colors.black87.withAlpha(102),
    darkThemeColor: Colors.white.withAlpha(102),
    offset: const Offset(1, 1),
    blurRadius: 3,
    spreadRadius: 7,
  );
  copyWith({
    bool? followCardBackgroundColor,
    Color? lightThemeColor,
    Color? darkThemeColor,
    Offset? offset,
    double? blurRadius,
    double? spreadRadius,
    bool? withShadow,
  }) {
    return BoxShadowStyle(
      withShadow: withShadow ?? this.withShadow,
      followCardBackgroundColor:
          followCardBackgroundColor ?? this.followCardBackgroundColor,
      lightThemeColor: lightThemeColor ?? this.lightThemeColor,
      darkThemeColor: darkThemeColor ?? this.darkThemeColor,
      offset: offset ?? this.offset,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
    );
  }

  /// 将对象序列化为 JSON。仅写入非空字段，减少冗余。
  Map<String, dynamic> toJson() => _$BoxShadowStyleToJson(this);

  factory BoxShadowStyle.fromJson(Map<String, dynamic> json) {
    final style = _$BoxShadowStyleFromJson(json);

    final legacyOpacity = (json['opacity'] as num?)?.toDouble();
    if (legacyOpacity == null) return style;

    final a = (255 * legacyOpacity).round().clamp(0, 255);
    return style.copyWith(
      lightThemeColor: style.lightThemeColor.withAlpha(a),
      darkThemeColor: style.darkThemeColor.withAlpha(a),
    );
  }

  @override
  List<Object?> get props => [
        withShadow,
        followCardBackgroundColor,
        lightThemeColor,
        darkThemeColor,
        offset,
        blurRadius,
        spreadRadius,
      ];
}

@JsonSerializable()
class BoxBorderStyle extends Equatable {
  final double width;
  @ColorAHexConverter()
  final Color lightColor;
  @ColorAHexConverter()
  final Color darkColor;
  final double radius;
  final bool enabled;

  // final BorderType? type;

  BoxBorderStyle({
    required this.enabled,
    required this.width,
    required this.lightColor,
    required this.darkColor,
    required this.radius,
  });

  BoxBorderStyle copyWith({
    bool? enabled,
    double? width,
    Color? lightColor,
    Color? darkColor,
    double? radius,
  }) {
    return BoxBorderStyle(
      enabled: enabled ?? this.enabled,
      width: width ?? this.width,
      lightColor: lightColor ?? this.lightColor,
      darkColor: darkColor ?? this.darkColor,
      radius: radius ?? this.radius,
    );
  }

  /// 根据亮度解析最终边框颜色
  Color resolveColor(Brightness brightness) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  static get defaultBorder => BoxBorderStyle(
        enabled: false,
        width: 1,
        lightColor: Colors.black87,
        darkColor: Colors.white70,
        radius: 12,
      );

  toJson() => _$BoxBorderStyleToJson(this);
  factory BoxBorderStyle.fromJson(Map<String, dynamic> json) =>
      _$BoxBorderStyleFromJson(json);

  @override
  List<Object?> get props => [enabled, width, lightColor, darkColor, radius];
}

@JsonSerializable()
class BaseBoxStyleConfig extends Equatable {
  BaseBoxStyleConfig({
    required this.border,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    required this.shadow,
    // this.size,
  });

  // Border
  final BoxBorderStyle? border;

  // Background
  @NullableColorAHexConverter()
  final Color? lightBackgroundColor;
  @NullableColorAHexConverter()
  final Color? darkBackgroundColor;

  // Padding
  @EdgeInsetsConverter()
  final EdgeInsets padding;
  @EdgeInsetsConverter()
  final EdgeInsets margin;

  // Shadow
  final BoxShadowStyle shadow;

  // Size
  // final Size? size;

  /// 根据亮度解析背景颜色
  Color? resolveBackgroundColor(Brightness brightness) {
    return brightness == Brightness.light
        ? lightBackgroundColor
        : darkBackgroundColor;
  }

  /// 复制更新当前样式配置。
  ///
  /// 参数：对应字段的可选新值；未提供的字段保持原值。
  /// 返回：新配置对象。
  BaseBoxStyleConfig copyWith({
    BoxBorderStyle? border,
    Color? lightBackgroundColor,
    Color? darkBackgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxShadowStyle? shadow,
  }) {
    return BaseBoxStyleConfig(
      border: border ?? this.border,
      lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadow: shadow ?? this.shadow,
      // size: size ?? this.size,
    );
  }

  /// 将配置转换为 `BoxDecoration`。
  ///
  /// 行为：仅转换非空字段；未设置的属性保持默认，避免破坏现有渲染。
  BoxDecoration toBoxDecoration({Brightness brightness = Brightness.light}) {
    return BoxDecoration(
      color: resolveBackgroundColor(brightness) ?? Colors.transparent,
      border: _buildBorder(brightness),
      borderRadius: _buildBorderRadius(),
      boxShadow: _buildShadows(brightness: brightness),
    );
  }

  // /// 计算 `BoxConstraints` 尺寸约束。
  // /// 返回：若所有相关字段为 null，则返回 null；否则返回合成约束。
  // BoxConstraints? get constraints {
  //   if (size == null) return null;
  //   return BoxConstraints.tight(size!);
  // }

  Map<String, dynamic> toJson() => _$BaseBoxStyleConfigToJson(this);
  factory BaseBoxStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$BaseBoxStyleConfigFromJson(json);

  /// 将对象序列化为 JSON。仅写入非空字段，减少冗余。
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> json = {};
  //   void put(String key, Object? value) {
  //     if (value == null) return;
  //     json[key] = value;
  //   }

  //   put('border', border?.toJson());
  //   put('backgroundColor', lightBackgroundColor);
  //   put('darkBackgroundColor', darkBackgroundColor);
  //   put('padding', _edgeInsetsToJson(padding));
  //   put('margin', _edgeInsetsToJson(margin));
  //   put('shadow', _cardShadowToJson(shadow));
  //   // put('size', _sizeToJson(size));
  //   return json;
  // }

  /// 从 JSON 反序列化，支持可选字段与向后兼容。
  // factory BaseBoxStyleConfig.fromJson(Map<String, dynamic> json) {
  //   String? pickStr(String k) => json[k] as String?;
  //   double? pickNum(String k) => (json[k] as num?)?.toDouble();

  //   return BaseBoxStyleConfig(
  //     border: BoxBorderStyle.fromJson(json['border']),
  //     lightBackgroundColor: _parseColor(pickStr('lightBackgroundColorHex')),
  //     darkBackgroundColor: _parseColor(pickStr('darkBackgroundColorHex')),
  //     padding: _jsonToEdgeInsets(json['padding']),
  //     shadow: _jsonToCardShadow(json['shadow']),
  //     margin: _jsonToEdgeInsets(json['margin']),
  //     // size: _jsonToSize(json['size']),
  //   );
  // }

  @override
  List<Object?> get props => [
        border,
        lightBackgroundColor,
        darkBackgroundColor,
        padding,
        margin,
        shadow,
        // size,
      ];

  // ===== Helper implementations =====

  Border? _buildBorder(Brightness brightness) {
    if (border == null || !border!.enabled) return null;
    final w = border!.width;
    if (w <= 0) return null;
    return Border.all(color: border!.resolveColor(brightness), width: w);
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
    if (!shadow.withShadow) return null;
    final baseColor = shadow.followCardBackgroundColor
        ? resolveBackgroundColor(brightness)
        : shadow.resolveColor(brightness);

    if (baseColor == null) return null;

    final configured = shadow.resolveColor(brightness);
    final color = shadow.followCardBackgroundColor
        ? baseColor.withAlpha(configured.alpha)
        : configured;

    return [
      BoxShadow(
        color: color,
        offset: shadow.offset,
        blurRadius: shadow.blurRadius.clamp(0.0, double.infinity).toDouble(),
        spreadRadius:
            shadow.spreadRadius.clamp(0.0, double.infinity).toDouble(),
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

  static BoxShadowStyle? _boxShadowToCardShadow(List<BoxShadow>? shadows) {
    if (shadows == null || shadows.isEmpty) return null;
    final shadow = shadows.first;
    return BoxShadowStyle(
      withShadow: true,
      followCardBackgroundColor: false,
      lightThemeColor: shadow.color,
      darkThemeColor: shadow.color,
      offset: shadow.offset,
      blurRadius: shadow.blurRadius,
      spreadRadius: shadow.spreadRadius,
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

  static Map<String, dynamic>? _cardShadowToJson(BoxShadowStyle? shadow) {
    if (shadow == null) return null;
    return {
      'followCardBackgroundColor': shadow.followCardBackgroundColor,
      'lightThemeColor': _colorToAhex(shadow.lightThemeColor),
      'darkThemeColor': _colorToAhex(shadow.darkThemeColor),
      'offset': {'dx': shadow.offset.dx, 'dy': shadow.offset.dy},
      'blurRadius': shadow.blurRadius,
      'spreadRadius': shadow.spreadRadius,
    };
  }

  static BoxShadowStyle? _jsonToCardShadow(dynamic json) {
    if (json is! Map<String, dynamic>) return null;

    final rawLight = _parseColor(json['lightThemeColor'] as String?) ??
        Colors.black87.withAlpha(102);
    final rawDark = _parseColor(json['darkThemeColor'] as String?) ??
        Colors.white.withAlpha(102);

    final legacyOpacity = (json['opacity'] as num?)?.toDouble();
    if (legacyOpacity != null) {
      final a = (255 * legacyOpacity).round().clamp(0, 255);
      return BoxShadowStyle(
        withShadow: true,
        followCardBackgroundColor:
            json['followCardBackgroundColor'] as bool? ?? false,
        lightThemeColor: rawLight.withAlpha(a),
        darkThemeColor: rawDark.withAlpha(a),
        offset: Offset(
          (json['offset']?['dx'] as num?)?.toDouble() ?? 0,
          (json['offset']?['dy'] as num?)?.toDouble() ?? 0,
        ),
        blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 0,
        spreadRadius: (json['spreadRadius'] as num?)?.toDouble() ?? 0,
      );
    }

    return BoxShadowStyle(
      withShadow: true,
      followCardBackgroundColor:
          json['followCardBackgroundColor'] as bool? ?? false,
      lightThemeColor: rawLight,
      darkThemeColor: rawDark,
      offset: Offset(
        (json['offset']?['dx'] as num?)?.toDouble() ?? 0,
        (json['offset']?['dy'] as num?)?.toDouble() ?? 0,
      ),
      blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 0,
      spreadRadius: (json['spreadRadius'] as num?)?.toDouble() ?? 0,
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
