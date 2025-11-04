// lib/src/widgets/notation_view.dart

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../geometry/staff_position.dart';
import '../playback/playback_controller.dart';
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

  /// Fixed width per note (uniform spacing)
  final double noteWidth;

  /// Left padding for clef, key sig, time sig (even if not rendered yet)
  final double leftMargin;

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
    );
  }
}

/// Widget that displays musical notation
class NotationView extends StatefulWidget {
  /// Notes to display
  final List<Note> notes;

  /// Rests to display (optional)
  final List<Rest> rests;

  /// Optional playback controller for highlighting active notes
  final PlaybackController? playbackController;

  /// Visual configuration
  final NotationConfig config;

  const NotationView({
    super.key,
    required this.notes,
    this.rests = const [],
    this.playbackController,
    this.config = const NotationConfig(),
  });

  @override
  State<NotationView> createState() => _NotationViewState();
}

class _NotationViewState extends State<NotationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Create animation controller for smooth playback updates (60fps)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Listen to playback controller
    widget.playbackController?.addListener(_onPlaybackUpdate);
  }

  @override
  void didUpdateWidget(NotationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update playback controller listener
    if (oldWidget.playbackController != widget.playbackController) {
      oldWidget.playbackController?.removeListener(_onPlaybackUpdate);
      widget.playbackController?.addListener(_onPlaybackUpdate);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.playbackController?.removeListener(_onPlaybackUpdate);
    super.dispose();
  }

  void _onPlaybackUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Update playback position if playing
        if (widget.playbackController?.isPlaying ?? false) {
          widget.playbackController?.update(_animationController.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0 / 1000.0);
        }

        return Container(
          width: widget.config.width,
          height: widget.config.height,
          padding: widget.config.padding,
          child: CustomPaint(
            painter: NotationPainter(
              notes: [...widget.notes, ...widget.rests],
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