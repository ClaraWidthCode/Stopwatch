import 'package:flutter/material.dart';

class TimeDisplayWidget extends StatelessWidget {
  final Duration duration;
  final TextStyle? style;
  final bool showMilliseconds;
  final String separator;

  const TimeDisplayWidget({
    super.key,
    required this.duration,
    this.style,
    this.showMilliseconds = false,
    this.separator = ':',
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? Theme.of(context).textTheme.displayLarge;
    
    return Text(
      _formatDuration(duration),
      style: defaultStyle,
      textAlign: TextAlign.center,
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (showMilliseconds) {
      return '${hours.toString().padLeft(2, '0')}$separator'
             '${minutes.toString().padLeft(2, '0')}$separator'
             '${seconds.toString().padLeft(2, '0')}.'
             '${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '${hours.toString().padLeft(2, '0')}$separator'
             '${minutes.toString().padLeft(2, '0')}$separator'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
