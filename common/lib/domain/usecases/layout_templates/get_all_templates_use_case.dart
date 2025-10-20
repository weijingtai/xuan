import '../../../models/layout_template.dart';
import '../../../repositories/layout_template_repository.dart';

class GetAllTemplatesUseCase {
  const GetAllTemplatesUseCase(this._repository);

  final LayoutTemplateRepository _repository;

  Future<List<LayoutTemplate>> call({required String collectionId}) async {
    final templates = await _repository.getAllTemplates(collectionId);
    final sorted = List<LayoutTemplate>.of(templates)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}
