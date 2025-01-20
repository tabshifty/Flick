import 'package:flutter/material.dart';

class StatusBoard extends StatefulWidget {
  final double value;
  final Icon? icon;
  const StatusBoard({ super.key, required this.value, this.icon });

  @override
  State<StatusBoard> createState() => _BaseControllerWidget();
}

class _BaseControllerWidget extends State<StatusBoard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.fromRGBO(126, 120, 120, 0.59),
        borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        children: [
          widget.icon ?? SizedBox.shrink(),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: widget.value,
              minHeight: 20,
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
    );
  }
}