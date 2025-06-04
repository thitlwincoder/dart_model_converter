import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_model_converter/app/code_type.dart';

class Detector {
  CodeType detect(String content) {
    final result = parseString(content: content);
    final unit = result.unit;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        if (declaration.metadata.any(
          (e) => e.name.name.toLowerCase().contains('freezed'),
        )) {
          return CodeType.freezed;
        }

        if (declaration.metadata.any(
          (e) => e.name.name.toLowerCase().contains('jsonserializable'),
        )) {
          return CodeType.jsonSerializable;
        }

        if (declaration.metadata.any(
          (e) => e.name.name.toLowerCase().contains('hive'),
        )) {
          return CodeType.hive;
        }

        if (declaration.metadata.any(
          (e) => e.name.name.toLowerCase().contains('entity'),
        )) {
          return CodeType.objectbox;
        }
      }
    }

    return CodeType.normal;
  }
}
