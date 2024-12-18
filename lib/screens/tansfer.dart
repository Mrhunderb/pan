import 'package:flutter/material.dart';
import 'package:pan/models/download.dart';
import 'package:pan/models/task.dart';
import 'package:pan/models/upload.dart';
import 'package:pan/widgets/download_card.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  int? _currentTab = 0;

  Widget _buildListView(TaskQueue queue, bool isUpload) {
    return ListView(
      children: [
        for (var task in queue.allTasks)
          DownloadCard(
            task: task,
            onCancel: () => queue.cancelTask(task),
            onPause: () => {
              if (task.status == Status.running)
                queue.pauseTask(task)
              else if (task.status == Status.paused)
                queue.resumeTask(task)
            },
            isUpload: isUpload,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final downloadQueue = Provider.of<TaskQueue<Download>>(context);
    final uploadQueue = Provider.of<TaskQueue<Upload>>(context);
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
              initialLabelIndex: _currentTab,
              labels: const ['下载', '上传'],
              icons: const [Icons.file_download, Icons.file_upload],
              onToggle: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _currentTab == 0
                  ? _buildListView(downloadQueue, false)
                  : _buildListView(uploadQueue, true),
            ),
          ],
        ),
      ),
    );
  }
}
