import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';
import 'package:pan/widgets/file_card.dart';
import 'package:minio/models.dart';

class PanFilePage extends StatefulWidget {
  const PanFilePage({super.key, required this.title});

  final String title;

  @override
  State<PanFilePage> createState() => _PanFilePage();
}

class _PanFilePage extends State<PanFilePage> {
  late Future<List<Object>> _files;
  late Future<int> _fileCount;
  late Future<List<String>> _folders;

  @override
  void initState() {
    super.initState();
    _files = OssService.listFiles();
    _fileCount = OssService.fileCount();
    _folders = OssService.listFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FileCard(
              fileName: "头号玩家.mp4",
              isFolder: true,
            ),
            FileCard(
              fileName: "头号玩家.mp4",
              isFolder: true,
            ),
            FileCard(
              fileName: "头号玩家.mkv",
              fileSize: "1.2GB",
              createdTime: DateTime.now(),
              isFolder: false,
            ),
            FileCard(
              fileName: "头号玩家.txt",
              fileSize: "1.2GB",
              createdTime: DateTime.now(),
              isFolder: false,
            ),
            FileCard(
              fileName: "头号玩家.pdf",
              fileSize: "1.2GB",
              createdTime: DateTime.now(),
              isFolder: false,
            ),
            FileCard(
              fileName: "头号玩家.jpg",
              fileSize: "1.2GB",
              createdTime: DateTime.now(),
              isFolder: false,
            ),
            FutureBuilder<int>(
              future: _fileCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return FileCard(
                    fileName: '${snapshot.data} files',
                    fileSize: "1.2GB",
                    createdTime: DateTime.now(),
                    isFolder: false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
