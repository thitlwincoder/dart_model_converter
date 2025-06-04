import 'package:code_builder/code_builder.dart';

Class getObjectBoxClass({
  required String name,
  required List<Parameter> optionalParameters,
  required List<Parameter> requiredParameters,
}) {
  final parameters = [...optionalParameters, ...requiredParameters];

  return Class(
    (b) => b
      ..name = name
      ..annotations.add(CodeExpression(Code('Entity()')))
      ..fields.addAll(
        parameters.map((e) {
          return Field((b) {
            b
              ..name = e.name
              ..type = e.type;

            if (e.name == 'id') {
              b.docs.add('@Id()');
            }
          });
        }),
      )
      ..constructors.add(
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
      ),
  );
}
