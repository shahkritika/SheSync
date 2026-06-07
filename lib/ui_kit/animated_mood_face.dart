import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedMoodFace extends StatefulWidget {
  final int moodIndex;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedMoodFace({
    super.key,
    required this.moodIndex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedMoodFace> createState() => _AnimatedMoodFaceState();
}

class _AnimatedMoodFaceState extends State<AnimatedMoodFace>
    with TickerProviderStateMixin {

  late AnimationController _bounceController;
  late AnimationController _idleController;

  late Animation<double> _scale;
  late Animation<double> _idle;

  @override
  void initState() {
    super.initState();

    // 🎯 Tap bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );

    // 🌿 Idle breathing animation
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _idle = Tween(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(widget.moodIndex);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _idleController]),
        builder: (_, child) {
          double scale = _scale.value * _idle.value;

          return Transform.scale(
            scale: widget.isSelected ? scale : 1.0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? color.withOpacity(0.25)
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                        )
                      ]
                    : [],
              ),
              child: CustomPaint(
                size: const Size(40, 40),
                painter: AnimatedFacePainter(
                  widget.moodIndex,
                  color,
                  _idle.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColor(int mood) {
    return [
      Colors.pink.shade200,
      Colors.pink.shade300,
      Colors.pink.shade400,
      Colors.pink.shade500,
      Colors.pink.shade600,
    ][mood];
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _idleController.dispose();
    super.dispose();
  }
}

class AnimatedFacePainter extends CustomPainter {
  final int mood;
  final Color color;
  final double animationValue;

  AnimatedFacePainter(this.mood, this.color, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // 👀 Eyes (slight bounce)
    double eyeOffset = sin(animationValue * pi) * 1.5;

    canvas.drawCircle(
        Offset(center.dx - 8, center.dy - 5 + eyeOffset), 2, paint);
    canvas.drawCircle(
        Offset(center.dx + 8, center.dy - 5 + eyeOffset), 2, paint);

    // 😊 Animated mouth
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 6),
      width: 20,
      height: 10,
    );

    double curveAdjust = sin(animationValue * pi) * 0.3;

    switch (mood) {
      case 0:
        canvas.drawArc(rect, pi, pi + curveAdjust, false, paint);
        break;
      case 1:
        canvas.drawArc(rect, pi, 2.5 + curveAdjust, false, paint);
        break;
      case 2:
        canvas.drawLine(
          Offset(center.dx - 8, center.dy + 8),
          Offset(center.dx + 8, center.dy + 8),
          paint,
        );
        break;
      case 3:
        canvas.drawArc(rect, 0, 2.5 + curveAdjust, false, paint);
        break;
      case 4:
        canvas.drawArc(rect, 0, pi + curveAdjust, false, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}