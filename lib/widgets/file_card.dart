import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pan/screens/pan.dart';
import 'package:pan/screens/pdf_view.dart';
import 'package:pan/screens/picture_view.dart';
import 'package:pan/screens/unable_view.dart';
import 'package:pan/screens/video_view.dart';

class FileCard extends StatefulWidget {
  final String path;
  final String? fileSize;
  final DateTime? createdTime;
  final bool isFolder;

  const FileCard({
    super.key,
    required this.path,
    this.fileSize,
    this.createdTime,
    required this.isFolder,
  });

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  String get fileSuffix => widget.path.split('.').last;
  String get fileName => widget.isFolder
      ? widget.path.split('/')[widget.path.split('/').length - 2]
      : widget.path.split('/').last;

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

  String get type {
    if (widget.isFolder) {
      return 'folder';
    }
    return _suffixToType[fileSuffix] ?? 'file';
  }

  String get imagePath {
    return _fileTypeToImagePath[type]!;
  }

  bool _isPressed = false;

  void _onTap(BuildContext context) {
    if (widget.isFolder) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanFilePage(
            title: widget.path,
            prefix: widget.path,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            switch (type) {
              case 'image':
                return PictureView(picturePath: widget.path);
              case 'pdf':
                return PdfView(pdfPath: widget.path);
              case 'video':
                return VideoView(videoPath: widget.path);
              default:
                return const UnableView();
            }
          },
        ),
      );
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = widget.createdTime != null
        ? DateFormat('yyyy/MM/dd HH:mm:ss').format(widget.createdTime!)
        : '';

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isPressed ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => _onTap(context),
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
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
                  if (!widget.isFolder)
                    Text(
                      '$formattedDate · ${widget.fileSize}',
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
      ),
    );
  }
}
