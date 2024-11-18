class Task {
  final String id;
  final String name;
  final String projectId;

  Task({required this.id, required this.name, required this.projectId});

  // Convert a Task into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'projectId': projectId,
    };
  }

  // Create a Task from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      projectId: map['projectId'],
    );
  }

  @override
  String toString() => 'Task(id: $id, name: $name, projectId: $projectId)';
}
