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
  late final String pictureUrl;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final picturePath = widget.picturePath;
    final pictureName = picturePath.split('/').last;
    final pictureUrl = await OssService.getFileUrl(picturePath).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Failed to get picture url');
      },
    );
    setState(() {
      this.pictureName = pictureName;
      this.pictureUrl = pictureUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pictureName),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initialLoad,
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            return PhotoView(
              imageProvider: NetworkImage(pictureUrl),
            );
          },
        ),
      ),
    );
  }
}
