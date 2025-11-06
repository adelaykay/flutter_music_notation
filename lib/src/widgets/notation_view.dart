// lib/src/widgets/notation_view.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/measure.dart';
import '../geometry/staff_position.dart';
import '../playback/playback_controller.dart';
import '../layout/spacing_engine.dart';
import '../layout/line_breaker.dart';
import '../rendering/notation_painter.dart';

/// Configuration for notation display
class NotationConfig {
  /// Size of staff space in pixels
  final double staffSpaceSize;

  /// Color for staff lines
  final Color staffLineColor;

  /// Color for notes
  final Color noteColor;

  /// Color for active (playing) notes
  final Color activeNoteColor;

  /// Which clef to display
  final ClefType clef;

  /// Width of the notation area
  final double? width;

  /// Height of the notation area
  final double? height;

  /// Padding around the notation
  final EdgeInsets padding;

  /// Fixed width per note (used in legacy/uniform spacing mode)
  final double noteWidth;

  /// Left padding for clef, key sig, time sig
  final double leftMargin;

  /// Right margin
  final double rightMargin;

  /// Top margin
  final double topMargin;

  /// Spacing between measures
  final double measureSpacing;

  /// Minimum measure width
  final double minMeasureWidth;

  /// Spacing engine for calculating proportional spacing
  final SpacingEngine spacingEngine;

  /// Whether to use system layout (multi-line)
  final bool useSystemLayout;

  /// Height of each system (line of music)
  final double systemHeight;

  /// Vertical spacing between systems
  final double systemSpacing;

  /// Whether to show measure numbers
  final bool showMeasureNumbers;

  /// Whether to show clef on each system
  final bool showClefOnEachSystem;

  /// Line break configuration
  final LineBreakConfig? lineBreakConfig;

  const NotationConfig({
    this.staffSpaceSize = 12.0,
    this.staffLineColor = Colors.black,
    this.noteColor = Colors.black,
    this.activeNoteColor = Colors.green,
    this.clef = ClefType.treble,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.noteWidth = 60.0,
    this.leftMargin = 100.0,
    this.rightMargin = 20.0,
    this.topMargin = 40.0,
    this.measureSpacing = 40.0,
    this.minMeasureWidth = 100.0,
    this.spacingEngine = SpacingPresets.normal,
    this.useSystemLayout = false,
    this.systemHeight = 200.0,
    this.systemSpacing = 60.0,
    this.showMeasureNumbers = true,
    this.showClefOnEachSystem = true,
    this.lineBreakConfig,
  });

  NotationConfig copyWith({
    double? staffSpaceSize,
    Color? staffLineColor,
    Color? noteColor,
    Color? activeNoteColor,
    ClefType? clef,
    double? width,
    double? height,
    EdgeInsets? padding,
    double? noteWidth,
    double? leftMargin,
    double? rightMargin,
    double? topMargin,
    double? measureSpacing,
    double? minMeasureWidth,
    SpacingEngine? spacingEngine,
    bool? useSystemLayout,
    double? systemHeight,
    double? systemSpacing,
    bool? showMeasureNumbers,
    bool? showClefOnEachSystem,
    LineBreakConfig? lineBreakConfig,
  }) {
    return NotationConfig(
      staffSpaceSize: staffSpaceSize ?? this.staffSpaceSize,
      staffLineColor: staffLineColor ?? this.staffLineColor,
      noteColor: noteColor ?? this.noteColor,
      activeNoteColor: activeNoteColor ?? this.activeNoteColor,
      clef: clef ?? this.clef,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      noteWidth: noteWidth ?? this.noteWidth,
      leftMargin: leftMargin ?? this.leftMargin,
      rightMargin: rightMargin ?? this.rightMargin,
      topMargin: topMargin ?? this.topMargin,
      measureSpacing: measureSpacing ?? this.measureSpacing,
      minMeasureWidth: minMeasureWidth ?? this.minMeasureWidth,
      spacingEngine: spacingEngine ?? this.spacingEngine,
      useSystemLayout: useSystemLayout ?? this.useSystemLayout,
      systemHeight: systemHeight ?? this.systemHeight,
      systemSpacing: systemSpacing ?? this.systemSpacing,
      showMeasureNumbers: showMeasureNumbers ?? this.showMeasureNumbers,
      showClefOnEachSystem: showClefOnEachSystem ?? this.showClefOnEachSystem,
      lineBreakConfig: lineBreakConfig ?? this.lineBreakConfig,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NotationConfig &&
              runtimeType == other.runtimeType &&
              staffSpaceSize == other.staffSpaceSize &&
              staffLineColor == other.staffLineColor &&
              noteColor == other.noteColor &&
              activeNoteColor == other.activeNoteColor &&
              clef == other.clef &&
              width == other.width &&
              height == other.height &&
              padding == other.padding &&
              noteWidth == other.noteWidth &&
              leftMargin == other.leftMargin &&
              rightMargin == other.rightMargin &&
              topMargin == other.topMargin &&
              measureSpacing == other.measureSpacing &&
              minMeasureWidth == other.minMeasureWidth &&
              spacingEngine == other.spacingEngine &&
              useSystemLayout == other.useSystemLayout &&
              systemHeight == other.systemHeight &&
              systemSpacing == other.systemSpacing &&
              showMeasureNumbers == other.showMeasureNumbers &&
              showClefOnEachSystem == other.showClefOnEachSystem &&
              lineBreakConfig == other.lineBreakConfig;

  @override
  int get hashCode => Object.hash(
    staffSpaceSize,
    staffLineColor,
    noteColor,
    activeNoteColor,
    clef,
    width,
    height,
    padding,
    noteWidth,
    leftMargin,
    rightMargin,
    topMargin,
    measureSpacing,
    minMeasureWidth,
    spacingEngine,
    useSystemLayout,
    systemHeight,
    systemSpacing,
    showMeasureNumbers,
    showClefOnEachSystem,
  );
}

/// Widget that displays musical notation
class NotationView extends StatefulWidget {
  /// Measures to display (preferred for complete notation)
  final List<Measure>? measures;

  /// Notes to display (legacy mode, for backward compatibility)
  final List<Note>? notes;

  /// Rests to display (legacy mode)
  final List<Rest>? rests;

  /// Optional playback controller for highlighting active notes
  final PlaybackController? playbackController;

  /// Visual configuration
  final NotationConfig config;

  const NotationView({
    super.key,
    this.measures,
    this.notes,
    this.rests,
    this.playbackController,
    this.config = const NotationConfig(),
  }) : assert(
  measures != null || notes != null,
  'Either measures or notes must be provided',
  );

  @override
  State<NotationView> createState() => _NotationViewState();
}

class _NotationViewState extends State<NotationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();

    // Create animation controller but don't start it yet
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // Long duration, we'll use elapsed time
    );

    // Listen to playback controller
    widget.playbackController?.addListener(_onPlaybackUpdate);

    // Start animation only if playing
    if (widget.playbackController?.isPlaying ?? false) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(NotationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update playback controller listener
    if (oldWidget.playbackController != widget.playbackController) {
      oldWidget.playbackController?.removeListener(_onPlaybackUpdate);
      widget.playbackController?.addListener(_onPlaybackUpdate);
    }

    // Start/stop animation based on playback state
    final isPlaying = widget.playbackController?.isPlaying ?? false;
    if (isPlaying && !_animationController.isAnimating) {
      _startAnimation();
    } else if (!isPlaying && _animationController.isAnimating) {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.playbackController?.removeListener(_onPlaybackUpdate);
    super.dispose();
  }

  void _startAnimation() {
    _lastUpdateTime = DateTime.now();
    _animationController.repeat();
  }

  void _stopAnimation() {
    _animationController.stop();
    _lastUpdateTime = null;
  }

  void _onPlaybackUpdate() {
    if (mounted) {
      // Control animation based on playback state
      final isPlaying = widget.playbackController?.isPlaying ?? false;
      if (isPlaying && !_animationController.isAnimating) {
        _startAnimation();
      } else if (!isPlaying && _animationController.isAnimating) {
        _stopAnimation();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate height if using system layout
    double? effectiveHeight = widget.config.height;

    if (widget.config.useSystemLayout && widget.measures != null && effectiveHeight == null) {
      // Estimate height based on number of systems needed
      final measuresCount = widget.measures!.length;
      final estimatedSystems = (measuresCount / 4).ceil(); // Rough estimate
      effectiveHeight = widget.config.topMargin +
          (estimatedSystems * (widget.config.systemHeight + widget.config.systemSpacing));
    }

    // If no playback controller, just render statically
    if (widget.playbackController == null) {
      return Container(
        width: widget.config.width,
        height: effectiveHeight,
        padding: widget.config.padding,
        child: CustomPaint(
          painter: NotationPainter(
            measures: widget.measures,
            notes: widget.notes,
            rests: widget.rests,
            config: widget.config,
            activeNotes: {},
          ),
          size: Size.infinite,
        ),
      );
    }

    // With playback controller, use AnimatedBuilder only when playing
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Update playback position if playing
        if (widget.playbackController?.isPlaying ?? false) {
          final now = DateTime.now();
          if (_lastUpdateTime != null) {
            final deltaTime = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
            widget.playbackController?.update(deltaTime);
          }
          _lastUpdateTime = now;
        }

        return Container(
          width: widget.config.width,
          height: effectiveHeight,
          padding: widget.config.padding,
          child: CustomPaint(
            painter: NotationPainter(
              measures: widget.measures,
              notes: widget.notes,
              rests: widget.rests,
              config: widget.config,
              activeNotes: widget.playbackController?.activeNotes ?? {},
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}