// lib/src/rendering/note_renderer.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../geometry/staff_position.dart';
import '../geometry/staff_units.dart';
import 'notehead_renderer.dart';
import 'stem_renderer.dart';
import 'accidental_renderer.dart';
import 'staff_renderer.dart';
import 'dot_renderer.dart';
import 'rest_renderer.dart';
import 'flag_renderer.dart';


/// High-level renderer that combines notehead, stem, accidental, and dots
class NoteRenderer {
  final double staffSpaceSize;
  final StaffRenderer staffRenderer;
  final NoteheadRenderer noteheadRenderer;
  final StemRenderer stemRenderer;
  final AccidentalRenderer accidentalRenderer;
  final DotRenderer dotRenderer;
  final RestRenderer restRenderer;
  final FlagRenderer flagRenderer;


  NoteRenderer({
    required this.staffSpaceSize,
    Color color = Colors.black,
  })  : staffRenderer = StaffRenderer(staffSpaceSize: staffSpaceSize, lineColor: color),
        noteheadRenderer = NoteheadRenderer(staffSpaceSize: staffSpaceSize, color: color),
        stemRenderer = StemRenderer(staffSpaceSize: staffSpaceSize, color: color),
        accidentalRenderer = AccidentalRenderer(staffSpaceSize: staffSpaceSize, color: color),
        dotRenderer = DotRenderer(staffSpaceSize: staffSpaceSize, color: color),
        restRenderer = RestRenderer(staffSpaceSize: staffSpaceSize, color: color),
        flagRenderer = FlagRenderer(staffSpaceSize: staffSpaceSize, color: color);

  /// Render a complete note
  void paintNote(
      Canvas canvas, {
        required Note note,
        required Offset staffTopLeft,
        required double xPosition,
        required ClefType clef,
        required bool showAccidental,
        required bool isActive,
      }) {
    // Calculate staff position for this pitch
    final staffPosition = StaffPosition.forPitch(note.pitch, clef);

    // Convert to Y coordinate
    final yPosition = staffRenderer.positionToY(staffPosition);
    final noteCenter = Offset(xPosition, staffTopLeft.dy + yPosition);

    // Draw ledger lines if needed
    staffRenderer.paintLedgerLines(canvas, noteCenter, staffPosition);

    // Draw accidental if needed
    if (showAccidental && note.pitch.accidental != Accidental.natural) {
      accidentalRenderer.paint(canvas, noteCenter, note.pitch.accidental);
    }

    // Draw notehead
    final filled = NoteheadRenderer.shouldBeFilled(note.duration);
    noteheadRenderer.paint(canvas, noteCenter, filled: filled, isActive: isActive);

    // Draw stem and flags if needed
    if (note.duration.needsStem) {
      final stemDirection = StemRenderer.determineStemDirection(staffPosition);
      final stemEnd = stemRenderer.paint(
        canvas,
        noteCenter,
        direction: stemDirection,
        isActive: isActive,
      );

      // Draw flags if note needs them (eighth, sixteenth, etc.)
      if (note.duration.needsFlag) {
        flagRenderer.paint(
          canvas,
          stemEnd,
          direction: stemDirection,
          durationType: note.duration.type,
        );
      }
    }

    // Draw dots if needed
    if (note.duration.dots > 0) {
      dotRenderer.paintNoteDots(
        canvas,
        noteCenter,
        staffPosition,
        note.duration.dots,
      );
    }
  }

  /// Render a chord (multiple notes at same time position)
  void paintChord(
      Canvas canvas, {
        required Chord chord,
        required Offset staffTopLeft,
        required double xPosition,
        required ClefType clef,
        required Set<int> notesShowingAccidentals,
        required bool isActive,
      }) {
    final sortedNotes = chord.sortedNotes;

    // Calculate positions for all notes
    final positions = sortedNotes
        .map((n) => StaffPosition.forPitch(n.pitch, clef))
        .toList();

    // Determine stem direction for the chord
    final stemDirection = StemRenderer.determineStemDirectionForChord(positions);

    // Draw all noteheads and accidentals
    for (int i = 0; i < sortedNotes.length; i++) {
      final note = sortedNotes[i];
      final position = positions[i];
      final yPosition = staffRenderer.positionToY(position);
      final noteCenter = Offset(xPosition, staffTopLeft.dy + yPosition);

      // Draw ledger lines
      staffRenderer.paintLedgerLines(canvas, noteCenter, position);

      // Draw accidental if needed
      final showAccidental = notesShowingAccidentals.contains(note.pitch.midiNumber);
      if (showAccidental && note.pitch.accidental != Accidental.natural) {
        // Offset accidentals vertically to avoid collision in tight chords
        final accidentalOffset = Offset(xPosition - (i * 5), noteCenter.dy);
        accidentalRenderer.paint(canvas, accidentalOffset, note.pitch.accidental);
      }

      // Draw notehead
      final filled = NoteheadRenderer.shouldBeFilled(note.duration);
      noteheadRenderer.paint(canvas, noteCenter, filled: filled, isActive: isActive);
    }

    // Draw stem and flags for the whole chord
    if (chord.duration.needsStem) {
      final extremeNote = stemDirection == StemDirection.up
          ? sortedNotes.last  // Highest note
          : sortedNotes.first; // Lowest note

      final extremePosition = StaffPosition.forPitch(extremeNote.pitch, clef);
      final yPosition = staffRenderer.positionToY(extremePosition);
      final noteCenter = Offset(xPosition, staffTopLeft.dy + yPosition);

      final stemEnd = stemRenderer.paint(
        canvas,
        noteCenter,
        direction: stemDirection,
        isActive: isActive,
      );

      // Draw flags if chord needs them
      if (chord.duration.needsFlag) {
        flagRenderer.paint(
          canvas,
          stemEnd,
          direction: stemDirection,
          durationType: chord.duration.type,
        );
      }
    }

    // Draw dots for chord (on the highest note)
    if (chord.duration.dots > 0) {
      final highestNote = sortedNotes.last;
      final highestPosition = StaffPosition.forPitch(highestNote.pitch, clef);
      final yPosition = staffRenderer.positionToY(highestPosition);
      final noteCenter = Offset(xPosition, staffTopLeft.dy + yPosition);

      dotRenderer.paintNoteDots(
        canvas,
        noteCenter,
        highestPosition,
        chord.duration.dots,
      );
    }
  }

  /// Render a rest
  void paintRest(
      Canvas canvas, {
        required Rest rest,
        required Offset staffTopLeft,
        required double xPosition,
      }) {
    // Draw rest symbol
    restRenderer.paint(
      canvas,
      staffTopLeft,
      xPosition,
      rest.duration.type,
    );

    // Draw dots if needed
    if (rest.duration.dots > 0) {
      final restY = staffTopLeft.dy + (staffSpaceSize * 2); // Middle of staff
      dotRenderer.paintRestDots(
        canvas,
        Offset(xPosition, restY),
        rest.duration.dots,
      );
    }
  }

  /// Calculate the width occupied by a note
  double getWidth(Note note){
    var width = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    if(note.duration.needsFlag) width += StaffUnits.flagWidth.toPixels(staffSpaceSize);
    if(note.pitch.accidental != Accidental.natural) {
      width += StaffUnits.accidentalWidth.toPixels(staffSpaceSize) * 1.5;
    }
    return width;
  }
}