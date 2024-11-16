import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:pan/services/oss.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoPath;
  const VideoView({super.key, required this.videoPath});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;
  late String _videoUrl;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoUrl = await OssService.getFileUrl(widget.videoPath);

      _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      await _controller.initialize(); // Wait for initialization
      setState(() {});
    } catch (e) {
      throw Exception('Failed to get video url or initialize video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller only if it was initialized
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoName = widget.videoPath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(videoName),
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Ensure the controller is initialized before using it
          if (_controller.value.isInitialized) {
            return Center(
              child: Chewie(
                controller: ChewieController(
                  videoPlayerController: _controller,
                  autoPlay: true,
                  looping: true,
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
