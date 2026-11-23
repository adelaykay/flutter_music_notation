// lib/src/layout/grand_staff_layout.dart

import '../../flutter_music_notation.dart';

/// Manages layout for grand staff (two staves connected)
class GrandStaffLayout {
  final SpacingEngine spacingEngine;
  final double upperStaffHeight;
  final double lowerStaffHeight;
  final double staffGap; // Space between upper and lower staff
  final double systemSpacing; // Space between systems
  final bool showMeasureNumbers;
  final bool useSystemLayout;

  const GrandStaffLayout({
    required this.spacingEngine,
    this.upperStaffHeight = 40.0, // 4 * staffSpaceSize typically
    this.lowerStaffHeight = 40.0,
    this.staffGap = 60.0,
    this.systemSpacing = 80.0,
    this.showMeasureNumbers = true,
    this.useSystemLayout = false,
  });

  /// Total height of one grand staff system (both staves + gap)
  double get totalSystemHeight =>
      upperStaffHeight + staffGap + lowerStaffHeight;

  /// Lays out [grandStaff] exactly as [NotationPainter] draws it with
  /// [config] at [pageWidth]. Use it to size a view before painting.
  static GrandStaffScoreLayout forConfig(
    GrandStaff grandStaff,
    NotationConfig config,
    double pageWidth,
  ) {
    return GrandStaffLayout(
      spacingEngine: config.spacingEngine,
      upperStaffHeight: config.upperStaffHeight,
      lowerStaffHeight: config.lowerStaffHeight,
      staffGap: config.grandStaffGap,
      systemSpacing: config.systemSpacing,
      showMeasureNumbers: config.showMeasureNumbers,
      useSystemLayout: config.useSystemLayout,
    ).calculateLayout(
      grandStaff,
      pageWidth: pageWidth,
      leftMargin: config.leftMargin,
      rightMargin: config.rightMargin,
      topMargin: config.topMargin,
      measureSpacing: config.measureSpacing,
      lineBreakConfig: config.lineBreakConfig,
      staffSpaceSize: config.staffSpaceSize,
      prefixWidth: (first, firstSystem) =>
          systemPrefixWidth(config, first, firstSystem: firstSystem),
      justifyLastLine: config.expandWidth,
    );
  }

  /// The elements of both staves of a bar, one per beat, sorted by beat. Both
  /// staves share this grid, so a beat on either staff gets its own column
  /// and the two staves line up.
  static List<dynamic> unionByBeat(Measure upper, Measure lower) {
    final byBeat = <double, dynamic>{};
    for (final element in [...upper.elements, ...lower.elements]) {
      final beat = element is Note
          ? element.startBeat
          : (element as Rest).startBeat;
      final had = byBeat[beat];
      // Prefer a note over a rest: it decides the column's width.
      if (had == null || (had is Rest && element is Note)) {
        byBeat[beat] = element;
      }
    }
    final beats = byBeat.keys.toList()..sort();
    return [for (final beat in beats) byBeat[beat]];
  }

  static double _beatOf(dynamic e) =>
      e is Note ? e.startBeat : (e as Rest).startBeat;

  /// Calculate complete layout for a grand staff score.
  ///
  /// Bars are measured with both staves together, at [staffSpaceSize]. Each
  /// system reserves [prefixWidth] for its clef, key and time signatures, so a
  /// full system ends at `pageWidth - rightMargin` and never runs past it.
  GrandStaffScoreLayout calculateLayout(
    GrandStaff grandStaff, {
    required double pageWidth,
    required double leftMargin,
    required double rightMargin,
    required double topMargin,
    required double measureSpacing,
    LineBreakConfig? lineBreakConfig,
    double staffSpaceSize = 12.0,
    double Function(Measure first, bool firstSystem)? prefixWidth,
    bool justifyLastLine = false,
  }) {
    if (grandStaff.isEmpty) {
      return const GrandStaffScoreLayout(systems: [], totalHeight: 0);
    }

    final upper = grandStaff.upperStaff, lower = grandStaff.lowerStaff;
    final n = upper.length;
    final union = [for (var i = 0; i < n; i++) unionByBeat(upper[i], lower[i])];
    final widths = [
      for (var i = 0; i < n; i++)
        spacingEngine.calculateMinimumMeasureWidth(
          union[i],
          staffSpaceSize: staffSpaceSize,
          keySignature: upper[i].keySignature,
        ),
    ];
    double pre(int i, bool first) => prefixWidth?.call(upper[i], first) ?? 0;
    final maxPerLine = useSystemLayout
        ? (lineBreakConfig?.maxMeasuresPerLine ?? 6).floor().clamp(1, n)
        : n;

    // Greedy: fill each system as far as it fits, at least one bar.
    final lines = <List<int>>[];
    var start = 0;
    while (start < n) {
      final avail =
          pageWidth - leftMargin - rightMargin - pre(start, lines.isEmpty);
      var used = 0.0;
      var end = start;
      while (end < n) {
        final w = widths[end] + (end > start ? measureSpacing : 0);
        if (end > start &&
            useSystemLayout &&
            (used + w > avail || end - start >= maxPerLine)) {
          break;
        }
        used += w;
        end++;
      }
      lines.add([for (var i = start; i < end; i++) i]);
      start = end;
    }

    final systems = <GrandStaffSystemInfo>[];
    double currentY = topMargin;
    for (var li = 0; li < lines.length; li++) {
      final idx = lines[li];
      final first = li == 0;
      final lineSpacing = spacingEngine.calculateLineSpacing(
        [
          for (final i in idx)
            MeasureElements(
              elements: union[i],
              measureNumber: upper[i].number,
              keySignature: upper[i].keySignature,
              clef: ClefType.treble, // treble as the reference for spacing
            ),
        ],
        leftMargin + pre(idx.first, first),
        pageWidth - rightMargin,
        measureSpacing,
        staffSpaceSize: staffSpaceSize,
        isLastLine: li == lines.length - 1 && !justifyLastLine,
      );
      systems.add(
        GrandStaffSystemInfo(
          upperStaffMeasures: [for (final i in idx) upper[i]],
          lowerStaffMeasures: [for (final i in idx) lower[i]],
          spacingBeats: [
            for (final i in idx) [for (final e in union[i]) _beatOf(e)],
          ],
          systemNumber: li,
          yPosition: currentY,
          upperStaffHeight: upperStaffHeight,
          lowerStaffHeight: lowerStaffHeight,
          staffGap: staffGap,
          spacing: lineSpacing,
          showClef: first,
          showMeasureNumbers: showMeasureNumbers,
          instrumentName: first
              ? grandStaff.instrumentName
              : grandStaff.instrumentAbbreviation,
        ),
      );
      currentY += totalSystemHeight + systemSpacing;
    }

    final totalHeight = currentY - systemSpacing + topMargin;
    return GrandStaffScoreLayout(systems: systems, totalHeight: totalHeight);
  }
}

/// Complete layout information for a grand staff score
class GrandStaffScoreLayout {
  final List<GrandStaffSystemInfo> systems;
  final double totalHeight;

  const GrandStaffScoreLayout({
    required this.systems,
    required this.totalHeight,
  });

  /// Get system at a specific index
  GrandStaffSystemInfo? getSystem(int index) {
    if (index < 0 || index >= systems.length) return null;
    return systems[index];
  }

  /// Total number of systems
  int get systemCount => systems.length;

  /// Find which system contains a specific measure
  GrandStaffSystemInfo? findSystemForMeasure(int measureNumber) {
    for (final system in systems) {
      if (system.containsMeasure(measureNumber)) {
        return system;
      }
    }
    return null;
  }
}

/// Information about a single grand staff system
class GrandStaffSystemInfo {
  final List<Measure> upperStaffMeasures;
  final List<Measure> lowerStaffMeasures;
  final int systemNumber;
  final double yPosition;
  final double upperStaffHeight;
  final double lowerStaffHeight;
  final double staffGap;
  final LineSpacing spacing;

  /// For each bar, the beats of [spacing]'s columns (both staves together).
  final List<List<double>> spacingBeats;
  final bool showClef;
  final bool showMeasureNumbers;
  final String? instrumentName;

  const GrandStaffSystemInfo({
    required this.upperStaffMeasures,
    required this.lowerStaffMeasures,
    required this.systemNumber,
    required this.yPosition,
    required this.upperStaffHeight,
    required this.lowerStaffHeight,
    required this.staffGap,
    required this.spacing,
    this.spacingBeats = const [],
    this.showClef = false,
    this.showMeasureNumbers = false,
    this.instrumentName,
  });

  /// Y position of upper staff
  double get upperStaffY => yPosition;

  /// Y position of lower staff
  double get lowerStaffY => yPosition + upperStaffHeight + staffGap;

  /// Total height of this system
  double get totalHeight => upperStaffHeight + staffGap + lowerStaffHeight;

  /// Whether this system contains a specific measure
  bool containsMeasure(int measureNumber) {
    return upperStaffMeasures.any((m) => m.number == measureNumber);
  }

  /// Get upper and lower measures at a specific index
  GrandStaffMeasurePair getMeasurePair(int index) {
    assert(index >= 0 && index < upperStaffMeasures.length);
    return GrandStaffMeasurePair(
      upper: upperStaffMeasures[index],
      lower: lowerStaffMeasures[index],
    );
  }

  /// Number of measures in this system
  int get measureCount => upperStaffMeasures.length;

  /// First measure number in this system
  int get firstMeasureNumber =>
      upperStaffMeasures.isNotEmpty ? upperStaffMeasures.first.number : 0;

  /// Last measure number in this system
  int get lastMeasureNumber =>
      upperStaffMeasures.isNotEmpty ? upperStaffMeasures.last.number : 0;

  /// Whether this is the first system
  bool get isFirstSystem => systemNumber == 0;
}
