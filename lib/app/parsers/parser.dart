import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/code_type.dart';
import 'package:dart_model_converter/app/parsers/floor_parser.dart';
import 'package:dart_model_converter/app/parsers/freezed_parser.dart';
import 'package:dart_model_converter/app/parsers/hive_parser.dart';
import 'package:dart_model_converter/app/parsers/json_serializable_parser.dart';
import 'package:dart_model_converter/app/parsers/normal_parser.dart';
import 'package:dart_model_converter/app/parsers/object_box_parser.dart';

part '_parser.dart';

class ParseData {
  ParseData({
    required this.name,
    required this.optionalParameters,
    required this.requiredParameters,
  });

  final String name;
  final List<Parameter> optionalParameters;
  final List<Parameter> requiredParameters;
}

abstract class Parser {
  factory Parser(CodeType type) = _Parser;

  List<ParseData> parse(CompilationUnit unit);
}
