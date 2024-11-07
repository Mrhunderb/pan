import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class PictureView extends StatefulWidget {
  final String picturePath;

  const PictureView({super.key, required this.picturePath});

  @override
  State<PictureView> createState() => _PictureViewState();
}

class _PictureViewState extends State<PictureView> {
  late final String pictureName;

  @override
  void initState() {
    super.initState();
    pictureName = widget.picturePath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture View'),
      ),
      body: Center(
        child: FutureBuilder(
          future: OssService.downloadFileInTemp(widget.picturePath),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            final localPath = futureSnapshot.data as String;
            return PhotoView(
              imageProvider: FileImage(File(localPath)),
            );
          },
        ),
      ),
    );
  }
}
