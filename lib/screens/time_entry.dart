import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProjectId;
  String? selectedTaskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';
  bool isAddingNewProject = false;
  bool isAddingNewTask = false;
  final TextEditingController _newProjectController = TextEditingController();
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void dispose() {
    _newProjectController.dispose();
    _newTaskController.dispose();
    super.dispose();
  }

  void _addNewProject(BuildContext context) async {
    if (_newProjectController.text.isNotEmpty) {
      final provider = Provider.of<ProjectTaskProvider>(context, listen: false);
      final newProject = Project(
        id: DateTime.now().toString(),
        name: _newProjectController.text,
      );
      await provider.addProject(newProject);
      setState(() {
        selectedProjectId = newProject.id;
        isAddingNewProject = false;
        _newProjectController.clear();
      });
    }
  }

  void _addNewTask(BuildContext context) async {
    if (_newTaskController.text.isNotEmpty && selectedProjectId != null) {
      final provider = Provider.of<ProjectTaskProvider>(context, listen: false);
      final newTask = Task(
        id: DateTime.now().toString(),
        name: _newTaskController.text,
        projectId: selectedProjectId!,
      );
      await provider.addTask(newTask);
      setState(() {
        selectedTaskId = newTask.id;
        isAddingNewTask = false;
        _newTaskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Time Entry'),
      ),
      body: Consumer<ProjectTaskProvider>(
        builder: (context, projectTaskProvider, child) {
          final projects = projectTaskProvider.projects;
          final tasks = selectedProjectId != null
              ? projectTaskProvider.getTasksForProject(selectedProjectId!)
              : <Task>[];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!isAddingNewProject) ...[
                    DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      decoration: InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              isAddingNewProject = true;
                            });
                          },
                        ),
                      ),
                      items: [
                        ...projects.map((project) => DropdownMenuItem(
                              value: project.id,
                              child: Text(project.name),
                            )),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProjectId = newValue;
                          selectedTaskId = null; // Reset task selection
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a project' : null,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newProjectController,
                            decoration: InputDecoration(
                              labelText: 'New Project Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter a project name'
                                : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _addNewProject(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              isAddingNewProject = false;
                              _newProjectController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 16),
                  if (selectedProjectId != null && !isAddingNewTask) ...[
                    DropdownButtonFormField<String>(
                      value: selectedTaskId,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              isAddingNewTask = true;
                            });
                          },
                        ),
                      ),
                      items: [
                        ...tasks.map((task) => DropdownMenuItem(
                              value: task.id,
                              child: Text(task.name),
                            )),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTaskId = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a task' : null,
                    ),
                  ] else if (selectedProjectId != null && isAddingNewTask) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newTaskController,
                            decoration: InputDecoration(
                              labelText: 'New Task Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter a task name'
                                : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _addNewTask(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              isAddingNewTask = false;
                              _newTaskController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Total Time (hours)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter total time';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => totalTime = double.parse(value!),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null && picked != date) {
                        setState(() {
                          date = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(date.toString().split(' ')[0]),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some notes';
                      }
                      return null;
                    },
                    onSaved: (value) => notes = value!,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          selectedProjectId != null &&
                          selectedTaskId != null) {
                        _formKey.currentState!.save();
                        final project = projectTaskProvider
                            .getProjectById(selectedProjectId!);
                        final task =
                            projectTaskProvider.getTaskById(selectedTaskId!);
                        if (project != null && task != null) {
                          Provider.of<TimeEntryProvider>(context, listen: false)
                              .addTimeEntry(TimeEntry(
                            id: DateTime.now().toString(),
                            projectId:
                                project.name, // Use project name instead of ID
                            taskId: task.name, // Use task name instead of ID
                            totalTime: totalTime,
                            date: date,
                            notes: notes,
                          ));
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
