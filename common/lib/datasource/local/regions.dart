import 'package:json_annotation/json_annotation.dart';

class RegionDataSet {
  final int id;
  final String name;
  final Map<String, String> translations;
  final String wikiDataId;

  RegionDataSet({
    required this.id,
    required this.name,
    required this.translations,
    required this.wikiDataId,
  });

  factory RegionDataSet.fromJson(Map<String, dynamic> json) {
    return RegionDataSet(
      id: json['id'] as int,
      name: json['name'] as String,
      translations: Map<String, String>.from(json['translations']),
      wikiDataId: json['wikiDataId'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'translations': translations,
      'wikiDataId': wikiDataId,
    };
  }

  // Get translated name based on language code
  String getTranslatedName(String languageCode) {
    return translations[languageCode] ?? name;
  }

  @override
  String toString() {
    return 'RegionDataModel(id: $id, name: $name, wikiDataId: $wikiDataId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionDataSet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
