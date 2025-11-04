// lib/src/rendering/clef_renderer.dart

import 'package:flutter/material.dart';
import '../geometry/staff_position.dart';
import 'glyph_provider.dart';

/// Renders clef symbols at the beginning of a staff
class ClefRenderer {
  final double staffSpaceSize;
  final Color color;

  const ClefRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a clef symbol
  void paint(
      Canvas canvas,
      double x,
      double staffTopY,
      ClefType clefType,
      ) {
    switch (clefType) {
      case ClefType.treble:
        _drawTrebleClef(canvas, x, staffTopY);
        break;
      case ClefType.bass:
        _drawBassClef(canvas, x, staffTopY);
        break;
      case ClefType.alto:
        _drawAltoClef(canvas, x, staffTopY);
        break;
      case ClefType.tenor:
        _drawTenorClef(canvas, x, staffTopY);
        break;
    }
  }

  /// Draw treble (G) clef
  void _drawTrebleClef(Canvas canvas, double x, double staffTopY) {
    final size = staffSpaceSize * 5.0;
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.trebleClef,
      size,
      color: color,
    );

    // Position: curls around second line from bottom (G4)
    // The G clef wraps around the line where G4 sits
    final y = staffTopY - staffSpaceSize * 7.25;

    glyph.paint(canvas, Offset(x, y));
  }

  /// Draw bass (F) clef
  void _drawBassClef(Canvas canvas, double x, double staffTopY) {
    final size = staffSpaceSize * 4.0;
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.bassClef,
      size,
      color: color,
    );

    // Position: sits on second line from top (F3)
    final y = staffTopY - staffSpaceSize * 7;

    glyph.paint(canvas, Offset(x, y));
  }

  /// Draw alto (C) clef
  void _drawAltoClef(Canvas canvas, double x, double staffTopY) {
    final size = staffSpaceSize * 4.0;
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.altoClef,
      size,
      color: color,
    );

    // Position: centered on middle line (C4)
    final y = staffTopY - staffSpaceSize * 6.1;

    glyph.paint(canvas, Offset(x, y));
  }

  /// Draw tenor (C) clef
  void _drawTenorClef(Canvas canvas, double x, double staffTopY) {
    final size = staffSpaceSize * 4.0;
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.tenorClef,
      size,
      color: color,
    );

    // Position: centered on second line from top
    final y = staffTopY - staffSpaceSize * 7.1;

    glyph.paint(canvas, Offset(x, y));
  }

  /// Get the width occupied by a clef (for spacing)
  double getWidth(ClefType clefType) {
    final size = clefType == ClefType.treble
        ? staffSpaceSize * 7.0
        : staffSpaceSize * 4.0;

    final glyphCode = clefType == ClefType.treble
        ? GlyphProvider.trebleClef
        : (clefType == ClefType.bass ? GlyphProvider.bassClef : GlyphProvider.altoClef);

    final glyph = GlyphProvider.getGlyph(glyphCode, size, color: color);
    return glyph.width;
  }
}