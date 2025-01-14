import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


import 'package:flick/model/media_resource.dart';
import './base_controller.dart';

const apiPrefix = '192.168.1.8';
class FlickPlayer extends StatefulWidget {
  final MediaResource media;
  final bool shouldPlay;
  const FlickPlayer({ super.key, required this.media, required this.shouldPlay });

  @override
  State<FlickPlayer> createState() =>  _FlickPlayerState();
}

class _FlickPlayerState extends State<FlickPlayer> {
  late VideoPlayerController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('http://$apiPrefix:8096/Videos/${widget.media.id}/stream.mp4?Static=true&mediaSourceId=${widget.media.id}&api_key=10d0514b1f94460b9ebaf1a687d1db48'),
      // Uri.parse(widget.media.url)
    );
    _controller.addListener(() {
      setState(() {
        //
      });
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      _isLoading = false;
      // durationText = formatDuration(_controller.value.duration);
      if (widget.shouldPlay) {
        _controller.play();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlickPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          child: AspectRatio(
            aspectRatio: _isLoading ? widget.media.aspectRatio : _controller.value.aspectRatio,
            // child: _isLoading ? Image.network(widget.media.url) : VideoPlayer(_controller),
            child: _isLoading ? Image.network('http://$apiPrefix:8096/Items/${widget.media.id}/Images/Primary') : VideoPlayer(_controller),
          ),
        ),
        BaseController(controller: _controller, mediaResource: widget.media,),
      ],
    );
  }
}