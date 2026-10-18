import 'package:flutter/foundation.dart';

import '../models/tasks.dart';
import '../repositories/task_repository.dart';

enum ViewState { initial, loading, loaded, error }

class TaskListViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  TaskListViewModel(this._repository);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;
  bool get isOffline => _repository.isOffline;

  List<Tasks> _allTasks = [];
  List<Tasks> get tasks => _filteredTasks();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int? _selectedPriorityFilter; // null = All, 0 = Low, 1 = Medium, 2 = High
  int? get selectedPriorityFilter => _selectedPriorityFilter;

  bool _showOverdueOnly = false;
  bool get showOverdueOnly => _showOverdueOnly;

  // Categories
  final List<String> _categories = ['Work', 'Personal', 'Study'];
  List<String> get categories => List.unmodifiable(_categories);

  String? _selectedCategoryFilter; // null = All Categories
  String? get selectedCategoryFilter => _selectedCategoryFilter;

  int get allTasksCount => _allTasks.length;

  int getCategoryTaskCount(String categoryName) {
    return _allTasks.where((task) {
      final cat = task.category ?? 'Personal';
      return cat.toLowerCase() == categoryName.toLowerCase();
    }).length;
  }

  List<Tasks> getTasksForDate(DateTime date) {
    return _allTasks.where((task) {
      final taskDate = task.dueDate ?? task.createdAt;
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }

  void selectCategory(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void toggleOverdueFilter(bool showOverdue) {
    _showOverdueOnly = showOverdue;
    notifyListeners();
  }

  List<Tasks> _filteredTasks() {
    return _allTasks.where((task) {
      // 1. Category Filter
      if (_selectedCategoryFilter != null) {
        final taskCat = task.category ?? 'Personal';
        if (taskCat.toLowerCase() != _selectedCategoryFilter!.toLowerCase()) {
          return false;
        }
      }

      // 2. Overdue Filter
      if (_showOverdueOnly) {
        if (task.isCompleted) return false;
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final taskDate = task.dueDate ?? task.createdAt;
        return taskDate.isBefore(todayStart);
      }

      // 3. Priority Filter
      if (_selectedPriorityFilter != null) {
        if (task.priority != _selectedPriorityFilter) return false;
      }

      // 4. Date Filter (Applied when not filtering by Overdue or Priority or Category)
      if (!_showOverdueOnly &&
          _selectedPriorityFilter == null &&
          _selectedCategoryFilter == null) {
        final taskDate = task.dueDate ?? task.createdAt;
        final isSameDay =
            taskDate.year == _selectedDate.year &&
            taskDate.month == _selectedDate.month &&
            taskDate.day == _selectedDate.day;

        if (!isSameDay) return false;
      }

      return true;
    }).toList();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void filterByPriority(int? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTasks = await _repository.getTasks();
      _state = ViewState.loaded;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('fetchTasks error: $e');
      debugPrintStack(stackTrace: stack);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = ViewState.error;
      notifyListeners();
    }
  }

  Future<bool> addTask(
    String title,
    String? description,
    int priority,
    DateTime? dueDate,
    String category,
  ) async {
    try {
      final newTask = Tasks(
        id: 0,
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );

      await _repository.addTask(newTask);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskStatus(Tasks task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _repository.updateTask(updatedTask);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await fetchTasks();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
