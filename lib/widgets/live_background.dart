import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A subtle animated background with health-themed colors.
class LiveBackground extends StatelessWidget {
  const LiveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final baseGradient = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3366FF),
            Color(0xFF5B8DEF),
            Color(0xFF00BCD4),
          ],
        ),
      ),
    );

    final bubbles = Stack(
      children: [
        _bubble(const Offset(-40, 60), 140, const Color(0xFF90CAF9).withOpacity(0.25), 0),
        _bubble(const Offset(220, -20), 160, const Color(0xFF80DEEA).withOpacity(0.25), 400),
        _bubble(const Offset(-80, 380), 200, const Color(0xFFB39DDB).withOpacity(0.22), 800),
      ],
    );

    return SizedBox.expand(
      child: Stack(
        children: [
          baseGradient,
          bubbles,
        ],
      ),
    );
  }

  Widget _bubble(Offset offset, double size, Color color, int delayMs) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 1200.ms, delay: delayMs.ms)
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: 6000.ms,
            curve: Curves.easeInOut,
          )
          .moveY(
            begin: -8,
            end: 8,
            duration: 7000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
