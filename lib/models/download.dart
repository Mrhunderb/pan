import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';

enum Status { pending, running, completed, failed, paused, canceled }

class Download extends ChangeNotifier {
  final String name;
  final String path;
  int received = 0;
  int total = 0;
  double progress = 0;
  Status status = Status.pending;

  bool _isPaused = false;
  bool _isCanceled = false;

  Download(this.name, this.path);

  Future<void> download() async {
    status = Status.running;
    _isPaused = false;
    _isCanceled = false;
    notifyListeners();

    try {
      await OssService.fDownloadWithProgress(name, path, (received, total) {
        if (_isPaused || _isCanceled) {
          throw Exception(_isPaused ? "Paused" : "Canceled");
        }
        this.received = received;
        this.total = total;
        progress = received / total;
        notifyListeners();
      });
      status = Status.completed;
    } catch (e) {
      // 根据异常类型更新状态
      status = _isCanceled ? Status.failed : Status.paused;
    } finally {
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (status == Status.running) {
      _isPaused = true;
      status = Status.paused;
      notifyListeners();
    }
  }

  Future<void> cancel() async {
    if (status == Status.running || status == Status.paused) {
      _isCanceled = true;
      status = Status.canceled;
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (status == Status.pending || status == Status.paused) {
      await download();
    }
  }

  Future<void> resume() async {
    if (status == Status.paused) {
      _isPaused = false;
      status = Status.pending;
    }
  }
}
