// lib/src/rendering/flag_renderer.dart

import 'package:flutter/material.dart';
import '../models/duration.dart';
import 'stem_renderer.dart';
import 'glyph_provider.dart';

/// Renders flags for eighth notes and shorter durations
class FlagRenderer {
  final double staffSpaceSize;
  final Color color;

  const FlagRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint flag(s) on a note stem
  void paint(
      Canvas canvas,
      Offset stemEnd, {
        required StemDirection direction,
        required DurationType durationType,
      }) {

    if (!_needsFlag(durationType)) return;

    final flagCount = _getFlagCount(durationType);

    // Use SMuFL glyphs for flags
    _paintFlagsWithGlyphs(canvas, stemEnd, direction, flagCount);
  }

  /// Paint flags using Bravura font glyphs
  void _paintFlagsWithGlyphs(
      Canvas canvas,
      Offset stemEnd,
      StemDirection direction,
      int flagCount,
      ) {
    final size = staffSpaceSize * 3.0;

    // SMuFL codes for flags
    final upFlagGlyphs = [
      '\uE240', // Eighth flag up
      '\uE242', // Sixteenth flag up (or use compound)
      '\uE244', // Thirty-second flag up
      '\uE246', // Sixty-fourth flag up
    ];

    final downFlagGlyphs = [
      '\uE241', // Eighth flag down
      '\uE243', // Sixteenth flag down
      '\uE245', // Thirty-second flag down
      '\uE247', // Sixty-fourth flag down
    ];

    // Choose appropriate glyph based on direction and count
    final glyphList = direction == StemDirection.up ? upFlagGlyphs : downFlagGlyphs;
    final glyphIndex = (flagCount - 1).clamp(0, glyphList.length - 1);
    final glyph = glyphList[glyphIndex];

    final textPainter = GlyphProvider.getGlyph(glyph, size, color: color);

    // Position the flag at the end of the stem
    double x, y;
    if (direction == StemDirection.up) {
      // Flag goes to the right of stem end
      x = stemEnd.dx - textPainter.width * 0.1;
      y = stemEnd.dy - textPainter.height * 0.5;
    } else {
      // Flag goes to the left of stem end, flipped
      x = stemEnd.dx - textPainter.width * 0.1;
      y = stemEnd.dy - textPainter.height * 0.5;
    }

    textPainter.paint(canvas, Offset(x, y));
  }

  /// Paint flags using custom paths (fallback if glyphs don't work well)
  // void _paintFlagsWithPaths(
  //     Canvas canvas,
  //     Offset stemEnd,
  //     StemDirection direction,
  //     int flagCount,
  //     ) {
  //   final paint = Paint()
  //     ..color = color
  //     ..style = PaintingStyle.fill;
  //
  //   final flagWidth = StaffUnits.flagWidth.toPixels(staffSpaceSize);
  //   final flagSpacing = staffSpaceSize * 0.7;
  //
  //   for (int i = 0; i < flagCount; i++) {
  //     final yOffset = i * flagSpacing;
  //
  //     final path = Path();
  //
  //     if (direction == StemDirection.up) {
  //       // Flag curves to the right from stem end
  //       final start = Offset(stemEnd.dx, stemEnd.dy + yOffset);
  //       path.moveTo(start.dx, start.dy);
  //
  //       // Bezier curve for smooth flag shape
  //       path.quadraticBezierTo(
  //         start.dx + flagWidth * 0.6,
  //         start.dy + staffSpaceSize * 0.3,
  //         start.dx + flagWidth * 0.8,
  //         start.dy + staffSpaceSize * 0.8,
  //       );
  //
  //       // Return stroke
  //       path.quadraticBezierTo(
  //         start.dx + flagWidth * 0.4,
  //         start.dy + staffSpaceSize * 0.6,
  //         start.dx,
  //         start.dy + staffSpaceSize * 0.4,
  //       );
  //
  //       path.close();
  //     } else {
  //       // Flag curves to the left from stem end
  //       final start = Offset(stemEnd.dx, stemEnd.dy - yOffset);
  //       path.moveTo(start.dx, start.dy);
  //
  //       // Bezier curve for smooth flag shape
  //       path.quadraticBezierTo(
  //         start.dx - flagWidth * 0.6,
  //         start.dy - staffSpaceSize * 0.3,
  //         start.dx - flagWidth * 0.8,
  //         start.dy - staffSpaceSize * 0.8,
  //       );
  //
  //       // Return stroke
  //       path.quadraticBezierTo(
  //         start.dx - flagWidth * 0.4,
  //         start.dy - staffSpaceSize * 0.6,
  //         start.dx,
  //         start.dy - staffSpaceSize * 0.4,
  //       );
  //
  //       path.close();
  //     }
  //
  //     canvas.drawPath(path, paint);
  //   }
  // }

  /// Check if a duration needs flags
  bool _needsFlag(DurationType type) {
    return type.flagCount > 0;
  }

  /// Get number of flags needed
  int _getFlagCount(DurationType type) {
    return type.flagCount;
  }
}