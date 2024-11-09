import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pan/models/download.dart';

class TaskQueue with ChangeNotifier {
  final int maxConcurrentTasks;
  final Queue<Download> _taskQueue = Queue();
  final Queue<Download> _downloadTasks = Queue();
  final Queue<Download> _completedTasks = Queue();
  int _currentTaskCount = 0;

  TaskQueue(this.maxConcurrentTasks);

  void addTask(Download task) {
    task.addListener(notifyListeners);
    _taskQueue.add(task);
    _startNextTask();
  }

  void _startNextTask() {
    if (_currentTaskCount >= maxConcurrentTasks || _taskQueue.isEmpty) {
      return;
    }
    _currentTaskCount++;
    final item = _taskQueue.removeFirst();
    _downloadTasks.add(item);
    item.start().whenComplete(() {
      _completedTasks.add(item);
      _downloadTasks.remove(item);
      _currentTaskCount--;
      notifyListeners();
      _startNextTask();
    });
  }

  List<Download> get tasks => _taskQueue.toList();
  List<Download> get completedTasks => _completedTasks.toList();
  List<Download> get downloadTasks => _downloadTasks.toList();
  List<Download> get allTasks =>
      [..._downloadTasks, ..._taskQueue, ..._completedTasks];
}
