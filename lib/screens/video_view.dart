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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(''))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoUrl = await OssService.getFileUrl(widget.videoPath);
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoName = widget.videoPath.split('/').last;
    return Scaffold(
      appBar: AppBar(
        title: Text(videoName),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Chewie(
                controller: ChewieController(
                  videoPlayerController: _controller,
                  autoPlay: true,
                  looping: true,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
