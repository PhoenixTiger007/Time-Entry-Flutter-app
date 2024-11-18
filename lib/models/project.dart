class Project {
  final String id;
  final String name;

  Project({required this.id, required this.name});

  // Convert a Project into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a Project from a Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
