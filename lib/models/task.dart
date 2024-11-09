import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pan/models/download.dart';

class TaskQueue with ChangeNotifier {
  final int maxConcurrentTasks;
  final Queue<Download> _taskQueue = Queue();
  final Queue<Download> _downloadTasks = Queue();
  final Queue<Download> _completedTasks = Queue();
  final Queue<Download> _pausedTasks = Queue();
  int _currentTaskCount = 0;

  TaskQueue(this.maxConcurrentTasks);

  void addTask(Download task) {
    task.addListener(notifyListeners);
    _taskQueue.add(task);
    _startNextTask();
  }

  void removeTask(Download task) {
    task.cancel();
    task.removeListener(notifyListeners);
    _taskQueue.remove(task);
    _completedTasks.remove(task);
    _downloadTasks.remove(task);
    _pausedTasks.remove(task);
    notifyListeners();
  }

  void cancelTask(Download task) {
    task.cancel();
    removeTask(task);
  }

  void pauseTask(Download task) {
    task.pause();
    _pausedTasks.add(task);
    _downloadTasks.remove(task);
    notifyListeners();
    _startNextTask();
  }

  void resumeTask(Download task) {
    task.resume();
    _pausedTasks.remove(task);
    _taskQueue.add(task);
    notifyListeners();
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
      if (item.status != Status.canceled) {
        _startNextTask();
      }
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
      [..._downloadTasks, ..._pausedTasks, ..._taskQueue, ..._completedTasks];
}
