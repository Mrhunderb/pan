import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DownloadPage extends StatelessWidget {
  final List<DownloadItem> items;

  const DownloadPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('传输列表'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              ToggleSwitch(
                initialLabelIndex: 0,
                labels: const ['下载', '上传'],
                icons: const [Icons.file_download, Icons.file_upload],
                onToggle: (index) {
                  // Handle toggle
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.file_download),
                        title: Text(item.title),
                        subtitle: Text(item.subtitle),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Handle more options
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class DownloadItem {
  final String title;
  final String subtitle;

  DownloadItem({required this.title, required this.subtitle});
}
