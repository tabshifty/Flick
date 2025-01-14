
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// import 'package:flick/helper/helper.dart';
import './full_controller.dart';
import 'package:flutter/services.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

class FullFlickPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const FullFlickPlayer({ super.key, required this.controller });

  @override
  State<FullFlickPlayer> createState() =>  _FullPlayerState();
}

class _FullPlayerState extends State<FullFlickPlayer> {

  // bool _isLoading = true;
  void videoListener () {
    setState(() {
      
    });
  }

  Future<void> setOrientation () async {
    final size = widget.controller.value.size;
    final width = size.width;
    final height = size.height;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (width < height) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> resetOrientation () async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }


  @override
  void initState() {
    super.initState();
    // WakelockPlus.enable();
    setOrientation();
    widget.controller.addListener(videoListener);
    // _controller = VideoPlayerController.networkUrl(
    //   Uri.parse('http://${Helper.apiPrefix}:8096/Videos/${widget.media.id}/stream.mp4?Static=true&mediaSourceId=${widget.media.id}&api_key=10d0514b1f94460b9ebaf1a687d1db48'),
    // );
    // _controller.addListener(() {
    //   setState(() {
    //     //
    //   });
    // });
    // _controller.setLooping(true);
    // _controller.initialize().then((_) {
    //   _isLoading = false;
    //   _controller.play();
    // });
  }

  @override
  void dispose() {
    widget.controller.removeListener(videoListener);
    resetOrientation();
    // WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          FullController(controller: widget.controller)
        ],
      ),
    );
  }
}