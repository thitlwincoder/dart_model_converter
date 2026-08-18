import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';
import 'package:dart_model_converter/app/parsers/parser_base.dart';

class RealmParser extends ParserBase {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    return parseClassesByFields(
      unit,
      className: (declaration) => '${declaration.name}'.replaceFirst('_', ''),
      defaultValue: (variable) {
        if (variable.equals == null) return null;
        return '${variable.endToken}';
      },
    );
  }
}
