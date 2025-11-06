// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../models/measure.dart';
import '../widgets/notation_view.dart';
import '../layout/spacing_engine.dart';
import '../layout/system_layout.dart';
import '../layout/line_breaker.dart';
import 'note_renderer.dart';
import 'clef_renderer.dart';
import 'key_signature_renderer.dart';
import 'time_signature_renderer.dart';
import 'barline_renderer.dart';

/// CustomPainter that renders musical notation with multi-line support
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
      _paintMeasuresMultiLine(canvas, size);
    } else if (notes != null) {
      _paintLegacyNotes(canvas, size);
    }
  }

  /// Paint measures with full system layout (multi-line support)
  void _paintMeasuresMultiLine(Canvas canvas, Size size) {
    if (measures == null || measures!.isEmpty) return;

    // Create renderers
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

    // Use system layout if enabled (multi-line mode)
    if (config.useSystemLayout) {
      _paintWithSystemLayout(
        canvas,
        size,
        noteRenderer,
        clefRenderer,
        keySignatureRenderer,
        timeSignatureRenderer,
        barlineRenderer,
      );
    } else {
      // Single-line mode (legacy)
      _paintSingleLine(
        canvas,
        size,
        noteRenderer,
        clefRenderer,
        keySignatureRenderer,
        timeSignatureRenderer,
        barlineRenderer,
      );
    }
  }

  /// Paint with full system layout (multiple lines)
  void _paintWithSystemLayout(
      Canvas canvas,
      Size size,
      NoteRenderer noteRenderer,
      ClefRenderer clefRenderer,
      KeySignatureRenderer keySignatureRenderer,
      TimeSignatureRenderer timeSignatureRenderer,
      BarlineRenderer barlineRenderer,
      ) {
    // Create system layout
    final systemLayout = SystemLayout(
      spacingEngine: config.spacingEngine,
      systemHeight: config.systemHeight,
      systemSpacing: config.systemSpacing,
      showMeasureNumbers: config.showMeasureNumbers,
    );

    // Calculate complete layout
    final scoreLayout = systemLayout.calculateLayout(
      measures!,
      pageWidth: size.width,
      leftMargin: config.leftMargin,
      rightMargin: config.rightMargin,
      topMargin: config.topMargin,
      measureSpacing: config.measureSpacing,
      lineBreakConfig: config.lineBreakConfig,
    );

    final staffHeight = noteRenderer.staffRenderer.height;

    // Draw each system
    for (final system in scoreLayout.systems) {
      final staffY = system.yPosition;
      final staffTopLeft = Offset(config.leftMargin, staffY);

      // Track current X position (we need this to calculate staff width)
      double currentX = config.leftMargin;
      double prefixWidth = 0.0; // Width of clef/key/time sig

      // Calculate prefix width (clef, key sig, time sig on first measure)
      if (system.isFirstSystem && system.measures.isNotEmpty) {
        final firstMeasure = system.measures.first;

        prefixWidth += clefRenderer.getWidth(config.clef) + config.staffSpaceSize;

        if (firstMeasure.keySignature.accidentals != 0) {
          prefixWidth += keySignatureRenderer.getWidth(firstMeasure.keySignature);
        }

        prefixWidth += timeSignatureRenderer.getWidth(firstMeasure.timeSignature) + config.staffSpaceSize;
      } else if (config.showClefOnEachSystem && system.measures.isNotEmpty) {
        prefixWidth += clefRenderer.getWidth(config.clef) + config.staffSpaceSize * 0.5;
      }

      // Calculate actual staff width including prefix
      final lastMeasureSpacing = system.spacing.measureSpacings.last;
      final staffWidth = prefixWidth + (lastMeasureSpacing.endX - config.leftMargin) ;

      // Draw staff lines for this system (only to the end of content)
      noteRenderer.staffRenderer.paint(
        canvas,
        staffTopLeft,
        staffWidth,
      );

      // Draw each measure in this system
      for (int measureIndex = 0; measureIndex < system.measures.length; measureIndex++) {
        final measure = system.measures[measureIndex];
        final measureSpacing = system.spacing.measureSpacings[measureIndex];

        // Show clef, key sig, time sig on first measure of first system
        if (system.isFirstSystem && measureIndex == 0) {
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
        // Show clef on subsequent systems if configured
        else if (measureIndex == 0 && config.showClefOnEachSystem) {
          clefRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            config.clef,
          );
          currentX += clefRenderer.getWidth(config.clef) + config.staffSpaceSize * 0.5;
        }

        // Draw measure number if configured
        if (config.showMeasureNumbers && measureIndex == 0) {
          _drawMeasureNumber(
            canvas,
            measure.number,
            Offset(currentX, staffY - config.staffSpaceSize * 2),
          );
        }

        // Calculate the offset between measureSpacing.startX and our currentX
        // This ensures notes are positioned relative to where we actually are after clef/key/time sig
        final xOffset = currentX - measureSpacing.startX;

        // Draw measure content with proper offset
        _drawMeasureContent(
          canvas,
          measure,
          measureSpacing,
          staffTopLeft,
          xOffset,
          noteRenderer,
        );

        // Draw barline at measure end (also offset)
        final measureEndX = measureSpacing.endX + xOffset;
        barlineRenderer.paint(
          canvas,
          measureEndX,
          staffTopLeft.dy,
          staffTopLeft.dy + staffHeight,
          measure.endBarline,
        );

        // Move to next measure
        currentX = measureEndX + config.measureSpacing;
      }
    }
  }

  /// Paint single line (legacy mode without system layout)
  void _paintSingleLine(
      Canvas canvas,
      Size size,
      NoteRenderer noteRenderer,
      ClefRenderer clefRenderer,
      KeySignatureRenderer keySignatureRenderer,
      TimeSignatureRenderer timeSignatureRenderer,
      BarlineRenderer barlineRenderer,
      ) {
    // Calculate staff position
    final staffHeight = noteRenderer.staffRenderer.height;
    final staffY = (size.height - staffHeight) / 2;
    final staffTopLeft = Offset(config.leftMargin, staffY);

    double currentX = staffTopLeft.dx;

    // Use spacing engine for proportional spacing
    final spacingEngine = config.spacingEngine;

    // First pass: calculate all positions to determine staff width
    double finalBarlineX = currentX;

    // Track accidentals for each measure
    for (int measureIndex = 0; measureIndex < measures!.length; measureIndex++) {
      final measure = measures![measureIndex];

      // Calculate clef, key sig, time sig width for first measure
      if (measure.isFirstMeasure) {
        currentX += clefRenderer.getWidth(config.clef) + config.staffSpaceSize;

        if (measure.keySignature.accidentals != 0) {
          currentX += keySignatureRenderer.getWidth(measure.keySignature);
        }

        currentX += timeSignatureRenderer.getWidth(measure.timeSignature) + config.staffSpaceSize;
      }

      final measureStartX = currentX;

      // Get all elements
      final elements = measure.elements;
      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();
      final flatElements = sortedBeats.map((beat) => elementsByBeat[beat]!.first).toList();
      final positions = spacingEngine.calculateSpacing(
        flatElements,
        startX: measureStartX,
      );

      final measureEndX = positions.isNotEmpty
          ? positions.last + config.noteWidth
          : measureStartX + config.minMeasureWidth;

      finalBarlineX = measureEndX;
      currentX = measureEndX + config.measureSpacing;
    }

    // Now we know the final staff width - draw staff lines only to that point
    final staffWidth = finalBarlineX - staffTopLeft.dx + config.staffSpaceSize;
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      staffWidth,
    );

    // Second pass: actually draw everything
    currentX = staffTopLeft.dx;

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

  /// Draw measure content with spacing
  void _drawMeasureContent(
      Canvas canvas,
      Measure measure,
      MeasureSpacing measureSpacing,
      Offset staffTopLeft,
      double xOffset,
      NoteRenderer noteRenderer,
      ) {
    final seenPitchClasses = <int>{};

    // Get all elements sorted by start beat
    final elements = measure.elements;

    // Group by beat
    final elementsByBeat = <double, List<dynamic>>{};
    for (final element in elements) {
      final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
      elementsByBeat.putIfAbsent(beat, () => []).add(element);
    }

    final sortedBeats = elementsByBeat.keys.toList()..sort();

    // Draw each element
    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final elementsAtBeat = elementsByBeat[beat]!;
      final xPosition = measureSpacing.positionAt(i) + xOffset; // Apply offset

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
        // Render notes
        final notesAtBeat = elementsAtBeat.cast<Note>();

        if (notesAtBeat.length == 1) {
          final note = notesAtBeat.first;
          final isActive = activeNotes.contains(note);

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
  }

  /// Draw measure number
  void _drawMeasureNumber(Canvas canvas, int measureNumber, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${measureNumber + 1}', // Display as 1-indexed
        style: TextStyle(
          fontSize: config.staffSpaceSize * 1.2,
          color: config.noteColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, position);
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

    // Draw staff lines
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      size.width - config.leftMargin - 20,
    );

    // Track which notes need accidentals
    final seenPitchClasses = <int>{};

    // Sort all elements by start beat
    final allElements = <dynamic>[...notes!, ...?rests];
    allElements.sort((a, b) {
      final aStart = a is Note ? a.startBeat : (a as Rest).startBeat;
      final bStart = b is Note ? b.startBeat : (b as Rest).startBeat;
      return aStart.compareTo(bStart);
    });

    // Group by beat
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

      if (elementsAtBeat.first is Rest) {
        final rest = elementsAtBeat.first as Rest;
        noteRenderer.paintRest(
          canvas,
          rest: rest,
          staffTopLeft: staffTopLeft,
          xPosition: xPosition,
        );
      } else {
        final notesAtBeat = elementsAtBeat.cast<Note>();

        if (notesAtBeat.length == 1) {
          final note = notesAtBeat.first;
          final isActive = activeNotes.contains(note);

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
          final chord = Chord(notes: notesAtBeat);
          final isActive = notesAtBeat.any((n) => activeNotes.contains(n));

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