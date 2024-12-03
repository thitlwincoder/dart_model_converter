import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

class JsonSerializableGenerator {
  JsonSerializableGenerator({
    required this.name,
    required this.optionalParameters,
    required this.requiredParameters,
  });

  final String name;
  final List<Parameter> optionalParameters;
  final List<Parameter> requiredParameters;

  Class gen() => Class(
        (b) => b
          ..name = name
          ..docs.add(
            "part '${name.toSnakeCase()}.g.dart';",
          )
          ..annotations.add(CodeExpression(Code('JsonSerializable()')))
          ..fields.addAll([
            ...optionalParameters.map((e) {
              return Field(
                (b) => b
                  ..name = e.name
                  ..type = e.type
                  ..modifier = FieldModifier.final$,
              );
            }),
            ...requiredParameters.map(
              (e) => Field(
                (b) => b
                  ..name = e.name
                  ..type = e.type
                  ..modifier = FieldModifier.final$,
              ),
            ),
          ])
          ..constructors.addAll([
            Constructor(
              (b) => b
                ..optionalParameters.addAll(
                  optionalParameters.map(
                    (e) => e.rebuild(
                      (b) => b
                        ..toThis = true
                        ..type = null,
                    ),
                  ),
                )
                ..requiredParameters.addAll(
                  requiredParameters.map(
                    (e) => e.rebuild(
                      (b) => b
                        ..toThis = true
                        ..type = null,
                    ),
                  ),
                ),
            ),
            Constructor(
              (b) => b
                ..name = 'fromJson'
                ..factory = true
                ..lambda = true
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = 'json'
                      ..type = Reference('Map<String, dynamic>'),
                  ),
                )
                ..body = Code('_\$${name}FromJson(json)'),
            ),
          ])
          ..methods.add(
            Method(
              (b) => b
                ..name = 'toJson'
                ..lambda = true
                ..returns = Reference('Map<String,dynamic>')
                ..body = Code('_\$${name}ToJson(this)'),
            ),
          ),
      );
}
