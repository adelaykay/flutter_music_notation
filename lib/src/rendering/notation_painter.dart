// lib/src/rendering/notation_painter.dart

import 'package:flutter/material.dart';
import 'package:flutter_music_notation/src/rendering/stem_renderer.dart';
import '../../flutter_music_notation.dart';
import '../layout/grand_staff_layout.dart';
import 'brace_renderer.dart';
import 'notehead_renderer.dart';

/// CustomPainter that renders musical notation with multi-line support
class NotationPainter extends CustomPainter {
  final List<Measure>? measures;
  final GrandStaff? grandStaff;
  final List<Note>? notes;
  final List<Rest>? rests;
  final NotationConfig config;
  final Set<Note> activeNotes;

  /// Ties that leave one bar and land in the next, keyed by clef and pitch.
  /// Filled while a bar is drawn and consumed by the following bar; reset on
  /// every paint.
  final Map<String, _PendingTie> _pendingTies = {};

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
    _pendingTies.clear();
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
      useSystemLayout: config.useSystemLayout,
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
      final braceTotalHeight =
          (lowerStaffY + noteRenderer.staffRenderer.height) - upperStaffY;

      if (config.showBrace) {
        final braceX =
            config.leftMargin -
            braceRenderer.getWidth(height: braceTotalHeight) -
            config.staffSpaceSize / 4;
        braceRenderer.paint(
          canvas,
          braceX,
          upperStaffY,
          lowerStaffY,
          noteRenderer.staffRenderer.height,
        );
      }

      // Draw shared start barline (e.g. left of the first system, after brace)
      if (system.isFirstSystem &&
          system.upperStaffMeasures.isNotEmpty &&
          system.upperStaffMeasures.first.startBarline != null) {
        barlineRenderer.paint(
          canvas,
          config.leftMargin,
          upperStaffY,
          lowerStaffY + noteRenderer.staffRenderer.height,
          system.upperStaffMeasures.first.startBarline!,
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
        showMeasureNumbers:
            system.showMeasureNumbers && config.showMeasureNumbers,
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
        final isLastMeasure = i == system.upperStaffMeasures.length - 1;
        // Flush the final barline to the right edge when expanding the width
        final barlineX = config.expandWidth && isLastMeasure
            ? system.spacing.lineWidth
            : upperBarlinePositions[i]; // Use tracked position

        final barlineRenderer = BarlineRenderer(
          staffSpaceSize: config.staffSpaceSize,
          color: config.noteColor,
        );

        barlineRenderer.paint(
          canvas,
          barlineX,
          upperStaffY,
          lowerStaffY + noteRenderer.staffRenderer.height,
          measure.endBarline,
        );
      }

      if (system.isFirstSystem && system.instrumentName != null) {
        _drawInstrumentName(
          canvas,
          system.instrumentName!,
          Offset(
            config.leftMargin -
                braceRenderer.getWidth(height: braceTotalHeight) -
                config.staffSpaceSize * 6,
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

    // Content (clef etc.) starts a configurable gap to the right of the
    // staff's left edge (where the start barline sits).
    double currentX = config.leftMargin + config.barlineToClefSpace;
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

      // Time signature
      if (config.showTimeSignature) {
        timeSignatureRenderer.paint(
          canvas,
          currentX,
          staffTopLeft.dy,
          firstMeasure.timeSignature,
        );
        currentX +=
            timeSignatureRenderer.getWidth(firstMeasure.timeSignature) +
            config.staffSpaceSize;
      }

      currentX += config.leadingSpace;
    } else if (measures.isNotEmpty && config.showKeySignatureOnEachSystem) {
      // Add key signature on subsequent systems if configured
      if (config.showKeySignatureOnEachSystem) {
        final firstMeasure = measures.first;
        if (firstMeasure.keySignature.accidentals != 0) {
          keySignatureRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            firstMeasure.keySignature,
            config.clef,
          );
          currentX +=
              keySignatureRenderer.getWidth(firstMeasure.keySignature) +
              config.clefNoteMargin;
        }
      }
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

    // Draw staff lines with correct width
    final staffWidth = config.expandWidth
        ? lineSpacing.lineWidth - config.leftMargin
        : currentX - config.leftMargin - config.measureSpacing;
    noteRenderer.staffRenderer.paint(canvas, staffTopLeft, staffWidth);
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
      Offset(
        position.dx - textPainter.width,
        position.dy - textPainter.height / 2,
      ),
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

      // Content starts a configurable gap to the right of the staff's left edge.
      double currentX = config.leftMargin + config.barlineToClefSpace;

      if (system.isFirstSystem && system.measures.isNotEmpty) {
        final firstMeasure = system.measures.first;

        if (firstMeasure.startBarline != null) {
          barlineRenderer.paint(
            canvas,
            config.leftMargin,
            staffTopLeft.dy,
            staffTopLeft.dy + staffHeight,
            firstMeasure.startBarline!,
          );
        }

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

        if (config.showTimeSignature) {
          timeSignatureRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            firstMeasure.timeSignature,
          );
          currentX +=
              timeSignatureRenderer.getWidth(firstMeasure.timeSignature) +
              config.staffSpaceSize;
        }
        currentX += config.leadingSpace;
      } else if (system.measures.isNotEmpty && config.showClefOnEachSystem) {
        clefRenderer.paint(canvas, currentX, staffTopLeft.dy, config.clef);
        currentX += 35 + config.clefNoteMargin;
      }

      final barlinePositions = <double>[];

      for (
        int measureIndex = 0;
        measureIndex < system.measures.length;
        measureIndex++
      ) {
        final measure = system.measures[measureIndex];
        final measureSpacing = system.spacing.measureSpacings[measureIndex];

        if (config.showMeasureNumbers && measureIndex == 0) {
          _drawMeasureNumber(
            canvas,
            measure.number,
            Offset(currentX, staffY - config.staffSpaceSize * 2),
          );
        }

        // Show key signature on non-first systems if configured
        if (!system.isFirstSystem &&
            measureIndex == 0 &&
            config.showKeySignatureOnEachSystem) {
          if (measure.keySignature.accidentals != 0) {
            keySignatureRenderer.paint(
              canvas,
              currentX,
              staffTopLeft.dy,
              measure.keySignature,
              config.clef,
            );
            currentX +=
                keySignatureRenderer.getWidth(measure.keySignature) +
                config.clefNoteMargin;
          }
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
        final isLastMeasure = measureIndex == system.measures.length - 1;
        final barlineX = config.expandWidth && isLastMeasure
            ? system.spacing.lineWidth
            : measureEndX;
        barlinePositions.add(barlineX);

        currentX = measureEndX + config.measureSpacing;
      }

      // Draw staff lines with correct width
      final staffWidth = config.expandWidth
          ? system.spacing.lineWidth - config.leftMargin
          : currentX - config.leftMargin - config.measureSpacing;
      noteRenderer.staffRenderer.paint(canvas, staffTopLeft, staffWidth);

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

    // Content starts a configurable gap to the right of the staff's left edge
    // (where a start barline sits).
    double currentX = staffTopLeft.dx + config.barlineToClefSpace;
    final spacingEngine = config.spacingEngine;

    // Calculate total width needed
    double finalBarlineX = currentX;

    for (
      int measureIndex = 0;
      measureIndex < measures!.length;
      measureIndex++
    ) {
      final measure = measures![measureIndex];

      if (measure.isFirstMeasure) {
        currentX += 35 + config.staffSpaceSize;
        if (measure.keySignature.accidentals != 0) {
          currentX += keySignatureRenderer.getWidth(measure.keySignature);
        }
        if (config.showTimeSignature) {
          currentX +=
              timeSignatureRenderer.getWidth(measure.timeSignature) +
              config.staffSpaceSize;
        }
        currentX += config.leadingSpace;
      }

      final measureStartX = currentX;
      final elements = measure.elements;

      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note
            ? element.startBeat
            : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();
      final flatElements = sortedBeats
          .map((beat) => elementsByBeat[beat]!.first)
          .toList();
      final positions = spacingEngine.calculateSpacing(
        flatElements,
        startX: measureStartX,
        staffSpaceSize: config.staffSpaceSize,
        clef: config.clef,
        keySignature: measure.keySignature,
      );

      double lastNoteWidth = config.noteWidth;
      if (flatElements.isNotEmpty) {
        final last = flatElements.last;
        if (last is Note) {
          lastNoteWidth =
              CollisionDetector.calculateNoteWidthStatic(
                last,
                measure.keySignature.needsAccidental(last.pitch),
                config.staffSpaceSize,
              ) +
              config.staffSpaceSize;
        }
      }

      final measureEndX = positions.isNotEmpty
          ? positions.last + lastNoteWidth
          : measureStartX + config.minMeasureWidth;

      finalBarlineX = measureEndX;
      currentX = measureEndX + config.measureSpacing;
    }

    final staffWidth =
        finalBarlineX - staffTopLeft.dx + config.staffSpaceSize - 10;

    // Notify about the total width for scrolling
    if (size.width < staffWidth + config.leftMargin + config.rightMargin) {
      // In a real scenario, we might want to pass this width back to the widget
    }

    noteRenderer.staffRenderer.paint(canvas, staffTopLeft, staffWidth);

    // Draw measures with Phase 6 features
    currentX = staffTopLeft.dx + config.barlineToClefSpace;
    for (
      int measureIndex = 0;
      measureIndex < measures!.length;
      measureIndex++
    ) {
      final measure = measures![measureIndex];

      if (measure.isFirstMeasure) {
        if (measure.startBarline != null) {
          barlineRenderer.paint(
            canvas,
            staffTopLeft.dx,
            staffTopLeft.dy,
            staffTopLeft.dy + staffHeight,
            measure.startBarline!,
          );
        }
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

        if (config.showTimeSignature) {
          timeSignatureRenderer.paint(
            canvas,
            currentX,
            staffTopLeft.dy,
            measure.timeSignature,
          );
          currentX +=
              timeSignatureRenderer.getWidth(measure.timeSignature) +
              config.staffSpaceSize;
        }
        currentX += config.leadingSpace;
      }

      final measureStartX = currentX;
      final elements = measure.elements;

      final elementsByBeat = <double, List<dynamic>>{};
      for (final element in elements) {
        final beat = element is Note
            ? element.startBeat
            : (element as Rest).startBeat;
        elementsByBeat.putIfAbsent(beat, () => []).add(element);
      }

      final sortedBeats = elementsByBeat.keys.toList()..sort();
      final flatElements = sortedBeats
          .map((beat) => elementsByBeat[beat]!.first)
          .toList();
      final positions = spacingEngine.calculateSpacing(
        flatElements,
        startX: measureStartX,
        staffSpaceSize: config.staffSpaceSize,
        clef: config.clef,
        keySignature: measure.keySignature,
      );

      double lastNoteWidth = config.noteWidth;
      if (flatElements.isNotEmpty) {
        final last = flatElements.last;
        if (last is Note) {
          lastNoteWidth =
              CollisionDetector.calculateNoteWidthStatic(
                last,
                measure.keySignature.needsAccidental(last.pitch),
                config.staffSpaceSize,
              ) +
              config.staffSpaceSize;
        }
      }

      // Create a fake MeasureSpacing for _drawMeasureContent
      final measureSpacing = MeasureSpacing(
        positions: positions,
        totalWidth: positions.isNotEmpty
            ? positions.last - positions.first
            : config.minMeasureWidth,
        startX: measureStartX,
        endX: positions.isNotEmpty
            ? positions.last + lastNoteWidth
            : measureStartX + config.minMeasureWidth,
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

      final measureEndX = measureSpacing.endX;

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
    final elements = measure.elements;
    final accidentalNotes = measure.keySignature.notesNeedingAccidentals(
      elements.whereType<Note>(),
    );

    final elementsByBeat = <double, List<dynamic>>{};
    for (final element in elements) {
      final beat = element is Note
          ? element.startBeat
          : (element as Rest).startBeat;
      elementsByBeat.putIfAbsent(beat, () => []).add(element);
    }

    final sortedBeats = elementsByBeat.keys.toList()..sort();

    // Phase 6: Get beam groups, ties, slurs, tuplets
    final beamGroups = measure.beamGroups;
    final ties = config.enableTieDetection
        ? measure.tiesInMeasure
        : measure.explicitTiesInMeasure;
    final slurs = measure.slursInMeasure;
    final tuplets = measure.tupletsInMeasure;

    // Track which notes are beamed
    final beamedNotes = <Note>{};
    for (final beamGroup in beamGroups) {
      beamedNotes.addAll(beamGroup.notes);
    }

    // Draw elements
    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final elementsAtBeat = elementsByBeat[beat]!;
      final xPosition = measureSpacing.positionAt(i) + xOffset;

      // Group notes by voice for SATB/multi-voice support
      final voicesAtBeat = <int, List<Note>>{};
      final restsAtBeat = <Rest>[];

      for (final element in elementsAtBeat) {
        if (element is Note) {
          voicesAtBeat.putIfAbsent(element.voice, () => []).add(element);
        } else if (element is Rest) {
          restsAtBeat.add(element);
        }
      }

      // Draw rests
      for (final rest in restsAtBeat) {
        noteRenderer.paintRest(
          canvas,
          rest: rest,
          staffTopLeft: staffTopLeft,
          xPosition: xPosition,
        );
      }

      // Draw each voice separately if they have different voices or explicit stem directions
      // If multiple notes share the same voice, they are treated as a chord
      for (final voice in voicesAtBeat.keys) {
        final notesInVoice = voicesAtBeat[voice]!;

        // Skip if all notes in this voice are beamed
        if (config.enableBeaming &&
            notesInVoice.every((n) => beamedNotes.contains(n))) {
          continue;
        }

        if (notesInVoice.length == 1) {
          final note = notesInVoice.first;
          final isActive = activeNotes.contains(note);
          final showAccidental = accidentalNotes.contains(note);

          // Determine stem direction: explicit -> voice-based -> auto
          StemDirection stemDir = note.stemDirection ?? StemDirection.auto;
          if (stemDir == StemDirection.auto) {
            // SATB defaults:
            // Voice 0 (Soprano/Treble Top) -> Up
            // Voice 1 (Alto/Treble Bottom) -> Down
            // Voice 2 (Tenor/Bass Top) -> Up
            // Voice 3 (Bass/Bass Bottom) -> Down
            if (voice == 0 || voice == 2) {
              stemDir = StemDirection.up;
            } else if (voice == 1 || voice == 3) {
              stemDir = StemDirection.down;
            } else {
              stemDir = StemRenderer.determineStemDirection(
                StaffPosition.forPitch(note.pitch, clef),
              );
            }
          }

          noteRenderer.paintNote(
            canvas,
            note: note,
            staffTopLeft: staffTopLeft,
            xPosition: xPosition,
            clef: clef,
            showAccidental: showAccidental,
            isActive: isActive,
            isBeamed: false,
            stemDirection: stemDir,
          );
        } else {
          final chord = Chord(notes: notesInVoice);
          final isActive = notesInVoice.any((n) => activeNotes.contains(n));
          final chordAccidentals = <int>{};

          for (final note in notesInVoice) {
            if (accidentalNotes.contains(note)) {
              chordAccidentals.add(note.pitch.midiNumber);
            }
          }

          // Determine stem direction for the voice
          StemDirection stemDir =
              notesInVoice.first.stemDirection ?? StemDirection.auto;
          if (stemDir == StemDirection.auto) {
            if (voice == 0 || voice == 2) {
              stemDir = StemDirection.up;
            } else if (voice == 1 || voice == 3) {
              stemDir = StemDirection.down;
            } else {
              stemDir = StemRenderer.determineStemDirectionForChord(
                notesInVoice
                    .map((n) => StaffPosition.forPitch(n.pitch, clef))
                    .toList(),
              );
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
            stemDirection: stemDir,
          );
        }
      }
    }

    // Draw beam groups with properly calculated stem ends
    if (config.enableBeaming) {
      for (final beamGroup in beamGroups) {
        final beamNotes = beamGroup.notes;
        final xPositions = <double>[];
        final showAccidentals = <int, bool>{};
        final noteheadCenters = <Offset>[];
        final staffPositions = <StaffPosition>[];

        for (final note in beamNotes) {
          final beatIndex = sortedBeats.indexOf(note.startBeat);
          if (beatIndex >= 0) {
            final x = measureSpacing.positionAt(beatIndex) + xOffset;
            xPositions.add(x);

            // Calculate staff position and notehead center
            final staffPos = StaffPosition.forPitch(note.pitch, clef);
            final y = noteRenderer.staffRenderer.positionToY(staffPos);
            noteheadCenters.add(Offset(x, staffTopLeft.dy + y));
            staffPositions.add(staffPos);

            showAccidentals[note.pitch.midiNumber] = accidentalNotes.contains(
              note,
            );
          }
        }

        if (xPositions.length == beamNotes.length) {
          // Calculate proper stem direction
          final stemDirection = StemRenderer.determineStemDirectionForChord(
            staffPositions,
          );

          // Calculate stem ends using the beam renderer's method
          final stemEnds = noteRenderer.beamRenderer.calculateStemEnds(
            beamNotes,
            noteheadCenters,
            staffPositions,
            stemDirection,
          );

          // Draw noteheads and accidentals first
          for (int i = 0; i < beamNotes.length; i++) {
            final note = beamNotes[i];
            final noteCenter = noteheadCenters[i];
            final staffPos = staffPositions[i];
            final isActive = activeNotes.contains(note);
            final showAccidental =
                showAccidentals[note.pitch.midiNumber] ?? false;

            // Draw ledger lines
            noteRenderer.staffRenderer.paintLedgerLines(
              canvas,
              noteCenter,
              staffPos,
            );

            // Draw accidental if needed
            if (showAccidental && note.pitch.accidental != Accidental.natural) {
              noteRenderer.accidentalRenderer.paint(
                canvas,
                noteCenter,
                note.pitch.accidental,
              );
            }

            // Draw notehead
            final filled = NoteheadRenderer.shouldBeFilled(note.duration);
            noteRenderer.noteheadRenderer.paint(
              canvas,
              noteCenter,
              filled: filled,
              isActive: isActive,
            );

            // Draw dots if needed
            if (note.duration.dots > 0) {
              noteRenderer.dotRenderer.paintNoteDots(
                canvas,
                noteCenter,
                staffPos,
                note.duration.dots,
              );
            }
          }

          // Draw stems
          for (int i = 0; i < beamNotes.length; i++) {
            final noteCenter = noteheadCenters[i];
            final isActive = activeNotes.contains(beamNotes[i]);

            noteRenderer.stemRenderer.paint(
              canvas,
              noteCenter,
              direction: stemDirection,
              isActive: isActive,
            );
          }

          // Draw beams
          noteRenderer.beamRenderer.paintBeamGroup(
            canvas,
            beamGroup,
            stemEnds,
            stemDirection,
          );
        }
      }
    }

    // Draw ties with CORRECTED direction logic
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

        // FIXED: Inverted logic - notes BELOW middle (value < 4) curve up
        final direction = startStaffPos.value < 4.0
            ? CurveDirection.down
            : CurveDirection.up;

        tieRenderer.paintTie(canvas, tie, startCenter, endCenter, direction);
      }
    }

    // Ties that cross the barline: finish the ones arriving from the previous
    // bar, then record the ones leaving this bar.
    final measureNotes = elements.whereType<Note>().toList();
    final explicitTieStarts = Set<Note>.identity()
      ..addAll(ties.map((t) => t.startNote));
    final arriving = Map.of(_pendingTies)
      ..removeWhere((key, _) => !key.startsWith('${clef.name}:'));
    _pendingTies.removeWhere((key, _) => key.startsWith('${clef.name}:'));

    Offset centerOf(Note note) {
      final index = sortedBeats.indexOf(note.startBeat);
      final pos = StaffPosition.forPitch(note.pitch, clef);
      return Offset(
        measureSpacing.positionAt(index < 0 ? 0 : index) + xOffset,
        staffTopLeft.dy + noteRenderer.staffRenderer.positionToY(pos),
      );
    }

    for (final note in measureNotes) {
      if (note.startBeat > 0.001) continue;
      final pending = arriving['${clef.name}:${note.pitch.midiNumber}'];
      if (pending == null) continue;
      final end = centerOf(note);
      final tie = Tie(startNote: pending.note, endNote: note);
      if ((pending.center.dy - end.dy).abs() < 0.5) {
        tieRenderer.paintTie(
          canvas,
          tie,
          pending.center,
          end,
          pending.direction,
        );
      } else {
        // The tie crosses a line break: draw it as two halves.
        final half = config.staffSpaceSize * 2.5;
        tieRenderer.paintTie(
          canvas,
          tie,
          pending.center,
          pending.center.translate(half, 0),
          pending.direction,
        );
        tieRenderer.paintTie(
          canvas,
          tie,
          end.translate(-half, 0),
          end,
          pending.direction,
        );
      }
    }

    for (final note in measureNotes) {
      if (!note.tieToNext || explicitTieStarts.contains(note)) continue;
      final pos = StaffPosition.forPitch(note.pitch, clef);
      _pendingTies['${clef.name}:${note.pitch.midiNumber}'] = _PendingTie(
        note,
        centerOf(note),
        pos.value < 4.0 ? CurveDirection.down : CurveDirection.up,
      );
    }

    // Draw slurs with CORRECTED direction logic
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
        // FIXED: Calculate direction properly
        final avgPosition =
            staffPositions.reduce((a, b) => a + b) / staffPositions.length;

        // Notes BELOW middle (value < 4) should curve up
        final direction = avgPosition < 4.0
            ? CurveDirection.down
            : CurveDirection.up;

        slurRenderer.paintSlur(canvas, slur, noteheadCenters, direction);
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

        tupletRenderer.paintTuplet(canvas, tuplet, notePositions, direction);
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

  void _paintLegacyNotes(Canvas canvas, Size size) {
    if (notes == null || notes!.isEmpty) return;

    final noteRenderer = NoteRenderer(
      staffSpaceSize: config.staffSpaceSize,
      color: config.noteColor,
    );

    final staffHeight = noteRenderer.staffRenderer.height;
    final staffY = (size.height - staffHeight) / 2;
    final staffTopLeft = Offset(config.leftMargin, staffY);

    noteRenderer.staffRenderer.paint(
      canvas,
      staffTopLeft,
      size.width - config.leftMargin - 20,
    );

    // No key signature in this mode: accidentals follow C major bar rules.
    final accidentalNotes = KeySignature.cMajor.notesNeedingAccidentals(notes!);
    final allElements = <dynamic>[...notes!, ...?rests];
    allElements.sort((a, b) {
      final aStart = a is Note ? a.startBeat : (a as Rest).startBeat;
      final bStart = b is Note ? b.startBeat : (b as Rest).startBeat;
      return aStart.compareTo(bStart);
    });

    final elementsByBeat = <double, List<dynamic>>{};
    for (final element in allElements) {
      final beat = element is Note
          ? element.startBeat
          : (element as Rest).startBeat;
      elementsByBeat.putIfAbsent(beat, () => []).add(element);
    }

    final sortedBeats = elementsByBeat.keys.toList()..sort();

    for (int i = 0; i < sortedBeats.length; i++) {
      final beat = sortedBeats[i];
      final elementsAtBeat = elementsByBeat[beat]!;

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

          final showAccidental = accidentalNotes.contains(note);

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
            if (accidentalNotes.contains(note)) {
              chordAccidentals.add(note.pitch.midiNumber);
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

/// A tie leaving a bar, waiting for its end note in the next bar.
class _PendingTie {
  const _PendingTie(this.note, this.center, this.direction);
  final Note note;
  final Offset center;
  final CurveDirection direction;
}
