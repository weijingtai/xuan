import '../../../repositories/layout_template_repository.dart';

class DeleteTemplateUseCase {
  const DeleteTemplateUseCase(this._repository);

  final LayoutTemplateRepository _repository;

  Future<void> call({
    required String collectionId,
    required String templateId,
  }) {
    return _repository.deleteTemplate(collectionId, templateId);
  }
}
