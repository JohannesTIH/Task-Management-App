import 'package:flutter/foundation.dart';

import '../models/tasks.dart';
import '../repositories/task_repository.dart';

enum DetailsViewState { idle, loading, success, error }

class TaskDetailsViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  TaskDetailsViewModel(this._repository);

  DetailsViewState _state = DetailsViewState.idle;
  DetailsViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> updateTask(Tasks task) async {
    _state = DetailsViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateTask(task);
      _state = DetailsViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = DetailsViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    _state = DetailsViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTask(taskId);
      _state = DetailsViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = DetailsViewState.error;
      notifyListeners();
      return false;
    }
  }
}
