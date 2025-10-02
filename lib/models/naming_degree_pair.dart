class Constellation {
  final String name;
  final double degree;

  Constellation(this.name, this.degree);

  @override
  String toString() {
    return 'Constellation(name: $name, degree: $degree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Constellation &&
        other.name == name &&
        other.degree == degree;
  }

  @override
  int get hashCode => name.hashCode ^ degree.hashCode;
}

class Gong {
  final String name;
  final double degree;

  Gong(this.name, this.degree);

  @override
  String toString() {
    return 'Gong(name: $name, degree: $degree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gong && other.name == name && other.degree == degree;
  }

  @override
  int get hashCode => name.hashCode ^ degree.hashCode;
}

class ConstellationPosition {
  final String name;
  final double atDegree;
  final List<num>? dms;

  ConstellationPosition({
    required this.name,
    required this.atDegree,
    this.dms,
  });

  @override
  String toString() {
    return 'ConstellationPosition(name: $name, atDegree: $atDegree, dms: $dms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConstellationPosition &&
        other.name == name &&
        other.atDegree == atDegree &&
        other.dms == dms;
  }

  @override
  int get hashCode => name.hashCode ^ atDegree.hashCode ^ dms.hashCode;
}

class StarEnterInfo {
  final ConstellationPosition starInn;
  final ConstellationPosition gong;

  StarEnterInfo({
    required this.starInn,
    required this.gong,
  });

  @override
  String toString() {
    return 'StarEnterInfo(starInn: $starInn, gong: $gong)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StarEnterInfo &&
        other.starInn == starInn &&
        other.gong == gong;
  }

  @override
  int get hashCode => starInn.hashCode ^ gong.hashCode;
}
