import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/recipes/domain/entities/instruction_step_data.dart';

void main() {
  group('InstructionStepData Tests', () {
    test('format returns plain instruction when note is null or empty', () {
      expect(
        InstructionStepData.format(instruction: 'Boil water'),
        'Boil water',
      );
      expect(
        InstructionStepData.format(instruction: 'Boil water', note: '  '),
        'Boil water',
      );
    });

    test('format automatically prepends "# " when note lacks symbolic mark', () {
      final formatted = InstructionStepData.format(
        instruction: 'Crisp guanciale in pan',
        note: 'Low heat render slowly',
      );
      expect(formatted, 'Crisp guanciale in pan # Low heat render slowly');
    });

    test('format preserves existing "#" or symbolic tags', () {
      final formatted = InstructionStepData.format(
        instruction: 'Crisp guanciale in pan',
        note: '#chef-tip: render without extra oil',
      );
      expect(formatted, 'Crisp guanciale in pan #chef-tip: render without extra oil');
    });

    test('parse extracts plain instruction when no symbolic marks exist', () {
      final parsed = InstructionStepData.parse('Simmer sauce for 15 minutes');
      expect(parsed.instruction, 'Simmer sauce for 15 minutes');
      expect(parsed.hasNotes, isFalse);
      expect(parsed.notes, isEmpty);
    });

    test('parse handles inline "#" notes correctly', () {
      final parsed = InstructionStepData.parse(
        'Crisp guanciale in skillet # Chef Tip: Render slowly on medium-low heat',
      );
      expect(parsed.instruction, 'Crisp guanciale in skillet');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, ['# Chef Tip: Render slowly on medium-low heat']);
    });

    test('parse handles multiple inline hashtag badges', () {
      final parsed = InstructionStepData.parse(
        'Roast vegetables at 200C #crisp #golden-brown #oil-free',
      );
      expect(parsed.instruction, 'Roast vegetables at 200C');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, ['#crisp', '#golden-brown', '#oil-free']);
    });

    test('parse handles multi-line instruction and note formats', () {
      final parsed = InstructionStepData.parse(
        'Boil salted pasta water\n# Note: Use 10g coarse sea salt per liter',
      );
      expect(parsed.instruction, 'Boil salted pasta water');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, ['# Note: Use 10g coarse sea salt per liter']);
    });

    test('parse avoids false positive on step number hashtags like "#1"', () {
      final parsed = InstructionStepData.parse(
        'Repeat Step #1 carefully before proceeding',
      );
      expect(parsed.instruction, 'Repeat Step #1 carefully before proceeding');
      expect(parsed.hasNotes, isFalse);
    });

    test('parse distinguishes step number hashtag from actual note tag', () {
      final parsed = InstructionStepData.parse(
        'Refer to Step #1 # Note: Do not boil again',
      );
      expect(parsed.instruction, 'Refer to Step #1');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, ['# Note: Do not boil again']);
    });

    test('roundtrip format and parse preserves instruction and note', () {
      final formatted = InstructionStepData.format(
        instruction: 'Sear salmon skin-side down for 4 mins',
        note: '#chef-tip: Press gently with spatula for crispy skin',
      );
      final parsed = InstructionStepData.parse(formatted);
      expect(parsed.instruction, 'Sear salmon skin-side down for 4 mins');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, ['#chef-tip: Press gently with spatula for crispy skin']);
    });

    test('format and parse support multiple quick tags and custom note together', () {
      final formatted = InstructionStepData.format(
        instruction: 'Simmer tomato ragu gently',
        note: 'Stir every 5 minutes: prevent sticking',
        tags: ['# Low Heat', '# Simmer'],
      );
      final parsed = InstructionStepData.parse(formatted);
      expect(parsed.instruction, 'Simmer tomato ragu gently');
      expect(parsed.hasNotes, isTrue);
      expect(
        parsed.notes,
        containsAll(['# Low Heat', '# Simmer', '# Stir every 5 minutes: prevent sticking']),
      );
    });

    test('parse supports @tags and comma-separated tags', () {
      final parsed = InstructionStepData.parse(
        'Whisk egg yolks with Pecorino @off-heat #creamy, #emulsion',
      );
      expect(parsed.instruction, 'Whisk egg yolks with Pecorino');
      expect(parsed.hasNotes, isTrue);
      expect(parsed.notes, containsAll(['@off-heat', '#creamy', '#emulsion']));
    });
  });
}

