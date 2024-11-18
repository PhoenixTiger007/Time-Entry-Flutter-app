import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../provider/time_entry_provider.dart';
import 'time_entry.dart';
import 'project_task_management.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Time Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Projects & Tasks'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectTaskManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Time Entries'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Entries'),
            Tab(text: 'By Project'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllEntriesList(),
          _buildEntriesByProject(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Time Entry',
      ),
    );
  }

  Widget _buildAllEntriesList() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Time Entries',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add your first time entry',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.entries[index];
            return Dismissible(
              key: Key(entry.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) =>
                  _showDeleteConfirmationDialog(context),
              onDismissed: (direction) {
                provider.deleteTimeEntry(entry.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Time entry deleted')),
                );
              },
              child: ListTile(
                title: Text('${entry.projectId} - ${entry.totalTime} hours'),
                subtitle: Text(
                    '${DateFormat('MMM d, yyyy').format(entry.date)} - Notes: ${entry.notes}'),
                onTap: () {
                  // This could open a detailed view or edit screen
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEntriesByProject() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Time Entries',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add time entries to see them grouped by project',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        Map<String, List<TimeEntry>> groupedEntries = {};
        for (var entry in provider.entries) {
          if (!groupedEntries.containsKey(entry.projectId)) {
            groupedEntries[entry.projectId] = [];
          }
          groupedEntries[entry.projectId]!.add(entry);
        }

        return ListView.builder(
          itemCount: groupedEntries.length,
          itemBuilder: (context, index) {
            String projectId = groupedEntries.keys.elementAt(index);
            List<TimeEntry> projectEntries = groupedEntries[projectId]!;

            return ExpansionTile(
              title: Text(projectId),
              children: projectEntries.map((entry) {
                return Dismissible(
                  key: Key(entry.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) =>
                      _showDeleteConfirmationDialog(context),
                  onDismissed: (direction) {
                    provider.deleteTimeEntry(entry.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Time entry deleted')),
                    );
                  },
                  child: ListTile(
                    title: Text('${entry.taskId} - ${entry.totalTime} hours'),
                    subtitle: Text(
                        '${DateFormat('MMM d, yyyy').format(entry.date)} - Notes: ${entry.notes}'),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Time Entry'),
          content: Text('Are you sure you want to delete this time entry?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
