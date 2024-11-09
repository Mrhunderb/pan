import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pan/models/download.dart';

class TaskQueue with ChangeNotifier {
  final int maxConcurrentTasks;
  final Queue<Download> _taskQueue = Queue();
  final Queue<Download> _completedTasks = Queue();
  int _currentTaskCount = 0;

  TaskQueue(this.maxConcurrentTasks);

  void addTask(Download task) {
    task.addListener(notifyListeners);
    for (var t in _taskQueue) {
      if (t.name == task.name && t.status != Status.completed) {
        return;
      }
    }
    _taskQueue.add(task);
    _tryExecuteNext();
  }

  void removeTask(Download task) {
    _taskQueue.remove(task);
    _completedTasks.remove(task);
    notifyListeners();
  }

  void _tryExecuteNext() {
    if (_currentTaskCount < maxConcurrentTasks && _taskQueue.isNotEmpty) {
      _currentTaskCount++;
      final task = _taskQueue.removeFirst();
      task.start().whenComplete(() {
        _currentTaskCount--;
        _completedTasks.add(task);
        _tryExecuteNext();
      });
    }
  }

  List<Download> get tasks => _taskQueue.toList();
  List<Download> get completedTasks => _completedTasks.toList();
  List<Download> get allTasks => [..._taskQueue, ..._completedTasks];
}
