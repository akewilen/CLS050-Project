import 'package:flutter/material.dart';
import 'dart:async';

class TimerIndicator extends StatefulWidget {
  final bool isActive;
  final Function(int) onScore;
  final VoidCallback onTimeUp;

  const TimerIndicator({
    super.key,
    required this.isActive,
    required this.onScore,
    required this.onTimeUp,
  });

  @override
  State<TimerIndicator> createState() => _TimerIndicatorState();
}

class _TimerIndicatorState extends State<TimerIndicator> {
  Timer? _timer;
  int _timeLeft = 10;
  static const int maxScore = 50;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(TimerIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _timeLeft = 10;
        _startTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  void reset() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _timeLeft = 10;
      });
      if (widget.isActive) {
        _startTimer();
      }
    }
  }

  void stop() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _timeLeft = 0;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();  // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          // Calculate current score (50 to 0 linearly)
          final currentScore = (maxScore * _timeLeft / 10).round();
          widget.onScore(currentScore);
        } else {
          timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer),
          const SizedBox(width: 8),
          Text(
            '$_timeLeft',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}