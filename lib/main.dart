import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/project_task_provider.dart';
import 'package:tracker_app/provider/time_entry_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
        ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
      ],
      child: MaterialApp(
        title: 'Time Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
