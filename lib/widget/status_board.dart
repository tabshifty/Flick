class StatusBoard extends StatefulWidget {
  final double value;
  const StatusBoard({ super.key, required this.value });

  @override
  State<StatusBoard> createState() => _BaseControllerWidget();
}

class _BaseControllerWidget extends State<StatusBoard> {}