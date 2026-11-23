// lib/src/rendering/time_signature_renderer.dart

import 'package:flutter/material.dart';
import '../models/time_signature.dart';
import 'glyph_provider.dart';

/// Renders time signatures with the SMuFL time-signature glyphs from the
/// bundled music font, so digits and the common/cut time symbols match the
/// rest of the engraving on every platform.
///
/// SMuFL fonts are scaled so that one em is four staff spaces, and the
/// time-signature digits are two staff spaces tall, centred on their
/// baseline. The numerator is therefore drawn with its baseline one space
/// below the top line, the denominator three spaces below it, and the
/// common/cut symbols on the middle line.
class TimeSignatureRenderer {
  final double staffSpaceSize;
  final Color color;

  const TimeSignatureRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  static const _digitBase = 0xE080; // timeSig0
  static const _commonTime = '';
  static const _cutTime = '';

  double get _fontSize => staffSpaceSize * 4;

  static String _digits(int value) =>
      value.toString().split('').map((d) => String.fromCharCode(_digitBase + int.parse(d))).join();

  TextPainter _painter(String glyphs) => GlyphProvider.getGlyph(glyphs, _fontSize, color: color);

  /// Paints [glyphs] horizontally centred in a column of [columnWidth]
  /// starting at [x], with the glyph baseline at [baselineY].
  void _paintCentred(Canvas canvas, TextPainter p, double x, double columnWidth, double baselineY) {
    final baseline = p.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    p.paint(canvas, Offset(x + (columnWidth - p.width) / 2, baselineY - baseline));
  }

  /// Paint the time signature with its left edge at [x].
  void paint(Canvas canvas, double x, double staffTopY, TimeSignature timeSignature) {
    if (timeSignature.isCommonTime || timeSignature.isCutTime) {
      final p = _painter(timeSignature.isCommonTime ? _commonTime : _cutTime);
      _paintCentred(canvas, p, x, p.width, staffTopY + staffSpaceSize * 2);
      return;
    }

    final top = _painter(_digits(timeSignature.beats));
    final bottom = _painter(_digits(timeSignature.beatUnit));
    final column = top.width > bottom.width ? top.width : bottom.width;
    _paintCentred(canvas, top, x, column, staffTopY + staffSpaceSize);
    _paintCentred(canvas, bottom, x, column, staffTopY + staffSpaceSize * 3);
  }

  /// Width the time signature occupies (excluding any following gap).
  double getWidth(TimeSignature timeSignature) {
    if (timeSignature.isCommonTime || timeSignature.isCutTime) {
      return _painter(timeSignature.isCommonTime ? _commonTime : _cutTime).width;
    }
    final top = _painter(_digits(timeSignature.beats)).width;
    final bottom = _painter(_digits(timeSignature.beatUnit)).width;
    return top > bottom ? top : bottom;
  }
}
