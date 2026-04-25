import 'package:flutter/material.dart';
import 'dart:math';

class FloralBackground extends StatefulWidget {
  const FloralBackground({super.key});

  @override
  State<FloralBackground> createState() => _FloralBackgroundState();
}

class _FloralBackgroundState extends State<FloralBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final flowers = List.generate(12, (index) {
    return {
      "x": Random().nextDouble(),
      "y": Random().nextDouble(),
      "size": Random().nextDouble() * 20 + 10,
    };
  });

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: flowers.map((f) {
            return Positioned(
              left: (f["x"] as double) * MediaQuery.of(context).size.width,
              top: ((f["y"] as double) * MediaQuery.of(context).size.height +
                      (_controller.value * 40)) %
                  MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.local_florist,
                  size: f["size"] as double,
                  color: Colors.pink,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }