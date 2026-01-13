import 'package:flutter/material.dart';

/// Draws diagonal or horizontal stripes for retro backgrounds.
/// Used in: BadgePopup, PokemonDetail, TrainerCard, etc.
class StripePainter extends CustomPainter {
  final Color stripeColor;
  final double stripeHeight;
  final double gap;

  const StripePainter({
    required this.stripeColor,
    this.stripeHeight = 4.0,
    this.gap = 4.0, // Default gap equal to height for even stripes
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;
    // We draw a rectangle every (height + gap) pixels
    for (double i = 0; i < size.height; i += (stripeHeight + gap)) {
      canvas.drawRect(Rect.fromLTWH(0, i, size.width, stripeHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StripePainter oldDelegate) {
    return oldDelegate.stripeColor != stripeColor ||
           oldDelegate.stripeHeight != stripeHeight ||
           oldDelegate.gap != gap;
  }
}

/// Draws horizontal lines to look like notebook paper.
/// Used in: Diary Detail screens.
class LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineGap;
  final double strokeWidth;

  const LinedPaperPainter({
    this.lineColor = const Color(0xFFCCE0EA), // Default light blue
    this.lineGap = 24.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    for (double y = 0; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
           oldDelegate.lineGap != lineGap;
  }
}