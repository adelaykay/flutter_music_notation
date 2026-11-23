// lib/src/midi/midi_parser.dart

import 'package:flutter/foundation.dart';
import 'midi_note.dart';

class MidiParser {
  /// Parse MIDI file bytes into MidiData
  static MidiData parse(Uint8List bytes) {
    final notes = <MidiNote>[];
    int timeSignatureNumerator = 4;
    int timeSignatureDenominator = 4;
    int keySignatureSharps = 0;
    bool keySignatureIsMinor = false;
    double beatsPerMinute = 120.0;
    int ticksPerQuarterNote = 480;

    try {
      // Read MIDI header
      if (bytes.length < 14) throw Exception('Invalid MIDI file: too short');

      // Check for "MThd" header
      if (String.fromCharCodes(bytes.sublist(0, 4)) != 'MThd') {
        throw Exception('Invalid MIDI file: no MThd header');
      }

      // Read header chunk
      final headerLength = _readInt32(bytes, 4);
      final format = _readInt16(bytes, 8);
      final numTracks = _readInt16(bytes, 10);
      final division = _readInt16(bytes, 12);

      // Calculate ticks per beat
      ticksPerQuarterNote = division & 0x7FFF;

      // Default tempo: 120 BPM = 500000 microseconds per quarter note
      int microsecondsPerQuarterNote = 500000;

      // Parse all tracks
      int offset = 14; // After header

      for (int track = 0; track < numTracks; track++) {
        if (offset + 8 > bytes.length) break;

        // Check for "MTrk" header
        if (String.fromCharCodes(bytes.sublist(offset, offset + 4)) != 'MTrk') {
          throw Exception('Invalid track header');
        }

        final trackLength = _readInt32(bytes, offset + 4);
        offset += 8;

        final trackEnd = offset + trackLength;
        int currentTick = 0;
        int lastStatus = 0;

        // Track active notes for note off events
        final Map<int, int> activeNotes = {}; // midiNumber -> startTime

        while (offset < trackEnd && offset < bytes.length) {
          // Read variable-length delta time
          final deltaResult = _readVariableLength(bytes, offset);
          final delta = deltaResult.value;
          offset = deltaResult.offset;

          currentTick += delta;

          if (offset >= bytes.length) break;

          // Read status byte
          int status = bytes[offset];

          // Handle running status
          if (status < 0x80) {
            status = lastStatus;
          } else {
            offset++;
            lastStatus = status;
          }

          final statusType = status & 0xF0;

          // Parse event based on status
          if (statusType == 0x90) {
            // Note On
            if (offset + 2 > bytes.length) break;
            final note = bytes[offset];
            final velocity = bytes[offset + 1];
            offset += 2;

            final timeMs = _ticksToMilliseconds(
              currentTick,
              ticksPerQuarterNote,
              microsecondsPerQuarterNote,
            );

            if (velocity > 0) {
              // Note on
              activeNotes[note] = timeMs;
            } else {
              // Velocity 0 is equivalent to Note Off
              final startTime = activeNotes.remove(note);
              if (startTime != null) {
                notes.add(MidiNote(
                  midiNumber: note,
                  velocity: 64,
                  startTime: startTime,
                  endTime: timeMs,
                ));
              }
            }
          } else if (statusType == 0x80) {
            // Note Off
            if (offset + 2 > bytes.length) break;
            final note = bytes[offset];
            final velocity = bytes[offset + 1];
            offset += 2;

            final timeMs = _ticksToMilliseconds(
              currentTick,
              ticksPerQuarterNote,
              microsecondsPerQuarterNote,
            );

            final startTime = activeNotes.remove(note);
            if (startTime != null) {
              notes.add(MidiNote(
                midiNumber: note,
                velocity: velocity,
                startTime: startTime,
                endTime: timeMs,
              ));
            }
          } else if (statusType == 0xB0 || statusType == 0xE0) {
            // Control Change or Pitch Bend - skip 2 bytes
            offset += 2;
          } else if (statusType == 0xC0 || statusType == 0xD0) {
            // Program Change or Channel Pressure - skip 1 byte
            offset += 1;
          } else if (status == 0xFF) {
            // Meta event
            if (offset + 2 > bytes.length) break;
            final metaType = bytes[offset];
            offset++;

            final lengthResult = _readVariableLength(bytes, offset);
            final length = lengthResult.value;
            offset = lengthResult.offset;

            // Parse different meta event types
            if (metaType == 0x51 && length == 3) {
              // Tempo change (0x51)
              if (offset + 3 <= bytes.length) {
                microsecondsPerQuarterNote = (bytes[offset] << 16) |
                (bytes[offset + 1] << 8) |
                bytes[offset + 2];

                // Convert to BPM
                beatsPerMinute = 60000000.0 / microsecondsPerQuarterNote;
              }
            } else if (metaType == 0x58 && length == 4) {
              // Time signature (0x58)
              if (offset + 4 <= bytes.length) {
                timeSignatureNumerator = bytes[offset];
                timeSignatureDenominator = 1 << bytes[offset + 1]; // 2^dd
              }
            } else if (metaType == 0x59 && length == 2) {
              // Key signature (0x59)
              if (offset + 2 <= bytes.length) {
                // sf is a signed byte
                int sf = bytes[offset];
                if (sf > 127) sf -= 256; // Convert to signed

                keySignatureSharps = sf;
                keySignatureIsMinor = bytes[offset + 1] == 1;
              }
            }

            offset += length;
          } else if (status == 0xF0 || status == 0xF7) {
            // SysEx event - skip
            final lengthResult = _readVariableLength(bytes, offset);
            offset = lengthResult.offset + lengthResult.value;
          }
        }

        offset = trackEnd;
      }

      // Sort notes by start time
      notes.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      if (kDebugMode) {
        print('MIDI parsing error: $e');
      }
      // Return empty data on error
    }

    // If no key signature was found, try to infer it
    if (keySignatureSharps == 0 && !keySignatureIsMinor && notes.isNotEmpty) {
      final inferredKey = _inferKeySignature(notes);
      keySignatureSharps = inferredKey.sharps;
      keySignatureIsMinor = inferredKey.isMinor;
    }

    return MidiData(
      notes: notes,
      timeSignatureNumerator: timeSignatureNumerator,
      timeSignatureDenominator: timeSignatureDenominator,
      keySignatureSharps: keySignatureSharps,
      keySignatureIsMinor: keySignatureIsMinor,
      beatsPerMinute: beatsPerMinute,
      ticksPerQuarterNote: ticksPerQuarterNote,
    );
  }

  // Infer key signature from note content
  static ({int sharps, bool isMinor}) _inferKeySignature(List<MidiNote> notes) {
    // Count pitch class occurrences
    final pitchClassCounts = List<int>.filled(12, 0);

    for (final note in notes) {
      final pitchClass = note.midiNumber % 12;
      pitchClassCounts[pitchClass]++;
    }

    // Krumhansl-Schmuckler key profiles
    const majorProfile = [
      6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88
    ];
    const minorProfile = [
      6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17
    ];

    double maxCorrelation = -1.0;
    int bestKey = 0;
    bool bestIsMinor = false;

    // Try each possible key
    for (int key = 0; key < 12; key++) {
      // Test major
      double majorCorr = _calculateCorrelation(
          pitchClassCounts, _rotateProfile(majorProfile, key));

      // Test minor
      double minorCorr = _calculateCorrelation(
          pitchClassCounts, _rotateProfile(minorProfile, key));

      if (majorCorr > maxCorrelation) {
        maxCorrelation = majorCorr;
        bestKey = key;
        bestIsMinor = false;
      }

      if (minorCorr > maxCorrelation) {
        maxCorrelation = minorCorr;
        bestKey = key;
        bestIsMinor = true;
      }
    }

    final sharpsCount = _pitchClassToSharps(bestKey, bestIsMinor);
    return (sharps: sharpsCount, isMinor: bestIsMinor);
  }

  static double _calculateCorrelation(List<int> counts, List<double> profile) {
    final countMean = counts.reduce((a, b) => a + b) / counts.length;
    final profileMean = profile.reduce((a, b) => a + b) / profile.length;

    double numerator = 0.0;
    double denomCount = 0.0;
    double denomProfile = 0.0;

    for (int i = 0; i < counts.length; i++) {
      final countDiff = counts[i] - countMean;
      final profileDiff = profile[i] - profileMean;

      numerator += countDiff * profileDiff;
      denomCount += countDiff * countDiff;
      denomProfile += profileDiff * profileDiff;
    }

    if (denomCount == 0 || denomProfile == 0) return 0.0;
    return numerator / (denomCount * denomProfile).abs();
  }

  static List<double> _rotateProfile(List<double> profile, int amount) {
    final rotated = List<double>.filled(profile.length, 0);
    for (int i = 0; i < profile.length; i++) {
      rotated[i] = profile[(i - amount) % profile.length];
    }
    return rotated;
  }

  static int _pitchClassToSharps(int pitchClass, bool isMinor) {
    if (isMinor) {
      const minorSharps = {
        9: 0, 4: 1, 11: 2, 6: 3, 1: 4, 8: 5, 3: 6,
        10: -2, 5: -4, 0: -3, 7: -2, 2: -1,
      };
      return minorSharps[pitchClass] ?? 0;
    } else {
      const majorSharps = {
        0: 0, 7: 1, 2: 2, 9: 3, 4: 4, 11: 5, 6: 6,
        1: -5, 8: -4, 3: -3, 10: -2, 5: -1,
      };
      return majorSharps[pitchClass] ?? 0;
    }
  }

  static int _readInt16(Uint8List bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  static int _readInt32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];
  }

  static ({int value, int offset}) _readVariableLength(
      Uint8List bytes,
      int offset,
      ) {
    int value = 0;
    int byte;

    do {
      if (offset >= bytes.length) break;
      byte = bytes[offset++];
      value = (value << 7) | (byte & 0x7F);
    } while (byte & 0x80 != 0);

    return (value: value, offset: offset);
  }

  static int _ticksToMilliseconds(
      int ticks,
      int ticksPerBeat,
      int microsecondsPerQuarterNote,
      ) {
    final millisecondsPerTick = microsecondsPerQuarterNote / ticksPerBeat / 1000;
    return (ticks * millisecondsPerTick).round();
  }
}