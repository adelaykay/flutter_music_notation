// lib/src/rendering/accidental_renderer.dart

import 'package:flutter/material.dart';
import '../models/pitch.dart';
import '../geometry/staff_units.dart';
import 'glyph_provider.dart';

/// Renders accidental symbols (sharp, flat, natural, etc.)
class AccidentalRenderer {
  final double staffSpaceSize;
  final Color color;

  const AccidentalRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint an accidental to the left of a note
  void paint(
      Canvas canvas,
      Offset noteheadCenter,
      Accidental accidental,
      ) {
    final size = StaffUnits.accidentalHeight.toPixels(staffSpaceSize);
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.getAccidentalGlyph(accidental),
      size,
      color: color,
    );

    // Position accidental to the left of notehead
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final padding = StaffUnits.accidentalPadding.toPixels(staffSpaceSize);

    final x = noteheadCenter.dx - noteheadWidth / 2 - padding - glyph.width;
    final y = noteheadCenter.dy - glyph.height / 2;

    glyph.paint(canvas, Offset(x, y));
  }

  /// Calculate the width an accidental will occupy
  /// (useful for spacing calculations)
  double getWidth(Accidental accidental) {
    final size = StaffUnits.accidentalHeight.toPixels(staffSpaceSize);
    final glyph = GlyphProvider.getGlyph(
      GlyphProvider.getAccidentalGlyph(accidental),
      size,
      color: color,
    );

    final padding = StaffUnits.accidentalPadding.toPixels(staffSpaceSize);
    return glyph.width + padding;
  }
}