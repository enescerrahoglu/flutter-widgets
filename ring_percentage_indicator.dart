import 'package:flutter/material.dart';
import 'dart:math' as math;

class RingPercentageIndicator extends StatefulWidget {
  final double strokeWidth; // Width of the stroke (circle outline)
  final double progress; // Progress value (0.0 to 1.0)
  final double gapSize; // Gap size in radians
  final Widget? child; // Child widget to be centered

  const RingPercentageIndicator({
    super.key,
    required this.strokeWidth,
    required this.progress,
    required this.gapSize,
    this.child,
    this.height = 48,
    this.width = 48,
  });
  final double height;
  final double width;
  @override
  State<RingPercentageIndicator> createState() => _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState extends State<RingPercentageIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _progressTween;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration
    );

    // Initialize the Tween with the initial progress value
    _progressTween = Tween<double>(begin: 0.0, end: widget.progress);

    // Create the animation
    _progressAnimation = _progressTween.animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Start the animation
    _controller.forward();
  }

  @override
  void didUpdateWidget(RingPercentageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      // Update the Tween with the new progress value
      _progressTween = Tween<double>(begin: _progressAnimation.value, end: widget.progress);

      // Update the animation with the new Tween
      _progressAnimation = _progressTween.animate(_controller)
        ..addListener(() {
          setState(() {});
        });

      // Restart the animation
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _CircularProgressPainter(
              strokeWidth: widget.strokeWidth,
              progress: _progressAnimation.value,
              gapSize: widget.gapSize,
            ),
            child: Container(),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

// CustomPainter class to handle the drawing of the custom progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double strokeWidth; // Width of the stroke
  final double progress; // Progress value (0.0 to 1.0)
  final double gapSize; // Gap size in radians

  _CircularProgressPainter({
    required this.strokeWidth,
    required this.progress,
    required this.gapSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint for the progress arc
    final Paint progressPaint = Paint()
      ..color = Colors.blue // Green color
      ..strokeWidth = strokeWidth // Set stroke width
      ..style = PaintingStyle.stroke // Stroke style (no fill)
      ..strokeCap = StrokeCap.round; // Rounded ends of the stroke

    // Define the paint for the remaining progress arc
    final Paint remainingProgressPaint = Paint()
      ..color = Colors.grey.shade300 // Grey color for the remaining progress
      ..strokeWidth = strokeWidth // Set stroke width
      ..style = PaintingStyle.stroke // Stroke style (no fill)
      ..strokeCap = StrokeCap.round; // Rounded ends of the stroke

    // Calculate the radius of the circle
    final double radius = (size.width / 2) - (strokeWidth / 2);
    // Define the center of the circle
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate the angle for the progress arc
    final double progressAngle = 2 * math.pi * progress;
    // Calculate the actual gap size based on progress
    final double actualGapSize = math.min(gapSize, 2 * math.pi * (1 - progress));

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), // Define the bounding rectangle
      -math.pi / 2 + actualGapSize / 2, // Starting angle (top of the circle with gap)
      progressAngle - actualGapSize, // Sweep angle (based on progress minus the gap)
      false, // Do not use center (not a pie chart)
      progressPaint, // Use the progress paint
    );

    // Calculate the angle for the remaining progress arc
    final double remainingProgressAngle = 2 * math.pi * (1.0 - progress) - actualGapSize;
    // Draw the remaining progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), // Define the bounding rectangle
      -math.pi / 2 + progressAngle + actualGapSize / 2, // Starting angle after the progress arc with gap
      remainingProgressAngle, // Sweep angle (remaining progress minus the gap)
      false, // Do not use center (not a pie chart)
      remainingProgressPaint, // Use the remaining progress paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true to repaint whenever the progress changes
    return true;
  }
}
