import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  static String youtubeId = '6VEnTQ2rx_4';

  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: youtubeId,
    flags: const YoutubePlayerFlags(autoPlay: false),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          progressColors: ProgressBarColors(
            playedColor: Colors.blue,
            handleColor: Colors.blueAccent,
          ),
          onReady: () {
            _controller.play();
          },
        ),
      ),
    );
  }
}
