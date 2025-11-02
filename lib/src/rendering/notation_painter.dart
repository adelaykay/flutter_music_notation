// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../widgets/notation_view.dart';
import 'note_renderer.dart';

/// CustomPainter that renders musical notation
class NotationPainter extends CustomPainter {
  final List<Note> notes;
  final NotationConfig config;
  final Set<Note> activeNotes;

  NotationPainter({
    required this.notes,
    required this.config,
    required this.activeNotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty) return;

    final noteRenderer = NoteRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    // Calculate staff position
    final staffHeight = noteRenderer.staffRenderer.height;
    final staffY = (size.height - staffHeight) / 2;
    final staffTopLeft = Offset(50, staffY);

    /// Returns the number of distinct note/chord positions in the score.
    ///
    /// Notes that share the same `startBeat` (i.e. part of the same chord)
    /// are counted as one position.
    int countNotePositions(List<Note> notes) {
      // Use a set to collect unique beat values
      final beatSet = <double>{};

      for (final note in notes) {
        beatSet.add(note.startBeat);
      }

      return beatSet.length;
    }


    // Draw staff lines
    final totalWidth = (countNotePositions(notes) * config.pixelsPerNote);
    noteRenderer.staffRenderer.paint(canvas, staffTopLeft, totalWidth);

    // Track which notes need accidentals
    // (In a real implementation, this would consider key signature and measure context)
    final notesNeedingAccidentals = <int>{};
    final seenPitchClasses = <int>{};

    // Group notes by start beat (still needed to identify chords)
    final notesByBeat = <double, List<Note>>{};
    for (final note in notes) {
      notesByBeat.putIfAbsent(note.startBeat, () => []).add(note);
    }

// Sort beats to preserve order
    final sortedBeats = notesByBeat.keys.toList()..sort();

// Draw notes/chords equally spaced
    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final notesAtBeat = notesByBeat[beat]!;
      final xPosition = staffTopLeft.dx + (i * config.pixelsPerNote) + 20;

      if (notesAtBeat.length == 1) {
        final note = notesAtBeat.first;
        final isActive = activeNotes.contains(note);

        final pitchClass = note.pitch.midiNumber % 12;
        final showAccidental = note.pitch.accidental != Accidental.natural;

        noteRenderer.paintNote(
          canvas,
          note: note,
          staffTopLeft: staffTopLeft,
          xPosition: xPosition,
          clef: config.clef,
          showAccidental: showAccidental,
          isActive: isActive,
        );
      } else {
        // Chord case
        final chord = Chord(notes: notesAtBeat);
        final isActive = notesAtBeat.any((n) => activeNotes.contains(n));
        noteRenderer.paintChord(
          canvas,
          chord: chord,
          staffTopLeft: staffTopLeft,
          xPosition: xPosition,
          clef: config.clef,
          notesShowingAccidentals: notesAtBeat
              .where((n) => n.pitch.accidental != Accidental.natural)
              .map((n) => n.pitch.midiNumber)
              .toSet(),
          isActive: isActive,
        );
      }
    }
  }

  @override
  bool shouldRepaint(NotationPainter oldDelegate) {
    return oldDelegate.activeNotes != activeNotes ||
        oldDelegate.notes != notes ||
        oldDelegate.config != config;
  }
}