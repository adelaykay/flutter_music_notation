// lib/src/rendering/rest_renderer.dart

import 'package:flutter/material.dart';
import '../models/duration.dart';
import 'glyph_provider.dart';

/// Renders rest symbols at appropriate positions on staff
class RestRenderer {
  final double staffSpaceSize;
  final Color color;

  const RestRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a rest symbol
  /// Rests are positioned relative to the staff middle
  void paint(
      Canvas canvas,
      Offset staffTopLeft,
      double xPosition,
      DurationType durationType,
      ) {
    final glyph = GlyphProvider.getRestGlyph(durationType);
    final size = _getRestSize(durationType);

    final textPainter = GlyphProvider.getGlyph(glyph, size, color: color);

    // Calculate Y position based on rest type
    final yOffset = _getRestYOffset(durationType);
    final restY = staffTopLeft.dy + (staffSpaceSize * 2) + yOffset; // Middle line + offset

    final x = xPosition - textPainter.width / 2;
    final y = restY - textPainter.height / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  /// Get size for rest glyph based on duration
  double _getRestSize(DurationType type) {
    switch (type) {
      case DurationType.whole:
      case DurationType.breve:
      case DurationType.long:
      case DurationType.maxima:
        return staffSpaceSize * 2.0;
      case DurationType.half:
        return staffSpaceSize * 2.0;
      case DurationType.quarter:
        return staffSpaceSize * 3.5;
      case DurationType.eighth:
        return staffSpaceSize * 2.5;
      case DurationType.sixteenth:
        return staffSpaceSize * 3.0;
      case DurationType.thirtySecond:
      case DurationType.sixtyFourth:
        return staffSpaceSize * 3.5;
    }
  }

  /// Get vertical offset from staff middle for different rest types
  double _getRestYOffset(DurationType type) {
    switch (type) {
      case DurationType.whole:
      // Whole rest hangs from 4th line (below middle)
        return -staffSpaceSize * 0.5;
      case DurationType.half:
      // Half rest sits on middle line
        return staffSpaceSize * 0.5;
      case DurationType.quarter:
      case DurationType.eighth:
      case DurationType.sixteenth:
      case DurationType.thirtySecond:
      case DurationType.sixtyFourth:
      // These rests are centered on staff
        return 0;
      case DurationType.breve:
      case DurationType.long:
      case DurationType.maxima:
        return 0;
    }
  }

  /// Get the width a rest will occupy (for spacing calculations)
  double getWidth(DurationType type) {
    final glyph = GlyphProvider.getRestGlyph(type);
    final size = _getRestSize(type);
    final textPainter = GlyphProvider.getGlyph(glyph, size, color: color);
    return textPainter.width;
  }
}