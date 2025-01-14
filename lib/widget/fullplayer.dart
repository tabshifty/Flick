import 'package:flick/model/media_resource.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flick/helper/helper.dart';
// import 'package:flick/model/video_resource.dart';
import './full_controller.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullPlayer extends StatefulWidget {
  final MediaResource media;
  final bool? vertical;
  const FullPlayer({ super.key, required this.media, this.vertical });

  @override
  State<FullPlayer> createState() =>  _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  late VideoPlayerController _controller;

  bool _isLoading = true;

  Future<void> setOrientation () async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (widget.vertical != null && widget.vertical!) {
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
    WakelockPlus.enable();
    setOrientation();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('http://${Helper.apiPrefix}:8096/Videos/${widget.media.id}/stream.mp4?Static=true&mediaSourceId=${widget.media.id}&api_key=10d0514b1f94460b9ebaf1a687d1db48'),
    );
    _controller.addListener(() {
      setState(() {
        //
      });
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      _isLoading = false;
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    resetOrientation();
    WakelockPlus.disable();
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
            child: _isLoading ? Image.network(
              'http://${Helper.apiPrefix}:8096/Items/${widget.media.id}/Images/Backdrop?quality=90',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ) : AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          FullController(controller: _controller)
        ],
      ),
    );
  }
}