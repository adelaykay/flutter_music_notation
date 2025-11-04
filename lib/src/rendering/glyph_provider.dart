import 'package:flutter/material.dart';
import '../models/pitch.dart';
import '../models/duration.dart';
import '../models/notation_style.dart';

/// Provides SMuFL-compliant music glyphs from multiple notation fonts.
class GlyphProvider {
  static const String bravura = 'Bravura';
  static const String petaluma = 'Petaluma';
  static const String packageName = 'flutter_music_notation';

  /// The active notation style (default: Bravura)
  static NotationStyle currentStyle = NotationStyle.bravura;

  // Clefs
  static const trebleClef = '\uE050';
  static const bassClef = '\uE062';
  static const altoClef = '\uE05C';
  static const tenorClef = '\uE05C';

  // Accidentals
  static const sharp = '\uE262';
  static const flat = '\uE260';
  static const natural = '\uE261';
  static const doubleSharp = '\uE263';
  static const doubleFlat = '\uE264';

  // Rests
  static const wholeRest = '\uE4E3';
  static const halfRest = '\uE4E4';
  static const quarterRest = '\uE4E5';
  static const eighthRest = '\uE4E6';
  static const sixteenthRest = '\uE4E7';
  static const thirtySecondRest = '\uE4E8';
  static const sixtyFourthRest = '\uE4E9';

  // Noteheads
  static const noteheadBlack = '\uE0A4';
  static const noteheadHalf = '\uE0A3';
  static const noteheadWhole = '\uE0A2';

  // Flags
  static const flag8thUp = '\uE240';
  static const flag8thDown = '\uE241';
  static const flag16thUp = '\uE242';
  static const flag16thDown = '\uE243';
  static const flag32ndUp = '\uE244';
  static const flag32ndDown = '\uE245';
  static const flag64thUp = '\uE246';
  static const flag64thDown = '\uE247';

  /// Decide which font to use for a glyph
  static String _fontForGlyph(String codepoint) {
    // Always use Petaluma for accidentals when mixing
    const petalumaAccidentals = {
      sharp,
      flat,
      natural,
      doubleSharp,
      doubleFlat,
    };

    if (petalumaAccidentals.contains(codepoint)) {
      return petaluma;
    }

    // Otherwise, base on the active style
    switch (currentStyle) {
      case NotationStyle.bravura:
        return bravura;
      case NotationStyle.petaluma:
        return petaluma;
    }
  }

  /// Get a TextPainter for a music symbol
  static TextPainter getGlyph(
      String codepoint,
      double size, {
        Color color = Colors.black,
      }) {
    final font = _fontForGlyph(codepoint);
    return TextPainter(
      text: TextSpan(
        text: codepoint,
        style: TextStyle(
          fontFamily: font,
          fontSize: size,
          color: color,
          package: packageName,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Utility getters for accidentals, rests, flags
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

  static String getFlagGlyph(DurationType type, bool stemUp) {
    switch (type) {
      case DurationType.eighth:
        return stemUp ? flag8thUp : flag8thDown;
      case DurationType.sixteenth:
        return stemUp ? flag16thUp : flag16thDown;
      case DurationType.thirtySecond:
        return stemUp ? flag32ndUp : flag32ndDown;
      case DurationType.sixtyFourth:
        return stemUp ? flag64thUp : flag64thDown;
      default:
        return '';
    }
  }

  /// Call this to switch notation style globally at runtime
  static void setNotationStyle(NotationStyle style) {
    currentStyle = style;
  }
}
