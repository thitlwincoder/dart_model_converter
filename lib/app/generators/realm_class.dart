import 'package:code_builder/code_builder.dart';

Class getRealmClass({
  required String name,
  required List<Parameter> optionalParameters,
  required List<Parameter> requiredParameters,
}) {
  final parameters = [...optionalParameters, ...requiredParameters];

  return Class(
    (b) => b
      ..name = '_$name'
      ..annotations.add(CodeExpression(Code('RealmModel()')))
      ..fields.addAll(
        parameters.map(
          (e) => Field((b) {
            b
              ..name = e.name
              ..type = e.type;

            if (e.name == 'id') b.docs.add('@PrimaryKey()');

            if (e.defaultTo != null) {
              b.assignment = e.defaultTo;
            } else {
              b.late = true;
            }
          }),
        ),
      ),
  );
}
