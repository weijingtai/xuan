import 'layout_template.dart';

class LayoutTemplateDto {
  const LayoutTemplateDto(this.template);

  final LayoutTemplate template;

  LayoutTemplate toDomain() => template;

  Map<String, dynamic> toJson() => template.toJson();

  LayoutTemplateDto copyWith({LayoutTemplate? template}) {
    return LayoutTemplateDto(template ?? this.template);
  }

  factory LayoutTemplateDto.fromJson(Map<String, dynamic> json) {
    return LayoutTemplateDto(LayoutTemplate.fromJson(json));
  }

  factory LayoutTemplateDto.fromDomain(LayoutTemplate template) {
    return LayoutTemplateDto(template);
  }
}
