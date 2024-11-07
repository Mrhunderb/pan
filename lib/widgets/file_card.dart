import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileCard extends StatelessWidget {
  final String path;
  final String? fileSize;
  final DateTime? createdTime;
  final bool isFolder;

  FileCard({
    super.key,
    required this.path,
    this.fileSize,
    this.createdTime,
    required this.isFolder,
  });

  String get fileSuffix => path.split('.').last;
  String get fileName => isFolder
      ? path.split('/')[path.split('/').length - 2]
      : path.split('/').last;

  final Map<String, String> _fileTypeToImagePath = {
    'pdf': 'assets/pdf.png',
    'doc': 'assets/doc.png',
    'image': 'assets/image.png',
    'video': 'assets/video.png',
    'folder': 'assets/folder.png',
    'file': 'assets/file.png',
  };

  final Map<String, String> _suffixToType = {
    'pdf': 'pdf',
    'doc': 'doc',
    'txt': 'doc',
    'docx': 'doc',
    'png': 'image',
    'jpg': 'image',
    'jpeg': 'image',
    'mp4': 'video',
    'mp3': 'video',
    'mkv': 'video',
    'avi': 'video',
  };

  String get imagePath {
    if (isFolder) {
      return _fileTypeToImagePath['folder']!;
    }
    final String type = _suffixToType[fileSuffix] ?? 'file';
    return _fileTypeToImagePath[type]!;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = createdTime != null
        ? DateFormat('yyyy/MM/dd HH:mm:ss').format(createdTime!)
        : '';

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            height: 35,
            width: 45,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.length > 20
                      ? '${fileName.substring(0, 20)}...'
                      : fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isFolder)
                  Text(
                    '$formattedDate · $fileSize',
                    style: const TextStyle(
                      fontSize: 12,
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
