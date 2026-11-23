// lib/src/layout/system_prefix.dart

import '../../flutter_music_notation.dart';

/// The width of what opens a system before its first bar: the clef, the key
/// signature and, on the first system, the time signature. Layout reserves it
/// and the painter draws into it, so both use this one function.
double systemPrefixWidth(
  NotationConfig config,
  Measure first, {
  required bool firstSystem,
}) {
  final s = config.staffSpaceSize;
  var width = config.barlineToClefSpace + 35 + s; // clef
  final key = KeySignatureRenderer(
    staffSpaceSize: s,
  ).getWidth(first.keySignature);
  if (firstSystem) {
    width += key;
    if (config.showTimeSignature) {
      width +=
          TimeSignatureRenderer(
            staffSpaceSize: s,
          ).getWidth(first.timeSignature) +
          s;
    }
    width += config.leadingSpace;
  } else if (config.showKeySignatureOnEachSystem &&
      first.keySignature.accidentals != 0) {
    width += key + config.clefNoteMargin;
  }
  return width;
}
