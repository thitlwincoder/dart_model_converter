import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';
import 'package:dart_model_converter/app/parsers/parser_base.dart';

class JsonSerializableParser extends ParserBase {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    final result = <ParseData>[];

    for (final declaration in unit.declarations) {
      final optionalParameters = <Parameter>[];
      final requiredParameters = <Parameter>[];

      var parameters = <ParseFieldData>[];

      if (declaration is ClassDeclaration) {
        parameters = parseFields(declaration);

        for (final member in declaration.members) {
          if (member is ConstructorDeclaration) {
            final name = '${member.name}';
            if (name != 'null') continue;

            for (final param in member.parameters.parameters) {
              final name = '${param.name}';

              final parameter = parseParameter(
                name: name,
                param: param,
                type: getTypeByName(name, parameters),
                defaultValue: getDefaultValue(param),
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
