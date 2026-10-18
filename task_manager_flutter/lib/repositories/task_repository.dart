import 'package:flutter/foundation.dart';

import '../models/tasks.dart';
import '../services/task_api_service.dart';
import '../services/task_cache_service.dart';

class TaskRepository {
  final TaskApiService _apiService;
  final TaskCacheService _cacheService;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  TaskRepository({
    required TaskApiService apiService,
    required TaskCacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  /// Creates a task locally marked as offline pending server sync
  Future<Tasks> createOfflineTask(Tasks task) async {
    final offlineTask = await _cacheService.saveOfflineTask(task);
    debugPrint('Task saved locally as offline task: ${offlineTask.title}');
    return offlineTask;
  }

  /// Automatically posts pending creations, updates, and deletions to Web API once network is back
  Future<void> syncOfflineTasks() async {
    try {
      // 1. Sync Pending Deletions
      final pendingDeletes = await _cacheService.getPendingDeleteTasks();
      for (var delTask in pendingDeletes) {
        try {
          await _apiService.deleteTask(delTask.id);
          await _cacheService.deleteCachedTask(delTask.id);
          debugPrint('Synced offline deletion for task ID ${delTask.id} to Web API');
        } catch (e) {
          debugPrint('Failed to sync offline deletion for task ID ${delTask.id}: $e');
        }
      }

      // 2. Sync Pending Updates
      final pendingUpdates = await _cacheService.getPendingUpdateTasks();
      for (var updTask in pendingUpdates) {
        try {
          final serverPayload = updTask.copyWith(isPendingUpdate: false);
          await _apiService.updateTask(updTask.id, serverPayload);
          await _cacheService.saveOfflineUpdate(serverPayload);
          debugPrint('Synced offline update for task ID ${updTask.id} to Web API');
        } catch (e) {
          debugPrint('Failed to sync offline update for task ID ${updTask.id}: $e');
        }
      }

      // 3. Sync Pending Creations
      final pendingOffline = await _cacheService.getPendingOfflineTasks();
      for (var offlineTask in pendingOffline) {
        try {
          final serverPayload = offlineTask.copyWith(id: 0, isOffline: false);
          final createdServerTask = await _apiService.createTask(serverPayload);
          await _cacheService.markTaskSynced(offlineTask.id, createdServerTask);
          debugPrint('Synced offline creation "${offlineTask.title}" -> Web API ID ${createdServerTask.id}');
        } catch (e) {
          debugPrint('Failed to sync offline creation "${offlineTask.title}": $e');
        }
      }
    } catch (e) {
      debugPrint('syncOfflineTasks error occurred: $e');
    }
  }

  /// Fetches tasks from API and updates local cache.
  /// Automatically syncs any pending offline actions first when API is online.
  Future<List<Tasks>> getTasks() async {
    try {
      await syncOfflineTasks();

      final List<Tasks> remoteTasks;
      try {
        remoteTasks = await _apiService.fetchTasks();
        _isOffline = false;
      } catch (_) {
        _isOffline = true;
        rethrow;
      }

      try {
        await _cacheService.cacheTasks(remoteTasks);
      } catch (e) {
        debugPrint('Cache sync error ignored: $e');
      }

      final allTasks = await _cacheService.getCachedTasks();
      return allTasks.isNotEmpty ? allTasks : remoteTasks;
    } catch (_) {
      try {
        final cachedTasks = await _cacheService.getCachedTasks();
        if (cachedTasks.isNotEmpty) {
          return cachedTasks;
        }
      } catch (cacheError) {
        debugPrint('Cache read error: $cacheError');
      }

      rethrow;
    }
  }

  /// Creates task on Web API first. If offline, automatically saves as an offline task locally.
  Future<Tasks> addTask(Tasks task) async {
    try {
      await syncOfflineTasks();

      final createdTask = await _apiService.createTask(task);
      try {
        await getTasks(); // Re-sync local cache
      } catch (e) {
        debugPrint('Re-sync error ignored: $e');
      }
      return createdTask;
    } catch (e) {
      _isOffline = true;
      debugPrint('API unavailable when creating task, switching to offline creation: $e');
      final offlineTask = await createOfflineTask(task);
      return offlineTask;
    }
  }

  /// Updates task on backend. If offline, saves update locally as pending update.
  Future<void> updateTask(Tasks task) async {
    try {
      await syncOfflineTasks();
      await _apiService.updateTask(task.id, task);
      _isOffline = false;
      await _cacheService.saveOfflineUpdate(task.copyWith(isPendingUpdate: false));
    } catch (e) {
      _isOffline = true;
      debugPrint('API unavailable when updating task, saving update locally: $e');
      await _cacheService.saveOfflineUpdate(task);
    }
  }

  /// Deletes task on backend API. If offline, marks task for deletion locally.
  Future<void> deleteTask(int id) async {
    try {
      if (id < 0) {
        // Unsynced local task -> remove immediately
        await _cacheService.deleteCachedTask(id);
        return;
      }
      await syncOfflineTasks();
      await _apiService.deleteTask(id);
      _isOffline = false;
      await _cacheService.deleteCachedTask(id);
    } catch (e) {
      _isOffline = true;
      debugPrint('API unavailable when deleting task, marking for offline deletion: $e');
      await _cacheService.saveOfflineDelete(id);
    }
  }
}
