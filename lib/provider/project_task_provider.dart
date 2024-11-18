import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  ProjectTaskProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadProjects();
    await _loadTasks();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString('projects');
    if (projectsJson != null) {
      final projectsList = json.decode(projectsJson) as List;
      _projects = projectsList.map((item) => Project.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasksList = json.decode(tasksJson) as List;
      _tasks = tasksList.map((item) => Task.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = json.encode(_projects.map((p) => p.toMap()).toList());
    await prefs.setString('projects', projectsJson);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  // Project methods
  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      await _saveProjects();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    await _saveProjects();
    notifyListeners();
  }

  // Task methods
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  // Helper methods
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}
