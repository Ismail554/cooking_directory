/// Represents a parsed culinary instruction step with its core direction
/// and any attached symbolic notes or tags (e.g. '#' tags, '@tags', or chef notes).
class InstructionStepData {
  final String instruction;
  final List<String> notes;

  const InstructionStepData({
    required this.instruction,
    this.notes = const [],
  });

  bool get hasNotes => notes.isNotEmpty;

  /// Formats an instruction, optional note/tag text, and optional tag list into a single persisted string.
  static String format({
    required String instruction,
    String? note,
    List<String>? tags,
  }) {
    final cleanInst = instruction.trim();
    final parts = <String>[if (cleanInst.isNotEmpty) cleanInst];

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final t = tag.trim();
        if (t.isNotEmpty) {
          parts.add(_ensureSymbolicMark(t));
        }
      }
    }

    if (note != null && note.trim().isNotEmpty) {
      final cleanNote = note.trim();
      final subNotes = cleanNote.contains(',') && !cleanNote.contains(':')
          ? cleanNote
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : [cleanNote];
      for (final n in subNotes) {
        final formatted = _ensureSymbolicMark(n);
        if (!parts.contains(formatted)) {
          parts.add(formatted);
        }
      }
    }

    return parts.join(' ').trim();
  }

  /// Parses a raw instruction string into core direction and symbolic notes/tags.
  static InstructionStepData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const InstructionStepData(instruction: '');
    }

    final lines = rawText.split('\n');
    final instructionParts = <String>[];
    final extractedNotes = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (_isSymbolicLine(trimmed)) {
        extractedNotes.addAll(_splitTags(trimmed));
      } else {
        final match = _findInlineSymbolicMatch(trimmed);
        if (match != null) {
          final before = trimmed.substring(0, match.start).trim();
          if (before.isNotEmpty) {
            instructionParts.add(before);
          }
          final tagSection = trimmed.substring(match.start).trim();
          extractedNotes.addAll(_splitTags(tagSection));
        } else {
          instructionParts.add(trimmed);
        }
      }
    }

    final instruction = instructionParts.join(' ').trim();
    return InstructionStepData(
      instruction: instruction.isNotEmpty ? instruction : rawText.trim(),
      notes: extractedNotes,
    );
  }

  static String _ensureSymbolicMark(String text) {
    final clean = text.replaceFirst(RegExp(r':\s*$'), '').trim();
    if (clean.startsWith('#') ||
        clean.startsWith('@') ||
        clean.startsWith('*') ||
        clean.startsWith('Tip:') ||
        clean.startsWith('Note:')) {
      return clean;
    }
    return '# $clean';
  }

  static bool _isSymbolicLine(String line) {
    if (line.startsWith('#') ||
        line.startsWith('@') ||
        line.startsWith('* ') ||
        line.startsWith('Tip:') ||
        line.startsWith('Note:')) {
      if (RegExp(r'^#\d+\b').hasMatch(line)) return false;
      return true;
    }
    return false;
  }

  static Match? _findInlineSymbolicMatch(String text) {
    final reg = RegExp(
      r'\s+(#(?!\d+\b)[^\s]|#\s+[A-Za-z0-9]|@[A-Za-z0-9]|Note:|Tip:)',
    );
    return reg.firstMatch(text);
  }

  static List<String> _splitTags(String tagSection) {
    if (!tagSection.contains(' #') && !tagSection.contains(' @')) {
      return [tagSection.replaceFirst(RegExp(r'[,;:]\s*$'), '').trim()];
    }
    return tagSection
        .split(RegExp(r'[\s,]+(?=[#@])'))
        .map((s) => s.replaceFirst(RegExp(r'[,;:]\s*$'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
