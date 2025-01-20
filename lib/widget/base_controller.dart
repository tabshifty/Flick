import 'package:Flick/model/media_resource.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:Flick/helper/helper.dart';

import 'package:Flick/widget/full_flickplayer.dart';
import './progress_controller.dart';

String formatDuration(Duration? duration) {
  if (duration == null) {
    return '';
  }
  int hour = duration.inHours;
  if (hour > 0) {
    return [hour, duration.inMinutes, duration.inSeconds].map((ele) {
      return ele.remainder(60).toString().padLeft(2, '0');
    }).join(':');
  }
  return [duration.inMinutes, duration.inSeconds].map((ele) {
    return ele.remainder(60).toString().padLeft(2, '0');
  }).join(':');
}

class BaseController extends StatefulWidget {
  final VideoPlayerController controller;
  final MediaResource mediaResource;
  const BaseController({ super.key, required this.controller, required this.mediaResource});

  @override
  State<BaseController> createState() => _BaseControllerWidget();
}

class _BaseControllerWidget extends State<BaseController> {


  // bool _isMarked = false;
  final ValueNotifier<bool> _isMarked =  ValueNotifier(false);

  Future<void> isMediaMarked () async {
    Database db = await Helper.db;
    final queryResult = await db.query(
      'Media_Table',
      where: 'id = ?',
      whereArgs: [widget.mediaResource.id],
    );
    _isMarked.value = queryResult.isNotEmpty;
    // _isMarked = queryResult.isNotEmpty;
  }

  @override
  void initState() {
    isMediaMarked();
    super.initState();
  }

  Widget buildState() {
    return (!widget.controller.value.isInitialized || widget.controller.value.isBuffering) ?
      const CircularProgressIndicator(
        value: null,
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation(Color.fromRGBO(255, 255, 255, 0.8)),
      ) : widget.controller.value.isPlaying ? const SizedBox.shrink() : const Icon(
        CupertinoIcons.arrowtriangle_right_square_fill,
        color: Color.fromRGBO(255, 255, 255, 0.8),
        size: 100,
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.controller.value.isBuffering || !widget.controller.value.isInitialized) {
          return;
        }
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: Stack(
        // fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: buildState(),
          ),
          Positioned(
            // top: 0,
            right: 0,
            bottom: 200,
            // height: 700,//MediaQuery.of(context).size.height,
            child: Container(
              // color: Colors.deepPurple,
              width: 50,
              padding: EdgeInsets.only(right: 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  GestureDetector(
                    child: const Icon(
                      Icons.favorite_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Database datebase = await Helper.db;
                      if (_isMarked.value) {
                        datebase.delete(
                          'Media_Table',
                          where: 'id = ?',
                          whereArgs: [widget.mediaResource.id],
                        );
                      } else {
                        datebase.insert('Media_Table', widget.mediaResource.toMap());
                      }
                      _isMarked.value = !_isMarked.value;
                    },
                    child: ValueListenableBuilder(
                      valueListenable: _isMarked,
                      builder:(context, value, child) {
                        return Icon(
                          Icons.bookmark_remove_outlined,
                          size: 32,
                          color: value ? Colors.redAccent : Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FullFlickPlayer(controller: widget.controller,);
                          }
                        )
                      );
                    },
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          widget.controller.value.isInitialized ?
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ProgressController(
                    controller: widget.controller
                  )
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 20,
                  alignment: Alignment.centerRight,
                  // height: 2,
                  child: Text(
                    formatDuration(widget.controller.value.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          ) : SizedBox.shrink()
        ],
      ),
    );
  }
}

/*
VideoProgressIndicator(
  widget.controller,
  allowScrubbing: true,
  padding: EdgeInsets.symmetric(vertical: 10),
  colors: const VideoProgressColors(
    playedColor: Colors.white
  ),
)
*/ 