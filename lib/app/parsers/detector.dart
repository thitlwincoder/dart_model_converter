import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_model_converter/app/code_type.dart';

class Detector {
  CodeType detect(String content) {
    final result = parseString(content: content);

    for (final declaration in result.unit.declarations) {
      bool metadata(String pattern, {bool lowerCase = false}) {
        return declaration.metadata.any((e) {
          var name = e.name.name;
          if (lowerCase) name = name.toLowerCase();
          return name.contains(pattern);
        });
      }

      if (declaration is ClassDeclaration) {
        if (metadata('freezed', lowerCase: true)) return CodeType.freezed;

        if (metadata('JsonSerializable')) return CodeType.jsonSerializable;

        if (metadata('HiveType')) return CodeType.hive;

        if (metadata('Entity')) return CodeType.objectbox;

        if (metadata('entity')) return CodeType.floor;

        if (metadata('RealmModel')) return CodeType.realm;
      }
    }

    return CodeType.normal;
  }
}
