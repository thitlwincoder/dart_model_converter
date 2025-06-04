import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';

class FreezedParser extends Parser {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    final result = <ParseData>[];

    for (final declaration in unit.declarations) {
      final optionalParameters = <Parameter>[];
      final requiredParameters = <Parameter>[];

      final parameters = <String, String>{};

      if (declaration is ClassDeclaration) {
        for (final member in declaration.members) {
          if (member is ConstructorDeclaration) {
            final name = '${member.name}';
            if (name != 'null') continue;

            for (final param in member.parameters.parameters) {
              final name = '${param.name}';

              String? defaultValue;

              if (param is DefaultFormalParameter) {
                defaultValue = getDefaultValue(param);

                final childEntities = param.parameter.childEntities;
                parameters[name] =
                    '${childEntities.elementAt(param.isRequired ? 1 : 0)}';
              }

              final parameter = parseParameter(
                name: name,
                param: param,
                parameters: parameters,
                defaultValue: defaultValue,
              );

              if (param.isNamed) {
                optionalParameters.add(parameter);
              } else {
                requiredParameters.add(parameter);
              }
            }
          }
        }

        result.add(
          ParseData(
            name: '${declaration.name}',
            optionalParameters: optionalParameters,
            requiredParameters: requiredParameters,
          ),
        );
      }
    }

    return result;
  }
}
