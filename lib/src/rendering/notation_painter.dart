// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../models/measure.dart';
import '../widgets/notation_view.dart';
import 'note_renderer.dart';
import 'clef_renderer.dart';
import 'key_signature_renderer.dart';
import 'time_signature_renderer.dart';
import 'barline_renderer.dart';

/// CustomPainter that renders musical notation
class NotationPainter extends CustomPainter {
  final List<Measure>? measures;
  final List<Note>? notes;
  final List<Rest>? rests;
  final NotationConfig config;
  final Set<Note> activeNotes;

  NotationPainter({
    this.measures,
    this.notes,
    this.rests,
    required this.config,
    required this.activeNotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measures != null) {
      _paintMeasures(canvas, size);
    } else if (notes != null) {
      _paintLegacyNotes(canvas, size);
    }
  }

  /// Paint measures with proper clef, key signature, time signature, and barlines
  void _paintMeasures(Canvas canvas, Size size) {
    if (measures == null || measures!.isEmpty) return;

    final noteRenderer = NoteRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    final clefRenderer = ClefRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    final keySignatureRenderer = KeySignatureRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    final timeSignatureRenderer = TimeSignatureRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    final barlineRenderer = BarlineRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    // Calculate staff position
    final staffHeight = noteRenderer.staffRenderer.height;
    final staffY = (size.height - staffHeight) / 2;
    final staffTopLeft = Offset(config.leftMargin, staffY);

    // Draw staff lines
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      size.width - config.leftMargin - 20,
    );

    double currentX = staffTopLeft.dx;

    // Use spacing engine for proportional spacing
    final spacingEngine = config.spacingEngine;

    // Track accidentals for each measure
    for (int measureIndex = 0; measureIndex < measures!.length; measureIndex++) {
      final measure = measures![measureIndex];
      final seenPitchClasses = <int>{};

      // Draw clef, key signature, time signature on first measure
      if (measure.isFirstMeasure) {
        // Draw clef
        clefRenderer.paint(
          canvas,
          currentX,
          staffTopLeft.dy,
          config.clef,
        );
        currentX += clefRenderer.getWidth(config.clef) + config.staffSpaceSize;

        // Draw key signature
        if (measure.keySignature.accidentals != 0) {
          keySignatureRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            measure.keySignature,
            config.clef,
          );
          currentX += keySignatureRenderer.getWidth(measure.keySignature);
        }

        // Draw time signature
        timeSignatureRenderer.paint(
          canvas,
          currentX,
          staffTopLeft.dy,
          measure.timeSignature,
        );
        currentX += timeSignatureRenderer.getWidth(measure.timeSignature) + config.staffSpaceSize;
      }

      // Mark the start of the measure content
      final measureStartX = currentX;

      // Get all elements (notes and rests) sorted by start beat
      final elements = measure.elements;

      // Group consecutive notes with same start beat (chords)
      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();

      // Calculate spacing for this measure using the spacing engine
      final flatElements = sortedBeats.map((beat) => elementsByBeat[beat]!.first).toList();
      final positions = spacingEngine.calculateSpacing(
        flatElements,
        startX: measureStartX,
      );

      // Draw elements with calculated spacing
      for (int i = 0; i < sortedBeats.length; i++) {
        final beat = sortedBeats[i];
        final elementsAtBeat = elementsByBeat[beat]!;

        // Get position from spacing engine
        final xPosition = positions[i];

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
            final needsAccidental = measure.keySignature.needsAccidental(note.pitch);
            final showAccidental = needsAccidental && !seenPitchClasses.contains(pitchClass);

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
              final needsAccidental = measure.keySignature.needsAccidental(note.pitch);
              if (needsAccidental && !seenPitchClasses.contains(pitchClass)) {
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

      // Calculate measure end position based on last element position
      final measureEndX = positions.isNotEmpty
          ? positions.last + config.noteWidth
          : measureStartX + config.minMeasureWidth;

      // Draw barline at end of measure
      barlineRenderer.paint(
        canvas,
        measureEndX,
        staffTopLeft.dy,
        staffTopLeft.dy + staffHeight,
        measure.endBarline,
      );

      // Update position for next measure
      currentX = measureEndX + config.measureSpacing;
    }
  }

  /// Paint notes in legacy mode (for backward compatibility)
  void _paintLegacyNotes(Canvas canvas, Size size) {
    if (notes == null || notes!.isEmpty) return;

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
    final allElements = <dynamic>[...notes!, ...?rests];
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
        oldDelegate.rests != rests ||
        oldDelegate.measures != measures ||
        oldDelegate.config != config;
  }
}