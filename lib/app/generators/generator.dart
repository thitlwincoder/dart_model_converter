import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/main_screen.dart';

part '_generator.dart';

abstract class Generator {
  factory Generator({
    required String name,
    required CodeType type,
    required List<Parameter> optionalParameters,
    required List<Parameter> requiredParameters,
  }) = _Generator;

  String generate();
}
