// lib/src/rendering/glyph_provider.dart

import 'package:flutter/material.dart';
import '../models/pitch.dart';
import '../models/duration.dart';

/// Provides music notation symbols using SMuFL-compliant Bravura font
class GlyphProvider {
  static const String fontFamily = 'Bravura';
  static const String packageName = 'flutter_music_notation';

  // Clef glyphs
  static const trebleClef = '\uE050';
  static const bassClef = '\uE062';
  static const altoClef = '\uE05C';
  static const tenorClef = '\uE05C'; // Same as alto, positioned differently

  // Accidental glyphs
  static const sharp = '\uE262';
  static const flat = '\uE260';
  static const natural = '\uE261';
  static const doubleSharp = '\uE263';
  static const doubleFlat = '\uE264';

  // Rest glyphs
  static const wholeRest = '\uE4E3';
  static const halfRest = '\uE4E4';
  static const quarterRest = '\uE4E5';
  static const eighthRest = '\uE4E6';
  static const sixteenthRest = '\uE4E7';
  static const thirtySecondRest = '\uE4E8';
  static const sixtyFourthRest = '\uE4E9';


  // Notehead glyphs (we'll use shapes instead for better control)
  static const noteheadBlack = '\uE0A4';
  static const noteheadHalf = '\uE0A3';
  static const noteheadWhole = '\uE0A2';

  /// Get a TextPainter for a music symbol
  static TextPainter getGlyph(
      String codepoint,
      double size, {
        Color color = Colors.black,
      }) {
    return TextPainter(
      text: TextSpan(
        text: codepoint,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          color: color,
          package: packageName,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Get accidental glyph for an Accidental enum
  static String getAccidentalGlyph(Accidental accidental) {
    switch (accidental) {
      case Accidental.doubleFlat:
        return doubleFlat;
      case Accidental.flat:
        return flat;
      case Accidental.natural:
        return natural;
      case Accidental.sharp:
        return sharp;
      case Accidental.doubleSharp:
        return doubleSharp;
    }
  }

  /// Get rest glyph for a duration type
  static String getRestGlyph(DurationType type) {
    switch (type) {
      case DurationType.whole:
      case DurationType.breve:
      case DurationType.long:
      case DurationType.maxima:
        return wholeRest;
      case DurationType.half:
        return halfRest;
      case DurationType.quarter:
        return quarterRest;
      case DurationType.eighth:
        return eighthRest;
      case DurationType.sixteenth:
        return sixteenthRest;
      case DurationType.thirtySecond:
        return thirtySecondRest;
      case DurationType.sixtyFourth:
        return sixtyFourthRest;
    }
  }
}