import 'package:pan/models/task.dart';
import 'package:pan/services/oss.dart';

class Upload extends Task {
  bool _isPaused = false;
  bool _isCanceled = false;

  Upload({required super.name, required super.path});

  Future<void> upload() async {
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
      status = _isCanceled ? Status.failed : Status.paused;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> cancel() async {
    if (status == Status.running || status == Status.paused) {
      _isCanceled = true;
      status = Status.canceled;
      notifyListeners();
    }
  }

  @override
  Future<void> start() async {
    if (status == Status.pending || status == Status.paused) {
      await upload();
    }
  }

  @override
  Future<void> resume() async {}
}
