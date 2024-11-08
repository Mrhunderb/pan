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
        title: Text(pictureName),
      ),
      body: Center(
        child: FutureBuilder(
          future: OssService.getFileUrl(widget.picturePath),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            final pictureUrl = futureSnapshot.data as String;
            return PhotoView(
              imageProvider: NetworkImage(pictureUrl),
            );
          },
        ),
      ),
    );
  }
}
