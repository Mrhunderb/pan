import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';
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
        child: FutureBuilder<Stream<List<int>>>(
          future: OssService.downloadFile(widget.picturePath),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }

            return StreamBuilder<List<int>>(
              stream: futureSnapshot.data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                var stream = snapshot.data!;
                return PhotoView(
                  imageProvider: MemoryImage(Uint8List.fromList(stream)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained * 0.5,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
