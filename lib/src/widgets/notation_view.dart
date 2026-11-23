// lib/src/widgets/notation_view.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/measure.dart';
import '../models/grand_staff.dart';
import '../geometry/staff_position.dart';
import '../playback/playback_controller.dart';
import '../layout/spacing_engine.dart';
import '../layout/line_breaker.dart';
import '../rendering/notation_painter.dart';

/// Configuration for notation display
class NotationConfig {
  final double staffSpaceSize;
  final double barlineToClefSpace;
  final Color staffLineColor;
  final Color noteColor;
  final Color activeNoteColor;
  final ClefType clef;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double noteWidth;
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double leadingSpace;
  final double measureSpacing;
  final double minMeasureWidth;
  final SpacingEngine spacingEngine;
  final bool useSystemLayout;
  final double systemHeight;
  final double systemSpacing;
  final bool showMeasureNumbers;
  final bool showClefOnEachSystem;
  final bool showTimeSignature;
  final LineBreakConfig? lineBreakConfig;
  final double grandStaffGap;
  final double upperStaffHeight;
  final double lowerStaffHeight;
  final bool showBrace;
  final bool enableBeaming;
  final bool showKeySignatureOnEachSystem;
  final double clefNoteMargin;
  final bool enableTieDetection;
  final bool expandWidth;

  const NotationConfig({
    this.staffSpaceSize = 12.0,
    this.barlineToClefSpace = 0.0,
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
    this.leadingSpace = 0.0,
    this.measureSpacing = 40.0,
    this.minMeasureWidth = 100.0,
    this.spacingEngine = SpacingPresets.normal,
    this.useSystemLayout = false,
    this.systemHeight = 200.0,
    this.systemSpacing = 60.0,
    this.showMeasureNumbers = true,
    this.showClefOnEachSystem = true,
    this.showTimeSignature = true,
    this.lineBreakConfig,
    this.grandStaffGap = 60.0,
    this.upperStaffHeight = 40.0,
    this.lowerStaffHeight = 40.0,
    this.showBrace = true,
    this.enableBeaming = false,
    this.showKeySignatureOnEachSystem = true,
    this.clefNoteMargin = 20.0,
    this.enableTieDetection = false,
    this.expandWidth = false,
  });

  NotationConfig copyWith({
    double? staffSpaceSize,
    double? barlineToClefSpace,
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
    double? leadingSpace,
    double? measureSpacing,
    double? minMeasureWidth,
    SpacingEngine? spacingEngine,
    bool? useSystemLayout,
    double? systemHeight,
    double? systemSpacing,
    bool? showMeasureNumbers,
    bool? showClefOnEachSystem,
    bool? showTimeSignature,
    LineBreakConfig? lineBreakConfig,
    double? grandStaffGap,
    double? upperStaffHeight,
    double? lowerStaffHeight,
    bool? showBrace,
    bool? enableBeaming,
    bool? showKeySignatureOnEachSystem,
    double? clefNoteMargin,
    bool? enableTieDetection,
    bool? expandWidth,
  }) {
    return NotationConfig(
      staffSpaceSize: staffSpaceSize ?? this.staffSpaceSize,
      barlineToClefSpace: barlineToClefSpace ?? this.barlineToClefSpace,
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
      leadingSpace: leadingSpace ?? this.leadingSpace,
      measureSpacing: measureSpacing ?? this.measureSpacing,
      minMeasureWidth: minMeasureWidth ?? this.minMeasureWidth,
      spacingEngine: spacingEngine ?? this.spacingEngine,
      useSystemLayout: useSystemLayout ?? this.useSystemLayout,
      systemHeight: systemHeight ?? this.systemHeight,
      systemSpacing: systemSpacing ?? this.systemSpacing,
      showMeasureNumbers: showMeasureNumbers ?? this.showMeasureNumbers,
      showClefOnEachSystem: showClefOnEachSystem ?? this.showClefOnEachSystem,
      showTimeSignature: showTimeSignature ?? this.showTimeSignature,
      lineBreakConfig: lineBreakConfig ?? this.lineBreakConfig,
      grandStaffGap: grandStaffGap ?? this.grandStaffGap,
      upperStaffHeight: upperStaffHeight ?? this.upperStaffHeight,
      lowerStaffHeight: lowerStaffHeight ?? this.lowerStaffHeight,
      showBrace: showBrace ?? this.showBrace,
      enableBeaming: enableBeaming ?? this.enableBeaming,
      showKeySignatureOnEachSystem:
          showKeySignatureOnEachSystem ?? this.showKeySignatureOnEachSystem,
      clefNoteMargin: clefNoteMargin ?? this.clefNoteMargin,
      enableTieDetection: enableTieDetection ?? this.enableTieDetection,
      expandWidth: expandWidth ?? this.expandWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotationConfig &&
          runtimeType == other.runtimeType &&
          staffSpaceSize == other.staffSpaceSize &&
          barlineToClefSpace == other.barlineToClefSpace &&
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
          leadingSpace == other.leadingSpace &&
          measureSpacing == other.measureSpacing &&
          minMeasureWidth == other.minMeasureWidth &&
          spacingEngine == other.spacingEngine &&
          useSystemLayout == other.useSystemLayout &&
          systemHeight == other.systemHeight &&
          systemSpacing == other.systemSpacing &&
          showMeasureNumbers == other.showMeasureNumbers &&
          showClefOnEachSystem == other.showClefOnEachSystem &&
          showTimeSignature == other.showTimeSignature &&
          lineBreakConfig == other.lineBreakConfig &&
          grandStaffGap == other.grandStaffGap &&
          upperStaffHeight == other.upperStaffHeight &&
          lowerStaffHeight == other.lowerStaffHeight &&
          showBrace == other.showBrace &&
          expandWidth == other.expandWidth &&
          enableBeaming == other.enableBeaming &&
          showKeySignatureOnEachSystem == other.showKeySignatureOnEachSystem &&
          clefNoteMargin == other.clefNoteMargin &&
          enableTieDetection == other.enableTieDetection;

  @override
  int get hashCode => Object.hashAll([
    staffSpaceSize,
    barlineToClefSpace,
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
    leadingSpace,
    measureSpacing,
    minMeasureWidth,
    spacingEngine,
    useSystemLayout,
    systemHeight,
    systemSpacing,
    showMeasureNumbers,
    showClefOnEachSystem,
    showTimeSignature,
    lineBreakConfig,
    grandStaffGap,
    upperStaffHeight,
    lowerStaffHeight,
    showBrace,
    expandWidth,
    enableBeaming,
    showKeySignatureOnEachSystem,
    clefNoteMargin,
    enableTieDetection,
  ]);
}

/// Widget that displays musical notation
class NotationView extends StatefulWidget {
  final List<Measure>? measures;
  final GrandStaff? grandStaff;
  final List<Note>? notes;
  final List<Rest>? rests;
  final PlaybackController? playbackController;
  final NotationConfig config;

  const NotationView({
    super.key,
    this.measures,
    this.grandStaff,
    this.notes,
    this.rests,
    this.playbackController,
    this.config = const NotationConfig(),
  }) : assert(
         measures != null || grandStaff != null || notes != null,
         'Either measures, grandStaff, or notes must be provided',
       ),
       assert(
         (measures == null || grandStaff == null) &&
             (measures == null || notes == null) &&
             (grandStaff == null || notes == null),
         'Only one of measures, grandStaff, or notes should be provided',
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );

    widget.playbackController?.addListener(_onPlaybackUpdate);

    if (widget.playbackController?.isPlaying ?? false) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(NotationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playbackController != widget.playbackController) {
      oldWidget.playbackController?.removeListener(_onPlaybackUpdate);
      widget.playbackController?.addListener(_onPlaybackUpdate);
    }

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
    // Calculate height and width based on content type
    double? effectiveHeight = widget.config.height;
    double? effectiveWidth = widget.config.width;

    if (effectiveHeight == null) {
      if (widget.grandStaff != null) {
        // Grand staff: two staves + gap
        final measuresCount = widget.grandStaff!.measureCount;
        final estimatedSystems = widget.config.useSystemLayout
            ? (measuresCount / 3).ceil()
            : 1;
        final singleStaffHeight =
            widget.config.staffSpaceSize * 4; // 5 lines = 4 spaces
        final systemHeight =
            singleStaffHeight + widget.config.grandStaffGap + singleStaffHeight;
        effectiveHeight =
            widget.config.topMargin +
            (estimatedSystems * (systemHeight + widget.config.systemSpacing)) +
            widget.config.topMargin;
      } else if (widget.config.useSystemLayout && widget.measures != null) {
        // Multi-line single staff
        final measuresCount = widget.measures!.length;
        final estimatedSystems = (measuresCount / 4).ceil();
        effectiveHeight =
            widget.config.topMargin +
            (estimatedSystems *
                (widget.config.systemHeight + widget.config.systemSpacing));
      } else {
        // Single line or legacy mode
        effectiveHeight = 200;
      }
    }

    // Estimate width for single-line scrollable content
    if (effectiveWidth == null && !widget.config.useSystemLayout) {
      if (widget.measures != null) {
        // Estimate 150-200px per measure for single line
        effectiveWidth =
            widget.config.leftMargin +
            (widget.measures!.length * 180.0) +
            widget.config.rightMargin;
      } else if (widget.grandStaff != null) {
        effectiveWidth =
            widget.config.leftMargin +
            (widget.grandStaff!.measureCount * 180.0) +
            widget.config.rightMargin;
      }
    }

    Widget content = CustomPaint(
      painter: NotationPainter(
        measures: widget.measures,
        grandStaff: widget.grandStaff,
        notes: widget.notes,
        rests: widget.rests,
        config: widget.config,
        activeNotes: widget.playbackController?.activeNotes ?? const {},
      ),
      size: Size(effectiveWidth ?? double.infinity, effectiveHeight),
    );

    if (widget.playbackController != null) {
      content = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          if (widget.playbackController?.isPlaying ?? false) {
            final now = DateTime.now();
            if (_lastUpdateTime != null) {
              final deltaTime =
                  now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
              widget.playbackController?.update(deltaTime);
            }
            _lastUpdateTime = now;
          }
          return child!;
        },
        child: content,
      );
    }

    Widget result = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: widget.config.padding,
      child: content,
    );

    // If width is estimated and large, wrap in SingleChildScrollView
    if (effectiveWidth != null && !widget.config.useSystemLayout) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: result,
      );
    }

    return result;
  }
}
