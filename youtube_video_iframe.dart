import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeIframePlayer extends StatefulWidget {
  final String videoUrl;

  const YouTubeIframePlayer({super.key, required this.videoUrl});

  @override
  State<YouTubeIframePlayer> createState() => _YouTubeIframePlayerState();
}

class _YouTubeIframePlayerState extends State<YouTubeIframePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => player,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
