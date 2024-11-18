import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../provider/project_task_provider.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Projects and Tasks'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Projects'),
              Tab(text: 'Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProjectList(),
            _TaskList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _AddProjectTaskDialog(),
            );
          },
          child: Icon(Icons.add),
          tooltip: 'Add Project/Task',
        ),
      ),
    );
  }
}

class _ProjectList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectTaskProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.projects.length,
          itemBuilder: (context, index) {
            final project = provider.projects[index];
            return ListTile(
              title: Text(project.name),
              subtitle: Text(
                  'Tasks: ${provider.getTasksForProject(project.id).length}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  provider.deleteProject(project.id);
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _EditProjectDialog(project: project),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectTaskProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.tasks.length,
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            final project = provider.getProjectById(task.projectId);
            return ListTile(
              title: Text(task.name),
              subtitle: Text('Project: ${project?.name ?? 'Unknown'}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  provider.deleteTask(task.id);
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _EditTaskDialog(task: task),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AddProjectTaskDialog extends StatefulWidget {
  @override
  _AddProjectTaskDialogState createState() => _AddProjectTaskDialogState();
}

class _AddProjectTaskDialogState extends State<_AddProjectTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  bool _isProject = true;
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context, listen: false);
    return AlertDialog(
      title: Text(_isProject ? 'Add Project' : 'Add Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            SwitchListTile(
              title: Text('Is Project'),
              value: _isProject,
              onChanged: (value) {
                setState(() {
                  _isProject = value;
                });
              },
            ),
            if (!_isProject)
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: InputDecoration(labelText: 'Project'),
                items: provider.projects.map((project) {
                  return DropdownMenuItem(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (_isProject) {
                provider.addProject(
                    Project(id: DateTime.now().toString(), name: _name));
              } else {
                provider.addTask(Task(
                  id: DateTime.now().toString(),
                  name: _name,
                  projectId: _selectedProjectId!,
                ));
              }
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class _EditProjectDialog extends StatefulWidget {
  final Project project;

  _EditProjectDialog({required this.project});

  @override
  _EditProjectDialogState createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<_EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.project.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Project'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _name,
          decoration: InputDecoration(labelText: 'Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
          onSaved: (value) => _name = value!,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final provider =
                  Provider.of<ProjectTaskProvider>(context, listen: false);
              provider
                  .updateProject(Project(id: widget.project.id, name: _name));
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;

  _EditTaskDialog({required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _name = widget.task.name;
    _selectedProjectId = widget.task.projectId;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context, listen: false);
    return AlertDialog(
      title: Text('Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            DropdownButtonFormField<String>(
              value: _selectedProjectId,
              decoration: InputDecoration(labelText: 'Project'),
              items: provider.projects.map((project) {
                return DropdownMenuItem(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a project';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              provider.updateTask(Task(
                id: widget.task.id,
                name: _name,
                projectId: _selectedProjectId,
              ));
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
