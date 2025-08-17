import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/data/repositories/atomic_operation_repository.dart';

// Import all the real operation definitions
import 'package:tiebanshenshu/algorithm/operations/input_decomposition.dart';
import 'package:tiebanshenshu/algorithm/operations/core_transformation.dart';
import 'package:tiebanshenshu/algorithm/operations/composition_construction.dart';
import 'package:tiebanshenshu/algorithm/operations/aggregation_calculation.dart';
import 'package:tiebanshenshu/algorithm/operations/flow_control.dart';
import 'package:tiebanshenshu/algorithm/operations/validation_generation.dart';

class ProductionAtomicOperationRepository implements AtomicOperationRepository {
  late final List<AtomicOperation> _allAtoms;

  ProductionAtomicOperationRepository() {
    // Discover and compile all atoms from their respective files
    _allAtoms = [
      ...InputDecomposition.getOperations(),
      ...CoreTransformation.getOperations(),
      ...CompositionConstruction.getOperations(),
      ...AggregationCalculation.getOperations(),
      ...FlowControl.getOperations(),
      ...ValidationGeneration.getOperations(),
    ];
  }

  @override
  Future<List<AtomicOperation>> getAvailableAtoms() async {
    return Future.value(_allAtoms);
  }

  @override
  Future<AtomicOperation?> getAtomById(String id) async {
    try {
      final atom = _allAtoms.firstWhere((atom) => atom.id == id);
      return Future.value(atom);
    } catch (e) {
      return Future.value(null);
    }
  }
}
