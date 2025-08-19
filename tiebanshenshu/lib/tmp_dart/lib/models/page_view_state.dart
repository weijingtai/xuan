import 'atom_operation.dart';

class PageViewState {
  final int currentPage;
  final int totalPages;
  final bool isEmpty;
  final List<AtomOperation> operations;

  const PageViewState({
    this.currentPage = 0,
    this.totalPages = 0,
    this.isEmpty = true,
    this.operations = const [],
  });

  PageViewState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isEmpty,
    List<AtomOperation>? operations,
  }) {
    return PageViewState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isEmpty: isEmpty ?? this.isEmpty,
      operations: operations ?? this.operations,
    );
  }
}
