import 'package:flick/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProgressController extends StatefulWidget {
  final VideoPlayerController controller;
  final void Function()? onTouchStart;
  final void Function()? onTouchEnd;
  final bool? allowTap;
  final EdgeInsetsGeometry padding;
  const ProgressController({
    super.key,
    required this.controller,
    this.onTouchStart, this.onTouchEnd,
    this.allowTap,
    this.padding = const EdgeInsets.only(top: 20, bottom: 20)
  });

  @override
  State<ProgressController> createState() {
    return _ProgressControllerState();
  }
}

class _ProgressControllerState extends State<ProgressController> {
  final GlobalKey _uKey = GlobalKey();
  double _start = 0;
  final ValueNotifier<double> _pesudoStart = ValueNotifier(0);
  final ValueNotifier<bool> _showFake = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _uKey,
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.onTouchStart != null) {
          widget.onTouchStart!();
        }
        if (widget.onTouchEnd != null) {
          widget.onTouchEnd!();
        }
      },
      onTapDown: (details) {
        Helper.logger.d('TapDown');
        _start = details.localPosition.dx;
      },
      onTapUp: (details) {
        Helper.logger.d('TapUp');
        if (widget.allowTap !=null && widget.allowTap!) {
          double changed = details.localPosition.dx / _uKey.currentContext!.size!.width;
          _pesudoStart.value = changed > 1 ? 1 : changed < 0 ? 0 : changed;
          widget.controller.seekTo(
            Duration(milliseconds: (widget.controller.value.duration.inMilliseconds * _pesudoStart.value).toInt())
          );
        }
      },
      onHorizontalDragStart: (details) {
        _pesudoStart.value = widget.controller.value.position.inMilliseconds / widget.controller.value.duration.inMilliseconds;
        double changed = _pesudoStart.value + (_start === ? 0 : details.localPosition.dx - _start) / _uKey.currentContext!.size!.width;
        _pesudoStart.value = changed > 1 ? 1 : changed < 0 ? 0 : changed;
        _start = details.localPosition.dx;
        _showFake.value = true;
        if (widget.onTouchStart != null) {
          widget.onTouchStart!();
        }
        // Helper.logger.d(_uKey.currentContext?.size?.width);
        // Helper.logger.d(details.localPosition);
      },
      onHorizontalDragUpdate: (details) {
        double changed = _pesudoStart.value + (details.localPosition.dx - _start) / _uKey.currentContext!.size!.width;
        _pesudoStart.value = changed > 1 ? 1 : changed < 0 ? 0 : changed;
        _start = details.localPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        _showFake.value = false;
        if (widget.onTouchEnd != null) {
          widget.onTouchEnd!();
        }
        widget.controller.seekTo(
          Duration(milliseconds: (widget.controller.value.duration.inMilliseconds * _pesudoStart.value).toInt())
        );
      },
      child: Padding(
        padding: widget.padding,
        child: Stack(
          children: [
            LinearProgressIndicator(
              color: const Color.fromARGB(125, 83, 80, 80),
              backgroundColor: const Color.fromARGB(45, 255, 255, 255),
              value: widget.controller.value.buffered.isEmpty ? 0 : widget.controller.value.buffered[0].end.inMilliseconds / widget.controller.value.duration.inMilliseconds,
            ),
            ValueListenableBuilder(
              valueListenable: _showFake,
              builder:(context, value, child) {
                return value || widget.controller.value.isBuffering ? 
                  ValueListenableBuilder(
                    valueListenable: _pesudoStart,
                    builder:(context, value, child) {
                      return LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Colors.white,
                        value: value,
                      );
                    },
                  ) : 
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    value: widget.controller.value.position.inMilliseconds / widget.controller.value.duration.inMilliseconds,
                  );
              },
            )
          ],
        )
      ),
    );
  }
}