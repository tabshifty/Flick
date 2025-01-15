import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import './progress_controller.dart';

String formatDuration(Duration? duration, bool? long) {
  if (duration == null) {
    return '';
  }
  int hour = duration.inHours;
  if (hour > 0) {
    return [hour, duration.inMinutes, duration.inSeconds].map((ele) {
      return ele.remainder(60).toString().padLeft(2, '0');
    }).join(':');
  }
  String minuteText = [duration.inMinutes, duration.inSeconds].map((ele) {
    return ele.remainder(60).toString().padLeft(2, '0');
  }).join(':');
  if (long != null && long) {
    return '00:$minuteText';
  } else {
    return minuteText;
  }
}

class FullController extends StatefulWidget {
  final VideoPlayerController controller;
  const FullController({ super.key, required this.controller});

  @override
  State<FullController> createState() => _BaseControllerWidget();
}

class _BaseControllerWidget extends State<FullController> {
  final ValueNotifier<bool> _showProgress = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> _dragDuration = ValueNotifier<Duration>(Duration(seconds: 0));
  bool _showController = false;
  // bool _isTouchDownTriggered = false;
  Timer? timer;


  double touchStart = 0;
  int triggerDistance = 0;
  Duration startDuration = Duration(seconds: 0);
  // Duration dragDuration = Duration(seconds: 0);
  Widget buildState() {
    return (!widget.controller.value.isInitialized || widget.controller.value.isBuffering) ?
      const CircularProgressIndicator(
        value: null,
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation(Color.fromRGBO(255, 255, 255, 0.8)),
      ) : const SizedBox.shrink();
  }

  @override
  void initState() {
    if (widget.controller.value.isInitialized) {
      setState(() {
          _showController = true;
        });
        timer = Timer(Duration(seconds: 5), () {
          setState(() {
            _showController = false;
          });
        });
    } else {
      widget.controller.initialize().then((value) {
        setState(() {
          _showController = true;
        });
        timer = Timer(Duration(seconds: 5), () {
          setState(() {
            _showController = false;
          });
        });
      });

    }
    
    super.initState();
  }

  void hanldeTap () {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }

    _showController = !_showController;
    if (_showController) {
      timer = Timer(Duration(seconds: 5), () {
        setState(() {
          _showController = false;
        });
      });
    }
    setState(() {
    });
  }

  void handleInteractionStartTouch () {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    setState(() {
      _showController = true;
    });
  }

  void handleEndTouch () {
    if (_showController) {
      timer = Timer(Duration(seconds: 5), () {
        setState(() {
          _showController = false;
        });
      });
    }
  }
  


  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap:() {
        hanldeTap();
      },
      onHorizontalDragStart: (details) {
        touchStart = details.globalPosition.dx;
        triggerDistance = 0;
        startDuration = widget.controller.value.position;
        handleInteractionStartTouch();
      },
      onHorizontalDragUpdate: (details) {
        double distance = details.globalPosition.dx - touchStart;
        touchStart = details.globalPosition.dx;

        // dragScale modify here
        triggerDistance += distance > 0 ? 500 : -500;
        if (!_showProgress.value) {
          _showProgress.value = true;
        }
        Duration tmpDuration = startDuration + Duration(milliseconds: triggerDistance);
        if (tmpDuration.isNegative) {
          _dragDuration.value = Duration(minutes: 0);
        } else if (tmpDuration> widget.controller.value.duration) {
          _dragDuration.value = widget.controller.value.duration;
        } else {
          _dragDuration.value = tmpDuration;
        }
      },
      onHorizontalDragEnd: (details) {
        _showProgress.value = false;
        if (triggerDistance != 0) {
          widget.controller.seekTo(_dragDuration.value);
        }
        handleEndTouch();
      },
      child: Stack(
        // fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: buildState(),
          ),
          ValueListenableBuilder(
            valueListenable: _showProgress,
            builder:(context, value, child) {
              return Positioned.fill(
                child: Center(
                  child: !value ? SizedBox.shrink() : Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 120, 120, 0.59),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: _dragDuration,
                        builder:(context, value, child) {
                          return Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white
                              ),
                              children: [
                                TextSpan(
                                  text: formatDuration(value, true),
                                ),
                                const TextSpan(
                                  text: ' / '
                                ),
                                TextSpan(
                                  text: formatDuration(widget.controller.value.duration, true),
                                ),
                              ]
                            )
                          );
                        },
                      ),
                    ),
                  ),
                )
              );
            },
          ),
          Positioned(
            left: 0,
            top: 0,
            child: AbsorbPointer(
              absorbing: !_showController,
              child: Visibility(
                visible: _showController,
                child: Container(
                  // width: MediaQuery.of(context).size.width,
                  height: 44,
                  padding: EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  // color: Colors.brown,
                  child: GestureDetector(
                    onTap: () async {
                      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24,),
                  ),
                )
              ),
            ),
          ),
          widget.controller.value.isInitialized ?
          AbsorbPointer(
            absorbing: !_showController,
            child: Visibility(
              visible: _showController,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // VideoProgressIndicator(
                    //   widget.controller,
                    //   allowScrubbing: true,
                    //   padding: EdgeInsets.symmetric(vertical: 10),
                    //   colors: const VideoProgressColors(
                    //     playedColor: Colors.white
                    //   ),
                    // ),
                    ProgressController(
                      controller: widget.controller,
                      allowTap: true,
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      onTouchStart: handleInteractionStartTouch,
                      onTouchEnd: handleEndTouch,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            handleInteractionStartTouch();
                            handleEndTouch();
                            if (widget.controller.value.isPlaying) {
                              widget.controller.pause();
                            } else {
                              widget.controller.play();
                            }
                          },
                          child: widget.controller.value.isPlaying ?
                          Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 26,
                          ) :
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          )
                        ),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white
                            ),
                            children: [
                              TextSpan(
                                text: formatDuration(widget.controller.value.position, true),
                              ),
                              const TextSpan(
                                text: ' / '
                              ),
                              TextSpan(
                                text: formatDuration(widget.controller.value.duration, true),
                              ),
                            ]
                          )
                        ),
                      ],
                    )
                  ]
                )
              )
            )
          ) : SizedBox.shrink()
        ],
      ),
    );
  }
}
