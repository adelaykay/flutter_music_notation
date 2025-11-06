// lib/src/layout/system_layout.dart

import '../models/measure.dart';
import 'spacing_engine.dart';
import 'line_breaker.dart';

/// Manages the layout of multiple systems (lines) of music
class SystemLayout {
  final SpacingEngine spacingEngine;
  final double systemHeight;
  final double systemSpacing;
  final bool showMeasureNumbers;

  const SystemLayout({
    required this.spacingEngine,
    this.systemHeight = 200.0,
    this.systemSpacing = 60.0,
    this.showMeasureNumbers = true,
  });

  /// Calculate complete layout for all measures
  ScoreLayout calculateLayout(
      List<Measure> measures, {
        required double pageWidth,
        required double leftMargin,
        required double rightMargin,
        required double topMargin,
        required double measureSpacing,
        LineBreakConfig? lineBreakConfig,
      }) {
    if (measures.isEmpty) {
      return const ScoreLayout(systems: [], totalHeight: 0);
    }

    // Calculate available width for notation (this is what we have to work with)
    final availableWidth = pageWidth - leftMargin - rightMargin;

    // Use line breaker to split measures into lines
    final lineBreaker = LineBreaker(
      spacingEngine: spacingEngine,
      targetLineWidth: availableWidth, // Use full available width
      minMeasuresPerLine: lineBreakConfig?.minMeasuresPerLine ?? 2,
      maxMeasuresPerLine: lineBreakConfig?.maxMeasuresPerLine ?? 6,
    );

    final lines = lineBreakConfig?.strategy == LineBreakStrategy.explicit &&
        lineBreakConfig?.explicitBreakPoints != null
        ? lineBreaker.breakAtExplicitPoints(
      measures,
      lineBreakConfig!.explicitBreakPoints!,
      startX: leftMargin,
    )
        : lineBreaker.breakWithMinimalRaggedness(
      measures,
      startX: leftMargin,
      measureSpacing: measureSpacing,
    );

    // Create systems from lines
    final systems = <SystemInfo>[];
    double currentY = topMargin;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Calculate spacing for this system - use FULL available width
      final measureElements = line.measures.map((m) {
        return MeasureElements(
          elements: m.elements,
          measureNumber: m.number,
        );
      }).toList();

      final lineSpacing = spacingEngine.calculateLineSpacing(
        measureElements,
        leftMargin,
        pageWidth - rightMargin, // End position (use full width)
        measureSpacing,
      );

      systems.add(SystemInfo(
        measures: line.measures,
        systemNumber: i,
        yPosition: currentY,
        height: systemHeight,
        spacing: lineSpacing,
        showClef: i == 0, // Show clef only on first system
        showMeasureNumbers: showMeasureNumbers,
      ));

      currentY += systemHeight + systemSpacing;
    }

    final totalHeight = currentY - systemSpacing + topMargin;

    return ScoreLayout(
      systems: systems,
      totalHeight: totalHeight,
    );
  }

  /// Calculate layout for a single page
  PageLayout calculatePageLayout(
      List<Measure> measures, {
        required double pageWidth,
        required double pageHeight,
        required double leftMargin,
        required double rightMargin,
        required double topMargin,
        required double bottomMargin,
        required double measureSpacing,
        LineBreakConfig? lineBreakConfig,
      }) {
    final scoreLayout = calculateLayout(
      measures,
      pageWidth: pageWidth,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      topMargin: topMargin,
      measureSpacing: measureSpacing,
      lineBreakConfig: lineBreakConfig,
    );

    // Determine which systems fit on this page
    final availableHeight = pageHeight - topMargin - bottomMargin;
    final systemsOnPage = <SystemInfo>[];

    for (final system in scoreLayout.systems) {
      final systemBottom = system.yPosition + system.height;
      if (systemBottom <= availableHeight + topMargin) {
        systemsOnPage.add(system);
      } else {
        break; // System doesn't fit, stop here
      }
    }

    return PageLayout(
      systems: systemsOnPage,
      pageNumber: 0,
      width: pageWidth,
      height: pageHeight,
    );
  }

  /// Calculate layout across multiple pages
  List<PageLayout> calculateMultiPageLayout(
      List<Measure> measures, {
        required double pageWidth,
        required double pageHeight,
        required double leftMargin,
        required double rightMargin,
        required double topMargin,
        required double bottomMargin,
        required double measureSpacing,
        LineBreakConfig? lineBreakConfig,
      }) {
    final scoreLayout = calculateLayout(
      measures,
      pageWidth: pageWidth,
      leftMargin: leftMargin,
      rightMargin: rightMargin,
      topMargin: topMargin,
      measureSpacing: measureSpacing,
      lineBreakConfig: lineBreakConfig,
    );

    final pages = <PageLayout>[];
    final availableHeight = pageHeight - topMargin - bottomMargin;

    List<SystemInfo> currentPageSystems = [];
    double currentPageHeight = 0;

    for (final system in scoreLayout.systems) {
      final systemTotalHeight = system.height + systemSpacing;

      if (currentPageHeight + systemTotalHeight > availableHeight &&
          currentPageSystems.isNotEmpty) {
        // Start a new page
        pages.add(PageLayout(
          systems: currentPageSystems,
          pageNumber: pages.length,
          width: pageWidth,
          height: pageHeight,
        ));

        currentPageSystems = [];
        currentPageHeight = 0;
      }

      currentPageSystems.add(system);
      currentPageHeight += systemTotalHeight;
    }

    // Add the last page
    if (currentPageSystems.isNotEmpty) {
      pages.add(PageLayout(
        systems: currentPageSystems,
        pageNumber: pages.length,
        width: pageWidth,
        height: pageHeight,
      ));
    }

    return pages;
  }
}

/// Complete layout information for a score
class ScoreLayout {
  final List<SystemInfo> systems;
  final double totalHeight;

  const ScoreLayout({
    required this.systems,
    required this.totalHeight,
  });

  /// Get system at a specific index
  SystemInfo? getSystem(int index) {
    if (index < 0 || index >= systems.length) return null;
    return systems[index];
  }

  /// Find which system contains a specific measure
  SystemInfo? findSystemForMeasure(int measureNumber) {
    for (final system in systems) {
      if (system.containsMeasure(measureNumber)) {
        return system;
      }
    }
    return null;
  }

  /// Total number of systems
  int get systemCount => systems.length;
}

/// Information about a single system (line of music)
class SystemInfo {
  final List<Measure> measures;
  final int systemNumber;
  final double yPosition;
  final double height;
  final LineSpacing spacing;
  final bool showClef;
  final bool showMeasureNumbers;

  const SystemInfo({
    required this.measures,
    required this.systemNumber,
    required this.yPosition,
    required this.height,
    required this.spacing,
    this.showClef = false,
    this.showMeasureNumbers = false,
  });

  /// Whether this system contains a specific measure
  bool containsMeasure(int measureNumber) {
    return measures.any((m) => m.number == measureNumber);
  }

  /// Get measure at a specific index within this system
  Measure? getMeasure(int index) {
    if (index < 0 || index >= measures.length) return null;
    return measures[index];
  }

  /// First measure number in this system
  int get firstMeasureNumber =>
      measures.isNotEmpty ? measures.first.number : 0;

  /// Last measure number in this system
  int get lastMeasureNumber => measures.isNotEmpty ? measures.last.number : 0;

  /// Number of measures in this system
  int get measureCount => measures.length;

  /// Whether this is the first system
  bool get isFirstSystem => systemNumber == 0;
}

/// Layout information for a single page
class PageLayout {
  final List<SystemInfo> systems;
  final int pageNumber;
  final double width;
  final double height;

  const PageLayout({
    required this.systems,
    required this.pageNumber,
    required this.width,
    required this.height,
  });

  /// Whether this is the first page
  bool get isFirstPage => pageNumber == 0;

  /// Number of systems on this page
  int get systemCount => systems.length;

  /// First measure number on this page
  int get firstMeasureNumber =>
      systems.isNotEmpty ? systems.first.firstMeasureNumber : 0;

  /// Last measure number on this page
  int get lastMeasureNumber =>
      systems.isNotEmpty ? systems.last.lastMeasureNumber : 0;
}

/// Configuration for system layout
class SystemLayoutConfig {
  final double systemHeight;
  final double systemSpacing;
  final bool showMeasureNumbers;
  final bool showSystemBrackets;
  final MeasureNumberStyle measureNumberStyle;

  const SystemLayoutConfig({
    this.systemHeight = 200.0,
    this.systemSpacing = 60.0,
    this.showMeasureNumbers = true,
    this.showSystemBrackets = false,
    this.measureNumberStyle = MeasureNumberStyle.everySystem,
  });

  /// Default configuration
  static const standard = SystemLayoutConfig(
    systemHeight: 200.0,
    systemSpacing: 60.0,
    showMeasureNumbers: true,
  );

  /// Compact configuration (less vertical space)
  static const compact = SystemLayoutConfig(
    systemHeight: 160.0,
    systemSpacing: 40.0,
    showMeasureNumbers: true,
  );

  /// Spacious configuration (more vertical space)
  static const spacious = SystemLayoutConfig(
    systemHeight: 240.0,
    systemSpacing: 80.0,
    showMeasureNumbers: true,
  );
}

/// How to display measure numbers
enum MeasureNumberStyle {
  /// Show measure number at the start of every system
  everySystem,

  /// Show measure number on every measure
  everyMeasure,

  /// Show measure number every N measures
  periodic,

  /// Don't show measure numbers
  none,
}