import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';

class HiveParser extends Parser {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    final result = <ParseData>[];

    for (final declaration in unit.declarations) {
      final optionalParameters = <Parameter>[];
      final requiredParameters = <Parameter>[];

      var parameters = <String, String>{};

      if (declaration is ClassDeclaration) {
        parameters = parseFields(declaration);

        for (final member in parameters.entries) {
          final parameter = parseParameter(
            name: member.key,
            parameters: parameters,
          );

          optionalParameters.add(parameter);
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
