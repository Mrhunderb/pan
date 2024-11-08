import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:pan/screens/download.dart';
import 'package:pan/services/oss.dart';
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
  late Future<List<Object>> _files;
  late Future<List<String>> _folders;

  @override
  void initState() {
    super.initState();
    _files = OssService.listFiles(widget.prefix);
    _folders = OssService.listFolders(widget.prefix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
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
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_files, _folders]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Object> files = snapshot.data![0];
          List<String> folders = snapshot.data![1];
          return ListView(
            children: [
              for (var folder in folders)
                FileCard(
                  path: folder.runes.string,
                  isFolder: true,
                ),
              for (var file in files)
                FileCard(
                  path: file.key!,
                  fileSize: filesize(file.size!),
                  createdTime: file.lastModified,
                  isFolder: false,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
