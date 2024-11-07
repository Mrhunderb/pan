import 'package:filesize/filesize.dart';
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
  late Future<List<String>> _folders;

  @override
  void initState() {
    super.initState();
    _files = OssService.listFiles();
    _folders = OssService.listFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_files, _folders]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Object> files = snapshot.data![0];
          List<String> folders = snapshot.data![1];
          return ListView(
            children: [
              for (var folder in folders)
                FileCard(
                  fileName: folder.runes.string,
                  isFolder: true,
                ),
              for (var file in files)
                FileCard(
                  fileName: file.key!,
                  fileSize: filesize(file.size!),
                  createdTime: file.lastModified,
                  isFolder: false,
                ),
            ],
          );
        },
      ),
    );
  }
}
