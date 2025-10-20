import '../../../models/layout_template.dart';
import '../../../repositories/layout_template_repository.dart';

class GetTemplateByIdUseCase {
  const GetTemplateByIdUseCase(this._repository);

  final LayoutTemplateRepository _repository;

  Future<LayoutTemplate?> call({
    required String collectionId,
    required String templateId,
  }) {
    return _repository.getTemplateById(collectionId, templateId);
  }
}
