import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

class FreezedGenerator {
  FreezedGenerator({
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
          ..docs.addAll([
            "part '${name.toSnakeCase()}.freezed.dart';",
            "part '${name.toSnakeCase()}.g.dart';",
          ])
          ..mixins.add(Reference('_\$$name'))
          ..annotations.add(CodeExpression(Code('freezed')))
          ..constructors.addAll([
            Constructor(
              (b) => b
                ..factory = true
                ..constant = true
                ..optionalParameters.addAll(optionalParameters)
                ..requiredParameters.addAll(requiredParameters)
                ..redirect = Reference('_$name'),
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
          ]),
      );
}
