import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:pan/screens/download.dart';
import 'package:pan/services/oss.dart';
import 'package:pan/widgets/confirm.dart';
import 'package:pan/widgets/file_card.dart';
import 'package:minio/models.dart';

class PanFilePage extends StatefulWidget {
  final String title;
  final String prefix;

  const PanFilePage({
    super.key,
    required this.title,
    required this.prefix,
  });

  @override
  State<PanFilePage> createState() => _PanFilePage();
}

class _PanFilePage extends State<PanFilePage> {
  late Future<void> _initialLoad; // 初始加载 Future
  List<Object> _filesCache = []; // 缓存文件列表
  List<String> _foldersCache = []; // 缓存文件夹列表
  OverlayEntry? _overlayEntry;

  final Map<String, bool> _selectedFiles = {};

  void _onSelect(String path) {
    setState(() {
      _selectedFiles[path] = !_selectedFiles[path]!; // 切换选中状态
    });
    if (_selectedFiles.values.any((selected) => selected)) {
      _showOverlay(context);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  List<String> getSelectedFiles() {
    return _selectedFiles.entries
        .where((element) => element.value)
        .map((e) => e.key)
        .toList();
  }

  void _clearSelected() {
    setState(() {
      _selectedFiles.forEach((key, value) {
        _selectedFiles[key] = false;
      });
    });
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      return; // 防止重复显示
    }

    OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.white.withOpacity(0.98),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('删除'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: '删除',
                        content: '确认删除选中的文件吗？',
                        onConfirm: () {
                          Navigator.pop(context);
                          OssService.deleteFiles(
                            getSelectedFiles(),
                            widget.prefix,
                          );
                          _clearSelected();
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                          _refresh();
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('下载'),
                  onTap: () {
                    _clearSelected();
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  @override
  void initState() {
    super.initState();
    // 初始化数据并缓存
    _initialLoad = _loadFilesAndFolders();
  }

  Future<void> _loadFilesAndFolders() async {
    // 获取文件和文件夹并缓存
    final files = await OssService.listFiles(widget.prefix);
    final folders = await OssService.listFolders(widget.prefix);

    setState(() {
      _filesCache = files;
      _foldersCache = folders;
      // 初始化选择状态
      for (var folder in _foldersCache) {
        _selectedFiles.putIfAbsent(folder, () => false);
      }
      for (var file in _filesCache) {
        _selectedFiles.putIfAbsent(file.key!, () => false);
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _initialLoad = _loadFilesAndFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 1, child: Text(widget.title)),
            Text(
                "选中: ${_selectedFiles.values.where((selected) => selected).length}"),
            IconButton(
              icon: const Icon(Icons.swap_vert_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DownloadPage(
                    items: [
                      DownloadItem(
                        title: 'File 1',
                        subtitle: 'File 1 subtitle',
                      ),
                      DownloadItem(
                        title: 'File 2',
                        subtitle: 'File 2 subtitle',
                      ),
                    ],
                  );
                }));
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh, // 下拉刷新
        child: FutureBuilder<void>(
          future: _initialLoad,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return ListView(
              children: [
                for (var folder in _foldersCache)
                  FileCard(
                    path: folder,
                    isFolder: true,
                    onSelect: _onSelect,
                    isSelect: _selectedFiles[folder]!,
                  ),
                for (var file in _filesCache)
                  FileCard(
                    path: file.key!,
                    fileSize: filesize(file.size!),
                    createdTime: file.lastModified,
                    isFolder: false,
                    onSelect: _onSelect,
                    isSelect: _selectedFiles[file.key!]!,
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOverlay(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
