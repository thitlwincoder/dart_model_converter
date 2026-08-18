import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_model_converter/app/code_type.dart';
import 'package:dart_model_converter/app/generators/generator.dart';
import 'package:dart_model_converter/app/parsers/detector.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';
import 'package:dart_style/dart_style.dart';
import 'package:test/test.dart';

void main() {
  group('model conversion', () {
    test('preserves positional, named, required, and default parameters', () {
      final output = convert(
        input: '''
class User {
  User(this.id, {required this.name, this.age = 18});

  final int id;
  final String name;
  final int age;
}
''',
        outputType: CodeType.normal,
      );

      expect(output, contains('final int id;'));
      expect(output, contains('final String name;'));
      expect(output, contains('final int age;'));
      expect(
        output,
        contains('User(this.id, {required this.name, this.age = 18});'),
      );
      expect(output, contains('"age": age,'));
    });

    test('converts json_serializable constructors to freezed factories', () {
      final output = convert(
        input: '''
@JsonSerializable()
class Book {
  Book({required this.id, this.title = 'Untitled'});

  final int id;
  final String title;
}
''',
        outputType: CodeType.freezed,
      );

      expect(output, contains("part 'book.freezed.dart';"));
      expect(output, contains("part 'book.g.dart';"));
      expect(output, contains('@freezed'));
      expect(output, contains(r'class Book with _$Book'));
      expect(
        output,
        contains(
          'const factory Book({required int id, '
          "String title = 'Untitled'}) = _Book;",
        ),
      );
      expect(
        output,
        contains('factory Book.fromJson(Map<String, dynamic> json) =>'),
      );
    });

    test('converts Hive fields to Floor fields with primary key metadata', () {
      final output = convert(
        input: '''
@HiveType(typeId: 1)
class Note {
  @HiveField(0)
  int id;

  @HiveField(1)
  String text;
}
''',
        outputType: CodeType.floor,
      );

      expect(output, contains('@entity'));
      expect(output, contains('class Note'));
      expect(output, contains('@primaryKey\n  final int id;'));
      expect(output, contains('final String text;'));
      expect(output, contains('Note({required this.id, required this.text});'));
    });

    test('converts ObjectBox fields to Realm fields and class names', () {
      final output = convert(
        input: '''
@Entity()
class Task {
  int id = 0;
  String title = 'New';
}
''',
        outputType: CodeType.realm,
      );

      expect(output, contains('@RealmModel()'));
      expect(output, contains('class _Task'));
      expect(output, contains('@PrimaryKey()\n  int id;'));
      expect(output, contains('String title;'));
    });

    test('converts Realm private model names to ObjectBox entity names', () {
      final output = convert(
        input: '''
@RealmModel()
class _Person {
  @PrimaryKey()
  late int id;
  String name = 'Ada';
}
''',
        outputType: CodeType.objectbox,
      );

      expect(output, contains('@Entity()'));
      expect(output, contains('class Person'));
      expect(output, contains('@Id()\n  int id;'));
      expect(output, contains('String name;'));
      expect(output, contains('Person({required this.id, this.name = '));
    });
  });
}

String convert({required String input, required CodeType outputType}) {
  final inputType = Detector().detect(input);
  final unit = parseString(content: input).unit;
  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  return Parser(inputType)
      .parse(unit)
      .map((data) {
        return formatter.format(
          Generator(
            name: data.name,
            type: outputType,
            optionalParameters: data.optionalParameters,
            requiredParameters: data.requiredParameters,
          ).generate(),
        );
      })
      .join('\n');
}
