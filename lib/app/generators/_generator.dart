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
      CodeType.normal => normalGenerate(),
      CodeType.freezed => freezedGenerate(),
      CodeType.jsonSerializable => jsonSerializableGenerate(),
    };

    return '${out.accept(DartEmitter())}';
  }

  Class normalGenerate() => Class(
    (b) => b
      ..name = name
      ..fields.addAll([
        ...optionalParameters.map((e) {
          return Field(
            (b) => b
              ..name = e.name
              ..type = e.type
              ..modifier = FieldModifier.final$,
          );
        }),
        ...requiredParameters.map(
          (e) => Field(
            (b) => b
              ..name = e.name
              ..type = e.type
              ..modifier = FieldModifier.final$,
          ),
        ),
      ])
      ..constructors.addAll([
        Constructor(
          (b) => b
            ..optionalParameters.addAll(
              optionalParameters.map(
                (e) => e.rebuild(
                  (b) => b
                    ..toThis = true
                    ..type = null,
                ),
              ),
            )
            ..requiredParameters.addAll(
              requiredParameters.map(
                (e) => e.rebuild(
                  (b) => b
                    ..toThis = true
                    ..type = null,
                ),
              ),
            ),
        ),
        Constructor(
          (b) => b
            ..name = 'fromJson'
            ..factory = true
            ..lambda = true
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = 'json'
                  ..type = Reference('Map<String, dynamic>'),
              ),
            )
            ..body = Code(
              '{'
              '${optionalParameters.map((e) {
                return '${e.name}: json["${e.name}"] as ${e.type?.symbol},';
              }).join('\n')}'
              '${requiredParameters.map((e) {
                return '${e.name}: json["${e.name}"] as ${e.type?.symbol},';
              }).join('\n')}'
              '}',
            ),
        ),
      ])
      ..methods.add(
        Method(
          (b) => b
            ..name = 'toJson'
            ..lambda = true
            ..returns = Reference('Map<String,dynamic>')
            ..body = Code(
              '{'
              '${optionalParameters.map((e) {
                return '"${e.name}": ${e.name},';
              }).join('\n')}'
              '${requiredParameters.map((e) {
                return '"${e.name}": ${e.name},';
              }).join('\n')}'
              '}',
            ),
        ),
      ),
  );
  Class freezedGenerate() => Class(
    (b) => b
      ..name = name
      ..docs.addAll([
        "part '${name.toSnakeCase()}.freezed.dart';",
        "part '${name.toSnakeCase()}.g.dart';",
      ])
      ..mixins.add(Reference('_\$$name'))
      ..annotations.add(CodeExpression(Code('freezed')))
      ..constructors.addAll([
        Constructor(
          (b) => b
            ..factory = true
            ..constant = true
            ..optionalParameters.addAll(optionalParameters)
            ..requiredParameters.addAll(requiredParameters)
            ..redirect = Reference('_$name'),
        ),
        Constructor(
          (b) => b
            ..name = 'fromJson'
            ..factory = true
            ..lambda = true
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = 'json'
                  ..type = Reference('Map<String, dynamic>'),
              ),
            )
            ..body = Code('_\$${name}FromJson(json)'),
        ),
      ]),
  );

  Class jsonSerializableGenerate() => Class(
    (b) => b
      ..name = name
      ..docs.add("part '${name.toSnakeCase()}.g.dart';")
      ..annotations.add(CodeExpression(Code('JsonSerializable()')))
      ..fields.addAll([
        ...optionalParameters.map((e) {
          return Field(
            (b) => b
              ..name = e.name
              ..type = e.type
              ..modifier = FieldModifier.final$,
          );
        }),
        ...requiredParameters.map(
          (e) => Field(
            (b) => b
              ..name = e.name
              ..type = e.type
              ..modifier = FieldModifier.final$,
          ),
        ),
      ])
      ..constructors.addAll([
        Constructor(
          (b) => b
            ..optionalParameters.addAll(
              optionalParameters.map(
                (e) => e.rebuild(
                  (b) => b
                    ..toThis = true
                    ..type = null,
                ),
              ),
            )
            ..requiredParameters.addAll(
              requiredParameters.map(
                (e) => e.rebuild(
                  (b) => b
                    ..toThis = true
                    ..type = null,
                ),
              ),
            ),
        ),
        Constructor(
          (b) => b
            ..name = 'fromJson'
            ..factory = true
            ..lambda = true
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = 'json'
                  ..type = Reference('Map<String, dynamic>'),
              ),
            )
            ..body = Code('_\$${name}FromJson(json)'),
        ),
      ])
      ..methods.add(
        Method(
          (b) => b
            ..name = 'toJson'
            ..lambda = true
            ..returns = Reference('Map<String,dynamic>')
            ..body = Code('_\$${name}ToJson(this)'),
        ),
      ),
  );
}
