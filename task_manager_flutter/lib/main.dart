import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

// Services & Repositories

import 'services/task_api_service.dart';

import 'services/task_cache_service.dart';

import 'repositories/task_repository.dart';

// ViewModel & Views

import 'task_list/task_list_view_model.dart';

import 'task_list/task_list_view.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Instantiate services and repository

    final apiService = TaskApiService();

    final cacheService = TaskCacheService();

    final taskRepository = TaskRepository(
      apiService: apiService,

      cacheService: cacheService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // Provide TaskRepository so child views can access it
        Provider<TaskRepository>.value(
          value: taskRepository,
        ),

        // Provide TaskListViewModel to the widget tree
        ChangeNotifierProvider(
          create: (context) => TaskListViewModel(context.read<TaskRepository>()),
        ),
      ],

      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Task Manager',

            debugShowCheckedModeBanner: false,

            themeMode: themeNotifier.themeMode,

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E60F7),

                brightness: Brightness.light,
              ),

              useMaterial3: true,

              scaffoldBackgroundColor: const Color(0xFFF7F9FC),
            ),

            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E60F7),

                brightness: Brightness.light,
              ),

              useMaterial3: true,

              scaffoldBackgroundColor: const Color(0xFFEFE5DC), // Light Brown Background

              cardColor: Colors.white,
            ),

            home: const TaskListView(),
          );
        },
      ),
    );
  }
}
