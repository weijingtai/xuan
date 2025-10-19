abstract class EightCharsInfoRepository {
  // Row Order
  Future<void> saveBenMingRowOrder(List<String> order);
  Future<List<String>?> loadBenMingRowOrder();
  Future<void> saveLiuYunRowOrder(List<String> order);
  Future<List<String>?> loadLiuYunRowOrder();

  // Pillar Order
  Future<void> saveBenMingPillarOrder(List<String> order);
  Future<List<String>?> loadBenMingPillarOrder();
  Future<void> saveLiuYunPillarOrder(List<String> order);
  Future<List<String>?> loadLiuYunPillarOrder();

  // Row Visibility (Shared)
  Future<void> saveRowVisibility(Map<String, bool> visibility);
  Future<Map<String, bool>> loadRowVisibility();

  // Pillar Visibility (Specific)
  Future<void> saveBenMingPillarVisibility(Map<String, bool> visibility);
  Future<Map<String, bool>> loadBenMingPillarVisibility();
  Future<void> saveLiuYunPillarVisibility(Map<String, bool> visibility);
  Future<Map<String, bool>> loadLiuYunPillarVisibility();
}
