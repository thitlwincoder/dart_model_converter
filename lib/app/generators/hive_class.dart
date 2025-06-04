import 'package:code_builder/code_builder.dart';

Class getHiveClass({
  required String name,
  required List<Parameter> optionalParameters,
  required List<Parameter> requiredParameters,
}) {
  final params = [...optionalParameters, ...requiredParameters];

  return Class(
    (b) => b
      ..name = name
      ..extend = Reference('HiveObject')
      ..annotations.add(CodeExpression(Code('HiveType(typeId: 1)')))
      ..fields.addAll([
        for (var i = 0; i < params.length; i++)
          Field(
            (b) => b
              ..docs.add('@HiveField($i)')
              ..name = params[i].name
              ..type = params[i].type,
          ),
      ]),
  );
}
