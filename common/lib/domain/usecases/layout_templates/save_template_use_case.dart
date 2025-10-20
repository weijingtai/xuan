import '../../../models/layout_template.dart';
import '../../../repositories/layout_template_repository.dart';

class SaveTemplateUseCase {
  const SaveTemplateUseCase(this._repository);

  final LayoutTemplateRepository _repository;

  Future<void> call({required LayoutTemplate template}) {
    if (template.name.trim().isEmpty) {
      throw ArgumentError('Template name cannot be empty');
    }

    return _repository.saveTemplate(template);
  }
}
