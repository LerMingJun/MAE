import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Recording extends StatefulWidget {
  const Recording({super.key});

  @override
  State<Recording> createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String recordingURL = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(recordingURL)),
        );
      });
    });
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recording For Speech'),
      ),
      body: flickManager == null
          ? Center(child: CircularProgressIndicator())
          : OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  flickManager!.flickControlManager!.enterFullscreen();
                } else {
                  flickManager!.flickControlManager!.exitFullscreen();
                }
                return Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FlickVideoPlayer(
                      flickManager: flickManager!,
                      flickVideoWithControls: FlickVideoWithControls(
                        controls: FlickPortraitControls(),
                      ),
                      flickVideoWithControlsFullscreen: FlickVideoWithControls(
                        controls: FlickLandscapeControls(),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
