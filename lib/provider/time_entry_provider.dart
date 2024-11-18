import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  static const String _storageKey = 'time_entries';

  List<TimeEntry> get entries => _entries;

  TimeEntryProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString(_storageKey);
    if (entriesJson != null) {
      final entriesList = json.decode(entriesJson) as List;
      _entries = entriesList.map((item) => TimeEntry.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = json.encode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, entriesJson);
  }

  Future<void> addTimeEntry(TimeEntry entry) async {
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> deleteTimeEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveEntries();
    notifyListeners();
  }
}
