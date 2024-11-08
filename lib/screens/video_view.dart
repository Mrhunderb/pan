import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'http://10.111.23.47:9000/pan/%5BNekomoe%20kissaten&LoliHouse%5D%20Gimai%20Seikatsu%20-%2002%20%5BWebRip%201080p%20HEVC-10bit%20AAC%20ASSx2%5D.mkv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=6UQmclxevHd1Mbu8m4xD%2F20241107%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20241107T151735Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=68a460dc9487a2e0366cf28232cec60f651e5849f8e0e3465589b4083727f3ac'),
    )..initialize().then((_) {
        setState(
            () {}); // Ensure the first frame is shown after the video is initialized
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
