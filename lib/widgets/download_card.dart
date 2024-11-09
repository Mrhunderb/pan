import 'package:flutter/material.dart';
import 'package:pan/models/download.dart';

class DownloadCard extends StatefulWidget {
  final Download task;

  const DownloadCard({super.key, required this.task});

  @override
  State<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {
  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
