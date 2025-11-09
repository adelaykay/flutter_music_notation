// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import '../models/grand_staff.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../models/measure.dart';
import '../models/slur.dart';
import '../widgets/notation_view.dart';
import '../layout/spacing_engine.dart';
import '../layout/system_layout.dart';
import '../layout/grand_staff_layout.dart';
import 'brace_renderer.dart';
import 'tuplet_renderer.dart';
import 'note_renderer.dart';
import 'clef_renderer.dart';
import 'tie_renderer.dart';
import 'slur_renderer.dart';
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

    for (final system in scoreLayout.systems) {
      final upperStaffY = system.upperStaffY;
      final lowerStaffY = system.lowerStaffY;

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

      final upperBarlinePositions = <double>[];
      final lowerBarlinePositions = <double>[];

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
        showMeasureNumbers: false,
        barlinePositions: lowerBarlinePositions,
      );

      for (int i = 0; i < system.upperStaffMeasures.length; i++) {
        final measure = system.upperStaffMeasures[i];
        final barlineX = upperBarlinePositions[i];

        final barlineRenderer = BarlineRenderer(
          staffSpaceSize: config.staffSpaceSize,
          color: config.noteColor,
        );

        barlineRenderer.paint(
          canvas,
          barlineX,
          upperStaffY,
          lowerStaffY + config.lowerStaffHeight,
          measure.endBarline,
        );
      }

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
    clefRenderer.paint(canvas, currentX, staffTopLeft.dy, clef);
    currentX += 35 + config.staffSpaceSize;

    if (isFirstSystem && measures.isNotEmpty) {
      final firstMeasure = measures.first;

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

      timeSignatureRenderer.paint(
        canvas,
        currentX,
        staffTopLeft.dy,
        firstMeasure.timeSignature,
      );
      currentX += timeSignatureRenderer.getWidth(firstMeasure.timeSignature) + config.staffSpaceSize;
    }

    for (int i = 0; i < measures.length; i++) {
      final measure = measures[i];
      final measureSpacing = lineSpacing.measureSpacings[i];

      if (i == 0 && showMeasureNumbers) {
        _drawMeasureNumber(
          canvas,
          measure.number,
          Offset(currentX, staffY - config.staffSpaceSize * 2),
        );
      }

      final xOffset = currentX - measureSpacing.startX;

      _drawMeasureContent(
        canvas,
        measure,
        measureSpacing,
        staffTopLeft,
        xOffset,
        noteRenderer,
        clef,
      );

      final measureEndX = measureSpacing.endX + xOffset;
      barlinePositions.add(measureEndX);

      currentX = measureEndX + config.measureSpacing;
    }

    final staffWidth = currentX - config.leftMargin - config.measureSpacing;
    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      staffWidth,
    );
  }

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

  void _paintMeasuresMultiLine(Canvas canvas, Size size) {
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
      // FIXED: Use Phase 6 rendering in single-line mode too
      _paintSingleLineWithPhase6(
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

  void _paintWithSystemLayout(
      Canvas canvas,
      Size size,
      NoteRenderer noteRenderer,
      ClefRenderer clefRenderer,
      KeySignatureRenderer keySignatureRenderer,
      TimeSignatureRenderer timeSignatureRenderer,
      BarlineRenderer barlineRenderer,
      ) {
    final systemLayout = SystemLayout(
      spacingEngine: config.spacingEngine,
      systemHeight: config.systemHeight,
      systemSpacing: config.systemSpacing,
      showMeasureNumbers: config.showMeasureNumbers,
    );

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

    for (final system in scoreLayout.systems) {
      final staffY = system.yPosition;
      final staffTopLeft = Offset(config.leftMargin, staffY);

      double currentX = config.leftMargin;

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

      final barlinePositions = <double>[];

      for (int measureIndex = 0; measureIndex < system.measures.length; measureIndex++) {
        final measure = system.measures[measureIndex];
        final measureSpacing = system.spacing.measureSpacings[measureIndex];

        if (config.showMeasureNumbers && measureIndex == 0) {
          _drawMeasureNumber(
            canvas,
            measure.number,
            Offset(currentX, staffY - config.staffSpaceSize * 2),
          );
        }

        final xOffset = currentX - measureSpacing.startX;

        _drawMeasureContent(
          canvas,
          measure,
          measureSpacing,
          staffTopLeft,
          xOffset,
          noteRenderer,
          config.clef,
        );

        final measureEndX = measureSpacing.endX + xOffset;
        barlinePositions.add(measureEndX);

        currentX = measureEndX + config.measureSpacing;
      }

      final staffWidth = currentX - config.leftMargin - config.measureSpacing;
      noteRenderer.staffRenderer.paint(
        canvas,
        staffTopLeft,
        staffWidth,
      );

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

  /// NEW: Single-line rendering with Phase 6 features
  void _paintSingleLineWithPhase6(
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

    // Calculate total width needed
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

    // Draw measures with Phase 6 features
    currentX = staffTopLeft.dx;
    for (int measureIndex = 0; measureIndex < measures!.length; measureIndex++) {
      final measure = measures![measureIndex];

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

      // Create a fake MeasureSpacing for _drawMeasureContent
      final measureSpacing = MeasureSpacing(
        positions: positions,
        totalWidth: positions.isNotEmpty ? positions.last - positions.first : config.minMeasureWidth,
        startX: measureStartX,
        endX: positions.isNotEmpty ? positions.last + config.noteWidth : measureStartX + config.minMeasureWidth,
      );

      // Use Phase 6 rendering
      _drawMeasureContent(
        canvas,
        measure,
        measureSpacing,
        staffTopLeft,
        0, // No offset needed since positions are already absolute
        noteRenderer,
        config.clef,
      );

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

  /// Draw measure content with Phase 6 features (beaming, ties, slurs, tuplets)
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

    // Phase 6: Get beam groups, ties, slurs, tuplets
    final beamGroups = measure.beamGroups;
    final ties = measure.tiesInMeasure;
    final slurs = measure.slursInMeasure;
    final tuplets = measure.tupletsInMeasure;

    // Track which notes are beamed
    final beamedNotes = <Note>{};
    for (final beamGroup in beamGroups) {
      beamedNotes.addAll(beamGroup.notes);
    }

    // Draw non-beamed notes and rests
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

        // Skip if these notes are beamed
        if (notesAtBeat.every((n) => beamedNotes.contains(n))) {
          continue;
        }

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
            isBeamed: false,
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
            isBeamed: false,
          );
        }
      }
    }

    // Draw beam groups
    for (final beamGroup in beamGroups) {
      final beamNotes = beamGroup.notes;
      final xPositions = <double>[];
      final showAccidentals = <int, bool>{};

      for (final note in beamNotes) {
        final beatIndex = sortedBeats.indexOf(note.startBeat);
        if (beatIndex >= 0) {
          xPositions.add(measureSpacing.positionAt(beatIndex) + xOffset);

          final pitchClass = note.pitch.midiNumber % 12;
          final needsAccidental = measure.keySignature.needsAccidental(note.pitch);
          final showAccidental = needsAccidental && !seenPitchClasses.contains(pitchClass);

          showAccidentals[note.pitch.midiNumber] = showAccidental;
          if (showAccidental) seenPitchClasses.add(pitchClass);
        }
      }

      if (xPositions.length == beamNotes.length) {
        noteRenderer.paintBeamGroup(
          canvas,
          beamGroup,
          staffTopLeft,
          xPositions,
          clef,
          showAccidentals,
          activeNotes,
        );
      }
    }

    // Draw ties
    final tieRenderer = TieRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    for (final tie in ties) {
      final startIndex = sortedBeats.indexOf(tie.startNote.startBeat);
      final endIndex = sortedBeats.indexOf(tie.endNote.startBeat);

      if (startIndex >= 0 && endIndex >= 0) {
        final startX = measureSpacing.positionAt(startIndex) + xOffset;
        final endX = measureSpacing.positionAt(endIndex) + xOffset;

        final startStaffPos = StaffPosition.forPitch(tie.startNote.pitch, clef);
        final endStaffPos = StaffPosition.forPitch(tie.endNote.pitch, clef);

        final startY = noteRenderer.staffRenderer.positionToY(startStaffPos);
        final endY = noteRenderer.staffRenderer.positionToY(endStaffPos);

        final startCenter = Offset(startX, staffTopLeft.dy + startY);
        final endCenter = Offset(endX, staffTopLeft.dy + endY);

        final direction = startStaffPos.value > 4.0
            ? CurveDirection.down
            : CurveDirection.up;

        tieRenderer.paintTie(
          canvas,
          tie,
          startCenter,
          endCenter,
          direction,
        );
      }
    }

    // Draw slurs
    final slurRenderer = SlurRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    for (final slur in slurs) {
      final noteheadCenters = <Offset>[];
      final staffPositions = <double>[];

      for (final note in slur.notes) {
        final beatIndex = sortedBeats.indexOf(note.startBeat);
        if (beatIndex >= 0) {
          final x = measureSpacing.positionAt(beatIndex) + xOffset;
          final staffPos = StaffPosition.forPitch(note.pitch, clef);
          final y = noteRenderer.staffRenderer.positionToY(staffPos);

          noteheadCenters.add(Offset(x, staffTopLeft.dy + y));
          staffPositions.add(staffPos.value);
        }
      }

      if (noteheadCenters.length >= 2) {
        final direction = CurveCalculator.calculateOptimalDirection(
          slur.notes,
          staffPositions,
        );

        slurRenderer.paintSlur(
          canvas,
          slur,
          noteheadCenters,
          direction,
        );
      }
    }

    // Draw tuplets
    final tupletRenderer = TupletRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    for (final tuplet in tuplets) {
      final notePositions = <Offset>[];
      final staffPositions = <double>[];

      for (final note in tuplet.notes) {
        final beatIndex = sortedBeats.indexOf(note.startBeat);
        if (beatIndex >= 0) {
          final x = measureSpacing.positionAt(beatIndex) + xOffset;
          final staffPos = StaffPosition.forPitch(note.pitch, clef);
          final y = noteRenderer.staffRenderer.positionToY(staffPos);

          notePositions.add(Offset(x, staffTopLeft.dy + y));
          staffPositions.add(staffPos.value);
        }
      }

      if (notePositions.length >= 2) {
        final direction = tuplet.calculateDirection(staffPositions);

        tupletRenderer.paintTuplet(
          canvas,
          tuplet,
          notePositions,
          direction,
        );
      }
    }
  }

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