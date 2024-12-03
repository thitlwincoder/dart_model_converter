import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/generators/freezed_generator.dart';
import 'package:dart_model_converter/app/generators/json_serializable_generator.dart';
import 'package:dart_model_converter/app/main_screen.dart';

class Generator {
  Generator({
    required this.name,
    required this.type,
    required this.optionalParameters,
    required this.requiredParameters,
  });

  final String name;
  final CodeType type;
  final List<Parameter> optionalParameters;
  final List<Parameter> requiredParameters;

  Class gen() {
    if (type == CodeType.freezed) {
      return FreezedGenerator(
        name: name,
        optionalParameters: optionalParameters,
        requiredParameters: requiredParameters,
      ).gen();
    }

    return JsonSerializableGenerator(
      name: name,
      optionalParameters: optionalParameters,
      requiredParameters: requiredParameters,
    ).gen();
  }
}
