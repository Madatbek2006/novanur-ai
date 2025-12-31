import 'package:flutter/material.dart';
import 'dart:async';

class MyTypingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const MyTypingIndicator({Key? key, this.color = Colors.grey, this.size = 8}) : super(key: key);

  @override
  _MyTypingIndicatorState createState() => _MyTypingIndicatorState();
}

class _MyTypingIndicatorState extends State<MyTypingIndicator> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4; // 0,1,2,3
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: index < _dotCount ? widget.color : widget.color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
