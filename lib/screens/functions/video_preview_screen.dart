import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final title = widget.video['title'] ?? 'Vídeo';
    final description = widget.video['description'] ?? 'Sem descrição.';
    final channelName = widget.video['channelName'] ?? 'Autor desconhecido';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
      body: isVideoValid
          ? Column(
              children: [
                YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Theme.of(context).colorScheme.primary,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16.sp,
                            ),
                      ),
                      SizedBox(height: 8.0.h),
                      Text(
                        "Canal: $channelName",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'URL do vídeo inválida.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
    );
  }
}
