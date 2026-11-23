// lib/src/midi/satb_detector.dart

import 'quantizer.dart';

class Voice {
  final String name;
  final List<QuantizedNote> notes;
  final int minMidi;
  final int maxMidi;

  const Voice({
    required this.name,
    required this.notes,
    required this.minMidi,
    required this.maxMidi,
  });
}

class SATBDetector {
  // Typical SATB ranges (MIDI numbers)
  static const sopranoRange = (min: 60, max: 81); // C4-A5
  static const altoRange = (min: 55, max: 77);    // G3-F5
  static const tenorRange = (min: 48, max: 69);   // C3-A4
  static const bassRange = (min: 40, max: 64);    // E2-E4

  /// Attempt to detect 4 distinct SATB voices
  /// Returns null if detection fails
  ({Voice soprano, Voice alto, Voice tenor, Voice bass})? detectVoices(
      List<QuantizedNote> notes,
      ) {
    if (notes.isEmpty) return null;

    // Group notes by pitch range
    final sopranoNotes = <QuantizedNote>[];
    final altoNotes = <QuantizedNote>[];
    final tenorNotes = <QuantizedNote>[];
    final bassNotes = <QuantizedNote>[];

    for (final note in notes) {
      final midi = note.midiNote;

      // Assign to voice based on typical ranges
      if (midi >= sopranoRange.min && midi <= sopranoRange.max) {
        sopranoNotes.add(note);
      } else if (midi >= altoRange.min && midi <= altoRange.max) {
        altoNotes.add(note);
      } else if (midi >= tenorRange.min && midi <= tenorRange.max) {
        tenorNotes.add(note);
      } else if (midi >= bassRange.min && midi <= bassRange.max) {
        bassNotes.add(note);
      }
    }

    // Validation: Each voice should have roughly similar note counts
    final counts = [
      sopranoNotes.length,
      altoNotes.length,
      tenorNotes.length,
      bassNotes.length,
    ];

    // If any voice is empty or counts are too unbalanced, detection failed
    if (counts.any((c) => c == 0)) return null;

    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final minCount = counts.reduce((a, b) => a < b ? a : b);

    // If ratio is too extreme, likely not SATB
    if (maxCount / minCount > 3) return null;

    return (
    soprano: Voice(name: 'Soprano', notes: sopranoNotes,
        minMidi: sopranoRange.min, maxMidi: sopranoRange.max),
    alto: Voice(name: 'Alto', notes: altoNotes,
        minMidi: altoRange.min, maxMidi: altoRange.max),
    tenor: Voice(name: 'Tenor', notes: tenorNotes,
        minMidi: tenorRange.min, maxMidi: tenorRange.max),
    bass: Voice(name: 'Bass', notes: bassNotes,
        minMidi: bassRange.min, maxMidi: bassRange.max),
    );
  }

  /// Simple pitch-based split (fallback)
  ({List<QuantizedNote> treble, List<QuantizedNote> bass}) splitByPitch(
      List<QuantizedNote> notes, {
        int splitPoint = 60, // Middle C
      }) {
    final treble = notes.where((n) => n.midiNote >= splitPoint).toList();
    final bass = notes.where((n) => n.midiNote < splitPoint).toList();

    return (treble: treble, bass: bass);
  }
}