part of 'generator.dart';

class _Generator implements Generator {
  _Generator({
    required this.name,
    required this.type,
    required this.optionalParameters,
    required this.requiredParameters,
  });

  final String name;
  final CodeType type;
  final List<Parameter> optionalParameters;
  final List<Parameter> requiredParameters;

  @override
  String generate() {
    final out = switch (type) {
      CodeType.normal => _getNormalClass(),
      CodeType.freezed => _getFreezedClass(),
      CodeType.jsonSerializable => _getJsonSerializableGenerate(),
      CodeType.hive => _getHiveClass(),
      CodeType.objectbox => _getObjectBoxClass(),
    };

    return '${out.accept(DartEmitter())}';
  }

  Class _getNormalClass() => getNormalClass(
    name: name,
    optionalParameters: optionalParameters,
    requiredParameters: requiredParameters,
  );

  Class _getFreezedClass() => getFreezedClass(
    name: name,
    optionalParameters: optionalParameters,
    requiredParameters: requiredParameters,
  );

  Class _getJsonSerializableGenerate() => getJsonSerializableGenerate(
    name: name,
    optionalParameters: optionalParameters,
    requiredParameters: requiredParameters,
  );

  Class _getHiveClass() => getHiveClass(
    name: name,
    optionalParameters: optionalParameters,
    requiredParameters: requiredParameters,
  );

  Class _getObjectBoxClass() => getObjectBoxClass(
    name: name,
    optionalParameters: optionalParameters,
    requiredParameters: requiredParameters,
  );
}
