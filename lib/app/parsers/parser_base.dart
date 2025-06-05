import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';

abstract class ParserBase {
  List<ParseData> parse(CompilationUnit unit);

  String? getDefaultValue(FormalParameter param) {
    if (param is DefaultFormalParameter) {
      return param.defaultValue?.toSource();
    }

    return null;
  }

  Map<String, String> parseFields(ClassDeclaration declaration) {
    final parameters = <String, String>{};
    final fields = declaration.members.whereType<FieldDeclaration>();

    for (final member in fields) {
      for (final variable in member.fields.variables) {
        final name = variable.name;
        final type = member.fields.type;

        parameters['$name'] = '$type';
      }
    }

    return parameters;
  }

  Parameter parseParameter({
    required String name,
    required Map<String, String> parameters,
    FormalParameter? param,
    String? defaultValue,
  }) => Parameter(
    (b) => b
      ..name = name
      ..named = param?.isNamed ?? true
      ..type = Reference(parameters[name])
      ..required = param?.isRequiredNamed ?? true
      ..defaultTo = defaultValue == null ? null : Code(defaultValue),
  );
}
