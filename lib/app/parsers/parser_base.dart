import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';

class ParseFieldData {
  ParseFieldData({required this.name, required this.type, this.defaultValue});

  final String name;
  final String type;
  final String? defaultValue;
}

abstract class ParserBase {
  List<ParseData> parse(CompilationUnit unit);

  String? getDefaultValue(FormalParameter param) {
    if (param is DefaultFormalParameter) {
      return param.defaultValue?.toSource();
    }

    return null;
  }

  String? getTypeByName(String name, List<ParseFieldData> parameters) {
    return parameters.firstWhereOrNull((e) => e.name == name)?.type;
  }

  List<ParseFieldData> parseFields(ClassDeclaration declaration) {
    final parameters = <ParseFieldData>[];
    final fields = declaration.members.whereType<FieldDeclaration>();

    for (final member in fields) {
      for (final variable in member.fields.variables) {
        final name = variable.name;
        final type = member.fields.type;

        parameters.add(ParseFieldData(name: '$name', type: '$type'));
      }
    }

    return parameters;
  }

  List<Parameter> parseParametersByFields(
    ClassDeclaration declaration, {
    String? Function(VariableDeclaration variable)? defaultValue,
  }) {
    final parameters = <Parameter>[];
    final fields = declaration.members.whereType<FieldDeclaration>();

    for (final member in fields) {
      for (final variable in member.fields.variables) {
        final name = variable.name;
        final type = member.fields.type;

        parameters.add(
          parseParameter(
            name: '$name',
            type: '$type',
            defaultValue: defaultValue?.call(variable),
          ),
        );
      }
    }

    return parameters;
  }

  Parameter parseParameter({
    required String name,
    required String? type,
    FormalParameter? param,
    String? defaultValue,
  }) => Parameter((b) {
    b
      ..name = name
      ..type = Reference(type)
      ..named = param?.isNamed ?? true;

    if (defaultValue == null) {
      b.required = param?.isRequiredNamed ?? true;
    } else {
      b.defaultTo = Code(defaultValue);
    }
  });
}
