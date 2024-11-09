import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:pan/models/task.dart';

class DownloadCard extends StatefulWidget {
  final Task task;
  final bool isUpload;
  final Function() onCancel;
  final Function() onPause;

  const DownloadCard({
    super.key,
    required this.task,
    required this.onCancel,
    required this.onPause,
    required this.isUpload,
  });

  @override
  State<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {
  @override
  Widget build(BuildContext context) {
    String recv = filesize(widget.task.received);
    String total = filesize(widget.task.total);
    String progress = (widget.task.progress * 100).toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      child: Row(
        children: [
          Icon(
            switch (widget.task.status) {
              Status.pending => Icons.pending,
              Status.running => Icons.download,
              Status.completed => Icons.done,
              Status.failed => Icons.error,
              Status.paused => Icons.pause,
              Status.canceled => Icons.cancel,
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.name.length > 20
                    ? '${widget.task.name.substring(0, 20)}...'
                    : widget.task.name),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.task.progress,
                ),
                Text(
                  '$recv / $total ($progress%)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          widget.isUpload
              ? const SizedBox()
              : IconButton(
                  onPressed: () {
                    widget.onPause();
                  },
                  icon: Icon(widget.task.status == Status.running
                      ? Icons.pause
                      : Icons.play_arrow),
                ),
          IconButton(
            onPressed: () {
              widget.onCancel();
            },
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
