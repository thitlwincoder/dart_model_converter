import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/code_type.dart';
import 'package:dart_model_converter/app/generators/floor_class.dart';
import 'package:dart_model_converter/app/generators/freezed_class.dart';
import 'package:dart_model_converter/app/generators/hive_class.dart';
import 'package:dart_model_converter/app/generators/json_serializable_class.dart';
import 'package:dart_model_converter/app/generators/normal_class.dart';
import 'package:dart_model_converter/app/generators/object_box_class.dart';
import 'package:dart_model_converter/app/generators/realm_class.dart';

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
