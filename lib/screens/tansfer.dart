import 'package:flutter/material.dart';
import 'package:pan/models/task.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    final queue = Provider.of<TaskQueue>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('传输列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                itemCount: queue.allTasks.length,
                itemBuilder: (context, index) {
                  final task = queue.allTasks[index];
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Text(task.status.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        queue.removeTask(task);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
