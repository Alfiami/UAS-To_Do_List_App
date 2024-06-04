import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  DateTime? _selectedDate;

  List<Task> get tasks => _tasks;
  DateTime? get selectedDate => _selectedDate;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void toggleFavorite(Task task) {
    final taskIndex = _tasks.indexWhere((element) => element.id == task.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(isFavorite: !_tasks[taskIndex].isFavorite);
      moveTaskToTop(taskIndex);
      notifyListeners();
    }
  }

  void updateTask(Task task, String title, String? note) {
    final taskIndex = _tasks.indexWhere((element) => element.id == task.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = task.copyWith(title: title, note: note);
      notifyListeners();
    }
  }

  void toggleTaskCompletion(Task task) {
    final taskIndex = _tasks.indexWhere((element) => element.id == task.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void moveTaskToTop(int index) {
    final task = _tasks.removeAt(index);
    _tasks.insert(0, task);
    notifyListeners();
  }

  void moveCheckedTaskToBottom(Task checkedTask) {
    _tasks.remove(checkedTask);
    _tasks.add(checkedTask);
    notifyListeners();
  }

  void filterTasks(String query) {
    List<Task> filteredTasks = _tasks.where((task) => task.title.toLowerCase().contains(query.toLowerCase())).toList();
    _tasks.clear();
    _tasks.addAll(filteredTasks);
    notifyListeners();
  }
}
