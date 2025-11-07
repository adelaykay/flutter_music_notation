// lib/src/layout/grand_staff_layout.dart

import '../models/grand_staff.dart';
import '../models/measure.dart';
import 'spacing_engine.dart';
import 'line_breaker.dart';

/// Manages layout for grand staff (two staves connected)
class GrandStaffLayout {
  final SpacingEngine spacingEngine;
  final double upperStaffHeight;
  final double lowerStaffHeight;
  final double staffGap; // Space between upper and lower staff
  final double systemSpacing; // Space between systems
  final bool showMeasureNumbers;

  const GrandStaffLayout({
    required this.spacingEngine,
    this.upperStaffHeight = 40.0, // 4 * staffSpaceSize typically
    this.lowerStaffHeight = 40.0,
    this.staffGap = 60.0,
    this.systemSpacing = 80.0,
    this.showMeasureNumbers = true,
  });

  /// Total height of one grand staff system (both staves + gap)
  double get totalSystemHeight => upperStaffHeight + staffGap + lowerStaffHeight;

  /// Calculate complete layout for a grand staff score
  GrandStaffScoreLayout calculateLayout(
      GrandStaff grandStaff, {
        required double pageWidth,
        required double leftMargin,
        required double rightMargin,
        required double topMargin,
        required double measureSpacing,
        LineBreakConfig? lineBreakConfig,
      }) {
    if (grandStaff.isEmpty) {
      return const GrandStaffScoreLayout(systems: [], totalHeight: 0);
    }

    final availableWidth = pageWidth - leftMargin - rightMargin;

    // Use line breaker for upper staff (same breaks apply to lower staff)
    final lineBreaker = LineBreaker(
      spacingEngine: spacingEngine,
      targetLineWidth: availableWidth,
      minMeasuresPerLine: lineBreakConfig?.minMeasuresPerLine ?? 2,
      maxMeasuresPerLine: lineBreakConfig?.maxMeasuresPerLine ?? 6,
    );

    final lines = lineBreaker.breakWithMinimalRaggedness(
      grandStaff.upperStaff,
      startX: leftMargin,
      measureSpacing: measureSpacing,
    );

    // Create grand staff systems
    final systems = <GrandStaffSystemInfo>[];
    double currentY = topMargin;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final measureIndices = List.generate(
        line.measures.length,
            (index) => line.measures[index].number,
      );

      // Get corresponding lower staff measures
      final lowerMeasures = measureIndices
          .map((index) => grandStaff.lowerStaff[index])
          .toList();

      // Calculate spacing (same for both staves)
      final measureElements = line.measures.map((m) {
        return MeasureElements(
          elements: m.elements,
          measureNumber: m.number,
        );
      }).toList();

      final lineSpacing = spacingEngine.calculateLineSpacing(
        measureElements,
        leftMargin,
        pageWidth - rightMargin,
        measureSpacing,
      );

      systems.add(GrandStaffSystemInfo(
        upperStaffMeasures: line.measures,
        lowerStaffMeasures: lowerMeasures,
        systemNumber: i,
        yPosition: currentY,
        upperStaffHeight: upperStaffHeight,
        lowerStaffHeight: lowerStaffHeight,
        staffGap: staffGap,
        spacing: lineSpacing,
        showClef: i == 0,
        showMeasureNumbers: showMeasureNumbers,
        instrumentName: i == 0 ? grandStaff.instrumentName : grandStaff.instrumentAbbreviation,
      ));

      currentY += totalSystemHeight + systemSpacing;
    }

    final totalHeight = currentY - systemSpacing + topMargin;

    return GrandStaffScoreLayout(
      systems: systems,
      totalHeight: totalHeight,
    );
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