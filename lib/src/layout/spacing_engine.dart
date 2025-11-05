// lib/src/layout/spacing_engine.dart

import 'dart:math';

import '../models/note.dart';

/// Calculates optimal horizontal spacing for musical notation
/// based on duration and engraving best practices.
class SpacingEngine {
  /// Base spacing unit in pixels
  final double baseSpacing;

  /// Minimum spacing between any two elements
  final double minSpacing;

  /// Maximum spacing between any two elements
  final double maxSpacing;

  /// Whether to use proportional spacing (true) or uniform spacing (false)
  final bool proportional;

  const SpacingEngine({
    this.baseSpacing = 40.0,
    this.minSpacing = 20.0,
    this.maxSpacing = 120.0,
    this.proportional = true,
  });

  /// Calculate spacing for a list of elements (notes/rests)
  /// Returns a list of X positions for each element
  List<double> calculateSpacing(
      List<dynamic> elements, {
        required double startX,
        double? availableWidth,
      }) {
    if (elements.isEmpty) return [];

    if (!proportional) {
      // Uniform spacing (legacy mode)
      return _calculateUniformSpacing(elements, startX);
    }

    // Proportional spacing based on duration
    return _calculateProportionalSpacing(
      elements,
      startX,
      availableWidth,
    );
  }

  /// Calculate uniform spacing (equal distance between all elements)
  List<double> _calculateUniformSpacing(
      List<dynamic> elements,
      double startX,
      ) {
    final positions = <double>[];
    double currentX = startX;

    for (int i = 0; i < elements.length; i++) {
      positions.add(currentX);
      currentX += baseSpacing;
    }

    return positions;
  }

  /// Calculate proportional spacing based on note durations
  /// Longer notes get more space
  List<double> _calculateProportionalSpacing(
      List<dynamic> elements,
      double startX,
      double? availableWidth,
      ) {
    // Calculate duration for each element
    final durations = elements.map((e) {
      if (e is Note) return e.duration.beats;
      if (e is Rest) return e.duration.beats;
      return 1.0;
    }).toList();

    // Calculate spacing weights based on duration
    final spacingWeights = _calculateSpacingWeights(durations);

    // Calculate total width needed with ideal spacing
    final idealTotalWidth = spacingWeights.reduce((a, b) => a + b);

    // Determine scaling factor if we have a target width
    double scaleFactor = 1.0;
    if (availableWidth != null && idealTotalWidth > 0) {
      final usableWidth = availableWidth - startX - minSpacing;
      scaleFactor = (usableWidth / idealTotalWidth).clamp(0.3, 3.0);
    }

    // Calculate actual positions
    final positions = <double>[];
    double currentX = startX;

    for (int i = 0; i < elements.length; i++) {
      positions.add(currentX);

      // Add spacing before next element
      if (i < elements.length - 1) {
        final spacing = (spacingWeights[i] * scaleFactor)
            .clamp(minSpacing, maxSpacing);
        currentX += spacing;
      }
    }

    return positions;
  }

  /// Calculate spacing weights based on note durations
  /// Uses a logarithmic scale to prevent extreme spacing differences
  List<double> _calculateSpacingWeights(List<double> durations) {
    final weights = <double>[];

    for (int i = 0; i < durations.length; i++) {
      final currentDuration = durations[i];

      // Get the next duration (or current if last)
      final nextDuration = i < durations.length - 1
          ? durations[i + 1]
          : currentDuration;

      // Calculate weight based on current and next duration
      // Uses geometric mean for smooth transitions
      final avgDuration = (currentDuration + nextDuration) / 2;

      // Logarithmic scaling: log2(duration + 1) * baseSpacing
      // This prevents whole notes from taking 32x the space of 32nd notes
      final weight = _log2(avgDuration + 1) * baseSpacing;

      weights.add(weight);
    }

    return weights;
  }

  /// Calculate spacing for a measure with proper distribution
  MeasureSpacing calculateMeasureSpacing(
      List<dynamic> elements,
      double startX,
      double measureWidth,
      ) {
    if (elements.isEmpty) {
      return MeasureSpacing(
        positions: [],
        totalWidth: 0,
        startX: startX,
        endX: startX,
      );
    }

    // Calculate positions with justified spacing
    final positions = calculateSpacing(
      elements,
      startX: startX,
      availableWidth: measureWidth,
    );

    // Calculate actual end position
    final endX = positions.isNotEmpty
        ? positions.last + minSpacing
        : startX;

    return MeasureSpacing(
      positions: positions,
      totalWidth: endX - startX,
      startX: startX,
      endX: endX,
    );
  }

  /// Calculate minimum width needed for a measure
  double calculateMinimumMeasureWidth(List<dynamic> elements) {
    if (elements.isEmpty) return minSpacing;

    final positions = calculateSpacing(
      elements,
      startX: 0,
      availableWidth: null,
    );

    if (positions.isEmpty) return minSpacing;

    return positions.last + minSpacing;
  }

  /// Helper: Calculate log base 2
  double _log2(double x) {
    return (x > 0) ? (log(x.clamp(0.1, 100)) / log(2.0)) : 0;
  }

  /// Calculate spacing for multiple measures on a line
  LineSpacing calculateLineSpacing(
      List<MeasureElements> measures,
      double startX,
      double lineWidth,
      double measureSpacing,
      ) {
    final measureSpacings = <MeasureSpacing>[];
    double currentX = startX;

    // First pass: calculate minimum widths
    final minWidths = measures.map((m) {
      return calculateMinimumMeasureWidth(m.elements);
    }).toList();

    // Calculate total minimum width needed
    final totalMinWidth = minWidths.reduce((a, b) => a + b) +
        (measures.length - 1) * measureSpacing;

    // Calculate available width for distribution
    final availableWidth = lineWidth - startX;

    // Determine if we need to compress or can expand
    final scaleFactor = availableWidth > totalMinWidth
        ? availableWidth / totalMinWidth
        : 1.0;

    // Second pass: calculate actual positions with scaling
    for (int i = 0; i < measures.length; i++) {
      final measure = measures[i];
      final targetWidth = minWidths[i] * scaleFactor;

      final spacing = calculateMeasureSpacing(
        measure.elements,
        currentX,
        targetWidth,
      );

      measureSpacings.add(spacing);

      // Move to next measure
      currentX = spacing.endX + measureSpacing;
    }

    return LineSpacing(
      measureSpacings: measureSpacings,
      totalWidth: currentX - startX,
      lineWidth: lineWidth,
    );
  }
}

/// Represents spacing information for a single measure
class MeasureSpacing {
  /// X positions for each element in the measure
  final List<double> positions;

  /// Total width of the measure
  final double totalWidth;

  /// Start X position of the measure
  final double startX;

  /// End X position of the measure
  final double endX;

  const MeasureSpacing({
    required this.positions,
    required this.totalWidth,
    required this.startX,
    required this.endX,
  });

  /// Get position for a specific element index
  double positionAt(int index) {
    if (index < 0 || index >= positions.length) {
      return startX;
    }
    return positions[index];
  }
}

/// Represents spacing information for a line of measures
class LineSpacing {
  /// Spacing for each measure on the line
  final List<MeasureSpacing> measureSpacings;

  /// Total width used by all measures and spacing
  final double totalWidth;

  /// Total available width of the line
  final double lineWidth;

  const LineSpacing({
    required this.measureSpacings,
    required this.totalWidth,
    required this.lineWidth,
  });

  /// Whether this line has unused space
  bool get hasExtraSpace => totalWidth < lineWidth;

  /// Amount of unused space
  double get extraSpace => (lineWidth - totalWidth).clamp(0, double.infinity);
}

/// Container for measure elements (notes and rests)
class MeasureElements {
  final List<dynamic> elements;
  final int measureNumber;

  const MeasureElements({
    required this.elements,
    required this.measureNumber,
  });
}

/// Spacing configuration presets
class SpacingPresets {
  /// Tight spacing (for space-constrained layouts)
  static const tight = SpacingEngine(
    baseSpacing: 30.0,
    minSpacing: 15.0,
    maxSpacing: 80.0,
    proportional: true,
  );

  /// Normal spacing (default, balanced)
  static const normal = SpacingEngine(
    baseSpacing: 40.0,
    minSpacing: 20.0,
    maxSpacing: 120.0,
    proportional: true,
  );

  /// Loose spacing (for easy reading)
  static const loose = SpacingEngine(
    baseSpacing: 55.0,
    minSpacing: 30.0,
    maxSpacing: 160.0,
    proportional: true,
  );

  /// Uniform spacing (equal distance, simple)
  static const uniform = SpacingEngine(
    baseSpacing: 50.0,
    minSpacing: 50.0,
    maxSpacing: 50.0,
    proportional: false,
  );
}