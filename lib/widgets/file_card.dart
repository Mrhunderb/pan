import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final DateTime createdTime;
  final String imagePath;

  const FileCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.createdTime,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('yyyy/MM/dd HH:mm:ss').format(createdTime);

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.file(
            File(imagePath),
            height: 60,
            width: 70,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$formattedDate · $fileSize',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
