// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../widgets/notation_view.dart';
import 'note_renderer.dart';

/// CustomPainter that renders musical notation
class NotationPainter extends CustomPainter {
  final List<dynamic> notes;
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
    final staffTopLeft = Offset(config.leftMargin, staffY);

    // Draw staff lines (extend to right edge)
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      size.width - config.leftMargin - 20,
    );

    // Track which notes need accidentals
    final seenPitchClasses = <int>{};

    // Sort all elements (notes and rests) by start beat
    final allElements = <dynamic>[...notes];
    allElements.sort((a, b) {
      final aStart = a is Note ? a.startBeat : (a as Rest).startBeat;
      final bStart = b is Note ? b.startBeat : (b as Rest).startBeat;
      return aStart.compareTo(bStart);
    });

    // Group consecutive notes with same start beat (chords)
    final elementsByBeat = <double, List<dynamic>>{};
    for (final element in allElements) {
      final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
      elementsByBeat.putIfAbsent(beat, () => []).add(element);
    }

    final sortedBeats = elementsByBeat.keys.toList()..sort();

    // Draw elements with UNIFORM spacing
    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final elementsAtBeat = elementsByBeat[beat]!;

      // Uniform horizontal position
      final xPosition = staffTopLeft.dx + (i * config.noteWidth);

      // Check if this is a rest or notes
      if (elementsAtBeat.first is Rest) {
        // Render rest
        final rest = elementsAtBeat.first as Rest;
        noteRenderer.paintRest(
          canvas,
          rest: rest,
          staffTopLeft: staffTopLeft,
          xPosition: xPosition,
        );
      } else {
        // Render notes (single note or chord)
        final notesAtBeat = elementsAtBeat.cast<Note>();

        if (notesAtBeat.length == 1) {
          // Single note
          final note = notesAtBeat.first;
          final isActive = activeNotes.contains(note);

          // Determine if accidental should be shown
          final pitchClass = note.pitch.midiNumber % 12;
          final showAccidental = !seenPitchClasses.contains(pitchClass) &&
              note.pitch.accidental != Accidental.natural;

          if (showAccidental) {
            seenPitchClasses.add(pitchClass);
          }

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
          // Chord
          final chord = Chord(notes: notesAtBeat);
          final isActive = notesAtBeat.any((n) => activeNotes.contains(n));

          // Determine which notes in chord need accidentals
          final chordAccidentals = <int>{};
          for (final note in notesAtBeat) {
            final pitchClass = note.pitch.midiNumber % 12;
            if (!seenPitchClasses.contains(pitchClass) &&
                note.pitch.accidental != Accidental.natural) {
              chordAccidentals.add(note.pitch.midiNumber);
              seenPitchClasses.add(pitchClass);
            }
          }

          noteRenderer.paintChord(
            canvas,
            chord: chord,
            staffTopLeft: staffTopLeft,
            xPosition: xPosition,
            clef: config.clef,
            notesShowingAccidentals: chordAccidentals,
            isActive: isActive,
          );
        }
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