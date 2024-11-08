enum Status {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

class DownloadItem {
  final String id;
  final String name;
  double progress;
  String status;

  DownloadItem({
    required this.id,
    required this.name,
    this.progress = 0.0,
    this.status = 'pending',
  });

  @override
  String toString() {
    return 'DownloadItem{id: $id, name: $name, progress: $progress, status: $status}';
  }
}

class DownloadQueue {
  final List<DownloadItem> _items = [];

  List<DownloadItem> get items => _items;

  void add(DownloadItem item) {
    _items.add(item);
  }

  void remove(String id) {
    _items.removeWhere((element) => element.id == id);
  }

  void update(String id, double progress, String status) {
    final item = _items.firstWhere((element) => element.id == id);
    item.progress = progress;
    item.status = status;
  }
}
