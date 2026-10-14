import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tasks.dart';

class TaskCacheService {
  static Database? _database;
  final List<Tasks> _webInMemoryCache = [];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint('SQLite initialization bypassed: $e');
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_cache.db');

    print('Database path: $path');

    return await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        category TEXT,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        isOffline INTEGER NOT NULL DEFAULT 0,
        isPendingUpdate INTEGER NOT NULL DEFAULT 0,
        isPendingDelete INTEGER NOT NULL DEFAULT 0
      )
    ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS tasks');
        await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        category TEXT,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        isOffline INTEGER NOT NULL DEFAULT 0,
        isPendingUpdate INTEGER NOT NULL DEFAULT 0,
        isPendingDelete INTEGER NOT NULL DEFAULT 0
      )
    ''');
      },
    );
  }

  // Saves a task created while offline, assigning a local temp ID and marking isOffline = true
  Future<Tasks> saveOfflineTask(Tasks task) async {
    final tempId = task.id != 0
        ? task.id
        : -DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    final offlineTask = task.copyWith(id: tempId, isOffline: true);

    if (kIsWeb) {
      _webInMemoryCache.removeWhere((t) => t.id == tempId);
      _webInMemoryCache.add(offlineTask);
      return offlineTask;
    }

    try {
      final db = await database;
      if (db != null) {
        await db.insert(
          'tasks',
          offlineTask.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        _webInMemoryCache.removeWhere((t) => t.id == tempId);
        _webInMemoryCache.add(offlineTask);
      }
    } catch (e) {
      debugPrint('saveOfflineTask error ignored: $e');
      _webInMemoryCache.removeWhere((t) => t.id == tempId);
      _webInMemoryCache.add(offlineTask);
    }

    return offlineTask;
  }

  // Saves an offline task update pending server sync
  Future<Tasks> saveOfflineUpdate(Tasks task) async {
    final updatedTask = task.isOffline
        ? task
        : task.copyWith(isPendingUpdate: true);

    _webInMemoryCache.removeWhere((t) => t.id == task.id);
    _webInMemoryCache.add(updatedTask);

    if (kIsWeb) return updatedTask;

    try {
      final db = await database;
      if (db != null) {
        await db.insert(
          'tasks',
          updatedTask.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('saveOfflineUpdate error ignored: $e');
    }

    return updatedTask;
  }

  // Handles offline task deletion: if unsynced offline task, removes immediately; if server task, marks isPendingDelete = true
  Future<void> saveOfflineDelete(int id) async {
    if (id < 0) {
      // Local unsynced task -> delete completely
      await deleteCachedTask(id);
      return;
    }

    // Server task -> mark isPendingDelete = true so it is hidden from UI and queued for server deletion
    final existingIndex = _webInMemoryCache.indexWhere((t) => t.id == id);
    if (existingIndex != -1) {
      final existingTask = _webInMemoryCache[existingIndex];
      _webInMemoryCache[existingIndex] =
          existingTask.copyWith(isPendingDelete: true);
    }

    if (kIsWeb) return;

    try {
      final db = await database;
      if (db != null) {
        await db.rawUpdate(
          'UPDATE tasks SET isPendingDelete = 1 WHERE id = ?',
          [id],
        );
      }
    } catch (e) {
      debugPrint('saveOfflineDelete error ignored: $e');
    }
  }

  // Retrieves all pending offline new tasks (isOffline = true)
  Future<List<Tasks>> getPendingOfflineTasks() async {
    if (kIsWeb) {
      return _webInMemoryCache
          .where((t) => t.isOffline && !t.isPendingDelete)
          .toList();
    }

    try {
      final db = await database;
      if (db == null) {
        return _webInMemoryCache
            .where((t) => t.isOffline && !t.isPendingDelete)
            .toList();
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isOffline = ? AND isPendingDelete = ?',
        whereArgs: [1, 0],
      );
      return maps.map((mappedRow) => Tasks.fromMap(mappedRow)).toList();
    } catch (e) {
      debugPrint('getPendingOfflineTasks error ignored: $e');
      return _webInMemoryCache
          .where((t) => t.isOffline && !t.isPendingDelete)
          .toList();
    }
  }

  // Retrieves all pending offline task updates (isPendingUpdate = true)
  Future<List<Tasks>> getPendingUpdateTasks() async {
    if (kIsWeb) {
      return _webInMemoryCache
          .where((t) => t.isPendingUpdate && !t.isPendingDelete)
          .toList();
    }

    try {
      final db = await database;
      if (db == null) {
        return _webInMemoryCache
            .where((t) => t.isPendingUpdate && !t.isPendingDelete)
            .toList();
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isPendingUpdate = ? AND isPendingDelete = ?',
        whereArgs: [1, 0],
      );
      return maps.map((mappedRow) => Tasks.fromMap(mappedRow)).toList();
    } catch (e) {
      debugPrint('getPendingUpdateTasks error ignored: $e');
      return _webInMemoryCache
          .where((t) => t.isPendingUpdate && !t.isPendingDelete)
          .toList();
    }
  }

  // Retrieves all pending offline task deletions (isPendingDelete = true)
  Future<List<Tasks>> getPendingDeleteTasks() async {
    if (kIsWeb) {
      return _webInMemoryCache.where((t) => t.isPendingDelete).toList();
    }

    try {
      final db = await database;
      if (db == null) {
        return _webInMemoryCache.where((t) => t.isPendingDelete).toList();
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isPendingDelete = ?',
        whereArgs: [1],
      );
      return maps.map((mappedRow) => Tasks.fromMap(mappedRow)).toList();
    } catch (e) {
      debugPrint('getPendingDeleteTasks error ignored: $e');
      return _webInMemoryCache.where((t) => t.isPendingDelete).toList();
    }
  }

  // Replaces temp offline local task with official server-created task once synced to Web API
  Future<void> markTaskSynced(int localTempId, Tasks serverTask) async {
    final syncedTask = serverTask.copyWith(
      isOffline: false,
      isPendingUpdate: false,
      isPendingDelete: false,
    );

    _webInMemoryCache.removeWhere((t) => t.id == localTempId);
    _webInMemoryCache.removeWhere((t) => t.id == syncedTask.id);
    _webInMemoryCache.add(syncedTask);

    if (kIsWeb) return;

    try {
      final db = await database;
      if (db != null) {
        await db.delete('tasks', where: 'id = ?', whereArgs: [localTempId]);
        await db.insert(
          'tasks',
          syncedTask.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('markTaskSynced error ignored: $e');
    }
  }

  // Replaces current SQLite cache with latest successful server data while preserving un-synced offline tasks
  Future<void> cacheTasks(List<Tasks> tasks) async {
    final pendingOffline = await getPendingOfflineTasks();
    final pendingUpdates = await getPendingUpdateTasks();
    final pendingDeletes = await getPendingDeleteTasks();

    if (kIsWeb) {
      _webInMemoryCache.clear();
      _webInMemoryCache.addAll(tasks);
      _webInMemoryCache.addAll(pendingOffline);
      return;
    }

    try {
      final db = await database;
      if (db == null) {
        _webInMemoryCache.clear();
        _webInMemoryCache.addAll(tasks);
        _webInMemoryCache.addAll(pendingOffline);
        return;
      }

      final batch = db.batch();
      batch.delete('tasks', where: 'isOffline = ?', whereArgs: [0]);

      for (var task in tasks) {
        final isDeleting = pendingDeletes.any((d) => d.id == task.id);
        if (isDeleting) continue;

        final offlineUpdate = pendingUpdates.firstWhere(
          (u) => u.id == task.id,
          orElse: () => task,
        );

        batch.insert(
          'tasks',
          offlineUpdate.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('cacheTasks error ignored: $e');
      _webInMemoryCache.clear();
      _webInMemoryCache.addAll(tasks);
      _webInMemoryCache.addAll(pendingOffline);
    }
  }

  // Retrieve cached tasks during offline reads (excluding tasks marked for pending deletion)
  Future<List<Tasks>> getCachedTasks() async {
    if (kIsWeb) {
      return List.unmodifiable(
        _webInMemoryCache.where((t) => !t.isPendingDelete).toList(),
      );
    }

    try {
      final db = await database;
      if (db == null) {
        return List.unmodifiable(
          _webInMemoryCache.where((t) => !t.isPendingDelete).toList(),
        );
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isPendingDelete = ?',
        whereArgs: [0],
      );
      return maps.map((mappedRows) => Tasks.fromMap(mappedRows)).toList();
    } catch (e) {
      debugPrint('getCachedTasks error ignored: $e');
      return List.unmodifiable(
        _webInMemoryCache.where((t) => !t.isPendingDelete).toList(),
      );
    }
  }

  // Remove single cached task
  Future<void> deleteCachedTask(int id) async {
    _webInMemoryCache.removeWhere((t) => t.id == id);
    if (kIsWeb) return;

    try {
      final db = await database;
      if (db != null) {
        await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
      }
    } catch (e) {
      debugPrint('deleteCachedTask error ignored: $e');
    }
  }
}
