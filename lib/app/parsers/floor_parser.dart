import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';
import 'package:dart_model_converter/app/parsers/parser_base.dart';

class FloorParser extends ParserBase {
  @override
  List<ParseData> parse(CompilationUnit unit) {
    return parseClassesByFields(unit);
  }
}
