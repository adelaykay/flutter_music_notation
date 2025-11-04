// lib/src/rendering/key_signature_renderer.dart

import 'package:flutter/material.dart';
import '../models/key_signature.dart';
import '../geometry/staff_position.dart';
import 'glyph_provider.dart';

/// Renders key signature symbols (sharps or flats) after the clef
class KeySignatureRenderer {
  final double staffSpaceSize;
  final Color color;

  const KeySignatureRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint the key signature
  void paint(
      Canvas canvas,
      double x,
      double staffTopY,
      KeySignature keySignature,
      ClefType clefType,
      ) {
    if (keySignature.accidentals == 0) return;

    final positions = _getAccidentalPositions(keySignature, clefType);
    final glyph = keySignature.usesSharps
        ? GlyphProvider.sharp
        : GlyphProvider.flat;

    final size = staffSpaceSize * 2.5;
    final spacing = staffSpaceSize * 1.2;

    for (int i = 0; i < positions.length; i++) {
      final position = positions[i];
      final textPainter = GlyphProvider.getGlyph(glyph, size, color: color);

      // Calculate Y position for this accidental
      final y = staffTopY + (position * staffSpaceSize / 2) - textPainter.height / 2;
      final accidentalX = x + (i * spacing);

      textPainter.paint(canvas, Offset(accidentalX, y));
    }
  }

  /// Get staff positions for accidentals based on clef and key signature
  List<double> _getAccidentalPositions(
      KeySignature keySignature,
      ClefType clefType,
      ) {
    final count = keySignature.accidentals.abs();

    if (keySignature.usesSharps) {
      return _getSharpPositions(clefType, count);
    } else {
      return _getFlatPositions(clefType, count);
    }
  }

  /// Get positions for sharps in order: F C G D A E B
  List<double> _getSharpPositions(ClefType clefType, int count) {
    switch (clefType) {
      case ClefType.treble:
      // F5, C5, G5, D5, A4, E5, B4 (positions on treble staff)
        const positions = [0.0, 3.0, -1.0, 2.0, 5.0, 1.0, 4.0];
        return positions.take(count).toList();

      case ClefType.bass:
      // F3, C4, G3, D4, A3, E4, B3 (positions on bass staff)
        const positions = [2.0, 5.0, 1.0, 4.0, 7.0, 3.0, 6.0];
        return positions.take(count).toList();

      case ClefType.alto:
      // Positions for alto clef
        const positions = [1.0, 5.0, 0.0, 4.0, 7.0, 2.0, 6.0];
        return positions.take(count).toList();

      case ClefType.tenor:
      // Positions for tenor clef
        const positions = [6.0, 2.0, 5.0, 1.0, 4.0, 0.0, 3.0];
        return positions.take(count).toList();
    }
  }

  /// Get positions for flats in order: B E A D G C F
  List<double> _getFlatPositions(ClefType clefType, int count) {
    switch (clefType) {
      case ClefType.treble:
      // B4, E5, A4, D5, G4, C5, F4 (positions on treble staff)
        const positions = [4.0, 1.0, 5.0, 2.0, 6.0, 3.0, 7.0];
        return positions.take(count).toList();

      case ClefType.bass:
      // B2, E3, A2, D3, G2, C3, F2 (positions on bass staff)
        const positions = [6.0, 3.0, 7.0, 4.0, 8.0, 5.0, 9.0];
        return positions.take(count).toList();

      case ClefType.alto:
      // Positions for alto clef
        const positions = [5.0, 2.0, 6.0, 3.0, 7.0, 4.0, 8.0];
        return positions.take(count).toList();

      case ClefType.tenor:
      // Positions for tenor clef
        const positions = [3.0, 0.0, 4.0, 1.0, 5.0, 2.0, 6.0];
        return positions.take(count).toList();
    }
  }

  /// Calculate the width occupied by the key signature
  double getWidth(KeySignature keySignature) {
    if (keySignature.accidentals == 0) return 0;

    final count = keySignature.accidentals.abs();
    final spacing = staffSpaceSize * 1.2;

    return (count * spacing) + staffSpaceSize;
  }
}