import 'package:flutter/material.dart';
import 'mood_theme.dart';

class SheButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const SheButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  State<SheButton> createState() => _SheButtonState();
}

class _SheButtonState extends State<SheButton>
    with SingleTickerProviderStateMixin {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(isPressed ? 0.96 : 1.0),

        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(isPressed ? 0.2 : 0.5),
              blurRadius: isPressed ? 8 : 18,
              spreadRadius: isPressed ? 1 : 3,
            )
          ],
        ),

        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}