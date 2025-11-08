// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/grand_staff.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../models/measure.dart';
import '../widgets/notation_view.dart';
import '../layout/spacing_engine.dart';
import '../layout/system_layout.dart';
import '../layout/line_breaker.dart';
import '../layout/grand_staff_layout.dart';
import 'brace_renderer.dart';
import 'note_renderer.dart';
import 'clef_renderer.dart';
import 'key_signature_renderer.dart';
import 'time_signature_renderer.dart';
import 'barline_renderer.dart';
import '../geometry/staff_position.dart';

/// CustomPainter that renders musical notation with multi-line support
class NotationPainter extends CustomPainter {
  final List<Measure>? measures;
  final GrandStaff? grandStaff;
  final List<Note>? notes;
  final List<Rest>? rests;
  final NotationConfig config;
  final Set<Note> activeNotes;

  NotationPainter({
    this.measures,
    this.grandStaff,
    this.notes,
    this.rests,
    required this.config,
    required this.activeNotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (grandStaff != null) {
      _paintGrandStaff(canvas, size);
    } else if (measures != null) {
      _paintMeasuresMultiLine(canvas, size);
    } else if (notes != null) {
      _paintLegacyNotes(canvas, size);
    }
  }

  /// Paint grand staff (two staves connected with brace)
  void _paintGrandStaff(Canvas canvas, Size size) {
    if (grandStaff == null || grandStaff!.isEmpty) return;

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

    final braceRenderer = BraceRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    // Calculate layout
    final grandStaffLayout = GrandStaffLayout(
      spacingEngine: config.spacingEngine,
      upperStaffHeight: config.upperStaffHeight,
      lowerStaffHeight: config.lowerStaffHeight,
      staffGap: config.grandStaffGap,
      systemSpacing: config.systemSpacing,
      showMeasureNumbers: config.showMeasureNumbers,
    );

    final scoreLayout = grandStaffLayout.calculateLayout(
      grandStaff!,
      pageWidth: size.width,
      leftMargin: config.leftMargin,
      rightMargin: config.rightMargin,
      topMargin: config.topMargin,
      measureSpacing: config.measureSpacing,
      lineBreakConfig: config.lineBreakConfig,
    );

    // Draw each grand staff system
    for (final system in scoreLayout.systems) {
      final upperStaffY = system.upperStaffY;
      final lowerStaffY = system.lowerStaffY;

      // Draw brace connecting both staves
      if (config.showBrace) {
        final braceX = config.leftMargin - braceRenderer.getWidth() - config.staffSpaceSize;
        braceRenderer.paint(
          canvas,
          braceX,
          upperStaffY,
          lowerStaffY,
          config.upperStaffHeight,
        );
      }

      // Track barline positions by rendering both staves and collecting their measure end positions
      final upperBarlinePositions = <double>[];
      final lowerBarlinePositions = <double>[];

      // Draw upper staff and collect barline positions
      _paintSingleStaffWithBarlines(
        canvas,
        system.upperStaffMeasures,
        upperStaffY,
        config.upperStaffHeight,
        noteRenderer,
        clefRenderer,
        keySignatureRenderer,
        timeSignatureRenderer,
        system.spacing,
        ClefType.treble,
        isFirstSystem: system.isFirstSystem,
        showMeasureNumbers: system.showMeasureNumbers && config.showMeasureNumbers,
        barlinePositions: upperBarlinePositions,
      );

      // Draw lower staff and collect barline positions
      _paintSingleStaffWithBarlines(
        canvas,
        system.lowerStaffMeasures,
        lowerStaffY,
        config.lowerStaffHeight,
        noteRenderer,
        clefRenderer,
        keySignatureRenderer,
        timeSignatureRenderer,
        system.spacing,
        ClefType.bass,
        isFirstSystem: system.isFirstSystem,
        showMeasureNumbers: false, // Don't duplicate measure numbers
        barlinePositions: lowerBarlinePositions,
      );

      // Draw shared barlines connecting both staves
      for (int i = 0; i < system.upperStaffMeasures.length; i++) {
        final measure = system.upperStaffMeasures[i];
        final barlineX = upperBarlinePositions[i]; // Use tracked position

        // Draw barline connecting both staves
        barlineRenderer.paint(
          canvas,
          barlineX,
          upperStaffY,
          lowerStaffY + config.lowerStaffHeight,
          measure.endBarline,
        );
      }

      // Draw instrument name on first system
      if (system.isFirstSystem && system.instrumentName != null) {
        _drawInstrumentName(
          canvas,
          system.instrumentName!,
          Offset(
            config.leftMargin - braceRenderer.getWidth() - config.staffSpaceSize * 6,
            upperStaffY + system.totalHeight / 2,
          ),
        );
      }
    }
  }

  /// Paint a single staff and return barline positions (for grand staff)
  void _paintSingleStaffWithBarlines(
      Canvas canvas,
      List<Measure> measures,
      double staffY,
      double staffHeight,
      NoteRenderer noteRenderer,
      ClefRenderer clefRenderer,
      KeySignatureRenderer keySignatureRenderer,
      TimeSignatureRenderer timeSignatureRenderer,
      LineSpacing lineSpacing,
      ClefType clef, {
        required bool isFirstSystem,
        required bool showMeasureNumbers,
        required List<double> barlinePositions,
      }) {
    final staffTopLeft = Offset(config.leftMargin, staffY);

    double currentX = config.leftMargin;

    // Draw clef, key signature, time signature on first system
    if (isFirstSystem && measures.isNotEmpty) {
      final firstMeasure = measures.first;

      // Clef
      clefRenderer.paint(canvas, currentX, staffTopLeft.dy, clef);
      currentX += 35 + config.staffSpaceSize;

      // Key signature
      if (firstMeasure.keySignature.accidentals != 0) {
        keySignatureRenderer.paint(
          canvas,
          currentX,
          staffTopLeft.dy,
          firstMeasure.keySignature,
          clef,
        );
        currentX += keySignatureRenderer.getWidth(firstMeasure.keySignature);
      }

      // Time signature
      timeSignatureRenderer.paint(
        canvas,
        currentX,
        staffTopLeft.dy,
        firstMeasure.timeSignature,
      );
      currentX += timeSignatureRenderer.getWidth(firstMeasure.timeSignature) + config.staffSpaceSize;
    }

    // Draw measures and track barline positions
    for (int i = 0; i < measures.length; i++) {
      final measure = measures[i];
      final measureSpacing = lineSpacing.measureSpacings[i];

      // Draw measure number on first measure if enabled
      if (i == 0 && showMeasureNumbers) {
        _drawMeasureNumber(
          canvas,
          measure.number,
          Offset(currentX, staffY - config.staffSpaceSize * 2),
        );
      }

      final xOffset = currentX - measureSpacing.startX;

      // Draw measure content
      _drawMeasureContent(
        canvas,
        measure,
        measureSpacing,
        staffTopLeft,
        xOffset,
        noteRenderer,
        clef,
      );

      // Calculate and store barline position
      final measureEndX = measureSpacing.endX + xOffset;
      barlinePositions.add(measureEndX);

      currentX = measureEndX + config.measureSpacing;
    }

    // Draw staff lines with correct width
    final staffWidth = currentX - config.leftMargin - config.measureSpacing;
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      staffWidth,
    );
  }

  /// Draw instrument name
  void _drawInstrumentName(Canvas canvas, String name, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: config.staffSpaceSize * 1.5,
          color: config.noteColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width, position.dy - textPainter.height / 2),
    );
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

      double currentX = config.leftMargin;

      // Draw clef, key sig, time sig on first measure of first system
      if (system.isFirstSystem && system.measures.isNotEmpty) {
        final firstMeasure = system.measures.first;

        clefRenderer.paint(canvas, currentX, staffTopLeft.dy, config.clef);
        currentX += 35 + config.staffSpaceSize;

        if (firstMeasure.keySignature.accidentals != 0) {
          keySignatureRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            firstMeasure.keySignature,
            config.clef,
          );
          currentX += keySignatureRenderer.getWidth(firstMeasure.keySignature);
        }

        timeSignatureRenderer.paint(
          canvas,
          currentX,
          staffTopLeft.dy,
          firstMeasure.timeSignature,
        );
        currentX += timeSignatureRenderer.getWidth(firstMeasure.timeSignature) + config.staffSpaceSize;
      } else if (system.measures.isNotEmpty && config.showClefOnEachSystem) {
        clefRenderer.paint(canvas, currentX, staffTopLeft.dy, config.clef);
        currentX += 35 + config.staffSpaceSize * 0.5;
      }

      // Track measure end positions for barlines
      final barlinePositions = <double>[];

      // Draw each measure in this system
      for (int measureIndex = 0; measureIndex < system.measures.length; measureIndex++) {
        final measure = system.measures[measureIndex];
        final measureSpacing = system.spacing.measureSpacings[measureIndex];

        // Draw measure number
        if (config.showMeasureNumbers && measureIndex == 0) {
          _drawMeasureNumber(
            canvas,
            measure.number,
            Offset(currentX, staffY - config.staffSpaceSize * 2),
          );
        }

        final xOffset = currentX - measureSpacing.startX;

        // Draw measure content
        _drawMeasureContent(
          canvas,
          measure,
          measureSpacing,
          staffTopLeft,
          xOffset,
          noteRenderer,
          config.clef,
        );

        // Calculate and store barline position
        final measureEndX = measureSpacing.endX + xOffset;
        barlinePositions.add(measureEndX);

        currentX = measureEndX + config.measureSpacing;
      }

      // Draw staff lines with correct width
      final staffWidth = currentX - config.leftMargin - config.measureSpacing;
      noteRenderer.staffRenderer.paint(
        canvas,
        staffTopLeft,
        staffWidth,
      );

      // Draw barlines at tracked positions
      for (int i = 0; i < system.measures.length; i++) {
        final measure = system.measures[i];
        final barlineX = barlinePositions[i];

        barlineRenderer.paint(
          canvas,
          barlineX,
          staffTopLeft.dy,
          staffTopLeft.dy + staffHeight,
          measure.endBarline,
        );
      }
    }
  }
  /// Paint single line (legacy mode)
  void _paintSingleLine(
      Canvas canvas,
      Size size,
      NoteRenderer noteRenderer,
      ClefRenderer clefRenderer,
      KeySignatureRenderer keySignatureRenderer,
      TimeSignatureRenderer timeSignatureRenderer,
      BarlineRenderer barlineRenderer,
      ) {
    final staffHeight = noteRenderer.staffRenderer.height;
    final staffY = (size.height - staffHeight) / 2;
    final staffTopLeft = Offset(config.leftMargin, staffY);

    double currentX = staffTopLeft.dx;
    final spacingEngine = config.spacingEngine;

    // Calculate staff width
    double finalBarlineX = currentX;

    for (int measureIndex = 0; measureIndex < measures!.length; measureIndex++) {
      final measure = measures![measureIndex];

      if (measure.isFirstMeasure) {
        currentX += 35 + config.staffSpaceSize;
        if (measure.keySignature.accidentals != 0) {
          currentX += keySignatureRenderer.getWidth(measure.keySignature);
        }
        currentX += timeSignatureRenderer.getWidth(measure.timeSignature) + config.staffSpaceSize;
      }

      final measureStartX = currentX;
      final elements = measure.elements;

      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();
      final flatElements = sortedBeats.map((beat) => elementsByBeat[beat]!.first).toList();
      final positions = spacingEngine.calculateSpacing(flatElements, startX: measureStartX);

      final measureEndX = positions.isNotEmpty
          ? positions.last + config.noteWidth
          : measureStartX + config.minMeasureWidth;

      finalBarlineX = measureEndX;
      currentX = measureEndX + config.measureSpacing;
    }

    final staffWidth = finalBarlineX - staffTopLeft.dx + config.staffSpaceSize - 10;
    noteRenderer.staffRenderer.paint(canvas, staffTopLeft, staffWidth);

    // Draw measures
    currentX = staffTopLeft.dx;
    for (int measureIndex = 0; measureIndex < measures!.length; measureIndex++) {
      final measure = measures![measureIndex];
      final seenPitchClasses = <int>{};

      if (measure.isFirstMeasure) {
        clefRenderer.paint(canvas, currentX, staffTopLeft.dy, config.clef);
        currentX += 35 + config.staffSpaceSize;

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

        timeSignatureRenderer.paint(canvas, currentX, staffTopLeft.dy, measure.timeSignature);
        currentX += timeSignatureRenderer.getWidth(measure.timeSignature) + config.staffSpaceSize;
      }

      final measureStartX = currentX;
      final elements = measure.elements;

      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();
      final flatElements = sortedBeats.map((beat) => elementsByBeat[beat]!.first).toList();
      final positions = spacingEngine.calculateSpacing(flatElements, startX: measureStartX);

      for (int i = 0; i < sortedBeats.length; i++) {
        final beat = sortedBeats[i];
        final elementsAtBeat = elementsByBeat[beat]!;
        final xPosition = positions[i];

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
            final needsAccidental = measure.keySignature.needsAccidental(note.pitch);
            final showAccidental = needsAccidental && !seenPitchClasses.contains(pitchClass);

            if (showAccidental) seenPitchClasses.add(pitchClass);

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

      final measureEndX = positions.isNotEmpty
          ? positions.last + config.noteWidth
          : measureStartX + config.minMeasureWidth;

      barlineRenderer.paint(
        canvas,
        measureEndX,
        staffTopLeft.dy,
        staffTopLeft.dy + staffHeight,
        measure.endBarline,
      );

      currentX = measureEndX + config.measureSpacing;
    }
  }

  /// Draw measure content
  void _drawMeasureContent(
      Canvas canvas,
      Measure measure,
      MeasureSpacing measureSpacing,
      Offset staffTopLeft,
      double xOffset,
      NoteRenderer noteRenderer,
      ClefType clef,
      ) {
    final seenPitchClasses = <int>{};
    final elements = measure.elements;

    final elementsByBeat = <double, List<dynamic>>{};
    for (final element in elements) {
      final beat = element is Note ? element.startBeat : (element as Rest).startBeat;
      elementsByBeat.putIfAbsent(beat, () => []).add(element);
    }

    final sortedBeats = elementsByBeat.keys.toList()..sort();

    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final elementsAtBeat = elementsByBeat[beat]!;
      final xPosition = measureSpacing.positionAt(i) + xOffset;

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
          final needsAccidental = measure.keySignature.needsAccidental(note.pitch);
          final showAccidental = needsAccidental && !seenPitchClasses.contains(pitchClass);

          if (showAccidental) seenPitchClasses.add(pitchClass);

          noteRenderer.paintNote(
            canvas,
            note: note,
            staffTopLeft: staffTopLeft,
            xPosition: xPosition,
            clef: clef,
            showAccidental: showAccidental,
            isActive: isActive,
          );
        } else {
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
            clef: clef,
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
        text: '${measureNumber + 1}',
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
        oldDelegate.grandStaff != grandStaff ||
        oldDelegate.config != config;
  }


}