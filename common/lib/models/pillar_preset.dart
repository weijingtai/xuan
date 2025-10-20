class PillarPreset {
  final String id;
  final String name;
  final String scene; // 适用场景，如 本命/运势 等
  final List<String> pillarIds; // 例如: ['year','month']
  final DateTime updatedAt;
  final bool favorite;

  const PillarPreset({
    required this.id,
    required this.name,
    required this.scene,
    required this.pillarIds,
    required this.updatedAt,
    this.favorite = false,
  });
}

