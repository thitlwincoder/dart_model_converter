import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';
import 'package:dart_model_converter/app/parsers/parser_base.dart';

class RealmParser extends ParserBase {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    final result = <ParseData>[];

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        result.add(
          ParseData(
            requiredParameters: [],
            name: '${declaration.name}'.replaceFirst('_', ''),
            optionalParameters: parseParametersByFields(
              declaration,
              defaultValue: (variable) {
                if (variable.equals == null) return null;
                return '${variable.endToken}';
              },
            ),
          ),
        );
      }
    }

    return result;
  }
}
