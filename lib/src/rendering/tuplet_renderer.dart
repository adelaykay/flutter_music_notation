// lib/src/rendering/tuplet_renderer.dart

import 'package:flutter/material.dart';
import '../models/tuplet_bracket.dart';

/// Renders tuplet brackets and numbers
class TupletRenderer {
  final double staffSpaceSize;
  final Color color;

  const TupletRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a tuplet bracket with number
  void paintTuplet(
      Canvas canvas,
      TupletBracket tuplet,
      List<Offset> notePositions,
      TupletDirection direction,
      ) {
    if (notePositions.length < 2) return;

    final startPos = notePositions.first;
    final endPos = notePositions.last;

    // Calculate bracket position
    final bracketY = _calculateBracketY(notePositions, direction);

    // Draw number
    _drawNumber(
      canvas,
      tuplet.displayText,
      startPos.dx,
      endPos.dx,
      bracketY,
      direction,
    );

    // Draw bracket if needed
    if (tuplet.shouldDrawBracket) {
      _drawBracket(
        canvas,
        startPos.dx,
        endPos.dx,
        bracketY,
        direction,
      );
    }
  }

  /// Calculate Y position for the bracket
  double _calculateBracketY(
      List<Offset> notePositions,
      TupletDirection direction,
      ) {
    if (direction == TupletDirection.above) {
      // Find highest note
      final highestY = notePositions
          .map((p) => p.dy)
          .reduce((a, b) => a < b ? a : b);

      // Place bracket above, with clearance
      return highestY - (staffSpaceSize * 3.0);
    } else {
      // Find lowest note
      final lowestY = notePositions
          .map((p) => p.dy)
          .reduce((a, b) => a > b ? a : b);

      // Place bracket below, with clearance
      return lowestY + (staffSpaceSize * 3.0);
    }
  }

  /// Draw the tuplet number
  void _drawNumber(
      Canvas canvas,
      String text,
      double startX,
      double endX,
      double y,
      TupletDirection direction,
      ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: staffSpaceSize * 1.4,
          color: color,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the number
    final centerX = (startX + endX) / 2;
    final textX = centerX - textPainter.width / 2;

    // Adjust Y based on direction
    final textY = direction == TupletDirection.above
        ? y - textPainter.height / 2
        : y - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));
  }

  /// Draw the bracket
  void _drawBracket(
      Canvas canvas,
      double startX,
      double endX,
      double y,
      TupletDirection direction,
      ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bracketHeight = staffSpaceSize * 0.5;
    final verticalOffset = direction == TupletDirection.above
        ? -bracketHeight
        : bracketHeight;

    final path = Path();

    // Left vertical line
    path.moveTo(startX, y);
    path.lineTo(startX, y + verticalOffset);

    // Horizontal line
    path.moveTo(startX, y);
    path.lineTo(endX, y);

    // Right vertical line
    path.moveTo(endX, y);
    path.lineTo(endX, y + verticalOffset);

    canvas.drawPath(path, paint);
  }

  /// Paint a tuplet number only (no bracket)
  /// Used for beamed tuplets
  void paintTupletNumber(
      Canvas canvas,
      TupletBracket tuplet,
      List<Offset> notePositions,
      TupletDirection direction,
      ) {
    if (notePositions.length < 2) return;

    final startPos = notePositions.first;
    final endPos = notePositions.last;

    // Position number near the beam
    final numberY = _calculateBracketY(notePositions, direction);

    _drawNumber(
      canvas,
      tuplet.displayText,
      startPos.dx,
      endPos.dx,
      numberY,
      direction,
    );
  }

  /// Paint nested tuplets
  void paintNestedTuplet(
      Canvas canvas,
      NestedTuplet nestedTuplet,
      Map<TupletBracket, List<Offset>> tupletPositions,
      TupletDirection outerDirection,
      TupletDirection innerDirection,
      ) {
    // Draw outer tuplet
    final outerPositions = tupletPositions[nestedTuplet.outerTuplet];
    if (outerPositions != null) {
      paintTuplet(
        canvas,
        nestedTuplet.outerTuplet,
        outerPositions,
        outerDirection,
      );
    }

    // Draw inner tuplets with offset
    for (final innerTuplet in nestedTuplet.innerTuplets) {
      final innerPositions = tupletPositions[innerTuplet];
      if (innerPositions != null) {
        paintTuplet(
          canvas,
          innerTuplet,
          innerPositions,
          innerDirection,
        );
      }
    }
  }

  /// Calculate optimal spacing for tuplet notes
  /// Tuplet notes should be visually evenly spaced
  List<double> calculateTupletSpacing(
      TupletBracket tuplet,
      double startX,
      double availableWidth,
      ) {
    final noteCount = tuplet.notes.length;
    final spacing = availableWidth / (noteCount - 1);

    final positions = <double>[];
    for (int i = 0; i < noteCount; i++) {
      positions.add(startX + (i * spacing));
    }

    return positions;
  }

  /// Paint a tuplet with custom styling (for special cases)
  void paintCustomTuplet(
      Canvas canvas,
      TupletBracket tuplet,
      List<Offset> notePositions,
      TupletDirection direction, {
        Color? numberColor,
        Color? bracketColor,
        double? fontSize,
        bool italic = true,
        bool bold = true,
      }) {
    if (notePositions.length < 2) return;

    final startPos = notePositions.first;
    final endPos = notePositions.last;
    final bracketY = _calculateBracketY(notePositions, direction);

    // Custom number
    final textPainter = TextPainter(
      text: TextSpan(
        text: tuplet.displayText,
        style: TextStyle(
          fontSize: fontSize ?? (staffSpaceSize * 1.4),
          color: numberColor ?? color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final centerX = (startPos.dx + endPos.dx) / 2;
    final textX = centerX - textPainter.width / 2;
    final textY = direction == TupletDirection.above
        ? bracketY - textPainter.height / 2
        : bracketY - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));

    // Custom bracket
    if (tuplet.shouldDrawBracket) {
      final paint = Paint()
        ..color = bracketColor ?? color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final bracketHeight = staffSpaceSize * 0.5;
      final verticalOffset = direction == TupletDirection.above
          ? -bracketHeight
          : bracketHeight;

      final path = Path();
      path.moveTo(startPos.dx, bracketY);
      path.lineTo(startPos.dx, bracketY + verticalOffset);
      path.moveTo(startPos.dx, bracketY);
      path.lineTo(endPos.dx, bracketY);
      path.moveTo(endPos.dx, bracketY);
      path.lineTo(endPos.dx, bracketY + verticalOffset);

      canvas.drawPath(path, paint);
    }
  }

  /// Draw a tuplet ratio (e.g., "3:2" instead of just "3")
  void paintTupletRatio(
      Canvas canvas,
      TupletBracket tuplet,
      List<Offset> notePositions,
      TupletDirection direction,
      ) {
    if (notePositions.length < 2) return;

    final startPos = notePositions.first;
    final endPos = notePositions.last;
    final bracketY = _calculateBracketY(notePositions, direction);

    // Draw ratio text
    final ratioText = '${tuplet.tuplet.actualNotes}:${tuplet.tuplet.normalNotes}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: ratioText,
        style: TextStyle(
          fontSize: staffSpaceSize * 1.2,
          color: color,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final centerX = (startPos.dx + endPos.dx) / 2;
    final textX = centerX - textPainter.width / 2;
    final textY = direction == TupletDirection.above
        ? bracketY - textPainter.height / 2
        : bracketY - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));

    // Draw bracket if needed
    if (tuplet.shouldDrawBracket) {
      _drawBracket(canvas, startPos.dx, endPos.dx, bracketY, direction);
    }
  }
}