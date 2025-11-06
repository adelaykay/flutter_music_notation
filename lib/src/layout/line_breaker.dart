// lib/src/layout/line_breaker.dart

import '../models/measure.dart';
import 'spacing_engine.dart';

/// Determines how to break measures across multiple lines
class LineBreaker {
  final SpacingEngine spacingEngine;
  final double targetLineWidth;
  final double minMeasuresPerLine;
  final double maxMeasuresPerLine;

  const LineBreaker({
    required this.spacingEngine,
    required this.targetLineWidth,
    this.minMeasuresPerLine = 2,
    this.maxMeasuresPerLine = 8,
  });

  /// Break a list of measures into lines
  List<LineOfMeasures> breakIntoLines(
      List<Measure> measures, {
        required double startX,
        required double measureSpacing,
      }) {
    if (measures.isEmpty) return [];

    final lines = <LineOfMeasures>[];
    int currentIndex = 0;

    while (currentIndex < measures.length) {
      final line = _createLine(
        measures,
        currentIndex,
        startX,
        measureSpacing,
      );

      lines.add(line);
      currentIndex += line.measures.length;
    }

    return lines;
  }

  /// Create a single line starting from the given measure index
  LineOfMeasures _createLine(
      List<Measure> allMeasures,
      int startIndex,
      double startX,
      double measureSpacing,
      ) {
    final availableWidth = targetLineWidth - startX;
    final lineMeasures = <Measure>[];
    double currentWidth = 0;

    // Try to fit as many measures as possible
    for (int i = startIndex; i < allMeasures.length; i++) {
      final measure = allMeasures[i];

      // Calculate minimum width needed for this measure
      final elements = measure.elements;
      final measureWidth = spacingEngine.calculateMinimumMeasureWidth(elements);

      // Check if adding this measure would exceed line width
      final totalWidth = currentWidth + measureWidth +
          (lineMeasures.isNotEmpty ? measureSpacing : 0);

      // Be more aggressive - allow up to 95% of available width
      if (lineMeasures.isNotEmpty && totalWidth > availableWidth * 0.95) {
        // Line is full, stop here
        break;
      }

      if (lineMeasures.length >= maxMeasuresPerLine) {
        // Reached maximum measures per line
        break;
      }

      // Add this measure to the line
      lineMeasures.add(measure);
      currentWidth = totalWidth;

      // If this is the last measure, stop
      if (i == allMeasures.length - 1) {
        break;
      }
    }

    // Ensure we have at least minMeasuresPerLine (if available)
    if (lineMeasures.length < minMeasuresPerLine &&
        startIndex + minMeasuresPerLine.toInt() <= allMeasures.length) {
      final remaining = minMeasuresPerLine.toInt() - lineMeasures.length;
      for (int i = 0; i < remaining; i++) {
        final index = startIndex + lineMeasures.length + i;
        if (index < allMeasures.length) {
          lineMeasures.add(allMeasures[index]);
        }
      }
    }

    return LineOfMeasures(
      measures: lineMeasures,
      lineNumber: 0, // Will be set later
      startX: startX,
      targetWidth: targetLineWidth,
    );
  }

  /// Calculate optimal line breaks using a greedy algorithm
  /// This version tries to minimize raggedness (uneven line lengths)
  List<LineOfMeasures> breakWithMinimalRaggedness(
      List<Measure> measures, {
        required double startX,
        required double measureSpacing,
      }) {
    if (measures.isEmpty) return [];

    final availableWidth = targetLineWidth - startX;
    final lines = <LineOfMeasures>[];

    // Calculate width for each measure
    final measureWidths = measures.map((m) {
      return spacingEngine.calculateMinimumMeasureWidth(m.elements);
    }).toList();

    int currentIndex = 0;

    while (currentIndex < measures.length) {
      final lineResult = _findOptimalLineBreak(
        measures,
        measureWidths,
        currentIndex,
        availableWidth,
        measureSpacing,
      );

      lines.add(LineOfMeasures(
        measures: lineResult.measures,
        lineNumber: lines.length,
        startX: startX,
        targetWidth: targetLineWidth,
      ));

      currentIndex += lineResult.measures.length;
    }

    return lines;
  }

  /// Find the optimal point to break a line
  _LineBreakResult _findOptimalLineBreak(
      List<Measure> allMeasures,
      List<double> measureWidths,
      int startIndex,
      double availableWidth,
      double measureSpacing,
      ) {
    double currentWidth = 0;
    int bestBreakPoint = startIndex + 1;
    double bestRaggedness = double.infinity;

    // Try different break points
    for (int i = startIndex; i < allMeasures.length; i++) {
      final measureWidth = measureWidths[i];
      final spacing = i > startIndex ? measureSpacing : 0;

      currentWidth += measureWidth + spacing;

      // Allow up to 95% of available width (more aggressive)
      if (currentWidth > availableWidth * 1.3) {
        break;
      }

      // Calculate raggedness (unused space)
      final raggedness = availableWidth - currentWidth;

      // Prefer break points that minimize raggedness
      // But penalize very short lines
      final lineLength = i - startIndex + 1;
      if (lineLength >= minMeasuresPerLine) {
        final penalty = lineLength < minMeasuresPerLine ? 1000 : 0;
        final score = raggedness + penalty;

        if (score < bestRaggedness) {
          bestRaggedness = score;
          bestBreakPoint = i + 1;
        }
      }

      // Stop if we've reached max measures per line
      if (lineLength >= maxMeasuresPerLine) {
        break;
      }
    }

    final endIndex = bestBreakPoint.clamp(startIndex + 1, allMeasures.length);
    final lineMeasures = allMeasures.sublist(startIndex, endIndex);

    return _LineBreakResult(measures: lineMeasures);
  }

  /// Break lines at explicit break points
  List<LineOfMeasures> breakAtExplicitPoints(
      List<Measure> measures,
      List<int> breakPoints, {
        required double startX,
      }) {
    if (measures.isEmpty) return [];

    final lines = <LineOfMeasures>[];
    int currentIndex = 0;

    // Add implicit break point at the end
    final allBreakPoints = [...breakPoints, measures.length];

    for (final breakPoint in allBreakPoints) {
      if (breakPoint <= currentIndex || breakPoint > measures.length) {
        continue;
      }

      final lineMeasures = measures.sublist(currentIndex, breakPoint);

      lines.add(LineOfMeasures(
        measures: lineMeasures,
        lineNumber: lines.length,
        startX: startX,
        targetWidth: targetLineWidth,
      ));

      currentIndex = breakPoint;
    }

    return lines;
  }
}

/// Represents a line of measures in the layout
class LineOfMeasures {
  final List<Measure> measures;
  final int lineNumber;
  final double startX;
  final double targetWidth;

  const LineOfMeasures({
    required this.measures,
    required this.lineNumber,
    required this.startX,
    required this.targetWidth,
  });

  /// Whether this is the first line
  bool get isFirstLine => lineNumber == 0;

  /// Number of measures in this line
  int get measureCount => measures.length;

  /// First measure number on this line
  int get firstMeasureNumber => measures.isNotEmpty ? measures.first.number : 0;

  /// Last measure number on this line
  int get lastMeasureNumber => measures.isNotEmpty ? measures.last.number : 0;
}

/// Internal result class for line breaking
class _LineBreakResult {
  final List<Measure> measures;

  const _LineBreakResult({required this.measures});
}

/// Line breaking strategies
enum LineBreakStrategy {
  /// Fit as many measures as possible per line
  greedy,

  /// Minimize raggedness (uneven line lengths)
  balanced,

  /// Break at explicit measure numbers
  explicit,

  /// Fixed number of measures per line
  fixed,
}

/// Configuration for line breaking
class LineBreakConfig {
  final LineBreakStrategy strategy;
  final double targetLineWidth;
  final double minMeasuresPerLine;
  final double maxMeasuresPerLine;
  final List<int>? explicitBreakPoints;
  final int? fixedMeasuresPerLine;

  const LineBreakConfig({
    this.strategy = LineBreakStrategy.balanced,
    required this.targetLineWidth,
    this.minMeasuresPerLine = 2,
    this.maxMeasuresPerLine = 8,
    this.explicitBreakPoints,
    this.fixedMeasuresPerLine,
  });

  /// Default configuration
  static LineBreakConfig defaultConfig(double lineWidth) {
    return LineBreakConfig(
      strategy: LineBreakStrategy.balanced,
      targetLineWidth: lineWidth,
      minMeasuresPerLine: 2,
      maxMeasuresPerLine: 6,
    );
  }

  /// Compact configuration (more measures per line)
  static LineBreakConfig compact(double lineWidth) {
    return LineBreakConfig(
      strategy: LineBreakStrategy.greedy,
      targetLineWidth: lineWidth,
      minMeasuresPerLine: 3,
      maxMeasuresPerLine: 8,
    );
  }

  /// Spacious configuration (fewer measures per line)
  static LineBreakConfig spacious(double lineWidth) {
    return LineBreakConfig(
      strategy: LineBreakStrategy.balanced,
      targetLineWidth: lineWidth,
      minMeasuresPerLine: 2,
      maxMeasuresPerLine: 4,
    );
  }
}