class MidiNote {
  final int midiNumber;
  final int velocity;
  final int startTime; // milliseconds
  final int endTime; // milliseconds

  const MidiNote({
    required this.midiNumber,
    required this.velocity,
    required this.startTime,
    required this.endTime,
  });

  int get duration => endTime - startTime;
}

class MidiData {
  final List<MidiNote> notes;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;
  final int keySignatureSharps;
  final bool keySignatureIsMinor;
  final double beatsPerMinute;
  final int ticksPerQuarterNote;

  const MidiData({
    required this.notes,
    this.timeSignatureNumerator = 4,
    this.timeSignatureDenominator = 4,
    this.keySignatureSharps = 0,
    this.keySignatureIsMinor = false,
    this.beatsPerMinute = 120.0,
    required this.ticksPerQuarterNote,
  });
}
