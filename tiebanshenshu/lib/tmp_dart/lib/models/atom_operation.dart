enum AtomOperationCategory {
  time('time'),
  number('number'),
  logic('logic'),
  format('format'),
  output('output');

  const AtomOperationCategory(this.value);
  final String value;

  static AtomOperationCategory fromString(String value) {
    switch (value) {
      case 'time':
        return AtomOperationCategory.time;
      case 'number':
        return AtomOperationCategory.number;
      case 'logic':
        return AtomOperationCategory.logic;
      case 'format':
        return AtomOperationCategory.format;
      default:
        throw ArgumentError('Unknown category: $value');
    }
  }
}

class AtomOperation {
  final String id;
  final String type;
  final String name;
  final String description;
  final AtomOperationCategory category;
  final String input;
  final String output;
  final String icon;
  final List<String> steps;

  const AtomOperation({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    required this.input,
    required this.output,
    required this.icon,
    this.steps = const [],
  });

  AtomOperation copyWith({
    String? id,
    String? type,
    String? name,
    String? description,
    AtomOperationCategory? category,
    String? input,
    String? output,
    String? icon,
    List<String>? steps,
  }) {
    return AtomOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      input: input ?? this.input,
      output: output ?? this.output,
      icon: icon ?? this.icon,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'category': category,
      'input': input,
      'output': output,
      'icon': icon,
      'steps': steps,
    };
  }

  factory AtomOperation.fromJson(Map<String, dynamic> json) {
    return AtomOperation(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      input: json['input'],
      output: json['output'],
      icon: json['icon'],
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}
