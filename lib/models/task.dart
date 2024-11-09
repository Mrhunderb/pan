import 'dart:collection';

import 'package:flutter/material.dart';

enum Status { pending, running, completed, failed, paused, canceled }

class Task extends ChangeNotifier {
  final String name;
  final String path;
  int received = 0;
  int total = 0;
  double progress = 0;
  Status status = Status.pending;

  Task({required this.name, required this.path});
  Future<void> start() {
    return Future.value();
  }

  Future<void> pause() {
    return Future.value();
  }

  Future<void> resume() {
    return Future.value();
  }

  Future<void> cancel() {
    return Future.value();
  }
}

class TaskQueue<T extends Task> extends ChangeNotifier {
  final int maxConcurrentTasks;
  final Queue<T> _taskQueue = Queue();
  final Queue<T> _downloadTasks = Queue();
  final Queue<T> _completedTasks = Queue();
  final Queue<T> _pausedTasks = Queue();
  int _currentTaskCount = 0;

  TaskQueue(this.maxConcurrentTasks);

  void addTask(T task) {
    task.addListener(notifyListeners);
    _taskQueue.add(task);
    _startNextTask();
  }

  void removeTask(T task) {
    task.cancel();
    task.removeListener(notifyListeners);
    _taskQueue.remove(task);
    _completedTasks.remove(task);
    _downloadTasks.remove(task);
    _pausedTasks.remove(task);
    notifyListeners();
  }

  void cancelTask(T task) {
    task.cancel();
    removeTask(task);
  }

  void pauseTask(T task) {
    task.pause();
    _pausedTasks.add(task);
    _downloadTasks.remove(task);
    notifyListeners();
    _startNextTask();
  }

  void resumeTask(T task) {
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
        return;
      }
      _currentTaskCount--;
      _downloadTasks.remove(item);
      _completedTasks.add(item);
      notifyListeners();
      _startNextTask();
    });
  }

  List<T> get tasks => _taskQueue.toList();
  List<T> get completedTasks => _completedTasks.toList();
  List<T> get downloadTasks => _downloadTasks.toList();
  List<T> get allTasks =>
      [..._downloadTasks, ..._pausedTasks, ..._taskQueue, ..._completedTasks];
}
