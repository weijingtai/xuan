import 'package:equatable/equatable.dart';

class PillarPreset extends Equatable {
  final String name;        // The display name, e.g., "四柱八字"
  final List<String> pillars; // The list of pillar labels, e.g., ['年', '月', '日', '时']

  const PillarPreset({required this.name, required this.pillars});

  @override
  List<Object?> get props => [name, pillars];
}
