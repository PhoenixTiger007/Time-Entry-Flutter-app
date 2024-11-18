import 'package:intl/intl.dart';

class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime;
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });

  // Convert a TimeEntry into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalTime': totalTime,
      'date': DateFormat('yyyy-MM-dd').format(date), // Format date as string
      'notes': notes,
    };
  }

  // Create a TimeEntry from a Map
  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'],
      projectId: map['projectId'],
      taskId: map['taskId'],
      totalTime: map['totalTime'],
      date: DateFormat('yyyy-MM-dd')
          .parse(map['date']), // Parse string to DateTime
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'TimeEntry(id: $id, projectId: $projectId, taskId: $taskId, totalTime: $totalTime, date: ${DateFormat('yyyy-MM-dd').format(date)}, notes: $notes)';
  }
}
