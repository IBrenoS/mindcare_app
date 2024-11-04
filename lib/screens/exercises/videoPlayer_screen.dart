import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart'; // Para controle de orientação de tela
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    // Extrai o ID do vídeo do URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Detecta mudanças de estado de tela cheia no player
    _controller.addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen && !_isFullScreen) {
      _setOrientationLandscape();
      setState(() {
        _isFullScreen = true;
      });
    } else if (!_controller.value.isFullScreen && _isFullScreen) {
      _setOrientationPortrait();
      setState(() {
        _isFullScreen = false;
      });
    }
  }

  // Altera a orientação para paisagem
  void _setOrientationLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // Altera a orientação para retrato
  void _setOrientationPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controller.dispose();
    _setOrientationPortrait(); // Retorna para a orientação retrato ao sair
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null // Esconde o AppBar no modo fullscreen
          : AppBar(
              title: Text('Assistir Vídeo'),
              backgroundColor: Colors.black,
            ),
      body: InteractiveViewer(
        panEnabled: false, // Desativa o movimento de arrasto
        minScale: 1.0,
        maxScale: 2.0, // Define o nível máximo de zoom
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              print("Player is ready.");
            },
          ),
          builder: (context, player) {
            return Column(
              children: [
                Expanded(child: player),
                if (!_isFullScreen)
                  Padding(
                    padding: EdgeInsets.all(8.0.w), // Responsive padding
                    child: Text(
                      'Descrição do vídeo ou outros detalhes podem ser exibidos aqui.',
                      style: TextStyle(
                        fontSize: 14.sp, // Responsive font size
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
