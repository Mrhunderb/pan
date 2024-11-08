import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pan/screens/pan.dart';
import 'package:pan/screens/pdf_view.dart';
import 'package:pan/screens/picture_view.dart';
import 'package:pan/screens/unable_view.dart';
import 'package:pan/screens/video_view.dart';
import 'package:pan/utils/type.dart';

class FileCard extends StatefulWidget {
  final String path;
  final String? fileSize;
  final DateTime? createdTime;
  final bool isFolder;
  final bool isSelect;
  final Function(String) onSelect;

  const FileCard({
    super.key,
    required this.path,
    this.fileSize,
    this.createdTime,
    required this.isFolder,
    required this.onSelect,
    required this.isSelect,
  });

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  String get fileSuffix => widget.path.split('.').last;
  String get fileName => widget.isFolder
      ? widget.path.split('/')[widget.path.split('/').length - 2]
      : widget.path.split('/').last;

  late String type;
  late String imagePath;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    type = getFileType(widget.path, widget.isFolder);
    imagePath = getImagePath(type);
  }

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
            //checkbox
            Checkbox(
              value: widget.isSelect,
              onChanged: (bool? value) {
                widget.onSelect(widget.path);
              },
            )
          ],
        ),
      ),
    );
  }
}
