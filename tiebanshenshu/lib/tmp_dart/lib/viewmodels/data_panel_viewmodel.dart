import 'package:flutter/material.dart';
import '../models/atom_operation.dart';
import '../models/page_view_state.dart';

class DataPanelViewModel extends ChangeNotifier {
  PageViewState _pageViewState = PageViewState();
  int _selectedTabIndex = 0;
  bool _isAutoHeight = false;
  double _panelHeight = 400.0;

  PageViewState get pageViewState => _pageViewState;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isAutoHeight => _isAutoHeight;
  double get panelHeight => _panelHeight;

  List<AtomOperation> get operations => _pageViewState.operations;
  int get currentPage => _pageViewState.currentPage;
  int get totalPages => _pageViewState.totalPages;

  void addOperation(AtomOperation operation) {
    final updatedOperations = List<AtomOperation>.from(
      _pageViewState.operations,
    )..add(operation);
    _pageViewState = _pageViewState.copyWith(
      operations: updatedOperations,
      totalPages: updatedOperations.length,
      currentPage: updatedOperations.length - 1,
    );
    notifyListeners();
  }

  void removeOperation(int index) {
    if (index >= 0 && index < _pageViewState.operations.length) {
      final updatedOperations = List<AtomOperation>.from(
        _pageViewState.operations,
      )..removeAt(index);
      int newCurrentPage = _pageViewState.currentPage;

      if (updatedOperations.isEmpty) {
        newCurrentPage = 0;
      } else if (newCurrentPage >= updatedOperations.length) {
        newCurrentPage = updatedOperations.length - 1;
      }

      _pageViewState = _pageViewState.copyWith(
        operations: updatedOperations,
        totalPages: updatedOperations.length,
        currentPage: newCurrentPage,
      );
      notifyListeners();
    }
  }

  void goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pageViewState.totalPages) {
      _pageViewState = _pageViewState.copyWith(currentPage: pageIndex);
      notifyListeners();
    }
  }

  void nextPage() {
    if (_pageViewState.currentPage < _pageViewState.totalPages - 1) {
      _pageViewState = _pageViewState.copyWith(
        currentPage: _pageViewState.currentPage + 1,
      );
      notifyListeners();
    }
  }

  void previousPage() {
    if (_pageViewState.currentPage > 0) {
      _pageViewState = _pageViewState.copyWith(
        currentPage: _pageViewState.currentPage - 1,
      );
      notifyListeners();
    }
  }

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void toggleAutoHeight() {
    _isAutoHeight = !_isAutoHeight;
    notifyListeners();
  }

  void setPanelHeight(double height) {
    _panelHeight = height.clamp(200.0, 800.0);
    notifyListeners();
  }

  void clearOperations() {
    _pageViewState = PageViewState();
    notifyListeners();
  }

  String getPageInfo() {
    if (_pageViewState.totalPages == 0) {
      return '暂无数据处理步骤';
    }
    return '第 ${_pageViewState.currentPage + 1} 页，共 ${_pageViewState.totalPages} 页';
  }
}
