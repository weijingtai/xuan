import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/data/repositories/mock_atomic_operations.dart';

abstract class AtomicOperationRepository {
  Future<List<AtomicOperation>> getAvailableAtoms();
  Future<AtomicOperation?> getAtomById(String id);
}

class MockAtomicOperationRepository implements AtomicOperationRepository {
  final List<AtomicOperation> _atoms = [
    GetFourPillarsAtom(),
    ConvertStemToNumberAtom(),
    BranchAtom(),
  ];

  @override
  Future<List<AtomicOperation>> getAvailableAtoms() async {
    // In a real app, this might come from a remote config or be generated
    // by reflecting on the codebase. For the prototype, we return our hardcoded list.
    return Future.value(_atoms);
  }

  @override
  Future<AtomicOperation?> getAtomById(String id) async {
    try {
      final atom = _atoms.firstWhere((atom) => atom.id == id);
      return Future.value(atom);
    } catch (e) {
      return Future.value(null);
    }
  }
}
