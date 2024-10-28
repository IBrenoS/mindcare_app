import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPreviewScreen extends StatefulWidget {
  final dynamic video;

  VideoPreviewScreen({required this.video});

  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late YoutubePlayerController _controller;
  bool isVideoValid = true;

  @override
  void initState() {
    super.initState();
    String videoUrl = widget.video['url'] ?? '';
    String? videoId = YoutubePlayer.convertUrlToId(videoUrl);

    if (videoId != null && videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          controlsVisibleAtStart: true,
        ),
      );
    } else {
      isVideoValid = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['title'] ?? 'Vídeo'),
      ),
      body: isVideoValid
          ? Column(
              children: [
                YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video['description'] ?? 'Sem descrição.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Canal: ${widget.video['channelName'] ?? 'Autor desconhecido'}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'URL do vídeo inválida.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
    );
  }
}
