import '../models/layout_template.dart';

abstract class LayoutTemplateRepository {
  Future<List<LayoutTemplate>> getAllTemplates(String collectionId);

  Future<LayoutTemplate?> getTemplateById(
    String collectionId,
    String templateId,
  );

  Future<void> saveTemplate(LayoutTemplate template);

  Future<void> deleteTemplate(String collectionId, String templateId);
}
