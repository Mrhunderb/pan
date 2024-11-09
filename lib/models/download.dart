import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';

enum Status { pending, running, completed, failed }

class Download extends ChangeNotifier {
  final String name;
  final String path;
  Status status = Status.pending;

  Download(this.name, this.path);

  Future<void> download() async {
    notifyListeners();
    status = Status.running;
    try {
      await OssService.fDownloadWithProgress(name, path, (received, total) {});
      status = Status.completed;
      notifyListeners();
    } catch (e) {
      status = Status.failed;
      notifyListeners();
    }
  }

  Future<void> start() async {
    status = Status.running;
    download();
  }
}
